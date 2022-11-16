$Out = [PSCustomObject]@{ LastBootUpTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToFileTimeUtc() }
$Out | ConvertTo-Json -Compress