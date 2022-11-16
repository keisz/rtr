$Process = Get-Process | Select-Object Id,Name
$Out = @(@(Get-NetTcpConnection -EA 0 | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,
OwningProcess) + @(Get-NetUDPEndpoint -EA 0 | Select-Object LocalAddress,LocalPort)) | ForEach-Object {
    $Protocol = if ($_.State) { 'TCP' } else { 'UDP' }
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('Protocol',$Protocol)))
    $_ | Select-Object Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess
}
$Out | ForEach-Object {
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('OwningProcessName',($Process |
        Where-Object Id -eq $_.OwningProcess).Name)))
}
$Out | ConvertTo-Json -Compress