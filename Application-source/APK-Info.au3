#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_OutFile=..\APK-Info.exe
#AutoIt3Wrapper_icon=APK-Info.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Shows info about Android Package Files (APK)
#AutoIt3Wrapper_Res_Description=APK-Info
#AutoIt3Wrapper_Res_LegalCopyright=zoster
#AutoIt3Wrapper_Res_Fileversion=1.35.0.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(AutoItExecuteAllowed True)

$ProgramVersion = "1.35"
$ProgramReleaseDate = "03.07.2019"
$ProgramName = 'APK-Info'

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
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>
;#include <Date.au3>

Opt("TrayMenuMode", 1)
Opt("TrayIconHide", 1)

$Debug = False
;$Debug = True ; Debug

$ScriptDir = @ScriptDir
If @Compiled == 0 Then $ScriptDir &= '\..'

Global $apk_Label, $apk_Labels, $apk_Icons, $apk_IconPath, $apk_IconPathBg, $apk_PkgName, $apk_Build, $apk_Version, $apk_Support
Global $apk_Permissions, $apk_Features, $hGraphic, $hImage, $hImage_bg, $apk_MinSDK, $apk_MaxSDK, $apk_TargetSDK, $apk_CompileSDK
Global $apk_Screens, $apk_Densities, $apk_ABIs, $apk_Signature, $apk_SignatureName, $apk_Debuggable
Global $apk_Locales, $apk_OpenGLES, $apk_Textures
Global $tempPath = @TempDir & "\APK-Info\" & @AutoItPID
Global $toolsDir = $ScriptDir & '\tools\'
Global $Inidir, $ProgramVersion, $ProgramReleaseDate, $ForceGUILanguage
Global $IniUser
Global $tmpArrBadge, $dirAPK, $fileAPK, $fullPathAPK
Global $sNewFilenameAPK, $searchPngCache, $hashCache
Global $progress = 0
Global $progressMax = 1

Global $nbsp = ChrW(0xA0)

$Inidir = $ScriptDir & "\"

$IniFile = $Inidir & "APK-Info.ini"
$IniUser = $Inidir & "user.ini"

; $aCmdLine[0] = number of parametrs passed to exe file
; $aCmdLine[1] = first parameter (optional) passed to exe file (apk file name)

; https://www.autoitscript.com/autoit3/docs/intro/running.htm
; An alternative to the limitation of $CmdLine[] only being able to return a maximum of 63 parameters.
Local $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)
; Uncomment it to Show all cmdline parameters
;_ArrayDisplay($aCmdLine)

Local $tmp_Filename = ''
If $aCmdLine[0] > 0 Then $tmp_Filename = $aCmdLine[1]

Local $tmp = _StringExplode($tmp_Filename, ':', 2)
If $tmp[0] == 'debug' Then
	$tmp_Filename = $tmp[2]
	$ProgramReleaseDate &= ' Log: ' & _getDebugFile($tmp[1])
ElseIf _readSettings("DebugLog", "0") == '1' Then
	$cmd = @ComSpec & ' /c ""' & $ScriptDir & '\' & @ScriptName & '" "debug:' & @AutoItPID & ':' & $tmp_Filename & '" > "' & _getDebugFile(@AutoItPID) & '""'
	RunWait($cmd, $ScriptDir, @SW_HIDE)
	Exit
EndIf

Func _getDebugFile($pid)
	Return $ScriptDir & '\log,' & $pid & '.txt'
EndFunc   ;==>_getDebugFile

; more info on country code
; https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm

$ForcedGUILanguage = _readSettings("ForcedGUILanguage", "auto")
$OSLanguageCode = @OSLang
If $ForcedGUILanguage == "auto" Then
	$Language_code = IniRead($IniFile, "OSLanguage", @OSLang, "en")
Else
	$Language_code = $ForcedGUILanguage
EndIf

$LocalizeName = _readSettings("LocalizeName", "1")
$CheckSignature = _readSettings("CheckSignature", "1")
$FileNamePattern = _readSettings("FileNamePattern", "%label% %version%.%build%")
$ShowHash = _readSettings("ShowHash", '')
$CustomStore = _readSettings("CustomStore", '')
$SignatureNames = _readSettings("SignatureNames", '')

$TextInfo = _readSettings("TextInfo", '')

$JavaPath = _readSettings("JavaPath", '')

$AdbInit = _readSettings("AdbInit", '')
$AdbKill = _readSettings("AdbKill", '0')
$AdbTimeout = _readSettings("AdbTimeout", '15')

$RestoreGUI = _readSettings("RestoreGUI", '0')

$OldVirusTotal = _readSettings("OldVirusTotal", '0')

$CheckNewVersion = _readSettings("CheckNewVersion", '1')

$ShowLangCode = _readSettings("ShowLangCode", "1")

Local $space = 'space'
$FileNameSpace = _readSettings("FileNameSpace", $space)
If $FileNameSpace == $space Then $FileNameSpace = ' '
$LastFolder = IniRead($IniUser, "State", "LastFolder", @WorkingDir)

Local $LastTop = IniRead($IniUser, "State", "LastTop", 0)
Local $LastLeft = IniRead($IniUser, "State", "LastLeft", 0)
Local $LastWidth = IniRead($IniUser, "State", "LastWidth", 0)
Local $LastHeight = IniRead($IniUser, "State", "LastHeight", 0)

Local $LangSection = "Strings-" & $Language_code

$strLabel = IniRead($IniFile, $LangSection, "Application", "Application")
$strVersion = IniRead($IniFile, $LangSection, "Version", "Version")
$strBuild = IniRead($IniFile, $LangSection, "Build", "Build")
$strPkg = IniRead($IniFile, $LangSection, "Package", "Package")
$strScreens = IniRead($IniFile, $LangSection, "ScreenSizes", "Screen Sizes")
$strDensities = IniRead($IniFile, $LangSection, "Densities", "Densities")
$strPermissions = IniRead($IniFile, $LangSection, "Permissions", "Permissions")
$strFeatures = IniRead($IniFile, $LangSection, "Features", "Features")
$strFilename = IniRead($IniFile, $LangSection, "CurrentName", "Current Name")
$strNewFilename = IniRead($IniFile, $LangSection, "NewName", "New Name")
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
$strABIs = IniRead($IniFile, $LangSection, "ABIs", "ABIs")
$strSignature = IniRead($IniFile, $LangSection, "Signature", "Signature")
$strIcon = IniRead($IniFile, $LangSection, "Icon", "Icon")
$strLoading = IniRead($IniFile, $LangSection, "Loading", "Loading")
$strTextures = IniRead($IniFile, $LangSection, "Textures", "Textures")
$strHash = IniRead($IniFile, $LangSection, "Hash", "Hash")
$strInstall = IniRead($IniFile, $LangSection, "Install", "Install")
$strUninstall = IniRead($IniFile, $LangSection, "Uninstall", "Uninstall")
$strLocales = IniRead($IniFile, $LangSection, "Locales", "Locales")
$strClose = IniRead($IniFile, $LangSection, "Close", "Close")
$strNoAdbDevices = IniRead($IniFile, $LangSection, "NoAdbDevicesFound", "No ADB devices found.")
$strMinMaxSDK = IniRead($IniFile, $LangSection, "MinMaxSDK", "Min. / Max. SDK")
$strMaxSDK = IniRead($IniFile, $LangSection, "MaxSDK", "Max. SDK")
$strTargetCompileSDK = IniRead($IniFile, $LangSection, "TargetCompileSDK", "Target / Compile SDK")
$strCompileSDK = IniRead($IniFile, $LangSection, "CompileSDK", "Compile SDK")
$strLanguage = IniRead($IniFile, $LangSection, "Language", "Language")
$strSupport = IniRead($IniFile, $LangSection, "Support", "Support")
$strDebuggable = IniRead($IniFile, $LangSection, "Debuggable", "Debuggable")
$strLabelInLocales = IniRead($IniFile, $LangSection, "LabelInLocales", "Application name in different locales")
$strNewVersionIsAvailable = IniRead($IniFile, $LangSection, "NewVersionIsAvailable", "A new version is available")
$strTextInformation = IniRead($IniFile, $LangSection, "TextInformation", "Text information")
$strLoadSignature = IniRead($IniFile, $LangSection, "LoadSignature", "Load signature")
$strStart = IniRead($IniFile, $LangSection, "Start", "Start")
$strExceededTimeout = IniRead($IniFile, $LangSection, "ExceededTimeout", "Exceeded timeout response from the command")
$strCheckUpdate = IniRead($IniFile, $LangSection, "CheckUpdate", "Check update")
$strYes = IniRead($IniFile, $LangSection, "Yes", "Yes")
$strNo = IniRead($IniFile, $LangSection, "No", "No")
$strNotFound = IniRead($IniFile, $LangSection, "NotFound", "Not found")
$strNoUpdatesFound = IniRead($IniFile, $LangSection, "NoUpdatesFound", "No updates found")
$strNeedJava = IniRead($IniFile, $LangSection, "NeedJava", 'Need Java 1.8 or higher.')

