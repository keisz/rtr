$Out = (Invoke-WebRequest 'ip-api.com/json' -UseBasicParsing -EA 0).Content | ConvertFrom-Json
$Out | ConvertTo-Json -Compress