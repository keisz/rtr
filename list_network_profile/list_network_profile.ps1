$Out = Get-NetConnectionProfile -EA 0 | Select-Object Name,InterfaceAlias,InterfaceIndex,NetworkCategory,
IPv4Connectivity,IPv6Connectivity | ForEach-Object {
    @($_.PSObject.Properties).foreach{ if ($_.Value.ToString()) { $_.Value = $_.Value.ToString() }}
    $_
}
$Out | ConvertTo-Json -Compress