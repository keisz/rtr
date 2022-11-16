$Out = [PSCustomObject]@{
    OA3xOriginalProductKey = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey }
$Out | ConvertTo-Json -Compress