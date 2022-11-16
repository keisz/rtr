$Out = Get-CimInstance Win32_Processor -EA 0 | Select-Object ProcessorId,Caption,DeviceID,Manufacturer,
    MaxClockSpeed,SocketDesignation,Name
$Out | ConvertTo-Json -Compress