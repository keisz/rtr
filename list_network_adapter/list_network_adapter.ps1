$Out = Get-NetAdapter -EA 0 | ForEach-Object {
    $Ip = Get-NetIpAddress -InterfaceIndex $_.IfIndex | Select-Object IPAddress,AddressFamily
    $_ | Select-Object Name,MacAddress,LinkSpeed,Virtual,Status,MediaConnectionState,FullDuplex,DriverName,
    DriverVersionString | ForEach-Object {
        $_.PSObject.Properties.Add((New-Object PSNoteProperty('Ipv4Address',($Ip | Where-Object {
            $_.AddressFamily -eq 'IPv4' }).IPAddress)))
        $_.PSObject.Properties.Add((New-Object PSNoteProperty('Ipv6Address',($Ip | Where-Object {
            $_.AddressFamily -eq 'IPv6'}).IPAddress)))
        $_
    }
}
$Out | ConvertTo-Json -Compress