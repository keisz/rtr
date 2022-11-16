$Tasks = Join-Path $env:SystemRoot '\system32\Tasks'
$Out = foreach ($Task in (Get-ChildItem $Tasks -File -Recurse -EA 0 | Select-Object Name,FullName)) {
    foreach ($Xml in ([xml] (Get-Content $Task.FullName))) {
        [PSCustomObject]@{
            Name = $Task.Name
            UserId = $Xml.Task.Principals.Principal.UserId
            Author = $Xml.Task.RegistrationInfo.Author
            Enabled = $Xml.Task.Settings.Enabled
            Command = $Xml.Task.Actions.Exec.Command
            Arguments = $Xml.Task.Actions.Exec.Arguments
        }
    }
}
$Out | ConvertTo-Json -Compress