$strUses = IniRead($IniFile, $LangSection, "Uses", "uses")
$strImplied = IniRead($IniFile, $LangSection, "Implied", "implied")
$strNotRequired = IniRead($IniFile, $LangSection, "NotRequired", "not required")
$strOthers = IniRead($IniFile, $LangSection, "Others", "others")

$strWinCode = 'WinCode'
$strOpenGLES = 'OpenGL ES '
$strTV = 'Android TV'
$strWatch = 'Wear OS'
$strAuto = 'Android Auto'
$strAndroid = 'Android'
$strVirusTotal = 'VirusTotal'
$strAdb = 'ADB'

$urlUpdate = 'https://github.com/Enyby/APK-Info/releases/latest'

$URLPlayStore = IniRead($IniFile, $LangSection, "URLPlaystore", "https://play.google.com/store/apps/details?id=")

$playStoreUrl = "https://play.google.com/store/apps/details?hl=en&id="
$apkPureUrl = "https://apkpure.com/apk-info/"
$strApkPure = "APKPure"

$PlayStoreLanguage = IniRead($IniFile, $LangSection, "PlayStoreLanguage", $Language_code)

Dim $sMinAndroidString, $sTgtAndroidString

Global $iconProgress = 5

;================== GUI ===========================

ProgressOn($strLoading & "...", $ProgramName)

$ProgramTitle = $ProgramName & ' ' & $ProgramVersion & " (" & $ProgramReleaseDate & ")"

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
$abiRatio = 1.25
Local $halfWidth = ($inputWidth - 5) / 2
Local $abiWidth = $halfWidth * $abiRatio

$editWidth = $inputWidth + 5 + $rightColumnWidth
$editHeight = 85
$editFlags = BitOR($ES_READONLY, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $WS_VSCROLL, $ES_WANTRETURN)

$offsetHeight = 5

$rightColumnStart = $inputStart + $inputWidth + 5

Local $fields = 11
If $ShowHash <> '' Then $fields += 1

$INFO_LBL = 0
$INFO_BTN = 1

$edits = 3
Global $edtInfo[$edits][2]

$fullWidth = $rightColumnStart + $rightColumnWidth + 5
$fullHeight = $offsetHeight + $fieldHeight * $fields + $bigFieldHeight * $edits

$localesWidth = 60
$localesStart = $fullWidth

$fullWidth += $localesWidth + 5

$btnIconSize = 40
$btnGap = 10
$btnStart = $fullWidth

$fullWidth += $btnIconSize + 5

$hGUI = GUICreate($ProgramTitle, $fullWidth, $fullHeight, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX), $WS_EX_ACCEPTFILES)

GUICtrlCreateLabel("", 0, 0, $fullWidth, $fullHeight, $WS_CLIPSIBLINGS) ; for accept drag & drop
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
;GUICtrlSetBkColor(-1, $COLOR_RED)

$globalStyle = $GUI_DROPACCEPTED + $GUI_ONTOP
$globalInputStyle = $GUI_ONTOP

$iconSize = 72
Local $placeHeight = 5 + $fieldHeight * 3
$lblIcon = GUICtrlCreateLabel('', $rightColumnStart + ($rightColumnWidth - $iconSize) / 2, ($placeHeight - $iconSize) / 2, $iconSize, $iconSize)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)

GUICtrlCreateLabel($strLocales & ':', $localesStart, $offsetHeight, $localesWidth, $inputHeight)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalStyle)
Local $top = $offsetHeight + $inputHeight
$edtLocales = GUICtrlCreateEdit('', $localesStart, $top, $localesWidth, $fullHeight - 5 - $top, $editFlags + $ES_NOHIDESEL)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKBOTTOM + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strLocales)

$btnLabels = GUICtrlCreateButton('...', $inputStart - $inputHeight, $offsetHeight, $inputHeight, $inputHeight)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKLEFT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalStyle)
GUICtrlSetTip(-1, $strLabelInLocales)
$inpLabel = _makeField($strLabel)
Local $buildWidth = 70
$inpBuild = GUICtrlCreateInput('', $inputStart + $inputWidth - $buildWidth, $offsetHeight, $buildWidth, $inputHeight, $inputFlags)
GUICtrlSetResizing(-1, $GUI_DOCKHEIGHT + $GUI_DOCKWIDTH + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strBuild)
$inpVersion = _makeField($strVersion & ' / ' & $strBuild, 0, $inputWidth - 5 - $buildWidth)
$inpPkg = _makeField($strPkg)

_makeLangLabel($strWinCode & ': ' & $OSLanguageCode)
$inpMaxSDK = GUICtrlCreateInput('', $inputStart + $inputWidth - $halfWidth, $offsetHeight, $halfWidth, $inputHeight, $inputFlags)
GUICtrlSetResizing(-1, $GUI_DOCKHEIGHT + $GUI_DOCKWIDTH + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strMaxSDK)
$inpMinSDK = _makeField($strMinMaxSDK, 0, $inputWidth - 5 - $halfWidth)

_makeLangLabel($strLanguage & ': ' & $Language_code)
$inpCompileSDK = GUICtrlCreateInput('', $inputStart + $inputWidth - $halfWidth, $offsetHeight, $halfWidth, $inputHeight, $inputFlags)
GUICtrlSetResizing(-1, $GUI_DOCKHEIGHT + $GUI_DOCKWIDTH + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalInputStyle)
GUICtrlSetTip(-1, $strCompileSDK)
$inpTargetSDK = _makeField($strTargetCompileSDK, 0, $inputWidth - 5 - $halfWidth)

$lblDebug = GUICtrlCreateLabel('', $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight, $SS_CENTER)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalStyle)
$inpScreens = _makeField($strScreens)
$lblOpenGL = GUICtrlCreateLabel('', $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight + $fieldHeight, $SS_CENTER)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalStyle)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$inpDensities = _makeField($strDensities)
$lblSupport = GUICtrlCreateLabel('', $inputStart + $abiWidth + 5, $offsetHeight + $labelTop, $inputWidth - $abiWidth - 5 + 5 + $rightColumnWidth, $inputHeight)
GUICtrlSetResizing(-1, $GUI_DOCKHEIGHT + $GUI_DOCKWIDTH + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
GUICtrlSetState(-1, $globalStyle)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$inpABIs = _makeField($strABIs, 0, $abiWidth)
$inpTextures = _makeField($strTextures, 0, $editWidth)

$edtPermissions = _makeField($strPermissions, 1, 0)
$edtFeatures = _makeField($strFeatures & @CRLF & @CRLF & "+ = " & $strUses & @CRLF & "# = " & $strImplied & @CRLF & "- = " & $strNotRequired & @CRLF & "@ = " & $strOthers, 2, 0, 0, $strFeatures)

$chSignature = GUICtrlCreateCheckbox($strSignature, $labelStart, $offsetHeight + $labelTop, $labelWidth, $inputHeight)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKLEFT)
Local $tmpStyle = $globalStyle
If $CheckSignature == 1 Then
	$tmpStyle = $tmpStyle + $GUI_CHECKED
Else
	$tmpStyle = $tmpStyle + $GUI_UNCHECKED
EndIf
GUICtrlSetState(-1, $tmpStyle)

$btnSignatureLoad = GUICtrlCreateButton('->', $inputStart - $inputHeight, $offsetHeight + $fieldHeight, $inputHeight, $inputHeight)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKLEFT)
GUICtrlSetState(-1, $globalStyle)
GUICtrlSetTip(-1, $strLoadSignature)

$lblSignature = GUICtrlCreateLabel('', $labelStart, $offsetHeight + $labelTop + $fieldHeight, $labelWidth, $editHeight - $fieldHeight)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKLEFT)
GUICtrlSetState(-1, $globalStyle)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

$edtSignature = _makeField(False, 3, 0, 0, $strSignature)

$inpHash = False
If $ShowHash <> '' Then $inpHash = _makeField($strHash, 0, $editWidth, $GUI_DOCKBOTTOM)

$inpName = _makeField($strFilename, 0, $editWidth, $GUI_DOCKBOTTOM)
$inpNewName = _makeField($strNewFilename, 0, $editWidth, $GUI_DOCKBOTTOM)

$offsetHeight = 5

$offsetWidth = $btnGap
$gBtn_Open = _makeButton($strSelectAPK, "open.bmp")
$gBtn_Play = _makeButton($strPlayStore, "play.bmp")
$gBtn_CustomStore = -1000
If $CustomStore <> '' Then
	$store = _StringExplode($CustomStore, '|', 1)
	If UBound($store) == 2 Then
		$gBtn_CustomStore = _makeButton($store[0], "web.bmp")
	Else
		$CustomStore = ''
	EndIf
