$Url = 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)'
$Out = foreach ($User in (Get-CimInstance Win32_UserProfile | Where-Object { $_.localpath -notmatch
'Windows' }).localpath) {
    foreach ($Path in @('Google\Chrome','Microsoft\Edge')) {
        $History = Join-Path $User "AppData\Local\$Path\User Data\Default\History"
        if (Test-Path $History) {
            Get-Content $History | Select-String -AllMatches $Url | ForEach-Object { ($_.Matches).Value } |
            Sort-Object -Unique | ForEach-Object {
                if ($_ -match $Search) {
                    [PSCustomObject]@{
                        Username = $User | Split-Path -Leaf
                        Browser = if ($History -match 'Chrome') { 'Chrome' } else { 'Edge' }
                        Domain = $_
                    }
                }
            }
        }
    }
}
$Out | ConvertTo-Json -Compress