function grk ([string]$Str) {
    $Obj = foreach ($N in (Get-ChildItem 'Registry::\').PSChildName) {
        if ($N -eq 'HKEY_USERS') {
            foreach ($V in (Get-ChildItem "Registry::\$N" -EA 0 | Where-Object { $_.Name -match
            'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName) {
                if (Test-Path "Registry::\$N\$V\$Str") { Get-ChildItem "Registry::\$N\$V\$Str" -EA 0 }
            }
        } elseif (Test-Path "Registry::\$N\$Str") {
            Get-ChildItem "Registry::\$N\$Str" -EA 0
        }
    }
    $Obj | ForEach-Object {
        $I = [PSCustomObject]@{}
        foreach ($P in $_.Property) {
            $I.PSObject.Properties.Add((New-Object PSNoteProperty($P,($_.GetValue($P)))))
        }
        $I
    }
}
$Out = @('Microsoft\Windows\CurrentVersion\Uninstall',
'Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall').foreach{
    grk "Software\$_" | Where-Object { $_.DisplayName -and $_.DisplayVersion -and $_.Publisher } |
        Select-Object DisplayName,DisplayVersion,Publisher,InstallLocation
}
$Out | ConvertTo-Json -Compress