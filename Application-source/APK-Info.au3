#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_OutFile=..\APK-Info.exe
#AutoIt3Wrapper_icon=APK-Info.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Shows info about Android Package Files (APK)
#AutoIt3Wrapper_Res_Description=APK-Info
#AutoIt3Wrapper_Res_Fileversion=1.16.0.0
#AutoIt3Wrapper_Res_LegalCopyright=zoster
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(AutoItExecuteAllowed True)
#include <Constants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <WinAPIShPath.au3>
#include <Array.au3>
#include <String.au3>
Opt("TrayMenuMode", 1)
Opt("TrayIconHide", 1)


; Adding the directives below, will cause your program be compiled with the indexing
; of the original lines shown in SciTE:
#AutoIt3Wrapper_Run_Before=ShowOriginalLine.exe %in%
#AutoIt3Wrapper_Run_After=ShowOriginalLine.exe %in%


Global $apk_Label, $apk_IconPath, $apk_IconPathBg, $apk_PkgName, $apk_VersionCode, $apk_VersionName
Global $apk_Permissions, $apk_Features, $hGraphic, $hImage, $hImage_bg, $apk_MinSDK, $apk_MinSDKVer, $apk_MinSDKName
Global $apk_TargetSDK, $apk_TargetSDKVer, $apk_TargetSDKName, $apk_Screens, $apk_Densities, $apk_ABIs, $apk_Signature
Global $tempPath = @TempDir & "\APK-Info\" & @AutoItPID
Global $Inidir, $ProgramVersion, $ProgramReleaseDate, $ForceGUILanguage
Global $IniProgramSettings, $IniLogReport, $IniLastFolderSettings
Global $tmpArrBadge, $tmp_Filename, $dirAPK, $fileAPK, $fullPathAPK
Global $sNewFilenameAPK, $searchPngCache

$IniProgramSettings = "APK-Info.ini"
$IniLastFolderSettings = "APK-Info.LastFolder.ini"
$IniLogReport = "APK-Info.log.txt"

; $aCmdLine[0] = number of parametrs passed to exe file
; $aCmdLine[1] = first parameter (optional) passed to exe file (apk file name)


; https://www.autoitscript.com/autoit3/docs/intro/running.htm
; An alternative to the limitation of $CmdLine[] only being able to return a maximum of 63 parameters.
Local $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)
; Uncomment it to Show all cmdline parameters
;_ArrayDisplay($aCmdLine)

$Inidir = @ScriptDir & "\"

;$ProgramVersion=Iniread ($Inidir & $IniProgramSettings, "Settings", "ProgramVersion", "0.7Q");
;$ProgramReleaseDate=Iniread ($Inidir & $IniProgramSettings, "Settings", "ProgramReleaseDate", "01.06.2017");

$ProgramVersion = "1.16"
$ProgramReleaseDate = "15.06.2018"

$ForcedGUILanguage = IniRead($Inidir & $IniProgramSettings, "Settings", "ForcedGUILanguage", "auto")


; Check OS language
$OS_language = @OSLang

; more info on country code
; https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm

$ForcedGUILanguage = IniRead($Inidir & $IniProgramSettings, "Settings", "ForcedGUILanguage", "auto")
$OSLanguageCode = @OSLang
If $ForcedGUILanguage = "auto" Then
	$Language_code = IniRead($Inidir & $IniProgramSettings, "OSLanguage", @OSLang, "en")
Else
	$Language_code = $ForcedGUILanguage
EndIf

$CheckSignature = IniRead($Inidir & $IniProgramSettings, "Settings", "CheckSignature", "1")

