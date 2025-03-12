@echo off
setlocal

:: Define variables
set URL_INDEX=https://shitstorm.ovh/launchers/index.json
set URL_LAUNCHER=https://shitstorm.ovh/launchers/SHITLAUNCHER.bat
set LOCAL_LAUNCHER=%~dp0SHITLAUNCHER.bat
set TEMP_INDEX=%TEMP%\index.json
set TEMP_LAUNCHER=%TEMP%\SHITLAUNCHER_NEW.bat

:: Download the JSON index from the server
echo Checking remote version...
curl -s -o "%TEMP_INDEX%" "%URL_INDEX%"

:: Extract the "mtime" date from the JSON (PowerShell)
for /f "delims=" %%i in ('powershell -Command "$json = Get-Content -Raw '%TEMP_INDEX%' | ConvertFrom-Json; $json | Where-Object { $_.name -eq 'SHITLAUNCHER.exe' } | Select-Object -ExpandProperty mtime"') do set REMOTE_DATE=%%i

:: Check if the local file exists
if not exist "%LOCAL_LAUNCHER%" goto UPDATE

:: Extract the local file's modification date (GMT format)
for /f "delims=" %%i in ('powershell -Command "(Get-Item '%LOCAL_LAUNCHER%').LastWriteTimeUtc.ToString('R')"') do set LOCAL_DATE=%%i

:: Compare dates
echo Local file: %LOCAL_DATE%
echo Remote file: %REMOTE_DATE%
if "%REMOTE_DATE%" GTR "%LOCAL_DATE%" goto UPDATE

echo No update needed. Local file is up to date.
goto CHECK_BUILD

:UPDATE
echo New version detected! Downloading...
set /p CONFIRM_UPDATE="Do you want to download and update the launcher? (y/n): "
if /i not "%CONFIRM_UPDATE%"=="y" exit
curl -s -o "%TEMP_LAUNCHER%" "%URL_LAUNCHER%"
move /y "%TEMP_LAUNCHER%" "%LOCAL_LAUNCHER%"
echo Update completed.
echo Launching updated launcher...
call "%LOCAL_LAUNCHER%"
exit

:CHECK_BUILD

:: Download the JSON index from nginx
set URL_NGINX_INDEX=https://shitstorm.ovh/builds/index.json
set TEMP_NGINX_INDEX=%TEMP%\nginx_index.json
set LOCAL_BUILD=%~dp0SHITSTORM_install\Standalone\SHITSTORM.exe
set TEMP_ZIP=%TEMP%\SHITSTORM.zip
set URL_BUILD=https://shitstorm.ovh/builds/SHITSTORM.zip

echo Checking remote build version...
curl -s -o "%TEMP_NGINX_INDEX%" "%URL_NGINX_INDEX%"

:: Extract the "mtime" date from the JSON (PowerShell)
for /f "delims=" %%i in ('powershell -Command "$json = Get-Content -Raw '%TEMP_NGINX_INDEX%' | ConvertFrom-Json; $json | Where-Object { $_.name -eq 'SHITSTORM.zip' } | Select-Object -ExpandProperty mtime"') do set REMOTE_BUILD_DATE=%%i

:: Check if the local file exists
if not exist "%LOCAL_BUILD%" goto UPDATE_BUILD

:: Extract the local file's modification date (GMT format)
for /f "delims=" %%i in ('powershell -Command "(Get-Item '%LOCAL_BUILD%').LastWriteTimeUtc.ToString('R')"') do set LOCAL_BUILD_DATE=%%i

:: Compare dates
echo Local build: %LOCAL_BUILD_DATE%
echo Remote build: %REMOTE_BUILD_DATE%
if "%REMOTE_BUILD_DATE%" GTR "%LOCAL_BUILD_DATE%" goto UPDATE_BUILD

echo No build update needed. Local build is up to date.
goto LAUNCH_BUILD

:UPDATE_BUILD
echo New build version detected! Downloading...
set /p CONFIRM_UPDATE_BUILD="Do you want to download and update the build? (y/n): "
if /i not "%CONFIRM_UPDATE_BUILD%"=="y" exit
rmdir /s /q "%~dp0SHITSTORM_install\Standalone"
curl -s -o "%TEMP_ZIP%" "%URL_BUILD%"
tar -xf "%TEMP_ZIP%" -C "%~dp0SHITSTORM_install\Standalone"
echo Build update completed.

:LAUNCH_BUILD
:: Launch the updated build
echo Launching build...
call "%LOCAL_BUILD%"
exit
