;PLAYDAY 2 by 0xB0BAFE77
global	currentVersion	:= 161008.2228
global	announcement	:= "Thanks for trying out PLAYDAY!`n`nI've put a ton of time and effort into it, and I hope you enjoy it as much as I do.`n`nThis program will be getting regular updates.`n`nCurrently the talent calculator isn't implemented. I skipped it so I could get this out for the Hoxton Housewarming. It's next on the to-do list followed by BLT mod support.`n`nThanks for trying PLAYDAY 2!"
/*
Created:		2016-09-20
Last Updated:	2016-10-08
First Version:	160920.0200

My Github:	https://github.com/0xB0BAFE77
	As of this update, this should be the only place this is getting downloaded from.
	
Notes and the design process can be seen at the bottom of the script.

Thanks for trying PLAYDAY2!
*/

;============================== Start Auto-Execution Section ==============================
; This label is not actually used and only exists for quick navigation while coding with SciTE4AutoHotkey
_AutoExecution:

; Always run as admine
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}

; Keeps script permanently running
#Persistent

; Avoids checking empty variables to see if they are environment variables.
; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv

; Ensures that there is only a single instance of this script running.
#SingleInstance, Force

; Determines how fast a script will run (affects CPU utilization).
; The value -1 means the script will run at it's max speed possible.
SetBatchLines, -1

;Sets the delay that will occur after each windowing command.
SetWinDelay, -1

; Makes a script unconditionally use its own folder as its working directory.
; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

; sets title matching to search for "containing" instead of "exact"
SetTitleMatchMode, 2

; sets the key send input type.
SendMode, Event

; Ensures that the path of the 64-bit Program Files directory is returned if the OS is 64-bit and the script is not.
SetRegView 64

; Something that saves me a ton of time because I don't have to reload my script every time I save!
GroupAdd, saveReload, %A_ScriptName%

; Gets the current install path of PD2
RegRead, installPath, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 218620, InstallLocation

; This label is not actually used and only exists for quick navigation while coding with SciTE4AutoHotkey
_Variables:

; Declaring variables
global	pd2Running		:= false
global	rightGUIActive	:= false
global	BottomGUIActive	:= false
global	pdBlue			:= 0x07A3FF
global	bgc				:= 0x000044

; Special characters for displaying in gui

; Less than or equal to sign
global	ltEql			:= Chr(0x2264)
; Greater than or equal to sign
global	gtEql			:= Chr(0x2265)
; Infinity symbol sign
global	infSym			:= Chr(0x221E)

; Vars used in gui hwnd storing
global	gh1				:= ""
global	gh2				:= ""
global	gh3				:= ""

; List for dynamically populating resolution dropdown menu
global	guiResList		:= ""
global	refreshRateList	:= "30|45|60|75|90|105|120|135|144|Unlimited|"
global	anisotropyList	:= "Off|2X|4X|8X|16X|"
global	texturesList	:= "Very Low|Low|Medium|High|"
global	shadowsList		:= "Very Low|Low|Medium|High|Very High|"
global	guideList		:= "Select Guide:||"

; Locations
global	playdayLoc		:= A_ScriptDir
global	imagesLoc		:= A_ScriptDir . "\PLAYDAY2 Files\"
global	playdayTmpLoc	:= A_Temp . "\PLAYDAY2\"
global	playdayTmpFile	:= A_Temp . "\PLAYDAY2\PLAYDAY2tmp.txt"
global	playdaySettings	:= A_Temp . "\PLAYDAY2\PLAYDAY2Settings.ini"
global	rendererTemp	:= A_Temp . "\PLAYDAY2\renderer_settings_temp.xml"
global	updater			:= A_Temp . "\PLAYDAY2\PLAYDAYUpdater.exe"
global	rendererFile	:= A_AppData . "\..\Local\PAYDAY 2\renderer_settings.xml"
global	crashFile		:= A_AppData . "\..\Local\PAYDAY 2\crash.txt"
global	fullCrashFile	:= A_AppData . "\..\Local\PAYDAY 2\crashlog.txt"
global	gitHubURL		:= "https://github.com/0xB0BAFE77/PLAYDAY"
global	gitHubURLAHK	:= "https://raw.githubusercontent.com/0xB0BAFE77/PLAYDAY/master/PLAYDAY2.ahk"
global	gitHubURLEXE	:= "https://github.com/0xB0BAFE77/PLAYDAY/raw/master/PLAYDAY2.exe"

; Guide array allows for easy addition of guides in the future.
global	guideArray		:= {"The Long Guide (PD2 Bible)":"https://steamcommunity.com/sharedfiles/filedetails/?id=267214370"
	, "PAYDAY 2 Achievement Guide":"https://steamcommunity.com/sharedfiles/filedetails/?id=394921695"
	, "Gage Package Locations":"https://klenium.github.io/pd2packages/"
	, "DW Damage Breakpoints":"http://i.imgur.com/0K6rICT.png"}

	; Creates guide dropdown list
	For key, value in guideArray
		guideList	:= guideList key "|"

; Create necessary directories for pictures and updater to install.
FileCreateDir, % imagesLoc
FileCreateDir, % playdayTmpLoc

; User Specific Vars
IniRead, lastX, %playdaySettings%, SavedVars, lastX
IniRead, lastY, %playdaySettings%, SavedVars, lastY

	; If no settings file is present, sets gui start position to x0 y0
	if lastX is not Integer
		lastX	:= 0
	if (lastX < 0)
		lastX	:= 0
	
	if lastY is not Integer
		lastY	:= 0
	if (lastY < 0)
		lastY	:= 0

IniRead, exitOnExit, %playdaySettings%, SavedVars, exitOnExit
	if (exitOnExit != 1)
		global	exitOnExit		:= 0

IniRead, autoUpdate, %playdaySettings%, SavedVars, autoUpdate
	if (autoUpdate != 1)
		global	autoUpdate		:= 0

IniRead, autoUpdaterOn, %playdaySettings%, SavedVars, autoUpdaterOn
	if (autoUpdaterOn != 1)
		global	autoUpdaterOn	:= 0
	
IniRead, autoOpenGuide, %playdaySettings%, SavedVars, autoOpenGuide
	if (autoOpenGuide != 1)
		global	autoOpenGuide	:= 0

IniRead, notified, %playdaySettings%, SavedVars, notified
	if (notified != 1)
		global	notified		:= 0

global	resolution		:= ""
global	windowed		:= ""
global	refreshRate		:= ""
global	modsEnabled		:= ""
global	gameRes			:= ""
global	fullWin			:= ""
global	vSync			:= ""
global	graphTextures	:= ""
global	graphShadows	:= ""
global	refreshRate		:= ""


; Install pictures. Needed for compiling.
FileInstall, PLAYDAY2 Files\Big Oil Calculator Engine BG.png, PLAYDAY2 Files\Big Oil Calculator Engine BG.png, 1
FileInstall, PLAYDAY2 Files\Big Oil Engine Calc Logo.png, PLAYDAY2 Files\Big Oil Engine Calc Logo.png, 1
FileInstall, PLAYDAY2 Files\Folder Open.png, PLAYDAY2 Files\Folder Open.png, 1
FileInstall, PLAYDAY2 Files\pd2BottomGUI.png, PLAYDAY2 Files\pd2BottomGUI.png, 1
FileInstall, PLAYDAY2 Files\pd2MainGUI.png, PLAYDAY2 Files\pd2MainGUI.png, 1
FileInstall, PLAYDAY2 Files\pd2RightGUI.png, PLAYDAY2 Files\pd2RightGUI.png, 1
FileInstall, PLAYDAY2 Files\PLAYDAY 2 Logo.png, PLAYDAY2 Files\PLAYDAY 2 Logo.png, 1
FileInstall, PLAYDAY2 Files\PLAYDAY2Icon.ico, PLAYDAY2 Files\PLAYDAY2Icon.ico, 1
FileInstall, PLAYDAYUpdater.exe, % updater, 1

