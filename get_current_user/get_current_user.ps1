$Out = Get-Process -IncludeUserName -EA 0 | Where-Object { $_.SessionId -ne 0 } |
    Select-Object SessionId,UserName | Sort-Object -Unique
$Out | ConvertTo-Json -Compress