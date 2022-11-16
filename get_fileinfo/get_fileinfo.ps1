function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.File } { throw "Missing required parameter 'File'." }
        { $_.File } {
            $_.File = validate $_.File
            if ((Test-Path $_.File -PathType Leaf) -eq $false) {
                throw "Cannot find path '$($_.File)' because it does not exist or is not a file."
            }
        }
    }
    $Param
}
function validate ([string]$Str) {
    if (![string]::IsNullOrEmpty($Str)) {
        if ($Str -match 'HarddiskVolume\d+\\') {
            $Def = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(
    string lpDeviceName,
    System.Text.StringBuilder lpTargetPath,
    uint ucchMax);
'@
            $StrBld = New-Object System.Text.StringBuilder(65536)
            $K32 = Add-Type -MemberDefinition $Def -Name Kernel32 -Namespace Win32 -PassThru
            foreach ($Vol in (Get-CimInstance Win32_Volume | Where-Object { $_.DriveLetter })) {
                [void]$K32::QueryDosDevice($Vol.DriveLetter,$StrBld,65536)
                $Ntp = [regex]::Escape($StrBld.ToString())
                $Str | Where-Object { $_ -match $Ntp } | ForEach-Object { $_ -replace $Ntp, $Vol.DriveLetter }
            }
        }
        else { $Str }
    }
}
$Param = parse $args[0]
$Out = foreach ($i in (Get-ChildItem $Param.File | Select-Object Length,CreationTime,LastWriteTime,LastAccessTime,
Mode,VersionInfo)) {
    foreach ($T in @('CreationTime','LastWriteTime','LastAccessTime')) {
        if ($i.$T) { $i.$T = $i.$T.ToFileTimeUtc() }
    }
    foreach ($P in ($i.VersionInfo | Select-Object OriginalFilename,FileDescription,ProductName,CompanyName,
    FileName,FileVersion)) {
        @($P.PSObject.Properties).Where({ $_.Value }).foreach{
            $i.PSObject.Properties.Add((New-Object PSNoteProperty($_.Name,$_.Value)))
        }
    }
    $i.PSObject.Properties.Remove('VersionInfo')
    if ($i.FileName) {
        @(Get-Content $i.FileName -Stream Zone.Identifier -EA 0 | Select-String -Pattern '=').Where({ $_ -match
        '(ZoneId|HostUrl)' }).foreach{
            [string[]]$A = $_ -split '='
            $i.PSObject.Properties.Add((New-Object PSNoteProperty($A[0],$A[1])))
        }
        $i.PSObject.Properties.Add((New-Object PSNoteProperty('Sha256',(Get-FileHash $i.FileName).Hash.ToLower())))
    }
    $i
}
$Out | ConvertTo-Json -Compress