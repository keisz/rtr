function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.Destination } { throw "Missing required parameter 'Destination'." }
        { !$_.Port } { throw "Missing required parameter 'Port'." }
    }
    $Param
}
$Param = parse $args[0]
$Out = Test-NetConnection -ComputerName $Param.Destination -Port $Param.Port | Select-Object ComputerName,
RemoteAddress,RemotePort,SourceAddress,InterfaceAlias,TcpTestSucceeded | ForEach-Object {
    if ($_.RemoteAddress) { $_.RemoteAddress = $_.RemoteAddress.IPAddressToString }
    if ($_.SourceAddress) { $_.SourceAddress = $_.SourceAddress.IPv4Address }
    $_
}
$Out | ConvertTo-Json -Compress