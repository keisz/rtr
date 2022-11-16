$Out = Get-SmbShare -EA 0 | Select-Object Name,ScopeName,Description,Path
$Out | ConvertTo-Json -Compress