$ShowLog = IniRead($Inidir & $IniProgramSettings, "Settings", "ShowLog", "0")
$ShowLangCode = IniRead($Inidir & $IniProgramSettings, "Settings", "ShowLangCode", "1")
; $ShowCmdLine=Iniread($Inidir & $IniProgramSettings,"Settings","ShowCmdLine","1");
$FileNamePrefix = IniRead($Inidir & $IniProgramSettings, "Settings", "FileNamePrefix", "")
If $FileNamePrefix = "" Then $FileNamePrefix = " "
$FileNameSuffix = IniRead($Inidir & $IniProgramSettings, "Settings", "FileNameSuffix", "")
If $FileNameSuffix = "" Then $FileNameSuffix = "."
$FileNameSpace = IniRead($Inidir & $IniProgramSettings, "Settings", "FileNameSpace", "")
If $FileNameSpace = "" Then $FileNameSpace = " "
$Lastfolder = IniRead($Inidir & $IniLastFolderSettings, "Settings", "LastFolder", @WorkingDir)

$String01 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String01", "Application")
$String02 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String02", "Version")
$String03 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String03", "Version Code")
$String04 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String04", "Package")
$String05 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String05", "Min. SDK")
$String06 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String06", "Traget SDK")
$String07 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String07", "Screen Size")
$String08 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String08", "Resolution")
$String09 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String09", "Permission")
$String10 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String10", "Feature")
$String11 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String11", "Current name")
$String12 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String12", "New name")
$String13 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String13", "Play Store")
$String14 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String14", "Rename File")
$String15 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String15", "Exit")
$String16 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String16", "Rename APK File")
$String17 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String17", "New APK Filename")
$String18 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String18", "Error!")
$String19 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String19", "APK File could not be renamed.")
$String20 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String20", "Select APK file")
$String21 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String21", "Cur_Dev")
$String22 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String22", "Current Dev. Build")
$String23 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String23", "Unknown")
$String24 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String24", "Unknown")
$String25 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String25", "Browse")
$String26 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String26", "OS Lang Code")
$String27 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String27", "Lang Name")
$String28 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String28", "ABIs")
$String29 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String29", "Signature")
$String30 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String30", "Debug")
$String31 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String31", "Icon")
$String32 = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "String32", "Loading")

$URLPlayStore = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "URLPlaystore", "https://play.google.com/store/apps/details?id=")

$PlayStoreLanguage = IniRead($Inidir & $IniProgramSettings, "Strings-" & $Language_code, "PlayStoreLanguage", "en")

Dim $sMinAndroidString, $sTgtAndroidString

Global $apk_Build = ''

;================== GUI ===========================

$ProgramTitle = "APK-Info " & $ProgramVersion & " (" & $ProgramReleaseDate & ")"
; iF $ShowLangCode="1" then
; $ProgramTitle=$ProgramTitle & "- OSLangCode = " & $OSLanguageCode & " - Lang = " & $Language_code
; Endif
If $ShowLog = "1" Then
	IniWrite($Inidir & $IniLogReport, "APK_Info Version", "Program version", $ProgramVersion)
	IniWrite($Inidir & $IniLogReport, "APK_Info Version", "Program release date", $ProgramReleaseDate)
	IniWrite($Inidir & $IniLogReport, "Language", "OSLanguage", @OSLang)
	IniWrite($Inidir & $IniLogReport, "Language", "OSLanguage", @OSLang)
	IniWrite($Inidir & $IniLogReport, "Language", "OSLanguage", @OSLang)
	IniWrite($Inidir & $IniLogReport, "Language", "ForcedLanguage", $ForcedGUILanguage)
	IniWrite($Inidir & $IniLogReport, "IniFile", "IniFileFolderPath", $Inidir)
	IniWrite($Inidir & $IniLogReport, "IniFile", "IniFileProgramSettings", $IniProgramSettings)
	IniWrite($Inidir & $IniLogReport, "IniFile", "IniFileGuiSettings", $IniProgramSettings)
	IniDelete($Inidir & $IniLogReport, "IniFile", "FileNamePrefix")
	IniWrite($Inidir & $IniLogReport, "IniFile", "FileNamePrefix", $FileNamePrefix)
	IniDelete($Inidir & $IniLogReport, "IniFile", "FileNameSuffix")
	IniWrite($Inidir & $IniLogReport, "IniFile", "FileNameSuffix", $FileNameSuffix)
	; Cleanup not defined variables
	IniWrite($Inidir & $IniLogReport, "Icon", "TempFilePath", "")
	IniWrite($Inidir & $IniLogReport, "Icon", "ApkIconeName", "")
	IniWrite($Inidir & $IniLogReport, "NewFile", "NewFilenameAPK", "")
	IniWrite($Inidir & $IniLogReport, "NewFile", "NewNameInput", "")
	IniWrite($Inidir & $IniLogReport, "OpenNewFile", "LastFileName", "")
	IniWrite($Inidir & $IniLogReport, "OpenNewFile", "TempFileName", "")
