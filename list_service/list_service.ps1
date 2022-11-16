$Out = Get-WmiObject Win32_Service -EA 0 | Select-Object ProcessId,Name,PathName
$Out | ConvertTo-Json -Compress