Sleep, 500

; Adds contact info for announcements
announcement	:= announcement "`n`n========`nContact Info:`nEmail:" A_Tab "0xB0BAFE77@gmail.com`nReddit:" A_Tab "/r/PLAYDAY2" A_Tab "/u/0xB0BAFE77`nSteam:" A_Tab "0xB0BAFE77" A_Tab "Profile ID:76561197967463466)"

; If no backup is detected, a backup of the current renderer_settings.xml is made
; disabled for now.
; BackupRenderer()

; Used to add icon to taskbar button and systray (which is hidden)
Menu, Tray, Icon, % imagesLoc "PLAYDAY2Icon.ico"

; Checks to see if user has been notified since update about changes.
notifiedCheck()

; Self explanitory...
GetSet(playdayTmpFile, playdaySettings, rendererFile, crashFile, fullCrashFile)

; Checks if user wants auto-close enabled per ini
gosub, AutoCloseToggle

; Creates GUI
gosub, MainGUI

return

; That thing that saves me a bunch of time
;============================== Save Reload / Quick Stop ==============================
#IfWinActive, ahk_group saveReload

; Use Control+S to save your script and reload it at the same time.
~^s::
	TrayTip, Reloading updated script, %A_ScriptName%
	SetTimer, RemoveTrayTip, 1500
	Sleep, 1750
	Reload
return

; Removes any popped up tray tips.
RemoveTrayTip:
	SetTimer, RemoveTrayTip, Off
	TrayTip 
return 

; Hard exit that just closes the script
^Esc::ExitApp

#IfWinActive



;============================== Main Script ==============================

;==================== GUIS ====================

; ========== Main GUI ==========
MainGUI:

	; GUI Options
	Gui, Main:Color, 000044
	Gui, Main:+Border -Caption +HwndMG
	Gui, Main:Font, s8 c0xDDDDDD, Times New Roman
	
	; Background
	Gui, Main:Add, Picture, x0 y0 w360 h500, % imagesLoc "pd2MainGUI.png"
	
	; Logo/Title
	Gui, Main:Add, Picture, x5 y5 w350 h55 , % imagesLoc "PLAYDAY 2 Logo.png"

	; Launch PAYDAY 2
	Gui, Main:Font, s16 bold
	Gui, Main:Add, Button, x15 y65 w260 h40 gStartPayday , START PAYDAY 2

	; Version Info
	Gui, Main:Font, s10 c0xDDDDDD , Arial Black
	Gui, Main:Add, Text, BackGroundTrans x280 y65 w80 h20 , Version:
	Gui, Main:Font, s8 c0xDDDDDD bold, Arial
	Gui, Main:Add, Text, BackGroundTrans x285 y85 w80 h20 , % currentVersion
	
	; GroupBoxes
	Gui, Main:Font
	Gui, Main:Font, s12 c0xDDDDDD bold, Times New Roman
	
	Gui, Main:Add, GroupBox, x10 y110 w150 h100, Calculators
	Gui, Main:Add, GroupBox, x170 y110 w180 h140, Update Info
	Gui, Main:Add, GroupBox, x10 y260 w180 h120, Guides
	Gui, Main:Add, GroupBox, x200 y260 w150 h180, Troubleshooting
	
	; Calculator
	Gui, Main:Font, s10 c0xDDDDDD norm
	
	Gui, Main:Add, Button, x20 y130 w130 h30 gTalentCalcGUI , Talent Calc
	Gui, Main:Add, Button, x20 y170 w130 h30 gBigOilCalcToggle , Big Oil Engine Calc
;	Gui, Main:Add, Button, x20 y210 w130 h30 , Reserved for future calculator(s)
	
	; Updater
	Gui, Main:Add, Text, BackGroundTrans x180 y135 w160 h20 vguiUpdateTopText, Click "Check For Update" to 
	Gui, Main:Add, Text, BackGroundTrans x180 y155 w160 h20 vguiUpdateBottomText, see if there's a new version.
	Gui, Main:Add, Button, x185 y180 w150 h30 gButtonUpdateCheck vguiCFUButton, Check For Update
	Gui, Main:Add, Text, BackGroundTrans x190 y223 w130 h20 +Right , Enable Auto-Update
	Gui, Main:Add, Checkbox, x325 y220 w15 h20 gAutoUpdateToggle vautoUpdate ,
	
	; Troubleshooting
	Gui, Main:Add, Checkbox, x210 y297 w15 h20 gDisableIPHLPAPI vmodsEnabled ,
	Gui, Main:Add, Text, BackGroundTrans x235 y285 w120 h60 , Disable Mods`n( Renames`nIPHLPAPI.dll )
	Gui, Main:Add, Button, x210 y340 w130 h30 gCrashReport , PD2 EZ Reporter
	Gui, Main:Add, Checkbox, x210 y375 w15 h20 vallCrashLogs ,
	Gui, Main:Add, Text, BackGroundTrans x230 y377 w100 h30 , ALL crash logs?
	Gui, Main:Add, Button, x210 y400 w130 h30 gVideoSettingsToggle, Edit Video Settings
	
	; Guides
	Gui, Main:Add, DropDownList, x20 y280 w160 h30 r10 gAutoOpenGuide vguiGuideList,
	Gui, Main:Add, Button, x100 y315 w80 h30 gOpenGuide, Open Guide
	Gui, Main:Add, Text, BackGroundTrans x45 y353 w140 h30 , Open Guide On Click
	Gui, Main:Add, Checkbox, x165 y350 w15 h20 gAutoOpenGuideCheck vguiAutoOpenGuide ,
	
	; Browse / Close / Minimize
	Gui, Main:Add, Picture, x10 y390 w50 h50 gOpenPaydayInstall , % imagesLoc "folder open.png"
	Gui, Main:Add, Button, x60 y400 w130 h30 gOpenPaydayInstall , Browse PAYDAY 2`nInstall Folder
	Gui, Main:Add, Button, x15 y455 w120 h30 gMinimizeGui, Minimize
	Gui, Main:Add, Text, BackGroundTrans x90 y455 w160 h30 +Right , Close Script When`nPAYDAY 2 Closes
	Gui, Main:Add, Checkbox, x255 y460 w15 h20 gAutoCloseToggle vexitOnExit,
	Gui, Main:Add, Button, x285 y455 w60 h30 gQuit, Exit
	
	; Set user prefernces
	GuiControl, Main:, guiGuideList, % guideList
	GuiControl, Main:, exitOnExit, % exitOnExit
	GuiControl, Main:, autoUpdate, % autoUpdate
	if (autoUpdate = 1)
		gosub, AutoUpdateToggle
	
	; Show GUI
	Gui, Main:Show, x%lastX% y%lastY% w360 h500, PLAYDAY 2
	
	OnMessage(0x200, "WM_MOUSEMOVE")
	GetGUIPos()
	SetLastPos()
	SetTimer, Docking, 50