EndIf
$gBtn_CheckUpdate = _makeButton($strCheckUpdate, "update.bmp")
$gBtn_VirusTotal = _makeButton($strVirusTotal, "virustotal.bmp")
$gBtn_Rename = _makeButton($strRename, "rename.bmp")
$gBtn_Adb = _makeButton($strAdb, "adb.bmp")

$gBtn_TextInfo = -1002
If $TextInfo <> '' Then $gBtn_TextInfo = _makeButton($strTextInformation, "text.bmp")

$newVersion = _checkNewVersion()
$gBtn_Update = -1001
If $newVersion Then $gBtn_Update = _makeButton($strNewVersionIsAvailable & ': ' & $newVersion, "new.bmp")

$gBtn_Exit = _makeButton($strExit, "exit.bmp")

$gSelAll = _initSelAll($hGUI)

_GDIPlus_Startup()
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)

$defBkColor = 0
$bkgColor = 0

_OpenNewFile($tmp_Filename, False)

GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
GUIRegisterMsg($WM_GETMINMAXINFO, "MY_WM_GETMINMAXINFO")

$minSize = WinGetPos($hGUI)

If $RestoreGUI <> '0' And $LastWidth And $LastHeight Then
	Local $repos = True
	If BitAND($RestoreGUI, 0x1) == 0 Then
		$LastLeft = $minSize[0] - ($LastWidth - $minSize[2]) / 2
		If $LastWidth < $minSize[2] Then $repos = False
		$LastTop = $minSize[1] - ($LastHeight - $minSize[3]) / 2
		If $LastHeight < $minSize[3] Then $repos = False
	EndIf

	Local $gap = 200
	Local $desktopWidth = _WinAPI_GetSystemMetrics(78) ; SM_CXVIRTUALSCREEN
	Local $desktopHeight = _WinAPI_GetSystemMetrics(79) ; SM_CYVIRTUALSCREEN

	If $repos Then
		Local $min = -$minSize[2] + $gap
		If $LastLeft < $min Then $LastLeft = $min
		Local $max = $desktopWidth - $gap
		If $LastLeft > $max Then $LastLeft = $max

		Local $min = -$minSize[3] + $gap
		If $LastTop < $min Then $LastTop = $min
		Local $max = $desktopHeight - $gap
		If $LastTop > $max Then $LastTop = $max

		WinMove($hGUI, '', $LastLeft, $LastTop)
	EndIf
	GUISetState(@SW_SHOW, $hGUI)
	If BitAND($RestoreGUI, 0x2) <> 0 Then
		If $LastWidth == 1 Then
			GUISetState(@SW_MAXIMIZE, $hGUI)
		Else
			Local $max = $desktopWidth + $gap
			If $LastLeft > $max Then $LastLeft = $max
			Local $max = $desktopHeight + $gap
			If $LastTop > $max Then $LastTop = $max
			WinMove($hGUI, '', Default, Default, $LastWidth, $LastHeight)
		EndIf
		_OnResize()
	EndIf
Else
	GUISetState(@SW_SHOW, $hGUI)
EndIf

_OnShow()
_saveGUIPos()

ProgressOff()

Local $whGap = '            '

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $gSelAll
			_SelAll()

		Case $gBtn_Play
			ShellExecute($URLPlayStore & $apk_PkgName & '&hl=' & $PlayStoreLanguage)

		Case $gBtn_Update
			ShellExecute($urlUpdate)

		Case $gBtn_CustomStore
			If $CustomStore <> '' Then
				ShellExecute(_ReplacePlaceholders(_StringExplode($CustomStore, '|', 1)[1]))
			EndIf

		Case $gBtn_CheckUpdate
			_checkUpdate()

		Case $gBtn_VirusTotal
			If $OldVirusTotal == '0' Then
				$url = 'https://www.virustotal.com/#/file/%sha256%/detection'
			Else
				If StringInStr(',ca,da,de,en,es,fr,hr,it,hu,nl,nb,pt,pl,sk,uk,vi,tr,ru,sr,bg,he,ka,ar,fa,zh-CN,zh-TW,ja,ko,', ',' & $Language_code & ',') Then
					$lang = $Language_code
				Else
					$lang = 'en'
				EndIf
				$url = 'https://www.virustotal.com/' & $lang & '/file/%sha256%/analysis/'
			EndIf
			ShellExecute(_ReplacePlaceholders($url))

		Case $GUI_EVENT_DROPPED
			_OpenNewFile(@GUI_DragFile)
			MY_WM_PAINT(0, 0, 0, 0)

		Case $gBtn_Open
			_OpenNewFile('')
			MY_WM_PAINT(0, 0, 0, 0)

		Case $btnLabels
			_showText($strLabel & ': ' & $fileAPK, $strLabelInLocales, $apk_Labels)

		Case $gBtn_TextInfo
			_showText($strLabel & ': ' & $fileAPK, $strTextInformation, _ReplacePlaceholders($TextInfo))

		Case $chSignature
			If BitAND(GUICtrlRead($chSignature), $GUI_CHECKED) = $GUI_CHECKED Then
				$CheckSignature = 1
			Else
				$CheckSignature = 0
			EndIf
			IniWrite($IniUser, "Settings", "CheckSignature", $CheckSignature)

		Case $gBtn_Rename
			$pos = WinGetPos($hGUI)
			$width = $minSize[2]
			$height = 130
			$sNewNameInput = InputBox($strRenameAPK, $strNewName, $sNewFilenameAPK, "", $width, $height, $pos[0] + ($pos[2] - $width) / 2, $pos[1] + ($pos[3] - $height) / 2, $hGUI)
			If $sNewNameInput <> "" Then _renameAPK($sNewNameInput)

		Case $gBtn_Adb
			_adb()

		Case $gBtn_Exit, $GUI_EVENT_CLOSE
			_cleanUp()
			Exit

		Case $GUI_EVENT_RESIZED, $GUI_EVENT_RESTORE, $GUI_EVENT_MAXIMIZE
			_OnResize()

		Case $edtInfo[0][$INFO_BTN]
			_showText($strLabel & ': ' & $fileAPK, $strPermissions, $apk_Permissions)

		Case $edtInfo[1][$INFO_BTN]
			_showText($strLabel & ': ' & $fileAPK, $strFeatures & $whGap & "+ = " & $strUses & $whGap & "# = " & $strImplied & $whGap & "- = " & $strNotRequired & $whGap & "@ = " & $strOthers, $apk_Features)

		Case $edtInfo[2][$INFO_BTN]
			_showText($strLabel & ': ' & $fileAPK, $strSignature & $whGap & StringReplace($apk_SignatureName, @CRLF, $whGap), $apk_Signature)

		Case $btnSignatureLoad
			_LoadSignature()
	EndSwitch
WEnd

;==================== End GUI =====================================

Func _initSelAll($hWnd)
	; Create dummy for accelerator key to activate
	$selAll = GUICtrlCreateDummy()

	_setSelAll($selAll, $hWnd)
	Return $selAll
EndFunc   ;==>_initSelAll

Func _setSelAll($dummy, $hWnd)
	; Set accelerators for Ctrl+a
	Dim $AccelKeys[1][2] = [["^a", $dummy]]
	GUISetAccelerators($AccelKeys, $hWnd)
EndFunc   ;==>_setSelAll

Func _SelAll()
	$hWnd = _WinAPI_GetFocus()
	$class = _WinAPI_GetClassName($hWnd)
	If $class == 'Edit' Then _GUICtrlEdit_SetSel($hWnd, 0, -1)
EndFunc   ;==>_SelAll

Func _makeLangLabel($label)
	If $ShowLangCode <> "1" Then Return
	GUICtrlCreateLabel($label, $rightColumnStart, $offsetHeight + $labelTop, $rightColumnWidth, $inputHeight, $SS_CENTER)
	GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
	GUICtrlSetState(-1, $globalStyle)
EndFunc   ;==>_makeLangLabel

Func _makeButton($label, $icon)
	$ret = GUICtrlCreateButton('', $btnStart, $offsetHeight, $btnIconSize, $btnIconSize, $BS_BITMAP)
	GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
	GUICtrlSetTip(-1, $label)
	_GUICtrlButton_SetImage($ret, $ScriptDir & '\icons\' & $icon)
	GUICtrlSetState(-1, $globalStyle)
	$offsetHeight += $btnIconSize + $btnGap
	Return $ret
EndFunc   ;==>_makeButton

Func _makeField($label, $edtNum = 0, $width = 0, $dock = $GUI_DOCKTOP, $btnTip = False)
	If Not $btnTip Then $btnTip = $label
	If $width == 0 Then $width = $inputWidth
	$labelHeight = $inputHeight
	If $edtNum Then $labelHeight = $editHeight
	If $label Then
		$label = GUICtrlCreateLabel($label, $labelStart, $offsetHeight + $labelTop, $labelWidth, $labelHeight)
		GUICtrlSetState(-1, $globalStyle)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	EndIf
	If $edtNum Then
		$num = $edtNum - 1

		GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKLEFT)
		$edtInfo[$num][$INFO_LBL] = $label

		$btn = GUICtrlCreateButton('...', $inputStart - $inputHeight, $offsetHeight + $editHeight - $inputHeight, $inputHeight, $inputHeight)
		GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKLEFT)
		GUICtrlSetState(-1, $globalStyle)
		GUICtrlSetTip(-1, $btnTip)
		$edtInfo[$num][$INFO_BTN] = $btn

		$ret = GUICtrlCreateEdit('', $inputStart, $offsetHeight, $editWidth, $editHeight, $editFlags)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
		GUICtrlSetState(-1, $globalInputStyle)
		$offsetHeight += $bigFieldHeight
	Else
		GUICtrlSetResizing(-1, $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKLEFT + $dock)
		$ret = GUICtrlCreateInput('', $inputStart, $offsetHeight, $width, $inputHeight, $inputFlags)
		GUICtrlSetResizing(-1, $GUI_DOCKHEIGHT + $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $dock)
		GUICtrlSetState(-1, $globalInputStyle)
		$offsetHeight += $fieldHeight
	EndIf
	Return $ret
