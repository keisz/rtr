$Out = foreach ($User in (Get-CimInstance Win32_UserProfile | Where-Object { $_.localpath -notmatch
'Windows' }).localpath) {
    foreach ($ExtPath in @('Google\Chrome','Microsoft\Edge')) {
        $Path = Join-Path $User "AppData\Local\$ExtPath\User Data\Default\Extensions"
        if (Test-Path $Path -PathType Container) {
            foreach ($Folder in (Get-ChildItem $Path | Where-Object { $_.Name -ne 'Temp' })) {
                foreach ($Item in (Get-ChildItem $Folder.FullName)) {
                    $Json = Join-Path $Item.FullName manifest.json
                    if (Test-Path $Json -PathType Leaf) {
                        Get-Content $Json | ConvertFrom-Json | ForEach-Object {
                            [PSCustomObject]@{
                                Username = $User | Split-Path -Leaf
                                Browser = if ($ExtPath -match 'Chrome') { 'Chrome' } else { 'Edge' }
                                Name = if ($_.name -notlike '__MSG*') { $_.name } else {
                                    $Id = ($_.name -replace '__MSG_','').Trim('_')
                                    @('_locales\en_US','_locales\en').foreach{
                                        $Msg = Join-Path (Join-Path $Item.Fullname $_) messages.json
                                        if (Test-Path -Path $Msg -PathType Leaf) {
                                            $App = Get-Content $Msg | ConvertFrom-Json
                                            (@('appName','extName','extensionName','app_name','application_title',
                                            $Id).foreach{
                                                if ($App.$_.message) { $App.$_.message }
                                            }) | Select-Object -First 1
                                        }
                                    }
                                }
                                Id = $Folder.Name
                                Version = $_.version
                                ManifestVersion = $_.manifest_version
                                ContentSecurityPolicy = $_.content_security_policy
                                OfflineEnabled = if ($_.offline_enabled) { $_.offline_enabled } else { $false }
                                Permissions = $_.permissions
                            }
                        }
                    }
                }
            }
        }
    }
}
$Out | ConvertTo-Json -Compress