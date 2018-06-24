#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_OutFile=..\APK-Info.exe
#AutoIt3Wrapper_icon=APK-Info.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Shows info about Android Package Files (APK)
#AutoIt3Wrapper_Res_Description=APK-Info
#AutoIt3Wrapper_Res_LegalCopyright=zoster
#AutoIt3Wrapper_Res_Fileversion=1.22.0.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(AutoItExecuteAllowed True)

$ProgramVersion = "1.22"
$ProgramReleaseDate = "23.06.2018"

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
#include <Crypt.au3>
#include <GuiButton.au3>
Opt("TrayMenuMode", 1)
Opt("TrayIconHide", 1)

; Adding the directives below, will cause your program be compiled with the indexing
; of the original lines shown in SciTE:
#AutoIt3Wrapper_Run_Before=ShowOriginalLine.exe %in%
#AutoIt3Wrapper_Run_After=ShowOriginalLine.exe %in%

Global $apk_Label, $apk_Labels, $apk_Icons, $apk_IconPath, $apk_IconPathBg, $apk_PkgName, $apk_Build, $apk_Version, $apk_Devices
Global $apk_Permissions, $apk_Features, $hGraphic, $hImage, $hImage_bg, $apk_MinSDK, $apk_MaxSDK, $apk_TargetSDK, $apk_CompileSDK
Global $apk_Screens, $apk_Densities, $apk_ABIs, $apk_Signature, $apk_SignatureName
Global $apk_Locales, $apk_OpenGLES, $apk_Textures
Global $tempPath = @TempDir & "\APK-Info\" & @AutoItPID
DirCreate($tempPath)
Global $toolsDir = 'tools/'
Global $Inidir, $ProgramVersion, $ProgramReleaseDate, $ForceGUILanguage
Global $IniProgramSettings, $IniLogReport, $IniLastFolderSettings
Global $tmpArrBadge, $tmp_Filename, $dirAPK, $fileAPK, $fullPathAPK, $tmpAPK
Global $sNewFilenameAPK, $searchPngCache, $hashCache
Global $progress = 0
Global $progressMax = 1

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
$IniFile = $Inidir & $IniProgramSettings

; more info on country code
; https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm

$ForcedGUILanguage = IniRead($IniFile, "Settings", "ForcedGUILanguage", "auto")
$OSLanguageCode = @OSLang
If $ForcedGUILanguage = "auto" Then
	$Language_code = IniRead($IniFile, "OSLanguage", @OSLang, "en")
Else
	$Language_code = $ForcedGUILanguage
EndIf

$CheckSignature = IniRead($IniFile, "Settings", "CheckSignature", "1")
$FileNamePattern = IniRead($IniFile, "Settings", "FileNamePattern", "%label% %version%.%build%")
$ShowHash = IniRead($IniFile, "Settings", "ShowHash", '')
$CustomStore = IniRead($IniFile, "Settings", "CustomStore", '')
$SignatureNames = IniRead($IniFile, "Settings", "SignatureNames", '')

$AdbInit = IniRead($IniFile, "Settings", "AdbInit", '')
$AdbKill = IniRead($IniFile, "Settings", "AdbKill", '0')

$ShowLog = IniRead($IniFile, "Settings", "ShowLog", "0")
$ShowLangCode = IniRead($IniFile, "Settings", "ShowLangCode", "1")
; $ShowCmdLine=Iniread($IniFile,"Settings","ShowCmdLine","1");
Local $space = 'space'
$FileNameSpace = IniRead($IniFile, "Settings", "FileNameSpace", $space)
If $FileNameSpace == $space Then $FileNameSpace = ' '
$Lastfolder = IniRead($Inidir & $IniLastFolderSettings, "Settings", "LastFolder", @WorkingDir)

Local $LangSection = "Strings-" & $Language_code

