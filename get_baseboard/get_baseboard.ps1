$Out = Get-CimInstance Win32_Baseboard -EA 0 | Select-Object Manufacturer,Product,Model,SerialNumber
$Out | ConvertTo-Json -Compress