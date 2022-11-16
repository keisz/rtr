$Out = Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,
AllowInboundRules,AllowLocalFirewallRules,AllowLocalIPsecRules,AllowUserApps,AllowUserPorts,
AllowUnicastResponseToMulticast,NotifyOnListen,EnableStealthModeForIPSec,LogFileName,LogMaxSizeKilobytes,
LogAllowed,LogBlocked,LogIgnored,DisabledInterfaceAliases | ForEach-Object {
    @($_.PSObject.Properties).foreach{
        if ($_.Value.ToString() -and $_.Name -ne 'DisabledInterfaceAliases') { $_.Value = $_.Value.ToString() }
    }
    $_
}
$Out | ConvertTo-Json -Compress