EndFunc   ;==>_makeField

; Draw PNG image
Func MY_WM_PAINT($hWnd, $Msg, $wParam, $lParam)
	_WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_UPDATENOW)
	$pos = ControlGetPos(GUICtrlGetHandle($lblIcon), "", 0)
	If $defBkColor == 0 Then
		$hDC = _WinAPI_GetDC($hGUI)
		$defBkColor = _WinAPI_GetPixel($hDC, $pos[0] + $pos[2] / 2, $pos[1] + $pos[3] / 2)
		_WinAPI_ReleaseDC($hGUI, $hDC)
		;$defBkColor = $COLOR_RED
		$defBkColor = BitOR($defBkColor, 0xFF000000)
	EndIf
	$color = $defBkColor
	If $bkgColor <> 0 Then $color = $bkgColor
	$hBrush = _GDIPlus_BrushCreateSolid($color)
	_GDIPlus_GraphicsFillRect($hGraphic, $pos[0], $pos[1], $pos[2], $pos[3], $hBrush)
	_GDIPlus_BrushDispose($hBrush)
	If $hImage_bg Then
		_GDIPlus_GraphicsDrawImage($hGraphic, $hImage_bg, $pos[0], $pos[1])
	EndIf
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $pos[0], $pos[1])
	_WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_VALIDATE)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_PAINT

#cs
	typedef struct {
	POINT ptReserved;
	POINT ptMaxSize;
	POINT ptMaxPosition;
	POINT ptMinTrackSize;
	POINT ptMaxTrackSize;
	} MINMAXINFO;
#ce

Func MY_WM_GETMINMAXINFO($hWnd, $Msg, $wParam, $lParam)
	$minmaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
	DllStructSetData($minmaxinfo, 7, $minSize[2]) ; min X
	DllStructSetData($minmaxinfo, 8, $minSize[3]) ; min Y
	Return 0
EndFunc   ;==>MY_WM_GETMINMAXINFO

Func _OnResize()
	; move halfs
	$full = ControlGetPos(GUICtrlGetHandle($inpPkg), "", 0)
	$half = ($full[2] - 5) / 2
	$halfStart = $inputStart + $half + 5

	GUICtrlSetPos($inpMinSDK, Default, Default, $half, Default)
	GUICtrlSetPos($inpMaxSDK, $halfStart, Default, $half, Default)

	GUICtrlSetPos($inpTargetSDK, Default, Default, $half, Default)
	GUICtrlSetPos($inpCompileSDK, $halfStart, Default, $half, Default)

	$half *= $abiRatio
	GUICtrlSetPos($inpABIs, Default, Default, $half, Default)
	GUICtrlSetPos($lblSupport, $inputStart + $half + 5, Default, $full[2] - $half - 5 + 5 + $rightColumnWidth, Default)

	; move edits
	$start = ControlGetPos(GUICtrlGetHandle($inpTextures), "", 0)
	If $inpHash Then
		$end = $inpHash
	Else
		$end = $inpName
	EndIf
	$end = ControlGetPos(GUICtrlGetHandle($end), "", 0)
	$height = ($end[1] - $start[1] - $fieldHeight) / $edits
	$gap = $bigFieldHeight - $editHeight
	$edH = $height - $gap

	$offsetHeight = $start[1] + $fieldHeight

	GUICtrlSetPos($edtPermissions, Default, $offsetHeight, Default, $edH)
	GUICtrlSetPos($edtInfo[0][$INFO_LBL], Default, $offsetHeight + $labelTop)
	GUICtrlSetPos($edtInfo[0][$INFO_BTN], Default, $offsetHeight + $edH - $inputHeight)
	$offsetHeight += $height

	GUICtrlSetPos($edtFeatures, Default, $offsetHeight, Default, $edH)
	GUICtrlSetPos($edtInfo[1][$INFO_LBL], Default, $offsetHeight + $labelTop)
	GUICtrlSetPos($edtInfo[1][$INFO_BTN], Default, $offsetHeight + $edH - $inputHeight)
	$offsetHeight += $height

	GUICtrlSetPos($edtSignature, Default, $offsetHeight, Default, $edH)
	GUICtrlSetPos($chSignature, Default, $offsetHeight + $labelTop)
	GUICtrlSetPos($lblSignature, Default, $offsetHeight + $labelTop + $fieldHeight)
	GUICtrlSetPos($edtInfo[2][$INFO_BTN], Default, $offsetHeight + $edH - $inputHeight)
	$offsetHeight += $height

	_GDIPlus_GraphicsDispose($hGraphic)
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	MY_WM_PAINT(0, 0, 0, 0)

	_saveGUIPos()
EndFunc   ;==>_OnResize

Func _saveGUIPos()
	If $RestoreGUI == '0' Then Return
	$pos = WinGetPos($hGUI)
	If BitAND(WinGetState($hGUI), $WIN_STATE_MAXIMIZED) <> 0 Then $pos[2] = 1
	IniWrite($IniUser, "State", "LastLeft", $pos[0])
	IniWrite($IniUser, "State", "LastTop", $pos[1])
	IniWrite($IniUser, "State", "LastWidth", $pos[2])
	IniWrite($IniUser, "State", "LastHeight", $pos[3])
EndFunc   ;==>_saveGUIPos

