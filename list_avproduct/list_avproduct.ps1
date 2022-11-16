$Out = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct -EA 0 | Select-Object DisplayName,
    ProductState
$Out | ConvertTo-Json -Compress