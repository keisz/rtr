$Out = Get-NetNeighbor -EA 0 | Select-Object IPAddress,InterfaceIndex,InterfaceAlias,AddressFamily,
    LinkLayerAddress,State,PolicyStore
$Out | ConvertTo-Json -Compress