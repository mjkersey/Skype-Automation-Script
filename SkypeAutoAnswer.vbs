Option Explicit

Dim ws, wEnv, pArch, sWow64, sPath, i32Bit, oFSO, oFile, sFolder, oSkype, nStatus
Dim autoAnswer, autoFocus, fullScreen, setSysVolume, callVolume, postCallVolume, autoLock, monitorOff

Set ws = CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")

' Configuration Directives (below this comment block)
' To enable a feature, set it to True. To disable, set it to False.
' NOTE: Regarding autoAnswer/fullScreen, autoLock, autoFocus, etc.: This script will NOT unlock a password-protected desktop! Can only wake screen.
' If the account is protected by a password, these options won't work right. Theoretically, it will answer the call, but I wouldn't count on it.
'  
'   - autoAnswer: 		Answers all incoming calls. Mildly creepy. Intended for the elderly or
'                 		disabled, not for nefarious purposes! Please don't use this to be a dick.
'                       Options: True, False
'
'   - autoFocus: 		Automatically brings the Skype window to the front and makes it the active 
'		                window. This happens regardless if fullScreen is enabled.
'		                Options: True, False
'
'   - fullScreen: 		Enters full screen when a call is answered. Implies autoFocus.
' 						Options: True, False
'
'   - setSysVolume: 	Change the system volume when a call is answered. Options: True, False
'
'   - callVolume: 		Set system volume when a call is received. Use if the above option is 
'                  		enabled. Requires NirCmd. TEST VOLUME FIRST! May cause deafness.
'		                Options: Integer(0-100)
'
'   - postCallVolume: 	Set system volume after a call. Use if setSysVolume is enabled.
'                      	Requires NirCmd. TEST VOLUME FIRST! May cause bleeding eardrums.
'						Options: Integer(0-100)
'
'   - autoLock: 		Lock screen after call. Note: you will not be able to unlock it 
'						automatically after a call!
'               		Options: True, False
'
'   - monitorOff: 		Alternative to above, turns monitor off automaticall after a call.
'						Windows 10 may display lock screen anyway.
'               		Options: True, False

autoAnswer =		False
autoFocus = 		False
fullScreen =   		False
setSysVolume = 		False
callVolume =   		26
postCallVolume = 	6
autoLock = 			False 'Probably shouldn't use this anyway. Will not unlock afterwards!
monitorOff = 		False

' See if we're using 32-bit. If not, bin this instance, and start with the 32-bit WScript
' Skype is a 32-bit process, so we need a 32-bit Windows Script Host.
Set wEnv = ws.Environment("Process")
pArch = wEnv("PROCESSOR_ARCHITECTURE")

'Get path of script
sPath = WScript.ScriptFullName
Set oFile = oFSO.GetFile(sPath)
sFolder = oFSO.GetParentFolderName(oFile) 

if Not pArch = "x86" Then
	sWow64 = ws.ExpandEnvironmentStrings("%windir%") & "\SysWOW64\wscript.exe "
	i32Bit =  sWow64 & chr(34) & sPath & chr(34)
	ws.Run(i32Bit)
	WScript.Quit()
End If

'Runs killall.vbs to terminate all others attached (Skype4COM doesn't detach)
ws.Run(sFolder & "\killall.vbs")

' Create a Skype API object
Set oSkype = Wscript.CreateObject("Skype4COM.Skype","Skype_")

' Start the Skype Client and attach
If Not oSkype.Client.IsRunning Then 
	oSkype.Client.Start()
End If

oSkype.Attach

' Keeps the script running.
Do While True 
	WScript.Sleep(60000) 
Loop

Public Sub Skype_AttachmentStatus(ByVal aStatus)
	oSkype.Convert.AttachmentStatusToText(aStatus)
	If aStatus = oSkype.Convert.TextToAttachmentStatus("AVAILABLE") Then 
		oSkype.Attach() 
	End If
End Sub

Public Sub SetVol(vol)
	If setSysVolume = True _
	Then
		ws.Run(sFolder & "\nircmd.exe mutesysvolume 0") 'Unmute system volume
		ws.Run(sFolder & "\nircmd.exe setsysvolume " & (vol / 100) * 65535)
	End If
End Sub

Public Sub Skype_CallStatus(ByRef aCall, ByVal aStatus)
	Dim oCall, sPartnerName
	
	'nStatus is set at the end of this sub. Skype4COM likes to repeat events, so we need to make sure
	'that the status has actually changed before we do anything.
	If nStatus = aCall.Status _
	Then
		Exit Sub
	End If

	'DEBUG: displays call status every time it changes. Since it changes pretty often, this will annoy you quickly. Do not uncomment unless you're a tinkerer.
	'WScript.Echo ">Call " & aCall.Id & " status " & aStatus & " " & oSkype.Convert.CallStatusToText(aStatus)
	
	'SetVol(callVolume)
	SetVol(callVolume)
	
	'Get display names of all participants
	'For Each oCall In oSkype.ActiveCalls
	'	sPartnerName = sPartnerName & " " & oCall.PartnerDisplayName
	'Next
	
	'On active call, one-time events
	If aCall.Status = 5 _
	Then
		'Speak that the call has started, and with whom
		sPartnerName = sPartnerName & " " & aCall.PartnerDisplayName
		ws.Run(sFolder & "\nircmd.exe speak text " & chr(34) & "Active call with " & sPartnerName & chr(34))
		
		If autoFocus = True _
			Or fullScreen = True _
		Then 
			WScript.Sleep 500 'Give us a little time to react
			'Set Skype window focus
			oSkype.Client.Focus
			If fullScreen = True _
			Then
				'Sends Alt+Enter for full screen call
				ws.SendKeys "%{ENTER}" 
			End If
		End If
	End If

	'On active call, loop events
	Do While aCall.Status = 5 'Loop while status is 5 (active), loop and send keys
		'DEBUG: tells you when you're in a call, but you probably already know. Annoying.
    	'WScript.Echo "In Progress"
		If Not aCall.Status = 5 Then 'If cStatus is not 5 (active), exit the loop, allowing sleep
			Exit Do
		End If
		ws.SendKeys "{F15}" '"Presses" F15 every 5 seconds to keep the screen awake. Shouldn't interfere with much.
		Wscript.Sleep 5000
	Loop

	If oSkype.Convert.TextToCallStatus("RINGING") = aStatus _
	And (oSkype.Convert.TextToCallType("INCOMING_P2P") = aCall.Type _
		Or oSkype.Convert.TextToCallType("INCOMING_PSTN") = aCall.Type) _
	Then
		'Speak incoming call
		ws.Run(sFolder & "\nircmd.exe speak text " & chr(34) & "Incoming call from " & aCall.PartnerDisplayName & chr(34))
		If autoAnswer = True _
		Then 
			aCall.Answer()
		End If
	End If
	
	'Post-call events
	If aCall.Status = 7 _
	Then
		'Locks desktop afterwards (see warnings about password protection above)
		If autoLock = True _
		Then
			ws.Run "%windir%\System32\rundll32.exe user32.dll,LockWorkStation"
		End If
		
		'Turns monitor(s) off after a call
		If monitorOff = True _
		Then
			ws.Run(sFolder & "\nircmd.exe monitor async_off")
		End If
		
		'Speak that the call has ended.
		ws.Run sFolder & "\nircmd.exe speak text " & chr(34) & "Call with " & sPartnerName & " has ended." & chr(34),0,True
		
		'Sets post-call volume
		SetVol(postCallVolume)
		
		'Clear sPartnerName
		sPartnerName = ""
	End If
	
	'Set status
	nStatus = aCall.Status
End Sub