;PLAYDAY 2 Updater by 0xB0BAFE77
;v1
;For transparency.

; Always run as admine
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}

; Avoids checking empty variables to see if they are environment variables.
; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv

; Ensures that there is only a single instance of this script running.
#SingleInstance, Force

; Disables tray icon. Not necessary for an updater.
#NoTrayIcon

; Determines how fast a script will run (affects CPU utilization).
; The value -1 means the script will run at it's max speed possible.
SetBatchLines, -1

; Makes a script unconditionally use its own folder as its working directory.
; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

global	imagesLoc		:= A_ScriptDir . "\PLAYDAY2 Files\"
global	playdayTmpLoc	:= A_Temp . "\PLAYDAY2\"
global	playdaySettings	:= A_Temp . "\PLAYDAY2\PLAYDAY2Settings.ini"
global	updater			:= A_Temp . "\PLAYDAY2\Updater.exe"
global	gitHubURL		:= "https://raw.githubusercontent.com/0xB0BAFE77/PLAYDAY/"
global	gitHubURLAHK	:= "https://raw.githubusercontent.com/0xB0BAFE77/PLAYDAY/master/PLAYDAY.ahk"
global	gitHubURLEXE	:= "https://github.com/0xB0BAFE77/PLAYDAY/blob/master/PLAYDAY2.exe"

IniRead, exeLocation, % playdaySettings, SavedVars, exeLocation
IniRead, downloadLoc, % playdaySettings, SavedVars, downloadLoc

; Close PLAYDAY2 if it's running
Process, Close, PLAYDAY2.exe
Sleep, 500

; Backup current exe
FileMove, % exeLocation, % exeLocation ".bak"

; Move new file in
FileCopy, % downloadLoc, % exeLocation

	; On error, restore backup
	if (ErrorLevel > 0){
		MsgBox, There was problem copying the new exe to the current location.`nAborting update and restoring backup.AtEOF
		FileMove, % exeLocation ".bak", % exeLocation
		Sleep, 1000
		Run, % exeLocation
	}

Sleep, 2000

MsgBox,,PLAYDAY Updater, Update successful!`n`nClick OK to run it.

Run % exeLocation

ExitApp