return
;========== End Main GUI ==========

;========== Big Oil Calculator GUI ==========

BigOilCalcGUI:

	Gui, RightGUI:Destroy
	
	; Get coords of playday GUI to get x/y for Big Oil Calc
	WinGetPos, mainGUIX, mainGUIY, mainGUIW, mainGUIH, PLAYDAY 2

	rightGUIX	:= mainGUIX + mainGUIW
	rightGUIY	:= mainGUIY

	; GUI Options
	Gui, RightGUI:Color, 000044
	Gui, RightGUI:+Border -Caption +OwnerMain +HwndRG
	
	; Background
	Gui, RightGUI:Add, Picture, x0 y0 w360 h500 , % imagesLoc "pd2RightGUI.png"

	; Title
	Gui, RightGUI:Add, Picture, x10 y10 w340 h40 , % imagesLoc "Big Oil Engine Calc Logo.png"

	; Groupbox layout
	Gui, RightGUI:Font, s12 c0xDDDDDD bold, Courier New
	
	Gui, RightGUI:Add, GroupBox, x10 y50 w110 h145 +Left, Gas
	Gui, RightGUI:Add, GroupBox, x130 y50 w110 h145 +Left, Nozzles
	Gui, RightGUI:Add, GroupBox, x250 y50 w100 h115 +Left, Pressure

	; Gas / Element
	Gui, RightGUI:Font, s10 c0xDDDDDD bold, Arial
	Gui, RightGUI:Add, Radio, gBigOilUpdate group Checked vgasGUI x20 y70 w80 h30 , ? ? ? ?
	Gui, RightGUI:Add, Radio, gBigOilUpdate x20 y100 w80 h30 , Nitrogen
	Gui, RightGUI:Add, Radio, gBigOilUpdate x20 y130 w80 h30 , Deterium
	Gui, RightGUI:Add, Radio, gBigOilUpdate x20 y160 w80 h30 , Helium
	
	; Nozzles / H
	Gui, RightGUI:Add, Radio, gBigOilUpdate group Checked vnozzleGUI x140 y70 w80 h30 , ? ? ? ?
	Gui, RightGUI:Add, Radio, gBigOilUpdate x140 y100 w80 h30 , %infSym% H
	Gui, RightGUI:Add, Radio, gBigOilUpdate x140 y130 w80 h30 , 2 x H
	Gui, RightGUI:Add, Radio, gBigOilUpdate x140 y160 w80 h30 , 3 x H
	
	; Pressure / Bar
	Gui, RightGUI:Add, Radio, gBigOilUpdate group Checked vpressureGUI x260 y70 w80 h30 , ? ? ? ?
	Gui, RightGUI:Add, Radio, gBigOilUpdate x260 y100 w80 h30 , %gtEql% 5783
	Gui, RightGUI:Add, Radio, gBigOilUpdate x260 y130 w80 h30 , %ltEql% 5812

	; Help Text
	Gui, RightGUI:Add, Text, x250 y170 w90 h50 , What Am I`nLooking For??

	; Middle Title
	Gui, RightGUI:Font, c0xDDDDDD s16 bold, Arial
	Gui, RightGUI:Add, Text, x20 y200 h30 +Center , Possible Engines

	; Basement Map
	Gui, RightGUI:Add, Picture, x10 y230 w340 h220, % imagesLoc "Big Oil Calculator Engine BG.png"

	; Engines0
	Gui, RightGUI:Font, c0xDDDDDD s18 norm, Impact
	
	; Column 1
	Gui, RightGUI:Add, Text, +Center vengine5 x35 y255 w30 h30 , 5
	Gui, RightGUI:Add, Text, +Center vengine3 x35 y323 w30 h30 , 3
	Gui, RightGUI:Add, Text, +Center vengine1 x35 y393 w30 h30 , 1

	; Column 2
	Gui, RightGUI:Add, Text, +Center vengine6 x101 y255 w30 h30 , 6
	Gui, RightGUI:Add, Text, +Center vengine4 x101 y323 w30 h30 , 4
	Gui, RightGUI:Add, Text, +Center vengine2 x101 y393 w30 h30 , 2
	
	; Column 3
	Gui, RightGUI:Add, Text, +Center vengine11 x231 y255 w30 h30 , 11
	Gui, RightGUI:Add, Text, +Center vengine9 x231 y323 w30 h30 , 9
	Gui, RightGUI:Add, Text, +Center vengine7 x231 y393 w30 h30 , 7
	
	; Column 4
	Gui, RightGUI:Add, Text, +Center vengine8 x297 y255 w30 h30 , 8
	Gui, RightGUI:Add, Text, +Center vengine10 x297 y323 w30 h30 , 10
	Gui, RightGUI:Add, Text, +Center vengine12 x297 y393 w30 h30 , 12
	
	Gui, RightGUI:Font
	Gui, RightGUI:Add, Button, gCloseRightGUI x250 y460 w100 h30 , Close

	Gui, RightGUI:Show, w360 h500 x%rightGUIX% y%rightGUIY% , Big Oil Engine Calculator
return

;========== End Big Oil Calculator GUI ==========

;========== Video Settings GUI ==========

VideoSettingsGUI:

	Gui, BottomGUI:Destroy
	
	; Get coords of playday GUI to get x/y for Big Oil Calc
	WinGetPos, x, y, w, h, PLAYDAY 2

	bottomGUIX	:= x
	bottomGUIY	:= y + h

	; GUI Options
	Gui, BottomGUI:Color, 0x000000
	Gui, BottomGUI:+Border -Caption +OwnerMain +HwndBG

	; Background
	Gui, BottomGUI:Add, Picture, x0 y0 w360 h180 , % imagesLoc "pd2BottomGUI.png"

	GUI, BottomGUI:Font, c0xDDDDDD s10, Times New Roman
	
	; Resolution
	Gui, BottomGUI:Add, GroupBox, x10 y10 w120 h100, Resolution
	Gui, BottomGUI:Add, DropDownList, x20 y30 w100 vvgRes ,
	Gui, BottomGUI:Add, Radio, x20 y60 w80 h20 vvgWindowed , Windowed
	Gui, BottomGUI:Add, Radio, x20 y80 w80 h20 vvgFullscreen, Fullscreen

	; Refresh Rate
	Gui, BottomGUI:Add, GroupBox, x10 y110 w120 h60, Refresh Rate
	Gui, BottomGUI:Add, DropDownList, x20 y135 w100 h20 r10 vvgRR ,
	
	; VSync
	Gui, BottomGUI:Add, GroupBox, x270 y10 w80 h70, VSync
	Gui, BottomGUI:Add, Radio, x280 y50 w60 h20 vvgVSync , Off
	Gui, BottomGUI:Add, Radio, x280 y30 w60 h20 , On
	
	; Graphics Settings
	Gui, BottomGUI:Add, GroupBox, x140 y10 w120 h160, Graphics Settings
	
	Gui, BottomGUI:Add, Text, x150 y30 w100 h20, Anisotropy:
	Gui, BottomGUI:Add, DropDownList, x150 y50 w100 h20 r10 vvgAnisotropy ,

	Gui, BottomGUI:Add, Text, x150 y75 w100 h20, Textures:
	Gui, BottomGUI:Add, DropDownList, x150 y95 w100 h20 r10 vvgTextures ,
	
	Gui, BottomGUI:Add, Text, x150 y120 w100 h20, Shadows:
	Gui, BottomGUI:Add, DropDownList, x150 y140 w100 h20 r10 vvgShadows ,
	
	; Update GUI Button
	Gui, BottomGUI:Add, Button, x270 y95 w80 h30 gVideoSettingsUpdate , Update Video Settings

	; Close GUI
	Gui, BottomGUI:Add, Button, x270 y140 w80 h30 gCloseBottomGUI, Close

	; Creates drop down menu dynamically
	gosub, MakeGUIResList
	
	; Gui contril is built into the GetSettings startup function to reduce code.
	GetSet(playdayTmpFile, playdaySettings, rendererFile, crashFile, fullCrashFile)

	GuiControl, BottomGUI:, % vgWindowed, % windowed

	Gui, BottomGUI:Show, w360 h180 x%bottomGUIX% y%bottomGUIY% , PD2 Video Settings
return

;========== End Video Settings GUI ==========

;========== Talent Calc GUI ==========
TalentCalcGUI:
	MsgBox Not complete yet.`n`nIt's next on the "to-do" list. Creating a talent calculator from scratch is a TON of work and I left this project for last because of how long I knew it would take. I took that time and instead put it toward getting everything else created and out in time for the Hoxton Housewarming.`n`nThe calculator WILL get finished and released.`n`nKeep clicking that "Check for update" button or enable Auto-Update.`n`nThanks for using PLAYDAY!`n`n-0xB0BAFE77
return

;==================== Functions and Subroutines ====================

; Start PAYDAY 2
StartPayday:
	Run, steam://rungameid/218620
return

; This is where the gui movement syncing takes place
Docking:
	GetGUIPos()
	
	; Wait for Left Mouse to be released then wait 50ms
	KeyWait, LButton
	Sleep, 100
	
	; If main gui moves, adjust bottom and right
	if (currentX1 != lastX1) || (currentY1 != lastY1){
		newX1	:= currentX1 + W1
		newY1	:= currentY1 + H1
		WinMove, ahk_id %RG%, , %newX1%, %currentY1%
		WinMove, ahk_id %BG%, , %currentX1%, %newY1%
		GetGUIPos()
		SetLastPos()
		Sleep, 50
		IniWrite, % lastX1, % playdaySettings, SavedVars, lastX
		IniWrite, % lastY1, % playdaySettings, SavedVars, lastY
		return
	}
	
	; If right gui moves, adjust bottom and main
	if (currentX2 != lastX2) || (currentY2 != lastY2){
		newX2	:= currentX2 - W1
		newY2	:= currentY2 + H1
		WinMove, ahk_id %MG%, , %newX2%, %currentY2%
		WinMove, ahk_id %BG%, , %newX2%, %newY2%
		GetGUIPos()
		SetLastPos()
		Sleep, 50
		IniWrite, % lastX1, % playdaySettings, SavedVars, lastX
		IniWrite, % lastY1, % playdaySettings, SavedVars, lastY
		return
	}
	
	; If bottom gui moves, adjust main and right
	if (currentX3 != lastX3) || (currentY3 != lastY3){
		newX3	:= currentX3 + W1
		newY3	:= currentY3 - H1
		WinMove, ahk_id %MG%, , %currentX3%, %newY3%
		WinMove, ahk_id %RG%, , %newX3%, %newY3%
		GetGUIPos()
		SetLastPos()
		Sleep, 50
		IniWrite, % lastX1, % playdaySettings, SavedVars, lastX
		IniWrite, % lastY1, % playdaySettings, SavedVars, lastY
		return
	}
return

; Toggles Big Oil Calc when button is pressed
BigOilCalcToggle:
	rightGUIActive	:= !rightGUIActive
	if (rightGUIActive = true)
		gosub, BigOilCalcGUI
	else
		gosub, CloseRightGUI
return

VideoSettingsToggle:
	bottomGUIActive	:= !bottomGUIActive
	if (bottomGUIActive = true){
		GetSet(playdayTmpFile, playdaySettings, rendererFile, crashFile, fullCrashFile)
		gosub, VideoSettingsGUI
	}else
		gosub, CloseBottomGUI
return

; Close Right GUI
CloseRightGUI:
	Gui, RightGUI:Destroy
	rightGUIActive	:= false
return

; Close Bottom GUI
CloseBottomGUI:
	Gui, BottomGUI:Destroy
	bottomGUIActive	:= false
return

; Big Oil Calculator Logic
BigOilUpdate:

	; Arrays that handle what numbers to turn on and off
	; Numbers included in array are the engines that item can't be.
	nitrogenGUI		:= [2,3,5,6,7,9,10,12]
	deteriumGUI		:= [1,3,4,6,7,8,10,11]
	heliumGUI		:= [1,2,4,5,8,9,11,12]
	nozzles1GUI		:= [3,4,5,6,7,8,9,10,11,12]
	nozzles2GUI		:= [1,2,7,8,9,10,11,12]
	nozzles3GUI		:= [1,2,3,4,5,6]
	pressureGTGUI	:= [1,5,7,8,9]
	pressureLTGUI	:= [2,6,11,12]

	Gui, RightGUI:Submit, NoHide

	Gui, RightGUI:Font, c0xDDDDDD s18 norm, Impact
	Loop, 12
		GuiControl, Font, engine%A_Index%	

	; If nitrogen
	if (gasGUI = 2){
		Gui, RightGUI:Font, c%bgc%
		for i, v in nitrogenGUI
			GuiControl, Font, % "engine" . v
	}

	; If deterium
	if (gasGUI = 3){
		Gui, RightGUI:Font, c%bgc%
		for i, v in deteriumGUI
			GuiControl, Font, % "engine" . v
	}

	; If Helium
	if (gasGUI = 4){
		Gui, RightGUI:Font, c%bgc%
		for i, v in heliumGUI
			GuiControl, Font, % "engine" . v
	}
	
	; If 1 nozzle (H)
	if (nozzleGUI = 2){
		Gui, RightGUI:Font, c%bgc%
		for i, v in nozzles1GUI
			GuiControl, Font, % "engine" . v
	}

	; If 1 nozzle (2 x H)
	if (nozzleGUI = 3){
		Gui, RightGUI:Font, c%bgc%
		for i, v in nozzles2GUI
			GuiControl, Font, % "engine" . v
	}

	; If 1 nozzle (3 x H)
	if (nozzleGUI = 4){
		Gui, RightGUI:Font, c%bgc%
		for i, v in nozzles3GUI
			GuiControl, Font, % "engine" . v
	}
	
	; If Pressure > 5783
	if (pressureGUI = 2){
		Gui, RightGUI:Font, c%bgc%
		for i, v in pressureGTGUI
			GuiControl, Font, % "engine" . v
	}

	; If Pressure < 5812
	if (pressureGUI = 3){
		Gui, RightGUI:Font, c%bgc%
		for i, v in pressureLTGUI
			GuiControl, Font, % "engine" . v
	}
return

; Disables/enables IPHLPAPI.dll if it's present
DisableIPHLPAPI:
	Gui, Main:Submit, NoHide
	
	IfNotExist, % installPath . "\IPHLPAPI.dll.disabled"
	{
		IfNotExist, % installPath . "\IPHLPAPI.dll"
		{
			GuiControl, , modsEnabled, 0
			MsgBox, "IPHLPAPI.dll doesn't seem to be present"
			return
		}
	}

	if (modsEnabled = 0){
		IfNotExist, % installPath . "\IPHLPAPI.dll.disabled"
			MsgBox, % "IPHLPAPI.dll.disabled is not present."
		IfExist, % installPath . "\IPHLPAPI.dll.disabled"
			FileMove, %installPath%\IPHLPAPI.dll.disabled, %installPath%\IPHLPAPI.dll
		return
	}

	if (modsEnabled = 1){
		IfNotExist, % installPath . "\IPHLPAPI.dll"
			MsgBox, % "IPHLPAPI.dll is not present."
		IfExist, % installPath . "\IPHLPAPI.dll"
			FileMove, %installPath%\IPHLPAPI.dll, %installPath%\IPHLPAPI.dll.disabled
		return
	}
return

; PD2 EZ Crash Reporter
CrashReport:

	Sleep, 50
	
	; Submit any changes
	Gui, Main:Submit, NoHide

	; Maintenance
	FileDelete, %playdayTmpLoc%\PD2EZReport.txt

	; EZ Reporter Formatter
	EZReportF(cat){
		; Write to log
		FileAppend, %cat%:`n, %playdayTmpLoc%\PD2EZReport.txt
		FileAppend, ============================================================`n, %playdayTmpLoc%\PD2EZReport.txt
	}

	; Check for mods/presence of IPHLPAPI.dll
	IfExist %installPath%\IPHLPAPI.dll
		tmp	:= "present"
	else
		tmp	:= "not present"

	; Write mod status to file
	EZReportF("Mod")
	FileAppend, IPHLPAPI.dll is %tmp% in the Payday 2 main folder.`n`n`n, %playdayTmpLoc%\PD2EZReport.txt

	IfExist %A_AppData%\..\Local\PAYDAY 2\crash.txt
		FileRead, tmp, %A_AppData%\..\Local\PAYDAY 2\crash.txt
	else
		tmp	:= "Crash log could not be found."	

	; Write crash report to file
	EZReportF("Last Crash")
	FileAppend, %tmp%`n`n`n, %playdayTmpLoc%\PD2EZReport.txt

	; Get renderer_settings.xml info
	IfExist %A_AppData%\..\Local\PAYDAY 2\renderer_settings.xml
		FileRead, tmp, %A_AppData%\..\Local\PAYDAY 2\renderer_settings.xml
	else
		tmp	:= "Full crash log could not be found."	

	; Write renderer_settings.xml to file
	EZReportF("renderer_settings.xml")
	FileAppend, %tmp%, %playdayTmpLoc%\PD2EZReport.txt

	; Write crash report to file
	if (allCrashLogs = 1){
		IfExist %A_AppData%\..\Local\PAYDAY 2\crashlog.txt
			FileRead, tmp, %A_AppData%\..\Local\PAYDAY 2\crashlog.txt
		else
			tmp	:= "Crash log could not be found."	

		; Write crash report to file
		EZReportF("Full Crash Log")
		FileAppend, %tmp%`n`n`n, %playdayTmpLoc%\PD2EZReport.txt
	}

	FileRead, tmp, %playdayTmpLoc%\PD2EZReport.txt
	RemoveBlankLines(tmp)

	Sleep, 50
	IfExist %playdayTmpLoc%\PD2EZReport.txt
		Run, %playdayTmpLoc%\PD2EZReport.txt
	else
		MsgBox, Could not generate crash report.
