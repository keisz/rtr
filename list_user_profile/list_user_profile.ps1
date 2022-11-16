$Out = @(Get-CimInstance Win32_UserProfile | Where-Object { $_.SID -match '^S-1-5-21' } |
Select-Object Sid,LocalPath,RoamingPath,RoamingConfigured,LastUseTime).foreach{
    @($_.PSObject.Properties).foreach{
        if ($_.Value -is [datetime]) { $_.Value = try { $_.Value.ToFileTimeUtc() } catch { $_.Value }}
    }
    $_
}
$Out | ConvertTo-Json -Compress