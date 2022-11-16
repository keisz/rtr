function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.SensorTag } { throw "Missing required parameter 'SensorTag'." }
    }
    $Param
}

$Param = parse $args[0]
$Key = 'HKLM\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\{16e0423f-7058-48c9-a204-72' +
    '5362b67639}\Default'
if ($Param.SensorTag) {
    $Tag = (reg query $Key 2>$null) -match 'GroupingTags'
    $Val = if ($Tag) {
        (($Tag -split 'REG_SZ')[-1].Trim().Split(',') + @($Param.SensorTag) | Select-Object -Unique) -join ','
    } else {
        $Param.SensorTag -join ','
    }
    [void](reg add $Key /v GroupingTags /d $Val /f)
}
$Out = [PSCustomObject]@{ SensorTag = "$((((reg query $Key 2>$null) -match 'GroupingTags') -split
    'REG_SZ')[-1].Trim())" }
$Out | ConvertTo-Json -Compress