$strLabel = IniRead($IniFile, $LangSection, "Application", "Application")
$strVersion = IniRead($IniFile, $LangSection, "Version", "Version")
$strBuild = IniRead($IniFile, $LangSection, "Build", "Build")
$strPkg = IniRead($IniFile, $LangSection, "Package", "Package")
$strScreens = IniRead($IniFile, $LangSection, "ScreenSize", "Screen Size")
$strResolution = IniRead($IniFile, $LangSection, "Resolution", "Resolution")
$strPermission = IniRead($IniFile, $LangSection, "Permission", "Permission")
$strFeature = IniRead($IniFile, $LangSection, "Feature", "Feature")
$strFilename = IniRead($IniFile, $LangSection, "CurrentName", "Current name")
$strNewFilename = IniRead($IniFile, $LangSection, "NewName", "New name")
$strPlayStore = IniRead($IniFile, $LangSection, "PlayStore", "Play Store")
$strRename = IniRead($IniFile, $LangSection, "RenameFile", "Rename File")
$strExit = IniRead($IniFile, $LangSection, "Exit", "Exit")
$strRenameAPK = IniRead($IniFile, $LangSection, "RenameAPKFile", "Rename APK File")
$strNewName = IniRead($IniFile, $LangSection, "NewAPKFilename", "New APK Filename")
$strError = IniRead($IniFile, $LangSection, "Error", "Error!")
$strRenameFail = IniRead($IniFile, $LangSection, "RenameFail", "APK File could not be renamed.")
$strSelectAPK = IniRead($IniFile, $LangSection, "SelectAPKFile", "Select APK file")
$strCurDev = IniRead($IniFile, $LangSection, "CurDev", "Cur_Dev")
$strCurDevBuild = IniRead($IniFile, $LangSection, "CurDevBuild", "Current Dev. Build")
$strUnknown = IniRead($IniFile, $LangSection, "Unknown", "Unknown")
$strLangCode = IniRead($IniFile, $LangSection, "LangCode", "OS Lang Code")
$strLangName = IniRead($IniFile, $LangSection, "LangName", "Lang Name")
$strABIs = IniRead($IniFile, $LangSection, "ABIs", "ABIs")
$strSignature = IniRead($IniFile, $LangSection, "Signature", "Signature")
$strDebug = IniRead($IniFile, $LangSection, "Debug", "Debug")
$strIcon = IniRead($IniFile, $LangSection, "Icon", "Icon")
$strLoading = IniRead($IniFile, $LangSection, "Loading", "Loading")
$strTextures = IniRead($IniFile, $LangSection, "Textures", "Textures")
$strTV = IniRead($IniFile, $LangSection, "TV", "TV")
$strWatch = IniRead($IniFile, $LangSection, "Watch", "Watch")
$strAuto = IniRead($IniFile, $LangSection, "Auto", "Auto")
$strHash = IniRead($IniFile, $LangSection, "Hash", "Hash")
$strInstall = IniRead($IniFile, $LangSection, "Install", "Install")
$strUninstall = IniRead($IniFile, $LangSection, "Uninstall", "Uninstall")
$strLocales = IniRead($IniFile, $LangSection, "Locales", "Locales")
$strClose = IniRead($IniFile, $LangSection, "Close", "Close")
$strNoAdbDevices = IniRead($IniFile, $LangSection, "NoAdbDevicesFound", "No ADB devices found.")
$strMinMaxSDK = IniRead($IniFile, $LangSection, "MinMaxSDK", "Min. / Max. SDK")
$strMaxSDK = IniRead($IniFile, $LangSection, "MaxSDK", "Max. SDK")
$strTargetCompileSDK = IniRead($IniFile, $LangSection, "TargetComipleSDK", "Target / Compile SDK")
$strCompileSDK = IniRead($IniFile, $LangSection, "ComipleSDK", "Compile SDK")

$strUses = IniRead($IniFile, $LangSection, "Uses", "uses")
$strImplied = IniRead($IniFile, $LangSection, "Implied", "implied")
$strNotRequired = IniRead($IniFile, $LangSection, "NotRequired", "not required")

$strOpenGLES = 'OpenGL ES '

$URLPlayStore = IniRead($IniFile, $LangSection, "URLPlaystore", "https://play.google.com/store/apps/details?id=")

$PlayStoreLanguage = IniRead($IniFile, $LangSection, "PlayStoreLanguage", $Language_code)

Dim $sMinAndroidString, $sTgtAndroidString

Global $apk_Debug = ''
Global $iconProgress = 5

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

$rightColumnWidth = 100

$fieldHeight = 24
$bigFieldHeight = 89

$labelStart = 5
$labelWidth = 126
$labelTop = 3

$inputStart = $labelStart + $labelWidth + 5
$inputWidth = 445
$inputHeight = 20
$inputFlags = BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY)

$editWidth = $inputWidth + 5 + $rightColumnWidth
$editHeight = 85
$editFlags = BitOR($ES_READONLY, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $WS_VSCROLL, $ES_WANTRETURN)

$offsetHeight = 5

$rightColumnStart = $inputStart + $inputWidth + 5

Local $fields = 11
If $ShowHash <> '' Then $fields += 1

$fullWidth = $rightColumnStart + $rightColumnWidth + 5
$fullHeight = $offsetHeight + $fieldHeight * $fields + $bigFieldHeight * 3

$localesWidth = 60
$localesStart = $fullWidth

$fullWidth += $localesWidth + 5

$btnIconSize = 40
$btnGap = 10
$btnStart = $fullWidth

$fullWidth += $btnIconSize + 5

$hGUI = GUICreate($ProgramTitle, $fullWidth, $fullHeight, -1, -1, -1, $WS_EX_ACCEPTFILES)

GUICtrlCreateLabel("", 0, 0, $fullWidth, $fullHeight, $WS_CLIPSIBLINGS) ; for accept drag & drop
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
;GUICtrlSetBkColor(-1, $COLOR_RED)

$globalStyle = $GUI_DROPACCEPTED + $GUI_ONTOP
$globalInputStyle = $GUI_ONTOP

$edtLocales = GUICtrlCreateEdit('', $localesStart, $offsetHeight, $localesWidth, $fullHeight - 5 - $offsetHeight, $editFlags)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strLocales)

$btnLabels = GUICtrlCreateButton('...', $rightColumnStart - 5, $offsetHeight, $inputHeight, $inputHeight)
GUICtrlSetState(-1, $globalStyle)
$inpLabel = _makeField($strLabel, False, 0)
Local $buildWidth = 65
$inpBuild = GUICtrlCreateInput('', $inputStart + $inputWidth - $buildWidth, $offsetHeight, $buildWidth, $inputHeight, $inputFlags)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strBuild)
$inpVersion = _makeField($strVersion & ' / ' & $strBuild, False, $inputWidth - 5 - $buildWidth)
_makeLangLabel($strLangCode)
$inpPkg = _makeField($strPkg, False, 0)

_makeLangLabel($OSLanguageCode)
Local $maxWidth = 220
$inpMaxSDK = GUICtrlCreateInput('', $inputStart + $inputWidth - $maxWidth, $offsetHeight, $maxWidth, $inputHeight, $inputFlags)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strMaxSDK)
$inpMinSDK = _makeField($strMinMaxSDK, False, $inputWidth - 5 - $maxWidth)

_makeLangLabel($strLangName & ': ' & $Language_code)
$inpCompileSDK = GUICtrlCreateInput('', $inputStart + $inputWidth - $maxWidth, $offsetHeight, $maxWidth, $inputHeight, $inputFlags)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strCompileSDK)
$inpTargetSDK = _makeField($strTargetCompileSDK, False, $inputWidth - 5 - $maxWidth)

