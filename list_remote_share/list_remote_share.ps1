$Out = foreach ($Value in (Get-ChildItem "Registry::\HKEY_USERS" -EA 0 | Where-Object { $_.Name -match
'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName) {
    @(Get-ChildItem "Registry::\HKEY_USERS\$Value\Network" -EA 0).foreach{
        [PSCustomObject]@{ Share = $_.PSChildName; RemotePath = $_.GetValue('RemotePath'); Sid = $Value;
            UserName = (Get-CimInstance Win32_UserAccount | Where-Object { $_.SID -eq $Value }).Name }
    }
}
$Out | ConvertTo-Json -Compress