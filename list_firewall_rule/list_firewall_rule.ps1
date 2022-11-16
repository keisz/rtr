$Out = Get-NetFirewallRule -EA 0 | Select-Object Name,DisplayName,DisplayGroup,Enabled,Profile,Direction,Action,
EdgeTraversalPolicy,LooseSourceMapping,LocalOnlyMapping,Owner,PrimaryStatus,EnforcementStatus,PolicyStoreSource,
PolicyStoreSourceType | ForEach-Object {
    @($_.PSObject.Properties).foreach{
        if ($_.Value -and $_.Value.ToString() -and $_.Value -isnot [array]) { $_.Value = $_.Value.ToString() }
    }
    $_
}
$Out | ConvertTo-Json -Compress