return

OpenPaydayInstall:
	Run, % installPath
return

; Auto-Close
AutoCloseToggle:
	Gui, Main:Submit, NoHide

	; Saves user prefrence
	IniWrite, % exitOnExit, % playdaySettings, SavedVars, exitOnExit	

	if (exitOnExit = 1)
		SetTimer, ScanForPD2Exit, 500
	else{
		SetTimer, ScanForPD2Exit, Off
		pd2Running	:= false
	}
return

ScanForPD2Exit:
	; Checks to see if PAYDAY 2 is running
	Process, Exist, payday2_win32_release.exe
	if (ErrorLevel > 0){
		pd2Running	:= true
	}

	if (pd2Running = true){
		Process, Exist, payday2_win32_release.exe
		if (ErrorLevel = 0)
			ExitApp
	}
return

AutoCloseScan:
return

; Writes the selected video values from the video gui to renderer_settings.xml
VideoSettingsUpdate:
	
	Gui, BottomGUI:Submit, NoHide
	
	; The video settings should be used to adjust settinsg when the game isn't running.
	; This checks to see if PAYDAY 2 is running. If yes, warn the user.
	Process, Exist, payday2_win32_release.exe
	
	if (ErrorLevel > 0)
		MsgBox, 4404, PAYDAY 2 Running, PAYDAY 2 is currently running. If you want to modify your video settings`, please do so from in game. Do you still want to update your video settings?
		IfMsgBox, No
			return
		
	; Start with a fresh file.
	FileDelete, % rendererTemp
	
	; Line by line copy of renderer_settings.xml
	Loop, Read, % rendererFile
	{
		tmp	:= A_LoopReadLine
		IfInString, tmp, resolution = 
		{
			tmp	:= RegExReplace(tmp, """\d*\s\d*""", """" vgRes """")
			StringReplace, tmp, tmp, x, %A_Space%
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		IfInString, tmp, windowed =
		{
			if (vgWindowed = 1)
				windowed	:= "true"
			else
				windowed	:= "false"
			tmp	:= RegExReplace(tmp, """.*""", """" windowed """")
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		IfInString, tmp, refresh_rate =  
		{
			tmp	:= RegExReplace(tmp, """.*""", """" vgRR """")
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		IfInString, tmp, v_sync = 
		{
			vsyncTmp	:= vgVSync
			; must be decremented because drop down lists start at 1 and true/false starts at 0
			vsyncTmp--
			tmp	:= RegExReplace(tmp, """\d*""", """" vsyncTmp """")
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		IfInString, tmp, max_anisotropy
		{
			anisoTmp	:= vgAnisotropy
			StringReplace, anisoTmp, anisoTmp, x,
			tmp	:= RegExReplace(tmp, "value="".*""", "value=""" anisoTmp """")
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		IfInString, tmp, texture_quality_default
		{
			vgTexturesTmp	:= vgTextures
			StringLower, vgTexturesTmp, vgTexturesTmp
			tmp	:= RegExReplace(tmp, "value="".*""", "value=""" vgTexturesTmp """")
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		IfInString, tmp, shadow_quality_default
		{
			vgShadowsTmp	:= vgShadows
			StringLower, vgShadowsTmp, vgShadowsTmp
			tmp	:= RegExReplace(tmp, "value="".*""", "value=""" vgShadowsTmp """")
			FileAppend, % tmp "`n", % rendererTemp
			continue
		}
		FileAppend, % tmp "`n", % rendererTemp
	}
	FileCopy, % rendererTemp, % rendererFile, 1
