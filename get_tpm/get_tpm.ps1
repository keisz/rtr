$Out = Get-Tpm -EA 0 | Select-Object TpmPresent,TpmReady,TpmEnabled,TpmActivated,TpmOwned,RestartPending,
    ManufacturerId,ManufacturerIdTxt,ManufacturerVersion,ManagedAuthLevel,OwnerAuth,OwnerClearDisabled,
    AutoProvisioning,LockedOut,LockoutHealTime,LockoutCount,LockoutMax,SelfTest
$Out | ConvertTo-Json -Compress