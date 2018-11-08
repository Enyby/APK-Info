@ECHO OFF

ECHO APK-Info shell integration...
ECHO.

for %%H in (HKCU) do (
	REG ADD "%%H\SOFTWARE\Classes\.apk" /ve /t REG_SZ /d "APK-Info" /f >nul 2>nul
	REG ADD "%%H\SOFTWARE\Classes\APK-Info\DefaultIcon" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\"" /f >nul 2>nul
	REG ADD "%%H\SOFTWARE\Classes\APK-Info\shell\open" /ve /t REG_SZ /d "APK-Info" /f >nul 2>nul
	REG ADD "%%H\SOFTWARE\Classes\APK-Info\shell\open\command" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\" \"%%1\"" /f >nul 2>nul
	
	REG ADD "%%H\SOFTWARE\Classes\SystemFileAssociations\.apk\Shell\APK-Info\Command" /ve /t REG_SZ /d "\"%cd%\APK-Info.exe\" \"%%1\"" /f >nul 2>nul
)

ECHO APK-Info shell integration completed!
ECHO.
ECHO.
ECHO     **** Press any key to exit ****
pause > NUL
