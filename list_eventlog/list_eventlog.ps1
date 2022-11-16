function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.LogName } { throw "Missing required parameter 'LogName'." }
    }
    $Param
}
$Param = parse $args[0]
$Out = try {
    Get-WinEvent $Param.LogName -MaxEvents 1000 | Select-Object TimeCreated,ProviderName,Id,Message |
    ForEach-Object {
        if ($_.TimeCreated) { $_.TimeCreated = $_.TimeCreated.ToFileTimeUtc() }
        $_
    }
} catch {
    throw $_
}
$Out | ConvertTo-Json -Compress