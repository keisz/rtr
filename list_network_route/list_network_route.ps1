$Out = Get-NetRoute -EA 0 | Select-Object DestinationPrefix,InterfaceIndex,InterfaceAlias,AddressFamily,NextHop,
    Publish,State,RouteMetric,InterfaceMetric,Protocol,PolicyStore
$Out | ConvertTo-Json -Compress