return

AutoUpdateToggle:
	Gui, Main:Submit, NoHide

	; Saves user prefrence
	IniWrite, % autoUpdate, % playdaySettings, SavedVars, autoUpdate	

	if (autoUpdate = 1){
		autoUpdaterOn	:=	true
		Sleep, 50
		SetTimer, VersionCheck, 300000 ;shloud be 300,000
	}else{
		autoUpdaterOn	:=	false
		SetTimer, VersionCheck, Off
	}
return

ButtonUpdateCheck:
	; Get new file and check version difference.
	gosub, VersionCheck
	
	if (updateIsAvailable = true){
		MsgBox, 8260, PLAYDAY Updater, An updated version is available!`n`nWould you like to download it?`n`nClick Yes to get the new version or No to continue using this version.
		
		; Check if user wants to download.
		IfMsgBox, No
			return
		
		; Start download process
		gosub, UpdatePLAYDAY		
	}else{
		MsgBox, 8516, PLAYDAY Updater, You have the most current version of PLAYDAY.`n`nWould you like force a reinstall from the web?`n`nClick Yes to force reinstall or No to exit the updater.
		IfMsgBox, Yes
		{
			MsgBox, 8516, PLAYDAY Updater, Are you sure?`n`nThere's no good reason to do this unless your version is acting up.
			IfMsgBox, Yes
				gosub, UpdatePLAYDAY
		}
		return
	}