$lblDevices = GUICtrlCreateLabel('', $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight, $SS_CENTER)
GUICtrlSetState(-1, $globalStyle)
$inpScreens = _makeField($strScreens, False, 0)
$lblDebug = GUICtrlCreateLabel('', $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight, $SS_CENTER)
GUICtrlSetState(-1, $globalStyle)
$inpDensities = _makeField($strResolution, False, 0)
$lblOpenGL = GUICtrlCreateLabel('', $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight, $SS_CENTER)
GUICtrlSetState(-1, $globalStyle)
$inpABIs = _makeField($strABIs, False, 0)
$inpTextures = _makeField($strTextures, False, $editWidth)

$edtPermissions = _makeField($strPermission, True, 0)
$edtFeatures = _makeField($strFeature & @CRLF & @CRLF & "+ = " & $strUses & @CRLF & "# = " & $strImplied & @CRLF & "- = " & $strNotRequired, True, 0)

$chSignature = GUICtrlCreateCheckbox($strSignature, $labelStart, $offsetHeight + $labelTop, $labelWidth, $inputHeight)
Local $tmpStyle = $globalStyle
If $CheckSignature == 1 Then
	$tmpStyle = $tmpStyle + $GUI_CHECKED
Else
	$tmpStyle = $tmpStyle + $GUI_UNCHECKED
EndIf
GUICtrlSetState(-1, $tmpStyle)

$lblSignature = GUICtrlCreateLabel('', $labelStart, $offsetHeight + $labelTop + $fieldHeight, $labelWidth, $editHeight - $fieldHeight)
GUICtrlSetState(-1, $globalStyle)

$edtSignature = _makeField(False, True, 0)

$inpHash = False
If $ShowHash <> '' Then $inpHash = _makeField($strHash, False, $editWidth)

$inpName = _makeField($strFilename, False, $editWidth)
$inpNewName = _makeField($strNewFilename, False, $editWidth)

$offsetHeight = 5

$offsetWidth = $btnGap
$gBtn_Play = _makeButton($strPlayStore, "play.bmp")
$gBtn_CustomStore = -1000
If $CustomStore <> '' Then
	$store = _StringExplode($CustomStore, '|', 2)
	If UBound($store) == 2 Then
		$gBtn_CustomStore = _makeButton($store[0], "web.bmp")
	Else
		$CustomStore = ''
	EndIf
EndIf
$gBtn_Rename = _makeButton($strRename, "rename.bmp")
$gBtn_Install = _makeButton($strInstall, "install.bmp")
$gBtn_Uninstall = _makeButton($strUninstall, "delete.bmp")
$gBtn_Exit = _makeButton($strExit, "exit.bmp")

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

GUISetState(@SW_SHOW, $hGUI)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $gBtn_Play
			ShellExecute($URLPlayStore & $apk_PkgName & '&hl=' & $PlayStoreLanguage)

		Case $gBtn_CustomStore
			If $CustomStore <> '' Then
				ShellExecute(StringReplace(StringReplace(_StringExplode($CustomStore, '|', 2)[1], '%package%', $apk_PkgName), '%lang%', $Language_code))
			EndIf

		Case $GUI_EVENT_DROPPED
			_OpenNewFile(@GUI_DragFile)
			MY_WM_PAINT(0, 0, 0, 0)

		Case $btnLabels
			_showText($strLabel & ': ' & $fileAPK, '', $apk_Labels)

		Case $chSignature
			If BitAND(GUICtrlRead($chSignature), $GUI_CHECKED) = $GUI_CHECKED Then
				$CheckSignature = 1
			Else
				$CheckSignature = 0
			EndIf
			IniWrite($IniFile, "Settings", "CheckSignature", $CheckSignature)

		Case $gBtn_Rename
			$sNewNameInput = InputBox($strRenameAPK, $strNewName, $sNewFilenameAPK, "", 300, 130)
			If $ShowLog = "1" Then
				IniWrite($Inidir & $IniLogReport, "NewFile", "NewFilenameAPK", $sNewFilenameAPK)
				IniWrite($Inidir & $IniLogReport, "NewFile", "NewNameInput", $sNewNameInput)
			EndIf
			If $sNewNameInput <> "" Then _renameAPK($sNewNameInput)

		Case $gBtn_Install, $gBtn_Uninstall
			_adb($nMsg == $gBtn_Install)

		Case $gBtn_Exit, $GUI_EVENT_CLOSE
			_cleanUp()
			Exit
	EndSwitch
WEnd

;==================== End GUI =====================================

Func _makeLangLabel($label)
	If $ShowLangCode <> "1" Then Return
	GUICtrlCreateLabel($label, $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight, $SS_CENTER)
	GUICtrlSetState(-1, $globalStyle)
EndFunc   ;==>_makeLangLabel

