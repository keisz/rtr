$Out = Get-LocalUser -EA 0 | Select-Object Name,FullName,Enabled,Sid,PasswordRequired,PasswordLastSet,
PasswordExpires,PrincipalSource,Description | ForEach-Object {
    @($_.PSObject.Properties).foreach{
        if ($_.Value -is [datetime]) { $_.Value = try { $_.Value.ToFileTimeUtc() } catch { $_.Value }}
    }
    if ($_.Sid) { $_.Sid = $_.Sid.ToString() }
    $_
}
$Out | ConvertTo-Json -Compress