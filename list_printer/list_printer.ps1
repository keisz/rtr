$Out = Get-Printer -EA 0 | Select-Object Name,Type,ShareName,PortName,DriverName,Location,Shared,Published,
    DeviceType,Priority,PrinterStatus
$Out | ConvertTo-Json -Compress