Func _makeButton($label, $icon)
	$ret = GUICtrlCreateButton('', $btnStart, $offsetHeight, $btnIconSize, $btnIconSize, $BS_BITMAP)
	GUICtrlSetTip(-1, $label)
	_GUICtrlButton_SetImage($ret, @ScriptDir & '\icons\' & $icon)
	GUICtrlSetState(-1, $globalStyle)
	$offsetHeight += $btnIconSize + $btnGap
	Return $ret
EndFunc   ;==>_makeButton

Func _makeField($label, $isEdit, $width)
	If $width == 0 Then $width = $inputWidth
	$labelHeight = $inputHeight
	If $isEdit Then $labelHeight = $editHeight
	If $label Then
		GUICtrlCreateLabel($label, $labelStart, $offsetHeight + $labelTop, $labelWidth, $labelHeight)
		GUICtrlSetState(-1, $globalStyle)
	EndIf
	If $isEdit Then
		$ret = GUICtrlCreateEdit('', $inputStart, $offsetHeight, $editWidth, $editHeight, $editFlags)
		GUICtrlSetState(-1, $globalInputStyle)
		$offsetHeight += $bigFieldHeight
	Else
		$ret = GUICtrlCreateInput('', $inputStart, $offsetHeight, $width, $inputHeight, $inputFlags)
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
	$y = 7
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
	$result = FileMove($dirAPK & "\" & $fileAPK, $dirAPK & "\" & $prmNewFilenameAPK)
	; if result<> = error
	If $result <> 1 Then
		MsgBox(0, $strError, $strRenameFail)
	Else
		$fileAPK = $prmNewFilenameAPK
		GUICtrlSetData($inpName, $fileAPK)
	EndIf
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
		$f_Sel = FileOpenDialog($strSelectAPK, $Lastfolder, "(*.apk)", 1, "")
		If @error Then Exit
		$Lastfolder = _SplitPath($f_Sel, True)
		IniWrite($Inidir & $IniLastFolderSettings, "Settings", "Lastfolder", $Lastfolder)
		;		IniWrite($IniFile, "Settings", "Lastfile", $f_sel);
		Return $f_Sel
	EndIf
EndFunc   ;==>_checkFileParameter

Func _OpenNewFile($apk)
	$searchPngCache = False
	$hashCache = False
	$fullPathAPK = _checkFileParameter($apk)
	$dirAPK = _SplitPath($fullPathAPK, True)
	$fileAPK = _SplitPath($fullPathAPK, False)

	$tmpAPK = False
	If BinaryToString(StringToBinary($fullPathAPK, $SB_ANSI), $SB_ANSI) <> $fullPathAPK Then
		$tmpAPK = $tempPath & 'base.apk'
		If FileCopy($fullPathAPK, $tmpAPK, $FC_CREATEPATH + $FC_OVERWRITE) == 1 And FileExists($tmpAPK) Then
			FileSetAttrib($tmpAPK, "-RASH")
			$fullPathAPK = $tmpAPK
		EndIf
	EndIf

	ProgressOn($strLoading & "...", '', $fileAPK)

	ProgressSet(0, $fileAPK, $strPkg & '...')

	$tmpArrBadge = _getBadge($fullPathAPK)
	_parseLines($tmpArrBadge)

	ProgressSet(25, $fileAPK, $strIcon & '...')

	_extractIcon()

	ProgressSet(75, $fileAPK, $strSignature & '...')

	_getSignature($fullPathAPK)

	$sNewFilenameAPK = _ReplacePlaceholders($FileNamePattern & '.apk')
	$hash = _ReplacePlaceholders($ShowHash)

	If $apk_Labels == '' Then
		$labels = $GUI_HIDE
	Else
		$labels = $GUI_SHOW
	EndIf

	GUICtrlSetData($inpLabel, $apk_Label)
	GUICtrlSetState($btnLabels, $labels)
	GUICtrlSetData($inpVersion, $apk_Version)
	GUICtrlSetData($inpBuild, $apk_Build)
	GUICtrlSetData($inpPkg, $apk_PkgName)
	GUICtrlSetData($inpMinSDK, _translateSDKLevel($apk_MinSDK))
	GUICtrlSetData($inpMaxSDK, _translateSDKLevel($apk_MaxSDK))
	GUICtrlSetData($inpTargetSDK, _translateSDKLevel($apk_TargetSDK))
	GUICtrlSetData($inpCompileSDK, _translateSDKLevel($apk_CompileSDK))
	GUICtrlSetData($inpScreens, $apk_Screens)
	GUICtrlSetData($inpDensities, $apk_Densities)
	GUICtrlSetData($inpABIs, $apk_ABIs)
	GUICtrlSetData($inpTextures, $apk_Textures)
	GUICtrlSetData($edtPermissions, $apk_Permissions)
	GUICtrlSetData($edtFeatures, $apk_Features)
	GUICtrlSetData($edtSignature, $apk_Signature)
	GUICtrlSetData($lblSignature, $apk_SignatureName)
	If $ShowHash <> '' Then GUICtrlSetData($inpHash, $hash)
	GUICtrlSetData($inpName, $fileAPK)
	GUICtrlSetData($inpNewName, $sNewFilenameAPK)
	GUICtrlSetData($edtLocales, $apk_Locales)
	GUICtrlSetData($lblOpenGL, $apk_OpenGLES)
	GUICtrlSetData($lblDebug, $apk_Debug)
	GUICtrlSetData($lblDevices, $apk_Devices)

	_drawPNG()

	ProgressOff()
	If $tmpAPK <> False Then FileDelete($tmpAPK)
	$searchPngCache = False
	$hashCache = False
EndFunc   ;==>_OpenNewFile

Func _ReplacePlaceholders($pattern)
	$out = $pattern
	$out = StringReplace($out, '%label%', StringReplace($apk_Label, " ", $FileNameSpace))
	$out = StringReplace($out, '%version%', StringReplace($apk_Version, " ", $FileNameSpace))
	$out = StringReplace($out, '%build%', StringReplace($apk_Build, " ", $FileNameSpace))
	$out = StringReplace($out, '%package%', StringReplace($apk_PkgName, " ", $FileNameSpace))

	$out = StringReplace($out, '%screens%', StringReplace($apk_Screens, " ", ','))
	$out = StringReplace($out, '%dpis%', StringReplace($apk_Densities, " ", ','))
	$out = StringReplace($out, '%abis%', StringReplace($apk_ABIs, " ", ','))
	$out = StringReplace($out, '%textures%', StringReplace($apk_Textures, " ", ','))
	$out = StringReplace($out, '%opengles%', StringReplace($apk_OpenGLES, $strOpenGLES, ''))

	$hashes = 'md2,md4,md5,sha1,sha256,sha384,sha512'
	$names = _StringExplode($hashes, ',')
	$ids = _StringExplode($CALG_MD2 & ',' & $CALG_MD4 & ',' & $CALG_MD5 & ',' & $CALG_SHA1 & ',' & $CALG_SHA_256 & ',' & $CALG_SHA_384 & ',' & $CALG_SHA_512, ',')

	If Not $hashCache Then $hashCache = $ids

	For $i = 0 To UBound($names) - 1
		$pll = '%' & $names[$i] & '%'
		$plu = '%' & StringUpper($names[$i]) & '%'
		If Not StringInStr($out, $pll) And Not StringInStr($out, $plu) Then ContinueLoop
		If $hashCache[$i] == $ids[$i] Then $hashCache[$i] = StringReplace(_Crypt_HashFile($fullPathAPK, $ids[$i]), '0x', '')
		$hash = $hashCache[$i]
		$out = StringReplace($out, $pll, StringLower($hash), 0, 1)
		$out = StringReplace($out, $plu, StringUpper($hash), 0, 1)
	Next

	Return $out
EndFunc   ;==>_ReplacePlaceholders

Func _getSignature($prmAPK)
	$output = ''
	If $CheckSignature == 1 Then
		$foo = Run('java -jar ' & $toolsDir & 'apksigner.jar verify --v --print-certs ' & '"' & $prmAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		While 1
			$bin = StderrRead($foo, False, True)
			If @error Then ExitLoop
			$output &= BinaryToString($bin, $SB_UTF8)
		WEnd
		While 1
			$bin = StdoutRead($foo, False, True)
			If @error Then ExitLoop
			$output &= BinaryToString($bin, $SB_UTF8)
		WEnd
	EndIf
	$apk_Signature = $output

	_getSignatureName()
EndFunc   ;==>_getSignature

Func _getSignatureName()
	$apk_SignatureName = ''
	$names = ''
	; Format: 'name=SHA1|'
	$names &= 'testkey=61ed377e85d386a8dfee6b864bd85b0bfaa5af81|'
	$names &= 'shared=5b368cff2da2686996bc95eac190eaa4f5630fe5|'
	$names &= 'platform=27196e386b875e76adf700e7ea84e4c6eee33dfa|'
	$names &= 'media=b79df4a82e90b57ea76525ab7037ab238a42f5d3|'
	$names &= 'frame HTC=1052f733fa71da5c2803611cb336f064a8728b36|'
	$names &= 'frame HUAWEI=059e2480adf8c1c5b3d9ec007645ccfc442a23c5|'
	$names &= 'frame Android=27196e386b875e76adf700e7ea84e4c6eee33dfa|'
	$names &= 'frame Android=736974b37123fa9007cf05cdc1fb43d915917622|'
	$names &= 'debug=da75ff38332859408959c7b3b5fee41ff82cac2e|'
	$names &= $SignatureNames
	For $item In _StringExplode($names, '|')
		$name = _StringExplode($item, '=')
		If UBound($name) <> 2 Then ContinueLoop
		If StringInStr($apk_Signature, $name[1]) Then $apk_SignatureName &= @CRLF & $name[0]
	Next
EndFunc   ;==>_getSignatureName

Func _getBadge($prmAPK)
	$foo = Run($toolsDir & 'aapt.exe d --include-meta-data badging ' & '"' & $prmAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	$output = ''
	While 1
		$bin = StdoutRead($foo, False, True)
		If @error Then ExitLoop
		$output &= BinaryToString($bin, $SB_UTF8)
	WEnd
	$arrayLines = _StringExplode($output, @CRLF)
	Return $arrayLines
EndFunc   ;==>_getBadge

Func _parseLines($prmArrayLines)
	$apk_Debug = ''
	$apk_Label = ''
	$apk_Labels = ''
	$apk_PkgName = ''
	$apk_Build = ''
	$apk_Version = ''
	$apk_Permissions = ''
	$apk_MinSDK = ''
	$apk_MaxSDK = ''
	$apk_TargetSDK = ''
	$apk_CompileSDK = ''
	$apk_Screens = ''
	$apk_Densities = ''
	$apk_ABIs = ''
	$apk_Locales = ''
	$apk_OpenGLES = $strOpenGLES & '1.0'
	$apk_Textures = ''
	$apk_Devices = ''

	$icons = ''
	$icons2 = ''
	$banners = ''

	$featuresUsed = ''
	$featuresNotRequired = ''
	$featuresImplied = ''
	For $line In $prmArrayLines
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $line = ' & $line & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		If $line == 'application-debuggable' Then
			$apk_Debug = $strDebug
		EndIf

		$arraySplit = _StringExplode($line, ":", 1)
		If UBound($arraySplit) > 1 Then
			$key = StringStripWS($arraySplit[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
			$value = $arraySplit[1]
		Else
			ContinueLoop
		EndIf

		If $key == 'leanback-launchable-activity' And Not StringInStr($apk_Devices, $strTV) Then
			If $apk_Devices <> '' Then $apk_Devices &= ' '
			$apk_Devices &= $strTV
		EndIf

		If StringInStr($key, 'application-icon-') Then
			If $icons2 <> '' Then $icons2 = @CRLF & $icons2
			$icons2 = _StringBetween2($value, "'", "'") & $icons2
			ContinueLoop
		EndIf

		If StringInStr($key, 'application-label') Then
			$add = StringReplace($line, 'application-label-', '')
			$add = StringReplace($add, 'application-label', 'default')
			If StringInStr($apk_Labels, $value) Then
				$apk_Labels = StringReplace($apk_Labels, ':' & $value, ', ' & $add)
			Else
				If $apk_Labels <> '' Then $apk_Labels &= @CRLF
				$apk_Labels &= $add
			EndIf
		EndIf

		Switch $key
			Case 'application-label'
				If $apk_Label == '' Then $apk_Label = _StringBetween2($value, "'", "'")

			Case 'application-label-' & $Language_code
				$apk_Label = _StringBetween2($value, "'", "'")

			Case 'application', 'launchable-activity', 'leanback-launchable-activity'
				If $apk_Label == '' Then $apk_Label = _StringBetween2($value, "label='", "'")
				$icon = _StringBetween2($value, "icon='", "'")
				If $icon <> '' Then
					If $icons <> '' Then $icons &= @CRLF
					$icons &= $icon
				EndIf
				$icon = _StringBetween2($value, "banner='", "'")
				If $icon <> '' Then
					If $banners <> '' Then $banners &= @CRLF
					$banners &= $icon
				EndIf

			Case 'package'
				$apk_PkgName = _StringBetween2($value, "name='", "'")
				$apk_Build = _StringBetween2($value, "versionCode='", "'")
				$apk_Version = _StringBetween2($value, "versionName='", "'")
				$apk_CompileSDK = _StringBetween2($value, "compileSdkVersion='", "'")

			Case 'uses-permission'
				If $apk_Permissions <> '' Then $apk_Permissions &= @CRLF
				$apk_Permissions &= _StringBetween2($value, "'", "'")

			Case 'uses-feature'
				If $featuresUsed <> '' Then $featuresUsed &= @CRLF
				$val = _StringBetween2($value, "'", "'")
				$featuresUsed &= '+ ' & $val

				If $val == 'android.hardware.type.watch' And Not StringInStr($apk_Devices, $strWatch) Then
					If $apk_Devices <> '' Then $apk_Devices &= ' '
					$apk_Devices &= $strWatch
				EndIf

			Case 'uses-feature-not-required'
				If $featuresNotRequired <> '' Then $featuresNotRequired &= @CRLF
				$featuresNotRequired &= '- ' & _StringBetween2($value, "'", "'")

			Case 'uses-implied-feature'
				If $featuresImplied <> '' Then $featuresImplied &= @CRLF
				$featuresImplied &= '# ' & _StringBetween2($value, "'", "'") & ' (' & _StringBetween2($value, "reason='", "'") & ')'

			Case 'sdkVersion'
				$apk_MinSDK = _StringBetween2($value, "'", "'")

			Case 'maxSdkVersion'
				$apk_MaxSDK = _StringBetween2($value, "'", "'")

			Case 'targetSdkVersion'
				$apk_TargetSDK = _StringBetween2($value, "'", "'")

			Case 'supports-screens'
				$apk_Screens = StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING)

			Case 'densities'
				$apk_Densities = StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING)

			Case 'native-code'
				$apk_ABIs = StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING)

			Case 'locales'
				$apk_Locales = StringReplace(StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES), ' ', @CRLF)

			Case 'uses-gl-es'
				$ver = _StringBetween2($value, "'", "'")
				Switch $ver
					Case '0x20000'
						$ver = '2.0'
					Case '0x30000'
						$ver = '3.0'
					Case '0x30001'
						$ver = '3.1'
				EndSwitch
				$apk_OpenGLES = $strOpenGLES & $ver

				If $featuresUsed <> '' Then $featuresUsed &= @CRLF
				$featuresUsed &= '+ ' & $apk_OpenGLES

			Case 'supports-gl-texture'
				If $apk_Textures <> '' Then $apk_Textures &= ' '
				$val = _StringBetween2($value, "'", "'")
				Switch $val
					Case 'GL_OES_compressed_ETC1_RGB8_texture'
						$val = 'ETC1'
					Case 'GL_OES_compressed_paletted_texture'
						$val = 'PAL'
					Case 'GL_AMD_compressed_3DC_texture'
						$val = '3DC'
					Case 'GL_AMD_compressed_ATC_texture'
						$val = 'ATC'
					Case 'GL_ATI_texture_compression_atitc'
						$val = 'ATI'
					Case 'GL_EXT_texture_compression_latc'
						$val = 'LATC'
					Case 'GL_EXT_texture_compression_dxt1'
						$val = 'DXT1'
					Case 'GL_EXT_texture_compression_s3tc'
						$val = 'S3TC'
					Case 'GL_IMG_texture_compression_pvrtc'
						$val = 'PVR'
				EndSwitch
				$apk_Textures &= $val

			Case 'meta-data'
				If _StringBetween2($value, "'", "'") == 'com.google.android.gms.car.application' And Not StringInStr($apk_Devices, $strAuto) Then
					If $apk_Devices <> '' Then $apk_Devices &= ' '
					$apk_Devices &= $strAuto
				EndIf
		EndSwitch
	Next

	If Not StringInStr($apk_Labels, @CRLF) Then $apk_Labels = ''

	$apk_Icons = ''
	Local $src[3]
	$src[0] = $icons
	$src[1] = $banners
	$src[2] = $icons2
	For $list In $src
		$list = StringStripWS($list, $STR_STRIPLEADING + $STR_STRIPTRAILING)
		If $list == '' Then ContinueLoop
		For $icon In _StringExplode($list, @CRLF)
			If $icon == '' Or StringInStr($apk_Icons, $icon) Then ContinueLoop
			If $apk_Icons <> '' Then $apk_Icons &= @CRLF
			$apk_Icons &= $icon
		Next
	Next

	$apk_Features = $featuresUsed
	If $featuresImplied <> '' Then
		If $apk_Features <> '' Then $apk_Features &= @CRLF
		$apk_Features &= $featuresImplied
	EndIf
	If $featuresNotRequired <> '' Then
		If $apk_Features <> '' Then $apk_Features &= @CRLF
		$apk_Features &= $featuresNotRequired
	EndIf

	$apk_Permissions = StringReplace(StringLower($apk_Permissions), "android.permission.", "")
	$apk_Features = StringReplace(StringReplace(StringLower($apk_Features), "android.hardware.", ""), "android.permission.", "")
EndFunc   ;==>_parseLines

Func _searchPng($res)
	$ret = $res

	If Not $searchPngCache Then
		$foo = Run($toolsDir & 'unzip.exe -l ' & '"' & $fullPathAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		$output = ''
		While 1
			$bin = StdoutRead($foo, False, True)
			If @error Then ExitLoop
			$output &= BinaryToString($bin, $SB_UTF8)
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
			$size = Int(StringStripWS($line, $STR_STRIPLEADING + $STR_STRIPTRAILING))
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

Func _parseXmlIcon($icon)
	$foo = Run($toolsDir & 'aapt.exe d xmltree ' & '"' & $fullPathAPK & '" "' & $icon & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	$output = ''
	While 1
		$bin = StdoutRead($foo, False, True)
		If @error Then ExitLoop
		$output &= BinaryToString($bin, $SB_UTF8)
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

			Case StringInStr($line, 'A: android:src')
				$ids[$fg] = _lastPart($line, "@")
		EndSelect
	Next
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _parseXmlIcon = ' & $ids[0] & '; ' & $ids[1] & @CRLF)

	_setProgress(1)

	If $ids[0] Or $ids[1] Then
		$foo = Run($toolsDir & 'aapt.exe d resources ' & '"' & $fullPathAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		$output = ''
		While 1
			$bin = StdoutRead($foo, False, True)
			If @error Then ExitLoop
			$output &= BinaryToString($bin, $SB_UTF8)
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
				$png[$i] = _StringBetween2($line, ":", ":")
			Next
		Next

		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _parseXmlIcon = ' & $png[0] & '; ' & $png[1] & @CRLF)

		If $png[0] Then
			$apk_IconPathBg = _searchPng('res/' & $png[0] & '.png')
		EndIf
		If $png[1] Then
			$apk_IconPath = _searchPng('res/' & $png[1] & '.png')
		EndIf

		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : _parseXmlIcon = ' & $apk_IconPathBg & '; ' & $apk_IconPath & @CRLF)
	EndIf
	_setProgress(1)
EndFunc   ;==>_parseXmlIcon

Func _loadIcon($icon)
	If StringRight($icon, 4) <> '.png' Then
		$icon = _searchPng($icon)
	EndIf

	_setProgress(1)

	Select
		Case StringRight($icon, 4) == '.xml'
			_parseXmlIcon($icon)

		Case Else
			_setProgress(2)
			$apk_IconPath = $icon
	EndSelect

	_setProgress(1)
EndFunc   ;==>_loadIcon

Func _setProgress($inc)
	$progress += $inc
	ProgressSet(25 + 40 * $progress / $progressMax, $fileAPK, $strIcon & '...')
EndFunc   ;==>_setProgress

Func _extractIcon()
	$apk_IconPath = False
	$apk_IconPathBg = False

	$icons = _StringExplode($apk_Icons, @CRLF)
	$progress = 0
	$progressMax = UBound($icons) * 4
	For $icon In $icons
		If $apk_IconPath And StringRight($apk_IconPath, 4) == '.png' Then ExitLoop
		_setProgress(0)

		_loadIcon($icon)
	Next
	ProgressSet(65, $fileAPK, $strIcon & '...')

	; extract icon
	$files = $apk_IconPath
	If $apk_IconPathBg Then
		$files &= ' ' & $apk_IconPathBg
	EndIf
	RunWait($toolsDir & "unzip.exe -o -j " & '"' & $fullPathAPK & '" ' & $files & " -d " & '"' & $tempPath & '"', @ScriptDir, @SW_HIDE)
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
	If $AdbKill == '2' Then RunWait($toolsDir & 'adb.exe kill-server', @ScriptDir, @SW_HIDE)
EndFunc   ;==>_cleanUp

Func _translateSDKLevel($sdk)
	If $sdk == '' Then Return ''
	If $sdk == "1000" Then
		$name = $strCurDev & '|' & $strCurDevBuild
	Else
		$name = IniRead($IniFile, "AndroidName", "SDK-" & $sdk, '??|' & $strUnknown)
	EndIf
	$tmp = _StringExplode($name, '|')
	If UBound($tmp) < 2 Then Return 'INI error: SDK-' & $sdk & ' must contain char "|"'
	Return $sdk & ': Android ' & $tmp[0] & ' (' & $tmp[1] & ')'
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
	If StringRight($filename, 5) == '.webp' Then
		$tmpFilename = StringTrimRight($filename, 5) & '.png'
		RunWait($toolsDir & 'dwebp.exe "' & $filename & '" -o "' & $tmpFilename & '"', @ScriptDir, @SW_HIDE)
		If FileExists($tmpFilename) Then
			FileDelete($filename) ; no need - try delete
			$filename = $tmpFilename
		EndIf
	EndIf
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

Func _StringBetween2($text, $from, $to)
	$var = _StringBetween($text, $from, $to)
	If $var <> 0 Then Return $var[0]
	Return ''
EndFunc   ;==>_StringBetween2

Func _showText($title, $message, $text)
	$height = $fullHeight
	$width = $fullWidth
	$gui = GUICreate($title, $width, $height)

	$offset = 5
	GUICtrlCreateLabel($message, 5, $offset, $width - 10, $inputHeight)
	$offset += $inputHeight + 5
	GUICtrlCreateEdit($text, 5, $offset, $width - 10, $height - 35 - $offset, BitOR($ES_READONLY, $ES_AUTOVSCROLL, $WS_VSCROLL, $ES_WANTRETURN))
	$btnClose = GUICtrlCreateButton($strClose, $width/4, $height - 30, $width/2)

	GUISetState(@SW_SHOW, $gui)
	GUISetState(@SW_RESTORE, $gui)
	GUISetState(@SW_HIDE, $hGUI)

	While 1
		$Msg = GUIGetMsg()
		If $Msg == $GUI_EVENT_CLOSE Or $Msg == $btnClose Then ExitLoop
	WEnd
	GUISetState(@SW_SHOW, $hGUI)
	GUISetState(@SW_RESTORE, $hGUI)
	GUISetState(@SW_HIDE, $gui)
	GUIDelete($gui)
EndFunc

Func _adbDevice($title)
	RunWait($toolsDir & 'adb.exe start-server', @ScriptDir, @SW_HIDE)

	For $cmd In _StringExplode($AdbInit, '|')
		If $cmd == '' Then ContinueLoop
		RunWait($toolsDir & 'adb.exe ' & $cmd, @ScriptDir, @SW_HIDE)
	Next

	$foo = Run($toolsDir & 'adb.exe devices -l', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
	$output = ''
	While 1
		$bin = StdoutRead($foo, False, True)
		If @error Then ExitLoop
		$output &= BinaryToString($bin, $SB_UTF8)
	WEnd

	$output = StringStripWS(StringReplace($output, 'List of devices attached', ''), $STR_STRIPLEADING + $STR_STRIPTRAILING)

	If $output == '' Then
		MsgBox(0, $title, $strNoAdbDevices)
		Return ''
	EndIf

	$arrayLines = _StringExplode($output, @CRLF)
	$cnt = UBound($arrayLines)

	$top = 10
	$btnHeight = 40
	$height = $top + $cnt * $btnHeight

	$gui = GUICreate($title, $fullWidth, $height)

	For $line In $arrayLines
		$btn = GUICtrlCreateButton(StringStripWS($line, $STR_STRIPLEADING + $STR_STRIPTRAILING), 10, $top, $fullWidth - 20)
		$top += $btnHeight
	Next

	$device = ''

	GUISetState(@SW_SHOW, $gui)
	GUISetState(@SW_RESTORE, $gui)
	GUISetState(@SW_HIDE, $hGUI)

	While 1
		$Msg = GUIGetMsg()
		If $Msg == $GUI_EVENT_CLOSE Then ExitLoop
		If $Msg > 0 Then
			$val = GUICtrlRead($Msg)
			If $val <> '0' Then
				$device = _StringExplode($val, ' ')[0]
				ExitLoop
			EndIf
		EndIf
	WEnd
	GUISetState(@SW_SHOW, $hGUI)
	GUISetState(@SW_RESTORE, $hGUI)
	GUISetState(@SW_HIDE, $gui)
	GUIDelete($gui)

	Return $device
EndFunc   ;==>_adbDevice

Func _adb($install)
	If $install Then
		$title = $strInstall
	Else
		$title = $strUninstall
	EndIf
	$device = _adbDevice($title & ': ' & $apk_Label & ' [' & $apk_PkgName & ']')

	If $device == '' Then Return

	ProgressOn($title, $strLoading)

	If $install Then
		If $tmpAPK <> False Then
			FileCopy($dirAPK & "\" & $fileAPK, $tmpAPK, $FC_CREATEPATH + $FC_OVERWRITE)
			FileSetAttrib($tmpAPK, "-RASH")
		EndIf

		$cmd = 'adb.exe -s "' & $device & '" install -r "' & $fullPathAPK & '"'
	Else
		$cmd = 'adb.exe -s "' & $device & '" uninstall "' & $apk_PkgName & '"'
	EndIf

	$foo = Run($toolsDir & $cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
	$output = ''
	$timer = TimerInit()
	$timeout = TimerInit()
	$max = 30 * 1000
	$last = 0
	While 1
		$time = TimerDiff($timeout)
		If $time > $max Then ExitLoop
		$bin = StdoutRead($foo, False, True)
		If @error Then ExitLoop
		If StringLen($bin) > 0 Then $timeout = TimerInit()
		$output &= BinaryToString($bin, $SB_UTF8)
		$check = Round(TimerDiff($timer) / 500)
		If $check <> $last Then
			$last = $check
			$tmp = _StringExplode(StringStripWS($output, $STR_STRIPLEADING + $STR_STRIPTRAILING), @CRLF)
			ProgressSet($time * 100 / $max, $tmp[UBound($tmp) - 1])
		EndIf
		If StringInStr($output, 'waiting for device') Then ExitLoop
	WEnd
	ProcessClose($foo)

	ProgressOff()

	$lines = _StringExplode(StringStripWS($output, $STR_STRIPLEADING + $STR_STRIPTRAILING), @CRLF)
	$output = ''
	For $line In $lines
		If StringInStr($line, '%]') Then ContinueLoop
		If $output <> '' Then $output &= @CRLF
		$output &= $line
	Next

	MsgBox(0, $title, $output)

	If $tmpAPK <> False Then FileDelete($tmpAPK)

	If $AdbKill == '1' Then RunWait($toolsDir & 'adb.exe kill-server', @ScriptDir, @SW_HIDE)
EndFunc   ;==>_adb
