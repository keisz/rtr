function hash ([object]$Obj, [string]$Str) {
    foreach ($I in $Obj) {
        $E = ($Obj | Where-Object { $_.$Str -eq $I.$Str } | Select-Object -Unique).Sha256
        $H = if ($E) { $E } else { try { (Get-FileHash $I.$Str -EA 0).Hash.ToLower() } catch { $null }}
        $I.PSObject.Properties.Add((New-Object PSNoteProperty('Sha256',$H)))
    }
    $Obj
}
$Out = Get-Process -EA 0 | Select-Object Id,Name,StartTime,WorkingSet,CPU,HandleCount,Path | ForEach-Object {
    @($_.PSObject.Properties).foreach{
        if ($_.Value -is [datetime]) { $_.Value = try { $_.Value.ToFileTimeUtc() } catch { $_.Value }}
    }
    $_
}
$Out = hash $Out Path
$Out | ConvertTo-Json -Compress