return

VersionCheck:
	; Get new version source
	URLDownloadToFile, % gitHubURLAHK, % playdayTmpFile
	
	; Check for dow'nloaded copy's version
	Loop, Read, % playdayTmpFile
	{
		; Get version number
		IfInString, A_LoopReadLine, currentVersion
		{
			; Ger version and format it
			global	newVersion			:= RegExReplace(A_LoopReadLine, "^.*=", "")
			global	newVersionForm		:= "Online Version: " newVersion
			
			; Got what was needed. End loop.
			break
		}
	}	
	; Version comparison
	if (newVersion > currentVersion){
		GuiControl, Main:, guiUpdateBottomText, % newVersionForm
		GuiControl, Main:, guiUpdateTopText, There is an update available!
		updateIsAvailable	:= true
		if (autoUpdaterOn = 1)
			gosub, UpdatePLAYDAY
	}else{
		GuiControl, Main:, guiUpdateTopText, You have the most current
		GuiControl, Main:, guiUpdateBottomText, version of PLAYDAY.
		updateIsAvailable	:= false
	}
return

; Program Updater
UpdatePLAYDAY:
	
	; get file extension type (ahk / exe)
	SplitPath, % A_ScriptFullPath, , , thisExt
	
	; .exe path
	if (thisExt = "exe"){
		
		global	downloadLoc		:= playdayTmpLoc A_ScriptName
		
		; Save current .exe location and downloaded .exe location
		IniWrite, % A_ScriptFullPath, % playdaySettings, SavedVars, exeLocation
		IniWrite, % downloadLoc, % playdaySettings, SavedVars, downloadLoc
		
		; Get new version exe
		URLDownloadToFile, % gitHubURLEXE, % downloadLoc
		
		; Warn user if error occurs
		if (ErrorLevel > 0){
			MsgBox, 8240, PLAYDAY Updater, There was a problem updating PLAYDAY.`n`nYou can try reloading the program and running the updater again.`n`nOther causes:`n- GitHub might be doing maintenance or be temporarily down.`n- Your firewall may be blocking the connection.`n`nYou can manually update by visiting the PLAYDAY GitHub page and downloading a fresh copy at:`n`nhttps://github.com/0xB0BAFE77/PLAYDAY
			return
		}
		
		; Make sure PLAYDAYUpdater.exe is present
		IfNotExist, % updater
		{
			MsgBox PLAYDAYUpdater.exe is corrupt or not present!!`n`nThis is a problem because it's packaged into the PLAYDAY executable.`n`nPlease download a fresh copy of PLAYDAY from %gitHubURL%
				autoUpdaterOn	:=	false
				SetTimer, UpdatePLAYDAY, Off
				
				; Disables the auto update check box due to PLAYDAYUpdater.exe failure.
				GuiControl, Main:, autoUpdate, -1
			return
		}
		
		; If all is good, run the PLAYDAYUpdater!
		; God it took forever to get here...I am not a professional coder. This shit took a while and every bug fixed made 2 more. Going at this shit head on, I still missed my target date of oct 7 for the hox housewarming. Luckily I'm going to be dropping it the tonight, the 8th. Just a little insight into making this (If you're one of those curious people that reads through the code.
		Run, % updater
		return
	}
	; .ahk path
	if (thisExt	= "ahk"){
		
		; Backup current version
		FileCopy, % A_ScriptFullPath, % A_ScriptFullPath ".bak", 1
		
		; Ensure backup was successful
		IfNotExist, % A_ScriptFullPath ".bak"
		{
			; If backup failed, allow user to end update.
			MsgBox, 260, Making backup failed.`n`nClick yes to update anyway. Click no to abort and turn off auto-update if it's on.
			IfMsgBox, No
			{
				autoUpdaterOn	:=	false
				SetTimer, UpdatePLAYDAY, Off
				return
			}
		}
		
		; Download new ahk to temp location
		URLDownloadToFile, % gitHubURLAHK, % A_ScriptFullPath
		
		; If there was an error, replace with the backup made
		if (ErrorLevel = 1){
			
			; Restore backuped up copy
			FileCopy, % A_ScriptFullPath ".bak", % A_ScriptFullPath, 1
			
			; Warn user
			MsgBox, 8240, PLAYDAY Updater, There was a problem updating PLAYDAY.`n`nYou can try reloading the program and running the updater again.`n`nOther causes:`n- GitHub might be doing maintenance or be temporarily down.`n- Your firewall may be blocking the connection.`n`nYou can manually update by visiting the PLAYDAY GitHub page and downloading a fresh copy at:`n`nhttps://github.com/0xB0BAFE77/PLAYDAY
			
			; Clean up old file
			FileDelete, % A_ScriptFullPath ".bak"
			
			GuiControl, Main:, guiUpdateTopText, Update has failed.
			GuiControl, Main:, guiUpdateBottomText, Please try again.
			return
		}
		; If no reload, disable auto updater so user doesn't get annoyed
		autoUpdaterOn	:=	false
		SetTimer, UpdatePLAYDAY, Off			
		
		; Set notified to 0 so next update's notification will show.
		IniWrite, 0, % playdaySettings, SavedVars, notified
		
		; Replaces "Check For Update" button with a reload button after
		; the automatic update has completed.
		Gui, Main:Add, Button, x185 y180 w150 h30 gReloadGUI vguiReloadButton, RELOAD NOW
		Guicontrol, Main:Hide, guiCFUButton
		GuiControl, Main:Show, guiReloadButton
		
		; Notifies user
		GuiControl, Main:, guiUpdateTopText, Update downloaded! Click
		GuiControl, Main:, guiUpdateBottomText, "Reload" to install.
		return
	}
MsgBox Stop for now...
return

; Dynamically creates resolution dropdown
MakeGUIResList:
	
	; Make new list
	guiResList		:= ""
	; Remove quotation marks
	StringReplace, resolutionTMP, resolution,",, All
	; Replace the space separator with an x for comparison below
	StringReplace, resolutionTMP, resolutionTMP,%A_Space%,x
	Loop, Read, % playdayTmpFile
	{
		tmp		:= A_LoopReadLine
		; Skip start title
		IfInString, tmp, [Resolutions Start]
			continue
		; End loop because end is reached
		IfInString, tmp, [Resolutions End]
			break
		; If this resolution is the current resolution, then add another pipe.
		; This sets the value as the selected starting value when the dropdown list
		; is genearted.
		IfInString, tmp, % resolutionTMP
			tmp		:= tmp . "|"
		guiResList	:= guiResList . tmp . "|"
	}
	GuiControl, BottomGUI:, vgRes, % guiResList
