@ECHO OFF

ECHO APK-Info shell integration...
ECHO.

REG ADD "HKCR\.apk" /ve /t REG_SZ /d "APK-Info" /f >nul 2>nul
REG ADD "HKCR\APK-Info\DefaultIcon" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\"" /f >nul 2>nul
REG ADD "HKCR\APK-Info\shell\APKInfo" /ve /t REG_SZ /d "APK-Info" /f >nul 2>nul
REG ADD "HKCR\APK-Info\shell\APKInfo\command" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\" \"%%1\"" /f >nul 2>nul
REG ADD "HKCU\SOFTWARE\Classes\.apk" /ve /t REG_SZ /d "APK-Info" /f >nul 2>nul
REG ADD "HKCU\SOFTWARE\Classes\APK-Info\DefaultIcon" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\"" /f >nul 2>nul
REG ADD "HKCU\SOFTWARE\Classes\APK-Info\shell\APKInfo" /ve /t REG_SZ /d "APK-Info" /f >nul 2>nul
REG ADD "HKCU\SOFTWARE\Classes\APK-Info\shell\APKInfo\command" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\" \"%%1\"" /f >nul 2>nul

ECHO APK-Info shell integration completed!
ECHO.
ECHO.
ECHO     **** Press any key to exit ****
pause > NUL
