$Key = 'HKLM\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\{16e0423f-7058-48c9-a204-72' +
    '5362b67639}\Default'
$Out = [PSCustomObject]@{ SensorTag = "$((((reg query $Key 2>$null) -match 'GroupingTags') -split
    'REG_SZ')[-1].Trim())" }
$Out | ConvertTo-Json -Compress