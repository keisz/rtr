$Out = Get-CimInstance -Namespace root\wmi -Class WmiMonitorID -EA 0 | Select-Object ManufacturerName,
UserFriendlyName,SerialNumberID | ForEach-Object {
    $_.PSObject.Properties | Where-Object { $_.Value -is [System.Array] } | ForEach-Object {
        $_.Value = ([System.Text.Encoding]::ASCII.GetString($_.Value -notmatch 0))
    }
    $_
}
$Out | ConvertTo-Json -Compress