EndIf
If $aCmdLine[0] = 0 And $ShowLog = "1" Then
	IniWrite($Inidir & $IniLogReport, "CommandLine", "Parameter1", $aCmdLine[0])
	IniWrite($Inidir & $IniLogReport, "CommandLine", "Parameter2", "")
	; Else
	;	IniWrite($Inidir & $IniLogReport, "CommandLine", "Parameter1", $aCmdLine[0]);
	;	IniWrite($Inidir & $IniLogReport, "CommandLine", "Parameter2", $aCmdLine[1]);
EndIf

$fieldHeight = 24
$bigFieldHeight = 93

$labelStart = 8
$labelWidth = 100
$labelHeight = 20
$labelTop = 3

$inputStart = 125
$inputWidth = 300
$inputHeight = 20
$inputFlags = BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY)

$editHeight = 85
$editFlags = BitOR($ES_READONLY, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $WS_VSCROLL, $ES_WANTRETURN)

$offsetHeight = 9

$rightColumnWidth = 100
$rightColumnStart = $inputStart + $inputWidth + 10

$fullWidth = $rightColumnStart + $rightColumnWidth + 10
$fullHeight = $offsetHeight + $fieldHeight * 11 + $bigFieldHeight * 3 + 50

$btnWidth = $fullWidth / 3 - 20

$hGUI = GUICreate($ProgramTitle, $fullWidth, $fullHeight, -1, -1, -1, $WS_EX_ACCEPTFILES)

GUICtrlCreateLabel("", 0, 0, $fullWidth, $fullHeight, $WS_CLIPSIBLINGS) ; for accept drag & drop
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
;GUICtrlSetBkColor(-1, $COLOR_RED)

$globalStyle = $GUI_DROPACCEPTED + $GUI_ONTOP
$globalInputStyle = $GUI_ONTOP

$Input1 = _makeField($String01, $apk_Label, False, 0)
$Input2 = _makeField($String02, $apk_VersionName, False, 0)
$Input3 = _makeField($String03, $apk_VersionCode & $apk_Build, False, 0)
$Input4 = _makeField($String04, $apk_PkgName, False, 0)

$Input6 = GUICtrlCreateInput($sMinAndroidString, 150, $offsetHeight, 275, $inputHeight, $inputFlags)
GUICtrlSetState(-1, $globalInputStyle)
$Input5 = _makeField($String05, $apk_MinSDK, False, 20)

$Input8 = GUICtrlCreateInput($sTgtAndroidString, 150, $offsetHeight, 275, $inputHeight, $inputFlags)
GUICtrlSetState(-1, $globalInputStyle)
$Input7 = _makeField($String06, $apk_TargetSDK, False, 20)

$Input9 = _makeField($String07, $apk_Screens, False, 0)
$Input10 = _makeField($String08, $apk_Densities, False, 0)
$Input13 = _makeField($String28, $apk_ABIs, False, 0)

$Edit1 = _makeField($String09, $apk_Permissions, True, 0)
$Edit2 = _makeField($String10, $apk_Features, True, 0)

$chSignature = GUICtrlCreateCheckbox($String29, $labelStart, $offsetHeight + $labelTop, $labelWidth, $labelHeight)
Local $tmpStyle = $globalStyle
If $CheckSignature == 1 Then
	$tmpStyle = $tmpStyle + $GUI_CHECKED
Else
	$tmpStyle = $tmpStyle + $GUI_UNCHECKED
