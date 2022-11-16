$Out = Get-LocalGroupMember -Group Administrators -EA 0 | Select-Object ObjectClass,Name,PrincipalSource
$Out | ConvertTo-Json -Compress