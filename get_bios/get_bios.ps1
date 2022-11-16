$Out = Get-CimInstance Win32_BIOS -EA 0 | Select-Object Manufacturer,Name,SerialNumber,Version
$Out | ConvertTo-Json -Compress