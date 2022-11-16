function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.Name } { throw "Missing required parameter 'Name'." }
    }
    $Param
}
$Param = parse $args[0]
$Out = @(Get-Service $Param.Name -EA 0 | Select-Object Name,DisplayName,Status).foreach{
    if ($_.Status) { $_.Status = $_.Status.ToString() }
    $_
}
if (!$Out) { throw "No service found matching '$($Param.Name)'." }
$Out | ConvertTo-Json -Compress