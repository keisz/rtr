$Def = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint QueryDosDevice(
    string lpDeviceName,
    System.Text.StringBuilder lpTargetPath,
    uint ucchMax);
'@
$StrBld = New-Object System.Text.StringBuilder(65535)
$K32 = Add-Type -MemberDefinition $Def -Name Kernel32 -Namespace Win32 -PassThru
$Out = @(Get-Volume -EA 0 | Where-Object { $_.DriveLetter } | Select-Object DriveLetter,FileSystemLabel,
FileSystem,SizeRemaining).foreach{
    [void]$K32::QueryDosDevice("$($_.DriveLetter):",$StrBld,65535)
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('NtPath',$StrBld.ToString())))
    $_
}
$Out | ConvertTo-Json -Compress