Func _renameAPK($prmNewFilenameAPK)
	$result = FileMove($dirAPK & "\" & $fileAPK, $dirAPK & "\" & $prmNewFilenameAPK)
	; if result<> = error
	If $result <> 1 Then
		MsgBox(0, $strError, $strRenameFail)
	Else
		$fileAPK = $prmNewFilenameAPK
		GUICtrlSetData($inpName, $fileAPK)
		_setFullPathAPK($dirAPK & "\" & $fileAPK)
		WinSetTitle($hGUI, "", $fileAPK & ' - ' & $ProgramTitle)
	EndIf
EndFunc   ;==>_renameAPK

Func ByteSuffix($iBytes)
	Local $iIndex = 0, $aArray = [' B', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
	While $iBytes > 1023
		$iIndex += 1
		$iBytes /= 1024
	WEnd
	Return Round($iBytes) & $aArray[$iIndex]
EndFunc   ;==>ByteSuffix

Func _SplitPath($prmFullPath, $prmReturnDir = False)
	$posSlash = StringInStr($prmFullPath, "\", 0, -1)
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
		ProgressOff()
		$f_Sel = FileOpenDialog($strSelectAPK, $LastFolder, "(*.apk)", 1, "")
		If @error Then Exit
		ProgressOn($strLoading & "...", '', $fileAPK)
		$LastFolder = _SplitPath($f_Sel, True)
		IniWrite($IniUser, "State", "LastFolder", $LastFolder)
		Return $f_Sel
	EndIf
EndFunc   ;==>_checkFileParameter

Func _setFullPathAPK($apk)
	If BinaryToString(StringToBinary($apk, $SB_ANSI), $SB_ANSI) <> $apk Then
		$fullPathAPK = FileGetShortName($apk)
	Else
		$fullPathAPK = $apk
	EndIf
EndFunc   ;==>_setFullPathAPK

Func _OpenNewFile($apk, $progress = True)
	$searchPngCache = False
	$hashCache = False
	$apk = _checkFileParameter($apk)
	$dirAPK = _SplitPath($apk, True)
	$fileAPK = _SplitPath($apk, False)

	WinSetTitle($hGUI, "", $fileAPK & ' - ' & $ProgramTitle)

	_setFullPathAPK($apk)

	If $progress Then ProgressOn($strLoading & "...", '', $fileAPK)

	ProgressSet(0, $fileAPK, $strSignature & '...')

	$processSignature = False
	If $CheckSignature == 1 Then $processSignature = _Run('apksigner', '"' & $JavaPath & 'java" -jar "' & $toolsDir & 'apksigner.jar" verify --v --print-certs "' & $fullPathAPK & '"', $STDERR_CHILD + $STDOUT_CHILD)

	ProgressSet(1, $fileAPK, $strPkg & '...')

	$tmp = _getBadge($fullPathAPK)
	_parseLines($tmp)
	$tmp = False ; free mem

	ProgressSet(25, $fileAPK, $strIcon & '...')

	_extractIcon()

	ProgressSet(75, $fileAPK, $strSignature & '...')

	_getSignature($fullPathAPK, $CheckSignature, $processSignature)

	$sNewFilenameAPK = _ReplacePlaceholders($FileNamePattern & '.apk')

	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, "\\", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, "/", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, ":", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, "*", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, "?", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, '"', $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, "<", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, ">", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, "|", $FileNameSpace)
	$sNewFilenameAPK = StringReplace($sNewFilenameAPK, $nbsp, $FileNameSpace)

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
	GUICtrlSetData($lblSupport, $strSupport & ': ' & $apk_Support)
	GUICtrlSetData($lblOpenGL, $apk_OpenGLES)
	GUICtrlSetData($lblDebug, $apk_Debuggable)

	_drawPNG()
	_OnShow()

	If $progress Then ProgressOff()
	$searchPngCache = False
EndFunc   ;==>_OpenNewFile

Func _OnShow()
	$pos = StringInStr($apk_Locales & @CRLF, @CRLF & $Language_code & @CRLF)
	If $pos Then
		_GUICtrlEdit_SetSel($edtLocales, $pos, $pos + StringLen($Language_code) + 1)
		_GUICtrlEdit_Scroll($edtLocales, $SB_SCROLLCARET)
	EndIf
EndFunc   ;==>_OnShow

Func _FixSpaces($str)
	Return StringReplace(StringReplace($str, " ", $FileNameSpace), $nbsp, $FileNameSpace)
EndFunc

Func _ReplacePlaceholders($pattern)
	$out = $pattern
	$p = '%label%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _FixSpaces($apk_Label))
	$p = '%version%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _FixSpaces($apk_Version))
	$p = '%build%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _FixSpaces($apk_Build))
	$p = '%package%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _FixSpaces($apk_PkgName))

	$p = '%min%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_MinSDK)
	$p = '%min_android%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _translateSDKLevel($apk_MinSDK, False))
	$p = '%max%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_MaxSDK)
	$p = '%max_android%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _translateSDKLevel($apk_MaxSDK, False))
	$p = '%target%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_TargetSDK)
	$p = '%target_android%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _translateSDKLevel($apk_TargetSDK, False))
	$p = '%compile%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_CompileSDK)
	$p = '%compile_android%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, _translateSDKLevel($apk_CompileSDK, False))

	$p = '%screens%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, StringReplace($apk_Screens, " ", ','))
	$p = '%dpis%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, StringReplace($apk_Densities, " ", ','))
	$p = '%abis%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, StringReplace($apk_ABIs, " ", ','))
	$p = '%textures%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, StringReplace($apk_Textures, " ", ','))
	$p = '%opengles%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, StringReplace($apk_OpenGLES, $strOpenGLES, ''))
	$p = '%support%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_Support)

	$p = '%file_bytes%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, FileGetSize($dirAPK & "\" & $fileAPK))
	$p = '%file_size%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, ByteSuffix(FileGetSize($dirAPK & "\" & $fileAPK)))

	$p = '%permissions%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_Permissions)
	$p = '%permissions_cnt%'
	If StringInStr($out, $p) Then
		If $apk_Permissions == '' Then
			$cnt = 0
		Else
			$cnt = UBound(_StringExplode($apk_Permissions, @CRLF))
		EndIf
		$out = StringReplace($out, $p, $cnt)
	EndIf

	$p = '%features%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $apk_Features)

	$p = '%lang%'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, $Language_code)

	$p = '\n'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, @CRLF)
	$p = '\t'
	If StringInStr($out, $p) Then $out = StringReplace($out, $p, @TAB)

	If StringInStr($out, '%sig_') Then
		_LoadSignature()
		$out = StringReplace($out, '%sig_sha256%', _StringBetween2($apk_Signature, ' certificate SHA-256 digest: ', @CRLF))
		$out = StringReplace($out, '%sig_sha1%', _StringBetween2($apk_Signature, ' certificate SHA-1 digest: ', @CRLF))
		$out = StringReplace($out, '%sig_md5%', _StringBetween2($apk_Signature, ' certificate MD5 digest: ', @CRLF))

		$dn = _StringBetween2($apk_Signature, ' certificate DN: ', @CRLF)
		$out = StringReplace($out, '%sig_dn%', $dn)

		$dn = ', ' & $dn & ', '
		$out = StringReplace($out, '%sig_email%', _StringBetween2($dn, ', EMAILADDRESS=', ', '))
		$out = StringReplace($out, '%sig_cn%', _StringBetween2($dn, ', CN=', ', '))
		$out = StringReplace($out, '%sig_ou%', _StringBetween2($dn, ', OU=', ', '))
		$out = StringReplace($out, '%sig_o%', _StringBetween2($dn, ', O=', ', '))
		$out = StringReplace($out, '%sig_l%', _StringBetween2($dn, ', L=', ', '))
		$out = StringReplace($out, '%sig_st%', _StringBetween2($dn, ', ST=', ', '))
		$out = StringReplace($out, '%sig_s%', _StringBetween2($dn, ', S=', ', '))
		$out = StringReplace($out, '%sig_c%', _StringBetween2($dn, ', C=', ', '))
	EndIf

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

Func _Run($label, $cmd, $options)
	ProgressSet(0, $label & '...')
	$process = Run(_FixCmd($cmd), $ScriptDir, @SW_HIDE, $options)
	ProgressSet(100, $label & '... OK')
	Return $process
EndFunc   ;==>_Run

Func _FixCmd($cmd)
	If StringInStr(@OSVersion, 'WIN_XP') And StringInStr($cmd, '\tools\adb"') Then
		$cmd = StringReplace($cmd, '\tools\adb"', '\tools\xp\adb"')
	EndIf
	Return $cmd
EndFunc   ;==>_RunWait

Func _RunWait($label, $cmd)
	ProgressSet(0, $label & '...')
	$ret = RunWait(_FixCmd($cmd), $ScriptDir, @SW_HIDE)
	ProgressSet(100, $label & '... OK')
	Return $ret
EndFunc   ;==>_RunWait

Func _LoadSignature()
	If $apk_Signature == '' Then
		ProgressOn($strLoading & "...", $strSignature)
		_getSignature($fullPathAPK, 1)
		ProgressOff()
		GUICtrlSetData($edtSignature, $apk_Signature)
	EndIf
EndFunc   ;==>_LoadSignature

Func _getSignature($prmAPK, $load, $process = False)
	$output = ''
	If $load == 1 Then
		If $process == False Then $process = _Run('apksigner', '"' & $JavaPath & 'java" -jar "' & $toolsDir & 'apksigner.jar" verify --v --print-certs "' & $prmAPK & '"', $STDERR_CHILD + $STDOUT_CHILD)
		$output &= _readAll($process, 'apksigner stdout')
		$output &= _readAll($process, 'apksigner stderr', False)

		If $output == '' Or StringInStr($output, 'java.lang.UnsupportedClassVersionError') Or StringInStr($output, 'Unsupported major.minor version') Then
			$output = $strNeedJava & @CRLF & @CRLF & $output
		EndIf

		GUICtrlSetState($btnSignatureLoad, $GUI_HIDE)
	Else
		GUICtrlSetState($btnSignatureLoad, $GUI_SHOW)
	EndIf
	$apk_Signature = StringStripWS($output, $STR_STRIPLEADING + $STR_STRIPTRAILING)

	_getSignatureName()
	GUICtrlSetData($lblSignature, $apk_SignatureName)
EndFunc   ;==>_getSignature

Func _getSignatureName()
	$apk_SignatureName = ''
	If $apk_Signature == '' Then Return
	ProgressSet(0, 'names...')
	$names = ''
	; Format: 'name=SHA1|'
	$names &= 'testkey=61ed377e85d386a8dfee6b864bd85b0bfaa5af81|'
	$names &= 'shared=5b368cff2da2686996bc95eac190eaa4f5630fe5|'
	$names &= 'platform=27196e386b875e76adf700e7ea84e4c6eee33dfa|'
	$names &= 'media=b79df4a82e90b57ea76525ab7037ab238a42f5d3|'
	$names &= 'frame HTC=1052f733fa71da5c2803611cb336f064a8728b36|'
	$names &= 'frame HUAWEI=059e2480adf8c1c5b3d9ec007645ccfc442a23c5|'
	$names &= 'frame Android=736974b37123fa9007cf05cdc1fb43d915917622|'
	$names &= 'debug=da75ff38332859408959c7b3b5fee41ff82cac2e|'
	$names &= $SignatureNames
	For $item In _StringExplode($names, '|')
		$name = _StringExplode($item, '=', 1)
		If UBound($name) <> 2 Then ContinueLoop
		If StringInStr($apk_Signature, $name[1]) Then $apk_SignatureName &= @CRLF & $name[0]
	Next
	ProgressSet(0, 'names... OK')
EndFunc   ;==>_getSignatureName

Func _getBadge($prmAPK)
	$foo = _Run('badging', '"' & $toolsDir & 'aapt" d --include-meta-data badging ' & '"' & $prmAPK & '"', $STDERR_CHILD + $STDOUT_CHILD)
	$output = StringStripWS(_readAll($foo, 'badging'), $STR_STRIPLEADING + $STR_STRIPTRAILING)
	If $output == '' Then $output = StringStripWS(_readAll($foo, 'badging stderr', False), $STR_STRIPLEADING + $STR_STRIPTRAILING)
	Return $output
EndFunc   ;==>_getBadge

Func _parseLines($lines)
	$prmArrayLines = _StringExplode($lines, @CRLF)

	$apk_Debuggable = ''
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
	$apk_Support = $strAndroid

	$anyDensity = False

	$icons = ''
	$icons2 = ''
	$banners = ''

	$featuresUsed = ''
	$featuresNotRequired = ''
	$featuresImplied = ''
	$featuresOthers = ''
	For $line In $prmArrayLines

		If $line == 'application-debuggable' Then
			$apk_Debuggable = $strDebuggable
		EndIf

		$arraySplit = _StringExplode($line, ":", 1)
		$key = StringStripWS($arraySplit[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
		If UBound($arraySplit) > 1 Then
			$value = $arraySplit[1]
		Else
			$value = ''
		EndIf

		If $key == 'leanback-launchable-activity' And Not StringInStr($apk_Support, $strTV) Then
			$apk_Support &= ', ' & $strTV
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
				If $LocalizeName == '1' Then $apk_Label = _StringBetween2($value, "'", "'")

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

				If $featuresOthers <> '' Then $featuresOthers &= @CRLF
				If $value <> '' Then $line = $key & ': ' & StringStripWS($value, $STR_STRIPLEADING + $STR_STRIPTRAILING)
				$featuresOthers &= '@ ' & StringStripWS($line, $STR_STRIPLEADING + $STR_STRIPTRAILING)

			Case 'package'
				$apk_PkgName = _StringBetween2($value, "name='", "'")
				$apk_Build = _StringBetween2($value, "versionCode='", "'")
				$apk_Version = _StringBetween2($value, "versionName='", "'")
				$apk_CompileSDK = _StringBetween2($value, "compileSdkVersion='", "'")

				$install = _StringBetween2($value, "install-location:'", "'")

				If $install <> '' Then
					If $featuresOthers <> '' Then $featuresOthers &= @CRLF
					$featuresOthers &= '@ ' & "install-location: '" & $install & "'"
				EndIf

			Case 'uses-permission'
				If $apk_Permissions <> '' Then $apk_Permissions &= @CRLF
				$apk_Permissions &= _StringBetween2($value, "'", "'")

			Case 'uses-feature'
				If $featuresUsed <> '' Then $featuresUsed &= @CRLF
				$val = _StringBetween2($value, "'", "'")
				$featuresUsed &= '+ ' & $val

				If $val == 'android.hardware.type.watch' And Not StringInStr($apk_Support, $strWatch) Then
					$apk_Support &= ', ' & $strWatch
				EndIf

			Case 'uses-feature-not-required'
				If $featuresNotRequired <> '' Then $featuresNotRequired &= @CRLF
				$featuresNotRequired &= '- ' & _StringBetween2($value, "'", "'")

			Case 'uses-implied-feature'
				If $featuresImplied <> '' Then $featuresImplied &= @CRLF
				$featuresImplied &= '# ' & _StringBetween2($value, "'", "'") & ' (' & _StringBetween2($value, "reason='", "'") & ')'

			Case 'provides-component', 'main', 'other-activities', 'other-receivers', 'other-services', 'requires-smallest-width', 'compatible-width-limit', 'largest-width-limit', 'uses-configuration', 'application-isGame', 'application-debuggable', 'uses-package', 'original-package', 'package-verifier', 'uses-library', 'uses-library-not-required', 'meta-data'
				If $featuresOthers <> '' Then $featuresOthers &= @CRLF
				If $value <> '' Then $line = $key & ': ' & StringStripWS($value, $STR_STRIPLEADING + $STR_STRIPTRAILING)
				If StringInStr($line, 'android.max_aspect') Then
					$int = _StringBetween2($value, "value='", "'")
					$float = _Lib_IntToFloat($int)
					$line &= ' // ' & Round($float, 3)
				EndIf
				$featuresOthers &= '@ ' & StringStripWS($line, $STR_STRIPLEADING + $STR_STRIPTRAILING)
				If $key == 'meta-data' And _StringBetween2($value, "name='", "'") == 'com.google.android.gms.car.application' And Not StringInStr($apk_Support, $strAuto) Then
					$apk_Support &= ', ' & $strAuto
				EndIf

			Case 'sdkVersion'
				$apk_MinSDK = _StringBetween2($value, "'", "'")

			Case 'maxSdkVersion'
				$apk_MaxSDK = _StringBetween2($value, "'", "'")

			Case 'targetSdkVersion'
				$apk_TargetSDK = _StringBetween2($value, "'", "'")

			Case 'supports-screens'
				$apk_Screens = StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING)

			Case 'supports-any-density'
				If _StringBetween2($value, "'", "'") == 'true' Then $anyDensity = True

			Case 'densities'
				$apk_Densities = StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING)
				$apk_Densities = StringReplace($apk_Densities, "120", "ldpi")
				$apk_Densities = StringReplace($apk_Densities, "160", "mdpi")
				$apk_Densities = StringReplace($apk_Densities, "240", "hdpi")
				$apk_Densities = StringReplace($apk_Densities, "320", "xhdpi")
				$apk_Densities = StringReplace($apk_Densities, "480", "xxhdpi")
				$apk_Densities = StringReplace($apk_Densities, "640", "xxxhdpi")
				$apk_Densities = StringReplace($apk_Densities, "65534", "anydpi")
				$apk_Densities = StringReplace($apk_Densities, "65535", "nodpi")
				$apk_Densities = StringReplace($apk_Densities, "-1", "undefineddpi")
				If $anyDensity And Not StringInStr($apk_Densities, "anydpi") Then $apk_Densities = StringStripWS($apk_Densities & ' anydpi', $STR_STRIPLEADING + $STR_STRIPTRAILING)

			Case 'native-code', 'alt-native-code'
				For $abi In _StringExplode('armeabi,armeabi-v7a,arm64-v8a,x86,x86_64,mips,mips64', ',')
					If Not StringInStr($value, "'" & $abi & "'") Then ContinueLoop
					If $apk_ABIs <> '' Then $apk_ABIs &= ' '
					$apk_ABIs &= $abi
				Next

			Case 'locales'
				$apk_Locales = StringReplace(StringStripWS(StringReplace($value, "'", ""), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES), ' ', @CRLF)

			Case 'uses-gl-es'
				$ver = _StringBetween2($value, "'", "'")
				If StringLen($ver) > 6 And StringLeft($ver, 2) == '0x' Then
					$ver = StringTrimLeft($ver, 2)
					$ver = Dec(StringTrimRight($ver, 4)) & '.' & Dec(StringRight($ver, 4))
				EndIf
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
					Case 'GL_KHR_texture_compression_astc_hdr'
						$val = 'hASTC'
					Case 'GL_KHR_texture_compression_astc_ldr'
						$val = 'lASTC'
					Case 'GL_OES_texture_compression_S3TC'
						$val = 'oS3TC'
					Case 'GL_OES_texture_compression_astc'
						$val = 'ASTC'
				EndSwitch
				$apk_Textures &= $val

				If $featuresOthers <> '' Then $featuresOthers &= @CRLF
				If $value <> '' Then $line = $key & ': ' & StringStripWS($value, $STR_STRIPLEADING + $STR_STRIPTRAILING)
				$featuresOthers &= '@ ' & StringStripWS($line, $STR_STRIPLEADING + $STR_STRIPTRAILING)
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
	If $featuresOthers <> '' Then
		If $apk_Features <> '' Then $apk_Features &= @CRLF
		$apk_Features &= $featuresOthers
	EndIf

	If StringInStr($apk_Permissions, @CRLF) Then
		$tmp = _StringExplode($apk_Permissions, @CRLF)
		_ArraySort($tmp)
		$apk_Permissions = _ArrayToString($tmp, @CRLF)
	EndIf

	;$apk_Permissions = StringReplace(StringLower($apk_Permissions), "android.permission.", "")
	;$apk_Features = StringReplace(StringReplace(StringLower($apk_Features), "android.hardware.", ""), "android.permission.", "")
EndFunc   ;==>_parseLines

Func _searchPng($res)
	$ret = $res

	If Not $searchPngCache Then
		$foo = _Run('list', '"' & $toolsDir & 'unzip" -l ' & '"' & $fullPathAPK & '"', $STDERR_CHILD + $STDOUT_CHILD)
		$output = _readAll($foo, 'list')
		$searchPngCache = _StringExplode($output, @CRLF)
	EndIf

	$start = StringLeft($res, 10) ; 'res/mipmap' or 'res/drawab'
	$apk_IconName = _lastPart($res, "/")
	$end = '/' & StringLeft($apk_IconName, StringLen($apk_IconName) - 3) & 'png'
	$bestSize = 0
	For $line In $searchPngCache
		$check = _StringBetween($line, $start, $end)
		If $check <> 0 Then
			$size = Int(StringStripWS($line, $STR_STRIPLEADING + $STR_STRIPTRAILING))
			If $size > $bestSize Then
				$bestSize = $size
				$ret = $start & $check[0] & $end
			EndIf
		EndIf
	Next
	Return $ret
EndFunc   ;==>_searchPng

Func _parseXmlIcon($icon)
	$foo = _Run('xmltree', '"' & $toolsDir & 'aapt" d xmltree ' & '"' & $fullPathAPK & '" "' & $icon & '"', $STDERR_CHILD + $STDOUT_CHILD)
	$output = _readAll($foo, 'xmltree')
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

	_setProgress(1)

	If $ids[0] Or $ids[1] Then
		$foo = _Run('resources', '"' & $toolsDir & 'aapt" d resources ' & '"' & $fullPathAPK & '"', $STDERR_CHILD + $STDOUT_CHILD)
		$output = _readAll($foo, 'resources')
		$arrayLines = _StringExplode($output, @CRLF)

		Local $png[2]
		$png[0] = 0
		$png[1] = 0
		For $line In $arrayLines
			If StringInStr($line, 'spec resource ') Then
				For $i = 0 To 1
					If Not $ids[$i] Or $png[$i] Or Not StringInStr($line, $ids[$i]) Then ContinueLoop
					$png[$i] = _StringBetween2($line, ":", ":")
				Next
			ElseIf $png[0] And StringLeft($png[0], 6) == 'color/' And StringInStr($line, ':' & $png[0] & ': ') And StringInStr($line, ' d=0x') Then
				$bkgColor = Dec(_StringBetween2($line, " d=0x", " "))
			EndIf
		Next

		If $png[0] Then
			$apk_IconPathBg = _searchPng('res/' & $png[0] & '.png')
		EndIf
		If $png[1] Then
			$apk_IconPath = _searchPng('res/' & $png[1] & '.png')
		EndIf
	EndIf
	_setProgress(1)
EndFunc   ;==>_parseXmlIcon

Func _loadIcon($icon)
	$icon = _searchPng($icon)

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
	$bkgColor = 0
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
	$files = StringStripWS($files, $STR_STRIPLEADING + $STR_STRIPTRAILING)
	If $files <> '' Then
		DirCreate($tempPath)
		_RunWait('icons', '"' & $toolsDir & 'unzip" -o -j ' & '"' & $fullPathAPK & '" ' & $files & " -d " & '"' & $tempPath & '"')
	EndIf
EndFunc   ;==>_extractIcon

Func _cleanUp()
	_saveGUIPos()

	If $hImage_bg Then
		_GDIPlus_ImageDispose($hImage_bg)
	EndIf
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()

	DirRemove($tempPath, 1) ; clean own dir
	DirRemove(@TempDir & "\APK-Info", 1) ; clean files from previous runs
	If $AdbKill == '2' Then _RunWait('kill', '"' & $toolsDir & 'adb" kill-server')
EndFunc   ;==>_cleanUp

Func _translateSDKLevel($sdk, $withNumber = True)
	If $sdk == '' Then Return ''
	If $sdk == "1000" Then
		$name = $strCurDev & '|' & $strCurDevBuild
	Else
		$name = IniRead($IniFile, "AndroidName", "SDK-" & $sdk, '??|' & $strUnknown)
	EndIf
	$tmp = _StringExplode($name, '|')
	$ret = $tmp[0]
	If UBound($tmp) >= 2 Then $ret = $ret & ' (' & $tmp[1] & ')'
	If $withNumber Then $ret = $sdk & ': Android ' & $ret
	Return $ret
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
		DirCreate($tempPath)
		_RunWait('dwebp', '"' & $toolsDir & 'dwebp" "' & $filename & '" -o "' & $tmpFilename & '"')
		If FileExists($tmpFilename) Then
			FileDelete($filename) ; no need - try delete
			$filename = $tmpFilename
		EndIf
	EndIf
	$hImage_original = _GDIPlus_ImageLoadFromFile($filename)
	; resize always the bigger icon to 48x48 pixels
	$hImage_ret = _GDIPlus_ImageResize($hImage_original, $iconSize, $iconSize)
	_GDIPlus_ImageDispose($hImage_original)
	FileDelete($filename) ; no need - try delete
	$type = VarGetType($hImage_ret)
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
	$pos = WinGetPos($hGUI)
	$width = $pos[2] - ($minSize[2] - $fullWidth)
	$height = $pos[3] - ($minSize[3] - $fullHeight)
	$gui = GUICreate($title, $width, $height, $pos[0], $pos[1], BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX))

	$offset = 5
	GUICtrlCreateLabel($message, 5, $offset, $width - 10, $inputHeight)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	$offset += $inputHeight + 5
	$edit = GUICtrlCreateEdit($text, 5, $offset, $width - 10, $height - 35 - $offset, BitOR($ES_READONLY, $ES_AUTOVSCROLL, $WS_VSCROLL, $ES_WANTRETURN))
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	$btnClose = GUICtrlCreateButton($strClose, $width / 4, $height - 30, $width / 2)
	GUICtrlSetResizing(-1, $GUI_DOCKHCENTER + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)

	$selAll = _initSelAll($gui)

	GUISetState(@SW_SHOW, $gui)
	GUISetState(@SW_SHOWNORMAL, $gui)
	GUISetState(@SW_HIDE, $hGUI)

	GUICtrlSetState($edit, $GUI_FOCUS)

	While 1
		$Msg = GUIGetMsg()
		Switch $Msg
			Case $GUI_EVENT_CLOSE, $btnClose
				ExitLoop
			Case $selAll
				_SelAll()
		EndSwitch
	WEnd
	GUISetState(@SW_SHOW, $hGUI)
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	GUISetState(@SW_HIDE, $gui)
	GUIDelete($gui)

	_setSelAll($gSelAll, $hGUI)
