function hash ([object]$Obj,[string]$Str) {
    foreach ($I in $Obj) {
        $E = ($Obj | Where-Object { $_.$Str -eq $I.$Str } | Select-Object -Unique).Sha256
        $H = if ($E) { $E } else { try { (Get-FileHash $I.$Str -EA 0).Hash.ToLower() } catch { $null }}
        $I.PSObject.Properties.Add((New-Object PSNoteProperty('Sha256',$H)))
    }
    $Obj
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
$Out | ConvertTo-Json -Compress