EndIf
GUICtrlSetState(-1, $tmpStyle)

$Edit3 = _makeField(False, $apk_Signature, True, 0)

$Input11 = _makeField($String11, $fileAPK, False, 0)
$Input12 = _makeField($String12, $sNewFilenameAPK, False, 0)

; Show OS language and language code
If $ShowLangCode = "1" Then
	GUICtrlCreateLabel($String26, $rightColumnStart, 84, $rightColumnWidth, $labelHeight, $SS_CENTER)
	GUICtrlSetState(-1, $globalStyle)
	GUICtrlCreateLabel($OSLanguageCode, $rightColumnStart, 108, $rightColumnWidth, $labelHeight, $SS_CENTER)
	GUICtrlSetState(-1, $globalStyle)
	GUICtrlCreateLabel($String27, $rightColumnStart, 156, $rightColumnWidth, $labelHeight, $SS_CENTER)
	GUICtrlSetState(-1, $globalStyle)
	GUICtrlCreateLabel($Language_code, $rightColumnStart, 180, $rightColumnWidth, $labelHeight, $SS_CENTER)
	GUICtrlSetState(-1, $globalStyle)
	;GUICtrlCreateLabel($sPadSpace,		 455, 228, 100,  20)
	;GUICtrlSetState(-1, $globalStyle)
EndIf

$offsetHeight += 11 ; buttons row gap

; Button Play / Rename / Exit
$offsetWidth = 10
$gBtn_Play = _makeButton($String13)
$gBtn_Rename = _makeButton($String14)
$gBtn_Exit = _makeButton($String15)

_GDIPlus_Startup()
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)

$defBkColor = 0

If $aCmdLine[0] > 0 Then
	$tmp_Filename = $aCmdLine[1]
Else
	$tmp_Filename = ""
EndIf

_OpenNewFile($tmp_Filename)

GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")

GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $gBtn_Play
			_openPlay()

		Case $GUI_EVENT_DROPPED
			_OpenNewFile(@GUI_DragFile)
			MY_WM_PAINT(0, 0, 0, 0)

		Case $chSignature
			If BitAND(GUICtrlRead($chSignature), $GUI_CHECKED) = $GUI_CHECKED Then
				$CheckSignature = 1
			Else
				$CheckSignature = 0
			EndIf
			IniWrite($Inidir & $IniProgramSettings, "Settings", "CheckSignature", $CheckSignature)

		Case $gBtn_Rename
			$sNewNameInput = InputBox($String16, $String17, $sNewFilenameAPK, "", 300, 130)
			If $ShowLog = "1" Then
				IniWrite($Inidir & $IniLogReport, "NewFile", "NewFilenameAPK", $sNewFilenameAPK)
				IniWrite($Inidir & $IniLogReport, "NewFile", "NewNameInput", $sNewNameInput)
			EndIf
			If $sNewNameInput <> "" Then _renameAPK($sNewNameInput)

		Case $gBtn_Exit
			_cleanUp()
			Exit

		Case $GUI_EVENT_CLOSE
			_cleanUp()
			Exit
	EndSwitch
WEnd

;==================== End GUI =====================================

Func _makeButton($value)
	$ret = GUICtrlCreateButton($value, $offsetWidth, $offsetHeight, $btnWidth)
	GUICtrlSetState(-1, $globalStyle)
	$offsetWidth += $btnWidth + 20
	Return $ret
EndFunc   ;==>_makeButton

Func _makeField($label, $value, $isEdit, $width)
	If $width == 0 Then
		$width = $inputWidth
	EndIf
	If $label Then
		GUICtrlCreateLabel($label, $labelStart, $offsetHeight + $labelTop, $labelWidth, $labelHeight)
		GUICtrlSetState(-1, $globalStyle)
	EndIf
	If $isEdit Then
		$ret = GUICtrlCreateEdit($value, $inputStart, $offsetHeight, $inputWidth + 10 + $rightColumnWidth, $editHeight, $editFlags)
		GUICtrlSetState(-1, $globalInputStyle)
		$offsetHeight += $bigFieldHeight
	Else
		$ret = GUICtrlCreateInput($value, $inputStart, $offsetHeight, $width, $inputHeight, $inputFlags)
		GUICtrlSetState(-1, $globalInputStyle)
		$offsetHeight += $fieldHeight
	EndIf
	Return $ret
