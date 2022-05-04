$Humio = @{ Cloud = ''; Token = '' }
switch ($Humio) {
    { $_.Cloud -and $_.Cloud -notmatch '/$' } { $_.Cloud += '/' }
    { ($_.Cloud -and !$_.Token) -or ($_.Token -and !$_.Cloud) } {
        throw "Both 'Cloud' and 'Token' are required when sending results to Humio."
    }
    { $_.Cloud -and $_.Cloud -notmatch '^https://cloud(.(community|us))?.humio.com/$' } {
        throw "'$($_.Cloud)' is not a valid Humio cloud value."
    }
    { $_.Token -and $_.Token -notmatch '^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$' } {
        throw "'$($_.Token)' is not a valid Humio ingest token."
    }
    { $_.Cloud -and $_.Token -and [Net.ServicePointManager]::SecurityProtocol -notmatch 'Tls12' } {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        } catch {
            throw $_
        }
    }
}
function hash ([object]$Obj,[string]$Str) {
    foreach ($I in $Obj) {
        $E = ($Obj | Where-Object { $_.$Str -eq $I.$Str } | Select-Object -Unique).Sha256
        $H = if ($E) { $E } else { try { (Get-FileHash $I.$Str -EA 0).Hash.ToLower() } catch { $null }}
        $I.PSObject.Properties.Add((New-Object PSNoteProperty('Sha256',$H)))
    }
    $Obj
}
function sendlist ([object]$Obj,[object]$Humio,[string]$Script) {
    if ($Obj -and $Humio.Cloud -and $Humio.Token) {
        $Iwr = @{ Uri = @($Humio.Cloud,'api/v1/ingest/humio-structured/') -join $null; Method = 'post';
            Headers = @{ Authorization = @('Bearer',$Humio.Token) -join ' '; ContentType = 'application/json' }}
        $A = @{ script = $Script; host = [System.Net.Dns]::GetHostName() }
        $R = reg query 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSAgent\Sim' 2>$null
        if ($R) {
            $A['cid'] = (($R -match 'CU ') -split 'REG_BINARY')[-1].Trim().ToLower()
            $A['aid'] = (($R -match 'AG ') -split 'REG_BINARY')[-1].Trim().ToLower()
        }
        $E = @($Obj).foreach{
            $C = $A.Clone()
            @($_.PSObject.Properties).foreach{ $C[$_.Name]=$_.Value }
            ,@{ timestamp = Get-Date -Format o; attributes = $C }
        }
        for ($i = 0; $i -lt ($E | Measure-Object).Count; $i += 200) {
            $B = @{ tags = @{ source = 'crowdstrike-rtr_script' }; events = @(@($E)[$i..($i + 199)]) }
            $Req = try { Invoke-WebRequest @Iwr -Body (ConvertTo-Json @($B) -Compress) -UseBasicParsing } catch {}
            if ($Req.StatusCode -ne 200) {
                $Rtr = Join-Path $env:SystemRoot 'system32\drivers\CrowdStrike\Rtr'
                $Json = $Script -replace '\.ps1',"_$((Get-Date).ToFileTimeUtc()).json"
                if ((Test-Path $Rtr -PathType Container) -eq $false) { [void](New-Item $Rtr -ItemType Directory) }
                ConvertTo-Json @($B) -Compress >> (Join-Path $Rtr $Json)
            }
        }
    }
}
$Pf = Join-Path $env:SystemRoot Prefetch
if ((Test-Path $Pf -PathType Container) -eq $false) { throw "Cannot find path '$Pf' because it does not exist." }
$Out = Get-ChildItem (Join-Path $env:SystemRoot Prefetch) *.pf -Recurse -File | Select-Object FullName,Length,
CreationTime,LastWriteTime,LastAccessTime | ForEach-Object {
    @($_.PSObject.Properties).foreach{
        if ($_.Value -is [datetime]) { $_.Value = try { $_.Value.ToFileTimeUtc() } catch { $_.Value }}
    }
    $_
}
$Out = hash $Out FullName
sendlist $Out $Humio 'list_prefetch.ps1'
$Out | ConvertTo-Json -Compress