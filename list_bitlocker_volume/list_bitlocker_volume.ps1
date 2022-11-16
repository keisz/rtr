$Out = Get-BitLockerVolume -EA 0
$Out | ConvertTo-Json -Compress