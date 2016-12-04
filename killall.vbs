'Killall.vbs - fistful_of_ideals (11/30/2016)
'Kills all instances of wscript.exe that are hosting SkypeAutoAnswer.vbs
'Should be called from SkypeAutoAnswer.vbs, but will work independently.

Option Explicit

Dim oWMI, aList, sProc, sCmd, sPath, sParent

Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2") 
Set aList = oWMI.ExecQuery("Select * from Win32_Process WHERE name = 'wscript.exe'")

'Find killall.vbs
For Each sProc in aList
	'Get PID of parent of this script(relevant if called from SkypeAutoAnswer.vbs)
	If (InStr(sProc.CommandLine, "killall.vbs")) _
	Then
		sParent = sProc.ParentProcessId
	End If
Next

'Loop again
For Each sProc in aList	
	'Terminate
    If (InStr(sProc.CommandLine, "SkypeAutoAnswer.vbs")) _
	And sProc.ProcessId <> sParent _
	Then
		sProc.Terminate()
    End if
Next