EndFunc   ;==>_makeField

; Draw PNG image
Func MY_WM_PAINT($hWnd, $Msg, $wParam, $lParam)
	_WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_UPDATENOW)
	$s = 48
	$x = $rightColumnStart + $rightColumnWidth / 2 - $s / 2
	$y = 10
	If $defBkColor == 0 Then
		$hDC = _WinAPI_GetDC($hGUI)
		$defBkColor = _WinAPI_GetPixel($hDC, $x + $s / 2, $y + $s / 2)
		_WinAPI_ReleaseDC($hGUI, $hDC)
		;$defBkColor = $COLOR_RED
		$defBkColor = BitOR($defBkColor, 0xFF000000)
	EndIf
	$hBrush = _GDIPlus_BrushCreateSolid($defBkColor)
	_GDIPlus_GraphicsFillRect($hGraphic, $x, $y, $s, $s, $hBrush)
	_GDIPlus_BrushDispose($hBrush)
	If $hImage_bg Then
		_GDIPlus_GraphicsDrawImage($hGraphic, $hImage_bg, $x, $y)
	EndIf
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $x, $y)
	_WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_VALIDATE)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_PAINT

Func _renameAPK($prmNewFilenameAPK)
	$result = FileMove($fullPathAPK, $dirAPK & "\" & $prmNewFilenameAPK)
	; if result<> = error
	If $result <> 1 Then MsgBox(0, $String18, $String19)
EndFunc   ;==>_renameAPK

Func _SplitPath($prmFullPath, $prmReturnDir = False)
	$posSlash = StringInStr($prmFullPath, "\", 0, -1)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $posSlash = ' & $posSlash & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	Switch $prmReturnDir
		Case False
			Return StringMid($prmFullPath, $posSlash + 1)
		Case True
			Return StringLeft($prmFullPath, $posSlash - 1)
	EndSwitch
EndFunc   ;==>_SplitPath

Func _checkFileParameter($prmFilename)
	If FileExists($prmFilename) Then
		Return $prmFilename
	Else
		$f_Sel = FileOpenDialog($String20, $Lastfolder, "(*.apk)", 1, "")
		If @error Then Exit
		$Lastfolder = _SplitPath($f_Sel, True)
		IniWrite($Inidir & $IniLastFolderSettings, "Settings", "Lastfolder", $Lastfolder)
		;		IniWrite($Inidir & $IniProgramSettings, "Settings", "Lastfile", $f_sel);
		Return $f_Sel
	EndIf
EndFunc   ;==>_checkFileParameter

Func _OpenNewFile($apk)
	$searchPngCache = False
	$fullPathAPK = _checkFileParameter($apk)
	$dirAPK = _SplitPath($fullPathAPK, True)
	$fileAPK = _SplitPath($fullPathAPK, False)
	$apk_Build = ''

	ProgressOn($String32 & "...", $fileAPK)

	ProgressSet(0, $String04 & '...')

	$tmpArrBadge = _getBadge($fullPathAPK)
	_parseLines($tmpArrBadge)

	ProgressSet(25, $String31 & '...')

	_extractIcon()

	ProgressSet(75, $String29 & '...')

	_getSignature($fullPathAPK)

	If $apk_MinSDKVer <> "" Then $sMinAndroidString = 'Android ' & $apk_MinSDKVer & ' (' & $apk_MinSDKName & ')'
	If $apk_TargetSDKVer <> "" Then $sTgtAndroidString = 'Android ' & $apk_TargetSDKVer & ' (' & $apk_TargetSDKName & ')'

	$sNewFilenameAPK = StringReplace($apk_Label, " ", $FileNameSpace) & $FileNamePrefix & StringReplace($apk_VersionName, " ", $FileNameSpace) & $FileNameSuffix & StringReplace($apk_VersionCode, " ", $FileNameSpace) & ".apk"

	GUICtrlSetData($Input1, $apk_Label)
	GUICtrlSetData($Input2, $apk_VersionName)
	GUICtrlSetData($Input3, $apk_VersionCode & $apk_Build)
	GUICtrlSetData($Input4, $apk_PkgName)
	GUICtrlSetData($Input5, $apk_MinSDK)
	GUICtrlSetData($Input6, $sMinAndroidString)
	GUICtrlSetData($Input7, $apk_TargetSDK)
	GUICtrlSetData($Input8, $sTgtAndroidString)
	GUICtrlSetData($Input9, $apk_Screens)
	GUICtrlSetData($Input10, $apk_Densities)
	GUICtrlSetData($Input13, $apk_ABIs)
	GUICtrlSetData($Edit1, $apk_Permissions)
	GUICtrlSetData($Edit2, $apk_Features)
	GUICtrlSetData($Edit3, $apk_Signature)
	GUICtrlSetData($Input11, $fileAPK)
	GUICtrlSetData($Input12, $sNewFilenameAPK)

	_drawPNG()

	ProgressOff()
	$searchPngCache = False
EndFunc   ;==>_OpenNewFile

Func _getSignature($prmAPK)
	$output = ''
	If $CheckSignature == 1 Then
		$foo = Run('java -jar apksigner.jar verify --v --print-certs ' & '"' & $prmAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		While 1
			$output &= StderrRead($foo)
			If @error Then ExitLoop
		WEnd
		While 1
			$output &= StdoutRead($foo)
			If @error Then ExitLoop
		WEnd
	EndIf
	$apk_Signature = $output
EndFunc   ;==>_getSignature

Func _getBadge($prmAPK)
	Local $foo = Run('aapt.exe d badging ' & '"' & $prmAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $output
	While 1
		$output &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	$arrayLines = _StringExplode($output, @CRLF)
	Return $arrayLines
EndFunc   ;==>_getBadge

Func _parseLines($prmArrayLines)
	For $line In $prmArrayLines
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $line = ' & $line & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		If $line == 'application-debuggable' Then
			$apk_Build = ' ' & $String30
		EndIf

		$arraySplit = _StringExplode($line, ":", 1)
		If UBound($arraySplit) > 1 Then
			$key = $arraySplit[0]
			$value = $arraySplit[1]
		Else
			ContinueLoop
		EndIf

		Switch $key
			Case 'application'
				$tmp_arr = _StringBetween($value, "label='", "'")
				$apk_Label = $tmp_arr[0]
				$tmp_arr = _StringBetween($value, "icon='", "'")
				$apk_IconPath = $tmp_arr[0]
				$apk_IconPathBg = False

			Case 'package'
				$tmp_arr = _StringBetween($value, "name='", "'")
				$apk_PkgName = $tmp_arr[0]
				$tmp_arr = _StringBetween($value, "versionCode='", "'")
				$apk_VersionCode = $tmp_arr[0]
				$tmp_arr = _StringBetween($value, "versionName='", "'")
				$apk_VersionName = $tmp_arr[0]

			Case 'uses-permission'
				$tmp_arr = _StringBetween($value, "'", "'")
				$apk_Permissions &= StringLower(StringReplace($tmp_arr[0], "android.permission.", "") & @CRLF)

			Case 'uses-feature'
				$tmp_arr = _StringBetween($value, "'", "'")
				$apk_Features &= StringLower(StringReplace($tmp_arr[0], "android.hardware.", "") & @CRLF)

			Case 'sdkVersion'
				$tmp_arr = _StringBetween($value, "'", "'")
				$apk_MinSDK = $tmp_arr[0]
				$apk_MinSDKVer = _translateSDKLevel($apk_MinSDK)
				$apk_MinSDKName = _translateSDKLevel($apk_MinSDK, True)

			Case 'targetSdkVersion'
				$tmp_arr = _StringBetween($value, "'", "'")
				$apk_TargetSDK = $tmp_arr[0]
				$apk_TargetSDKVer = _translateSDKLevel($apk_TargetSDK)
				$apk_TargetSDKName = _translateSDKLevel($apk_TargetSDK, True)

			Case 'supports-screens'
				$apk_Screens = StringStripWS(StringReplace($value, "'", ""), 3)

			Case 'densities'
				$apk_Densities = StringStripWS(StringReplace($value, "'", ""), 3)

			Case 'native-code'
				$apk_ABIs = StringStripWS(StringReplace($value, "'", ""), 3)

		EndSwitch
	Next
EndFunc   ;==>_parseLines

Func _searchPng($res)
	$ret = $res

	If Not $searchPngCache Then
		$foo = Run('unzip.exe -l ' & '"' & $fullPathAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		$output = ''
		While 1
			$output &= StdoutRead($foo)
			If @error Then ExitLoop
		WEnd
		$searchPngCache = _StringExplode($output, @CRLF)
	EndIf

	$start = StringLeft($res, 10) ; 'res/mipmap' or 'res/drawab'
	$apk_IconName = _lastPart($res, "/")
	$end = '/' & StringLeft($apk_IconName, StringLen($apk_IconName) - 3) & 'png'
	$bestSize = 0
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _searchPng = ' & $start & '; ' & $end & @CRLF)
	For $line In $searchPngCache
		$check = _StringBetween($line, $start, $end)
		;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $arrayLines = ' & $line & '; ' & $check & @crlf)
		If $check <> 0 Then
			$size = Int(StringStripWS($line, 3))
			;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $arrayLines = ' & $line & '; ' & $check[0] & '; ' & $size & '; ' & $bestSize & @crlf)
			If $size > $bestSize Then
				$bestSize = $size
				$ret = $start & $check[0] & $end

				;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $line = ' & $line & @crlf & $bestSize & ': ' & $apk_IconPath & @crlf)
			EndIf
		EndIf
	Next
	Return $ret
EndFunc   ;==>_searchPng

Func _parseXmlIcon()
	$foo = Run('aapt.exe d xmltree ' & '"' & $fullPathAPK & '" "' & $apk_IconPath & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	$output = ''
	While 1
		$output &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	$arrayLines = _StringExplode($output, @CRLF)

	$fg = 1
	Local $ids[2]
	$ids[0] = 0
	$ids[1] = 0
	For $line In $arrayLines
		Select
			Case StringInStr($line, 'E: background')
				$fg = 0

			Case StringInStr($line, 'E: foreground')
				$fg = 1

			Case StringInStr($line, 'A: android:drawable')
				$ids[$fg] = _lastPart($line, "@")
		EndSelect
	Next
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _parseXmlIcon = ' & $ids[0] & '; ' & $ids[1] & @CRLF)

	ProgressSet(45, $String31 & '...')

	If $ids[0] Or $ids[1] Then
		$foo = Run('aapt.exe d resources ' & '"' & $fullPathAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		$output = ''
		While 1
			$output &= StdoutRead($foo)
			If @error Then ExitLoop
		WEnd
		$arrayLines = _StringExplode($output, @CRLF)

		Local $png[2]
		$png[0] = 0
		$png[1] = 0
		For $line In $arrayLines
			If Not StringInStr($line, 'spec resource ') Then
				ContinueLoop
			EndIf
			For $i = 0 To 1
				If Not $ids[$i] Or $png[$i] Or Not StringInStr($line, $ids[$i]) Then
					ContinueLoop
				EndIf
				$tmp_arr = _StringBetween($line, ":", ":")
				$png[$i] = $tmp_arr[0]
			Next
		Next

		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _parseXmlIcon = ' & $png[0] & '; ' & $png[1] & @CRLF)

		ProgressSet(55, $String31 & '...')

		If $png[0] Then
			$apk_IconPathBg = _searchPng('res/' & $png[0] & '.png')
		EndIf
		If $png[1] Then
			$apk_IconPath = _searchPng('res/' & $png[1] & '.png')
		EndIf

		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _parseXmlIcon = ' & $apk_IconPathBg & '; ' & $apk_IconPath & @CRLF)
	EndIf
EndFunc   ;==>_parseXmlIcon

Func _extractIcon()
	;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _extractIcon = ' & $apk_IconPath & @crlf)
	If StringRight($apk_IconPath, 4) == '.xml' Then
		$apk_IconPath = _searchPng($apk_IconPath)
	EndIf

	ProgressSet(35, $String31 & '...')

	If StringRight($apk_IconPath, 4) == '.xml' Then
		_parseXmlIcon()
	EndIf

	ProgressSet(65, $String31 & '...')

	; extract icon
	DirCreate($tempPath)
	$files = $apk_IconPath
	If $apk_IconPathBg Then
		$files = $files & ' ' & $apk_IconPathBg
	EndIf
	$runCmd = "unzip.exe -o -j " & '"' & $fullPathAPK & '" ' & $files & " -d " & '"' & $tempPath & '"'
	RunWait($runCmd, @ScriptDir, @SW_HIDE)
EndFunc   ;==>_extractIcon

Func _cleanUp()
	If $hImage_bg Then
		_GDIPlus_ImageDispose($hImage_bg)
	EndIf
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()

	DirRemove($tempPath, 1) ; clean own dir
	DirRemove(@TempDir & "\APK-Info", 1) ; clean files from previous runs
EndFunc   ;==>_cleanUp

Func _openPlay()
	$url = $URLPlayStore & $apk_PkgName & '&hl=' & $PlayStoreLanguage
	ShellExecute($url)
EndFunc   ;==>_openPlay

Func _translateSDKLevel($prmSDKLevel, $prmReturnCodeName = False)
	If $prmSDKLevel = "1000" Then
		$sVersion = $String21
		$sCodeName = $String22
	Else
		$sVersion = IniRead($Inidir & $IniProgramSettings, "AndroidName", "SDK" & $prmSDKLevel & "-Version", $String23)
		$sCodeName = IniRead($Inidir & $IniProgramSettings, "AndroidName", "SDK" & $prmSDKLevel & "-CodeName", $String24)
	EndIf
	Switch $prmReturnCodeName
		Case True
			Return $sCodeName
		Case Else
			Return $sVersion
	EndSwitch
EndFunc   ;==>_translateSDKLevel

Func _drawPNG()
	If $hImage_bg Then
		_GDIPlus_ImageDispose($hImage_bg)
	EndIf
	$hImage_bg = 0
	If $apk_IconPathBg Then
		$hImage_bg = _drawImg($apk_IconPathBg)
	EndIf
	If $hImage Then
		_GDIPlus_ImageDispose($hImage)
	EndIf
	$hImage = _drawImg($apk_IconPath)
EndFunc   ;==>_drawPNG

Func _drawImg($path)
	$apk_IconName = _lastPart($path, "/")
	$filename = $tempPath & "\" & $apk_IconName
	$hImage_original = _GDIPlus_ImageLoadFromFile($filename)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $type = ' & VarGetType($hImage_original) & '; ' & $hImage_original & @CRLF & '>Error code: ' & @error & @CRLF)
	If $ShowLog = "1" Then
		IniWrite($Inidir & $IniLogReport, "Icon", "TempFilePath", $tempPath)
		IniWrite($Inidir & $IniLogReport, "Icon", "ApkIconeName", $apk_IconName)
	EndIf
	; resize always the bigger icon to 48x48 pixels
	$hImage_ret = _GDIPlus_ImageResize($hImage_original, 48, 48)
	_GDIPlus_ImageDispose($hImage_original)
	FileDelete($filename) ; no need - try delete
	$type = VarGetType($hImage_ret)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $type = ' & $type & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	Return $hImage_ret
EndFunc   ;==>_drawImg

Func _lastPart($str, $sep)
	$tmp_arr = _StringExplode($str, $sep)
	Return $tmp_arr[UBound($tmp_arr) - 1]
EndFunc   ;==>_lastPart
