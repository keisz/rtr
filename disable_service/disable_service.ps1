function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.Name } { throw "Missing required parameter 'Name'." }
    }
    $Param
}
$Param = parse $args[0]
$Service = Get-Service | Where-Object { $_.Name -eq $Param.Name }
if (!$Service) { throw "No results for service '$($Param.Name)'." }
if ($Service.StartType) { $Service | Set-Service -StartupType Disabled }
if ($Service.Status -ne 'Stopped') { $Service | Set-Service -Status Stopped }
$Out = Get-Service -Name $Param.Name | Select-Object Name,Status,StartType
$Out | ConvertTo-Json -Compress