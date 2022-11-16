$Out = Get-WinEvent -ListLog * | Where-Object { $_.RecordCount } | Select-Object RecordCount,LogName
$Out | ConvertTo-Json -Compress