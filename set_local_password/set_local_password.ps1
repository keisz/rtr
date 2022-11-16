function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.Username } { throw "Missing required parameter 'Username'." }
        { !$_.Password } { throw "Missing required parameter 'Password'." }
    }
    $Param
}
$Param = parse $args[0]
$Out = if ($PSVersionTable.PSVersion.ToString() -gt 5) {
    try {
        Set-LocalUser -Name $Param.Username -Password ($Param.Password |
            ConvertTo-SecureString -AsPlainText -Force)
        [PSCustomObject]@{ Username = $Param.Username; PasswordSet = $true }
    } catch {
        throw $_
    }
} else {
    try {
        ([adsi]("WinNT://$($env:ComputerName)/$($Param.Username), user")).SetPassword($Param.Password)
        [PSCustomObject]@{ Username = $Param.Username; PasswordSet = $true }
    } catch {
        throw $_
    }
}
$Session = Get-Process -IncludeUserName -EA 0 | Where-Object { $_.SessionId -ne 0 -and $_.UserName -match
$Param.Username } | Select-Object SessionId,UserName | Sort-Object -Unique
$Active = if ($Session.SessionId) {
    if ($Param.ForceLogoff -eq $true) { logoff $Session.SessionId; $false } else { $true }
} else {
    $false
}
$Out.PSObject.Properties.Add((New-Object PSNoteProperty('ActiveSession',$Active)))
$Out | ConvertTo-Json -Compress