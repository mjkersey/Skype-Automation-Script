fistful_of_ideals Skype API WakeScreen function v1.03 (11/30/2016)
Comments? Compliments? Hate mail? Send me a PM! https://reddit.com/u/fistful_of_ideals
---------------------------------------------------------------------------------------------------

Requires 32-bit WScript.exe in SysWow64 and 
C:\Program Files (x86)\Common Files\Skype\Skype4COM.dll (installed with Desktop Skype)

Will automatically select 32-bit interpreter if needed.

Installation
---------------------------------------------------------------------------------------------------

1. Copy the contents of this zip to a folder on your drive, and run install.bat.
2. If you want to use the autoVolume features, download NirCmd and unzip it into the same directory 
as this script.
3. Edit configuration below to your liking *****NOTE***** The script must be started after each change.
4. Run the script (if already running, you may have to kill the last script - look for wscript.exe
in task manager - Skype4COM doesn't always detach)


*****NOTE*****
Will require authorization in the Skype Client! You will receive a warning in the client
on first run. For this to work, you will need to accept the warning allowing wscript.exe access 
to Skype. It looks and sounds dangerous, but is fine with this script. As always, exercise common 
sense, and review all code before deciding whether something is malicious or not. Including this 
script, especially if you found it anywhere but reddit:

https://www.reddit.com/r/techsupport/comments/229aen/reddit_gold_to_the_person_who_posts_the_solution/cgkrvq6/

Contents of Zip Package
---------------------------------------------------------------------------------------------------
- README.txt - This file.
- SkypeAutoAnswer.vbs - The main script. This is the one you want to run on startup.
- killall.vbs - Terminates all running instances of the script that aren't the current instance.
- nircmd.exe - NirCmd executable. Required for autoVolume functions.
- nircmdc.exe - Command line NirCmd. Part of NirCmd package. Distributed with NirCmd.
- NirCmd.chm - NirCmd help file. Distributed with NirCmd.


Features
---------------------------------------------------------------------------------------------------

- Starts Skype Automatically
- Wakes screen when a call is received by "pressing" F15
- Keeps screen awake even during outbound calls
- Automatically answers inbound calls and brings the Skype window to the front
- Enters full screen on answering a call
- Automatically sets system volume to a user-defined level (note: this feature requires NirCmd)


Depends
---------------------------------------------------------------------------------------------------

NirCmd - http://www.nirsoft.net/utils/nircmd.html
NirCmd 2.81 is included in the mega.nz download, but can be downloaded at the URL above if you 
don't want to use included executable (or if you're using the pastebin download). If you download 
NirCmd from the URL above, simply unzip it into the same directory as this script.


*****NOTE*****

You will have to uncheck "Always ask before opening this file" when you run nircmd.exe the 
first time, as it's not signed by a publisher. Open it first and disable the warning before using 
it in the script. The installer will take care of unblocking the files.