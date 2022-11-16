function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.Message } { throw "Missing required parameter 'Message'." }
    }
    $Param
}

$Param = parse $args[0]
$Def = @"
using System;
using System.Runtime.InteropServices;

public class WTSMessage {
[DllImport("wtsapi32.dll", SetLastError = true)]
public static extern bool WTSSendMessage(
IntPtr hServer,
[MarshalAs(UnmanagedType.I4)] int SessionId,
String pTitle,
[MarshalAs(UnmanagedType.U4)] int TitleLength,
String pMessage,
[MarshalAs(UnmanagedType.U4)] int MessageLength,
[MarshalAs(UnmanagedType.U4)] int Style,
[MarshalAs(UnmanagedType.U4)] int Timeout,
[MarshalAs(UnmanagedType.U4)] out int pResponse,
bool bWait
);

static int response = 0;

public static int SendMessage(int SessionID, String Title, String Message, int Timeout, int MessageBoxType) {
WTSSendMessage(IntPtr.Zero, SessionID, Title, Title.Length, Message, Message.Length, MessageBoxType, Timeout, out response, true);

return response;
}
}
"@
if (!([System.Management.Automation.PSTypeName]'WTSMessage').Type) { Add-Type -TypeDefinition $Def }
$Out = Get-Process -IncludeUserName | Where-Object { $_.SessionId -ne 0 } | Select-Object SessionId, UserName |
Sort-Object -Unique | ForEach-Object {
    $Result = if ($_.SessionId) {
        [WTSMessage]::SendMessage($_.SessionId,'CrowdStrike Falcon',$Param.Message,15,0x00000040L)
    } else {
        'no_active_session'
    }
    [PSCustomObject]@{ Username = $_.UserName; Message  = if ($Result -eq 1) { $Param.Message } else { $Result }}
}
$Out | ConvertTo-Json -Compress