EndFunc   ;==>_showText

Func _adbDevice($title)
	ProgressOn($title, 'ADB')
	_RunWait('start', '"' & $toolsDir & 'adb" start-server')

	For $cmd In _StringExplode($AdbInit, '|')
		If $cmd == '' Then ContinueLoop
		_RunWait('init', '"' & $toolsDir & 'adb" ' & $cmd)
	Next

	$foo = _Run('devices', '"' & $toolsDir & 'adb" devices -l', $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
	$output = _readAll($foo, 'devices')

	$output = StringStripWS(StringReplace($output, 'List of devices attached', ''), $STR_STRIPLEADING + $STR_STRIPTRAILING)

	If $output == '' Then
		ProgressOff()
		MsgBox(0, $title, $strNoAdbDevices)
		Return ''
	EndIf

	$arrayLines = _StringExplode($output, @CRLF)
	$cnt = UBound($arrayLines)

	$gap = 5
	$top = $gap

	$lblHeight = 24
	$btnHeight = 30
	$itemHeight = $lblHeight + $gap + $btnHeight + $gap
	$height = $top + $cnt * $itemHeight + $gap

	$cmds = _StringExplode($strInstall & ': %adb% install -r "' & $fullPathAPK & '"; ' & $strInstall & ' + ' & $strStart & ': %adb% install -r "' & $fullPathAPK & '"|%adb% shell "monkey -p ' & $apk_PkgName & ' -c android.intent.category.LAUNCHER 1"; ' & $strStart & ': %adb% shell "monkey -p ' & $apk_PkgName & ' -c android.intent.category.LAUNCHER 1"; ' & $strUninstall & ': %adb% uninstall "' & $apk_PkgName & '"', '; ')

	$ids = ''
	$commands = ''

	$pos = WinGetPos($hGUI)

	$width = $minSize[2]
	$btnWidth = (($width - $gap) / UBound($cmds)) - $gap

	$gui = GUICreate($title, $width, $height, $pos[0] + ($pos[2] - $width) / 2, $pos[1] + ($pos[3] - $height) / 2)

	For $line In $arrayLines
		$device = _StringExplode($line, ' ', 1)[0]

		GUICtrlCreateLabel($line, $gap, $top, $width - $gap * 2)
		$top += $lblHeight + $gap
		$left = $gap
		For $cmd In $cmds
			$cmd = _StringExplode($cmd, ': ', 1)

			$ids &= GUICtrlCreateButton($cmd[0], $left, $top, $btnWidth, $btnHeight) & @CRLF
			$commands &= StringReplace($cmd[1], '%adb%', '"' & $toolsDir & 'adb" -s "' & $device & '"') & @CRLF

			$left += $btnWidth + $gap
		Next
		$top += $btnHeight + $gap
	Next

	$ids = _StringExplode(StringStripWS($ids, $STR_STRIPLEADING + $STR_STRIPTRAILING), @CRLF)
	$cnt = UBound($ids) - 1
	$commands = _StringExplode($commands, @CRLF)

	ProgressOff()

	$device = ''

	GUISetState(@SW_SHOW, $gui)
	GUISetState(@SW_SHOWNORMAL, $gui)
	GUISetState(@SW_HIDE, $hGUI)

	While 1
		$Msg = GUIGetMsg()
		If $Msg == $GUI_EVENT_CLOSE Or $device <> '' Then ExitLoop
		If $Msg > 0 Then
			$str = $Msg & ''
			For $i = 0 To $cnt
				If $ids[$i] <> $str Then ContinueLoop
				$val = GUICtrlRead($Msg)
				$device = $val & '|' & $commands[$i]
				ExitLoop
			Next
		EndIf
	WEnd
	GUISetState(@SW_SHOW, $hGUI)
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	GUISetState(@SW_HIDE, $gui)
	GUIDelete($gui)

	Return $device
EndFunc   ;==>_adbDevice

Func _adb()
	$device = _adbDevice($apk_Label & ' [' & $apk_PkgName & ']')

	If $device == '' Then Return

	$parts = _StringExplode($device, '|')

	$title = $parts[0]
	ProgressOn($title, $strLoading)

	$output = ''
	$timer = TimerInit()
	For $i = 1 To UBound($parts) - 1
		$cmd = $parts[$i]

		$foo = _Run('adb', $cmd, $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
		$timeout = TimerInit()
		$max = $AdbTimeout * 1000
		$last = 0
		While 1
			$time = TimerDiff($timeout)
			If $time > $max Then
				ProgressOff()
				If MsgBox($MB_RETRYCANCEL + $MB_ICONQUESTION, $title, $strExceededTimeout) <> $IDRETRY Then ExitLoop

				$timeout = TimerInit()

				$tmp = _StringExplode(StringStripWS($output, $STR_STRIPLEADING + $STR_STRIPTRAILING), @CRLF)
				ProgressOn($title, $strLoading, $tmp[UBound($tmp) - 1])
			EndIf
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
	Next

	ProgressOff()

	$lines = _StringExplode(StringStripWS($output, $STR_STRIPLEADING + $STR_STRIPTRAILING), @CRLF)
	$output = ''
	For $line In $lines
		If StringInStr($line, '%]') Then ContinueLoop
		If $output <> '' Then $output &= @CRLF
		$output &= $line
	Next

	MsgBox(0, $title, $output)

	If $AdbKill == '1' Then _RunWait('kill', '"' & $toolsDir & 'adb" kill-server')
EndFunc   ;==>_adb

Func _readAll($process, $error, $stdout = True)
	ProgressSet(0, $error & '...')
	$output = ''
	$max = 32 * 1000
	$timeout = TimerInit()
	$timer = TimerInit()
	$last = 0
	While 1
		$time = TimerDiff($timeout)
		If $time > $max Then ExitLoop
		If $stdout Then
			$bin = StdoutRead($process, False, True)
		Else
			$bin = StderrRead($process, False, True)
		EndIf
		If @error Then ExitLoop
		If StringLen($bin) > 0 Then
			$timeout = TimerInit()
			$output &= BinaryToString($bin, $SB_UTF8)
		Else
			$check = Round(TimerDiff($timer) / 500)
			If $check <> $last Then
				$last = $check
				ProgressSet($time * 100 / $max, $error & '... ' & Round($time / 1000))
			EndIf
		EndIf
	WEnd
	ProgressSet(100, $error & '... OK')
	Return $output
EndFunc   ;==>_readAll

Func _readSettings($name, $default)
	$ret = IniRead($IniUser, "Settings", $name, '')
	If $ret == '' Then $ret = IniRead($IniFile, "Settings", $name, $default)
	Return $ret
EndFunc   ;==>_readSettings

Func _checkNewVersion()
	If $CheckNewVersion <> '0' Then
		$tag = _StringExplode(IniRead($IniUser, "State", 'LastVersion', ''), '|', 1)
		$now = 'd' & @MON & '-' & @MDAY ; If $CheckNewVersion == '1' Then
		If $CheckNewVersion == '2' Then $now = 'w' & Round(@YDAY / 7)
		If $CheckNewVersion == '3' Then $now = 'm' & @MON
		If $tag[0] <> $now Or UBound($tag) <> 2 Then
			ProgressSet(10, $urlUpdate)
			$foo = _Run('latest', '"' & $toolsDir & 'curl" -s -k --ssl-no-revoke -D - "' & $urlUpdate & '"', $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
			$output = _readAll($foo, 'latest')
			ProgressSet(90, '')
			$url = _StringBetween2($output, "Location: ", @CRLF)
			$tag = ''
			If StringInStr($url, '/tag/') Then
				$tag = _StringExplode($url, '/tag/', 1)[1]
			EndIf
			$tag = $now & '|' & $tag
			IniWrite($IniUser, "State", 'LastVersion', $tag)
			$tag = _StringExplode($tag, '|', 1)
		EndIf
		If $tag[1] <> $ProgramVersion Then
			Return $tag[1]
		EndIf
	EndIf
	Return False
EndFunc   ;==>_checkNewVersion

Func _checkUpdate()
	ProgressOn($strCheckUpdate, $strPlayStore)
	$out = $strPlayStore & ':' & @CRLF
	$url1 = $playStoreUrl & $apk_PkgName
	$foo = _Run($strPlayStore, '"' & $toolsDir & 'curl" -s -k --ssl-no-revoke -L -A "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:62.0) Gecko/20100101 Firefox/62.0" "' & $url1 & '"', $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
	ProgressSet(20)
	$output = _readAll($foo, $strPlayStore)
	ProgressSet(30)
	;MsgBox(0, $url1, $output)
	$ver = StringRegExp($output, 'Current Version</div><span .*?>([^<]*?)</span></div>', $STR_REGEXPARRAYMATCH)
	If @error == 0 Then
		$ver = StringStripWS($ver[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
		If $ver <> $apk_Version And $ver <> 'Varies with device' Then $ver = $ver & '   <--- ' & $strNewVersionIsAvailable
	Else
		$ver = 'error: ' & @error
		If StringInStr($output, '<title>Not Found</title>') Then $ver = $strNotFound
	EndIf
	$out = $out & $ver & @CRLF

	$out = $out & @CRLF & $strApkPure & ':' & @CRLF
	ProgressSet(50, '', $strApkPure)
	$url2 = $apkPureUrl & $apk_PkgName
	$foo = _Run($strApkPure, '"' & $toolsDir & 'curl" -s -k --ssl-no-revoke -L -A "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:62.0) Gecko/20100101 Firefox/62.0" "' & $url2 & '"', $STDERR_CHILD + $STDOUT_CHILD + $STDERR_MERGED)
	ProgressSet(70)
	$output = _readAll($foo, $strApkPure)
	ProgressSet(80)
	;MsgBox(0, $url2, $output)
	;MsgBox(0, $url2, StringRight($output, 2000))
	$ver = StringRegExp($output, "version_name: '([^']*?)'", $STR_REGEXPARRAYMATCH)
	If @error == 0 Then
		$ver = StringStripWS($ver[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
		If $ver <> $apk_Version Then $ver = $ver & '   <--- ' & $strNewVersionIsAvailable
	Else
		$ver = 'error: ' & @error
		If StringInStr($output, '<title>404</title>') Then $ver = $strNotFound
	EndIf
	$out = $out & $ver & @CRLF

	If Not StringInStr($out, $strNewVersionIsAvailable) Then $out = $strNoUpdatesFound & @CRLF & @CRLF & $out

	$out = $out & @CRLF & $strYes & ' = ' & $strPlayStore & @CRLF & $strNo & ' = ' & $strApkPure

	ProgressOff()
	$ret = MsgBox($MB_ICONINFORMATION + $MB_YESNOCANCEL, $strCheckUpdate, $out)
	If $ret == $IDYES Then ShellExecute($URLPlayStore & $apk_PkgName & '&hl=' & $PlayStoreLanguage)
	If $ret == $IDNO Then ShellExecute($url2)
EndFunc   ;==>_checkUpdate

Func _Lib_IntToFloat($iInt)
	Local $tFloat, $tInt

	$tInt = DllStructCreate("int")
	$tFloat = DllStructCreate("float", DllStructGetPtr($tInt))
	DllStructSetData($tInt, 1, $iInt)
	Return DllStructGetData($tFloat, 1)
EndFunc   ;==>_Lib_IntToFloat