return

AutoOpenGuideCheck:
	Gui, Main:Submit, NoHide
	IniWrite, % autoOpenGuide, % playdaySettings, SavedVars, autoOpenGuide
return

AutoOpenGuide:
	Gui, Main:Submit, NoHide
	if (guiAutoOpenGuide = 1){
		if (guiGuideList = "Select Guide:"){
			MsgBox, You need to select a guide first.
			return
		}
		Run, % guideArray[guiGuideList]
	}
return

OpenGuide:
	Gui, Main:Submit, NoHide
	if (guiGuideList = "Select Guide:"){
		MsgBox, You need to select a guide first.
		return
	}
	Run, % guideArray[guiGuideList]
return

MinimizeGui:
	;Gui, Show/hide if wanting to minimize to tray
	WinMinimize, PLAYDAY 2
return

; GUI Reloader
ReloadGUI:
	Reload
return

; Exit Script
Quit:
FileDelete, % playdayTmpFile
ExitApp

; Used for testing
Test:
	MsgBox % allCrashLogs
return

; This label is not actually used and only exists for quick navigation while coding with SciTE4AutoHotkey
_Functions:
return

; Checks to see if the user has seen the notification popup since update.
; In the future there will be a "don't show this popup anymore" check box on a custom Popup I've designed.
notifiedCheck(){
	
	if (notified = 0){
		MsgBox, 8256, Announcement, % announcement
		IniWrite, 1, % playdaySettings, SavedVars, notified
	}
}

; Makes GUI movable when clicked and dragged.
WM_MOUSEMOVE(wparam, lparam, msg, hwnd){
	if (wparam = 1){
		PostMessage, 0xA1, 2,,, A
	}
}

; Test function. Delete.
TestF(){
	MsgBox Tested Function Working!
}

; Trim all white space from the beginning and end of a string
; Regex expression (^\s*|\s*$)
TrimWhite(tmp){
	tmp	:= RegExReplace(tmp, "(^\s*|\s*$)","")
	return tmp
}

; Function for removing blank lines
RemoveBlankLines(rbl){
	Loop
	{
		StringReplace, rbl, rbl, `r`n`r`n, `r`n, UseErrorLevel
		if ErrorLevel = 0
			break
	}
}

; Get positions of all open GUIs.
; Used in GUI movement syncing
GetGUIPos(){
	global
	WinGetPos, currentX1, currentY1, W1, H1, ahk_id %MG%
	WinGetPos, currentX2, currentY2, , , ahk_id %RG%
	WinGetPos, currentX3, currentY3, , , ahk_id %BG%
}

; Set positions last known locations for all GUIs.
; Used in GUI movement syncing
SetLastPos(){
	global
	lastX1	:= currentX1
	lastY1	:= currentY1
	lastX2	:= currentX2
	lastY2	:= currentY2
	lastX3	:= currentX3
	lastY3	:= currentY3
}

; Get current settings
GetSet(pld2, plds, rend, crash, fcrash){
	
	; Delete old file
	FileDelete, % pld2
	
	; Checks to see if PLAYDAY2Settings.ini exists. If not, it makes one.
	IfNotExist, % plds
	{
		; Creates header and trims all whitespace from the left of text
		FileAppend,
		(LTrim(
			;============================== PLAYDAY 2 Settings ==============================
			;
			[SavedVars]
		), % plds
	}
	
	; Used to track when to file append and when not to.
	; This helps trim off data not needed
	record	:= false
	
	; Used to "remove last 3" characters in resolutions.
	; This removes the refresh rates from the entries
	; And leaves a "RESOLUTION x RESOLUTION" format
	rl3		:= false
	
	; Parse info from renderer.xml
	Loop, Read, % rend
	{
		tmp	:= TrimWhite(A_LoopReadLine)
		
		; Skips blank lines
		if (tmp = "")
			continue
		
		; Get list of resolutions
		IfInString, tmp, Modes (width x height x refresh):
		{
			record	:= true
			rl3		:= true
			FileAppend, % "[Resolutions Start]`n", % pld2
			continue
		}
		
		; Stop recording when --> is found and insert "Resolutions end" tag
		IfInString, tmp, -->
		{
			record	:= false
			rl3		:= false
			FileAppend, % "[Resolutions End]`n", % pld2
			continue
		}
		
		; Record current resolution
		IfInString, tmp, resolution =
		{
			tmp	:= RegExReplace(tmp, "resolution = ","")
			StringReplace, resolution, tmp, ",, all
			IniWrite, % resolution, % plds, SavedVars, resolution
		}
		
		; Records if in window or fullscreen mode
		IfInString, tmp, windowed =
		{
			IfInString, tmp, true
			{
				windowed	:= "true"
				IniWrite, % windowed, % plds, SavedVars, windowed
				GuiControl, BottomGUI:, vgWindowed, 1
				continue
			}
			windowed	:= "false"
			IniWrite, % windowed, % plds, SavedVars, windowed
			GuiControl, BottomGUI:, vgFullscreen, 1
		}
		
		; Records current refresh rate
		IfInString, tmp, refresh_rate =
		{
			tmp	:= RegExReplace(tmp, "refresh_rate = ","")
			StringReplace, tmp, tmp, ", , all
			IniWrite, % tmp, % plds, SavedVars, refreshRate
			IfInString, refreshRateList, % tmp
			{
				StringReplace, refreshRateList, refreshRateList, ||, |, all
				StringReplace, refreshRateList, refreshRateList, %tmp%, %tmp%|
			}
			GuiControl, BottomGUI:, vgRR, % refreshRateList
		}
		
		; Records anisotropic settings
		IfInString, tmp, max_anisotropy
		{
			tmp	:= RegExReplace(tmp, "<variable name=""max_anisotropy"" ","")
			tmp	:= RegExReplace(tmp, "value=","")
			StringReplace, tmp, tmp, />, , all
			; If blank, assign value to Off
			if (tmp = """"""){
				tmp	:= "Off"
				IniWrite, % tmp, % plds, SavedVars, anisotropy
			}else{
				StringReplace, tmp, tmp, ", , all
				tmp	:= tmp "X"
				IniWrite, % tmp, % plds, SavedVars, anisotropy
			}
			IfInString, anisotropyList, % tmp
			{
				StringReplace, anisotropyList, anisotropyList, ||, |, all
				StringReplace, anisotropyList, anisotropyList, %tmp%, %tmp%|
			}
			GuiControl, BottomGUI:, vgAnisotropy, % anisotropyList
		}
		
		; Records texture settings
		IfInString, tmp, texture_quality_default
		{
			tmp	:= RegExReplace(tmp, "<variable name=""texture_quality_default"" value=""","")
			tmp	:= RegExReplace(tmp, """/>","")
			StringUpper, tmp, tmp, T
			IniWrite, % tmp, % plds, SavedVars, textures
			IfInString, texturesList, % tmp
			{
				StringReplace, texturesList, texturesList, ||, |, all
				StringReplace, texturesList, texturesList, %tmp%, %tmp%|
			}
			GuiControl, BottomGUI:, vgTextures, % texturesList
		}
		
		; Records shadow settings
		IfInString, tmp, shadow_quality_default
		{
			tmp	:= RegExReplace(tmp, "<variable name=""shadow_quality_default"" value=""","")
			tmp	:= RegExReplace(tmp, """/>","")
			StringUpper, tmp, tmp, T			
			IniWrite, % tmp, % plds, SavedVars, shadows
			IfInString, shadowsList, % tmp
			{
				StringReplace, shadowsList, shadowsList, ||, |, all
				StringReplace, shadowsList, shadowsList, %tmp%, %tmp%|
			}
			GuiControl, BottomGUI:, vgShadows, % shadowsList
		}
		
		; Records if VSync is enabled
		IfInString, tmp, v_sync =
		{
			tmp	:= RegExReplace(tmp, "v_sync = ","")
			StringReplace, tmp, tmp, ", , all
			IniWrite, % tmp, % plds, SavedVars, vsync
			; You have to increment because radio buttons start at 1
			; while true false works on 0 or 1.
			tmp++
			GuiControl, BottomGUI:, vgVSync, % tmp
		}
		
		; Trimming of refresh rate from resolution
		if (record = true){
			if (rl3 = true)
				StringTrimRight, tmp, tmp, 3
			if (tmp = "!")
				continue
			FileAppend, % tmp . "`n", % pld2
		}
	}
}

; Custom message box
pdMsgBox(msg){
	; Make a custom popup
	;Gui, POP:Destroy
	;Gui, POP:Add,Text,x10 y10 w430 h150,Text
	;Gui, POP:Add,Text,x10 y175 w140 h20,Blank Hyperlink
	;Gui, POP:Add,Button,x330 y200 w100 h30,Button
	;Gui, POP:Add,Checkbox,x20 y210 w250 h20,Disable update notificaitons. (Not recommended)
	;Gui, POP:Show,w450 h250,PLAYDAY Notification
}

BackupRenderer(){
	IfNotExist, % playdayTmpLoc . "\renderer_settings.xml.originalBackup"
		FileCopy, % rendererFile, % playdayTmpLoc . "\renderer_settings.xml.original", 1
}

;==================== Hotkeys ====================

#IfWinActive, ahk_exe payday2_win32_release.exe

; Custom paste function since pasting isn't recognized natively.
; Ctrl+V pastes text into payday chat box.
^v::
	
	SetKeyDelay, 100, 50
	
	;Backup whatever is on the clipboard to var
	clipSave	:= ClipboardAll
	
	;Call paste function
	PaysteDay(Clipboard)
	
	;Returns original content to clipboard.
	Clipboard	:= clipSave
	
	;Clears clipSave variable. 
	clipSave	:= ""
return

; PaysteDay function. cb = clipboard
PaysteDay(cb){
	; Removes carriage returns.
	StringReplace, cb, cb, `r`n, %A_Space%, all	

	; Removes formatting
	cb := cb

	; Payday 2's chat box can only accept a maximum of 78 characters
	charLeft	:= 79
	
	; Start with an empty var
	pasteVar	:= ""
	
	; Total substrings.
	; Start at -1 because loops start at 0
	totalSS		:= 0
	
	; Get total number of substring fields in clipboard
	Loop, Parse, cb, % A_Space
		totalSS++
	
	; Parse through clipboard. Treat spaces as delimiters.
	Loop, Parse, cb, %A_Space%
	{
		tmp	:=	A_LoopField . A_Space
		if (StrLen(tmp) < charLeft){
			pasteVar	.= tmp
			charLeft	-= StrLen(tmp)
;			MsgBox, pasteVar = %pasteVar%`ncharLeft = %charLeft%
			continue
		}else{
			pasteVar	.= A_LoopField
			SendInput, % "{Raw}" . pasteVar
			Sleep, 50
			Send, {Enter}
			Sleep, 50
			pasteVar	:= ""
			charLeft	:= 78
		}
	}
	SendInput, % "{Raw}" . pasteVar
	Sleep, 50
	Send, {Enter}
	Sleep, 50
	pasteVar	:= ""
	charLeft	:= 78
}

#IfWinActive

;============================== End Script ==============================
/*
;============================== Notes/Changes/Etc ==============================
========== Changle Log ==========
v. Beta - v161006
	Completed Features:
		PAYDAY 2 Launcher
		Big Oil Calculator
		PaysteDay Paste Support
		Quick Mod Disabling
		PD2 EZ Reporter w/ full crash log support
		Entire Video Settings Editing Module
		Browse PAYDAY 2 Install Folder
		GUI Docking fixed
		Auto-quit on PAYDAY 2 Exit
	Currently working on:
		Updater / Auto-Update
		Guides
			Have array made
			Need to poll people for their favorite guides
			Currently have:
				Long Guide (The PAYDAY 2 Bible)
				Package Locations
				All Achievements Guide
				Deathwish Damage Breakpoints
					This will eventually be replaced with a damage calculator
					built into the talent calculator
	

v. Alpha and design notes

Original features and concepts:
	Launch Game
	Enable/Disable BLT (For updates when mods are broken)
	Auto Updater
	PD2 EZ Crash Reporter
	In Game Chat Pasting (Ctrl+V actually pastes test into the chat window. I thought this was already implemented...)
	Auto-Trouble Shooter
		Disables IPHPAPI.dll
			Check = On
			Unchecked = Off
			Gray = Not present (On hover, say this)
		Resets renderer_settings.xml (Give warning)
			Set res to monitor's native resolution
			Set fullscreen to on
			Get monitor refresh rate and set to that?
			Set Anisotropic Filtering to 1 (Off)
			Set textures and shadows to "Very Low"

	Oustide Game Options
		Set refresh rate
		Set resolution/windowed mode
		Set Vsync on/off
		Set Texture and Shadow settings

	Talent Calculator (Future Update maybe?)
		Premade builds?
		Level specific builds?
			Example: If Jewelry store stealth is selected, suggest a build that handles all stealth aspects of that level. IE Ecm Jammers, safe cracking, max speed, etc.

	Engine Calculator
		Gas
			Nitrogen
				1 4 8 11
			Deterium
				2 5 9 12
			Helium
				3 6 7 10
		Pressure
			>5783
				2 3 4 6 10 11 12
			<5812
				1 3 4 5 7 8 9 10
		Hydrogen Cables
			H
				1 2
			2xH
				3 4 5 6
			3xH
				7 8 9 10 11 12

	Links to useful articles
		Long Guide
		Achievement Guide

	Hide Button
	Exit Button

==================== Notes / Thoughts / Things To TDo===================
Custom message box: pdMsgBox(msg)
	basic shell already created

Customizable hotkeys/user defined hotkeys? Might be added later for opening guides and calculators.

Add link to PD2 patch notes?

Add makeshift BLT mods management.
	Pull all mod infor from %installPath%/mods/

; Click Button Function
	/*
	On mouse over certain area, look for OnMessage mouse down
	guicontrol > change button to pressed down button image.
	Check for OnMouseUp
	guicontrol > change button back to depressed button image.'
	*/

; Steam Protocol Link:
; https://developer.valvesoftware.com/wiki/Steam_browser_protocol

; Payday 2 Steam ID:218620
;============================== 0xB0BAFE77 ==============================
