@echo off
setlocal

:: Define variables
set LAUNCHER_NAME=%~nx0
set LOCAL_LAUNCHER=%~dp0%~nx0

set URL_INDEX_LAUNCHERS=https://shitstorm.ovh/launchers
set URL_LAUNCHER=https://shitstorm.ovh/launchers/%LAUNCHER_NAME%

set TEMP_INDEX_LAUNCHERS=%TEMP%\index_launchers.json
set TEMP_LAUNCHER=%TEMP%\%LAUNCHER_NAME%

:: Download the JSON index from the server
echo Checking remote launcher...
curl -s -L -o "%TEMP_INDEX_LAUNCHERS%" "%URL_INDEX_LAUNCHERS%"
if %errorlevel% neq 0 (
    echo Failed to download JSON index.
    pause
    exit /b %errorlevel%
)

:: Extract the "mtime" date from the JSON (PowerShell)
for /f "delims=" %%i in ('powershell -Command "$json = Get-Content -Raw '%TEMP_INDEX_LAUNCHERS%' | ConvertFrom-Json; $json | Where-Object { $_.name -eq 'SHITLAUNCHER.bat' } | Select-Object -ExpandProperty mtime"') do set REMOTE_DATE=%%i
if %errorlevel% neq 0 (
    echo Failed to extract remote date.
    pause
    exit /b %errorlevel%
)
echo Remote launcher: %REMOTE_DATE%.

:: Check if the local file exists
if not exist "%LOCAL_LAUNCHER%" goto UPDATE_LAUNCHER

:: Extract the local file's modification date (GMT format)
for /f "delims=" %%i in ('powershell -Command "(Get-Item '%LOCAL_LAUNCHER%').LastWriteTimeUtc.ToString('R')"') do set LOCAL_DATE=%%i
if %errorlevel% neq 0 (
    echo Failed to extract local date.
    pause
    exit /b %errorlevel%
)

:: Compare dates
echo Local launcher: %LOCAL_DATE%
if "%REMOTE_DATE%" GTR "%LOCAL_DATE%" goto UPDATE_LAUNCHER

echo No update needed. Local launcher is up to date.
goto CHECK_BUILD

:UPDATE_LAUNCHER
echo New version detected! Downloading...
curl -s -L -o "%TEMP_LAUNCHER%" "%URL_LAUNCHER%"
if %errorlevel% neq 0 (
    echo Failed to download new launcher.
    pause
    exit /b %errorlevel%
)
move /y "%TEMP_LAUNCHER%" "%LOCAL_LAUNCHER%"
if %errorlevel% neq 0 (
    echo Failed to move new launcher.
    pause
    exit /b %errorlevel%
)
echo Update completed.
echo Launching updated launcher...
start "" "%LOCAL_LAUNCHER%"
exit

:CHECK_BUILD

:: Download the JSON index from nginx
set URL_INDEX_BUILDS=https://shitstorm.ovh/builds
set URL_BUILD=https://shitstorm.ovh/builds/SHITSTORM.zip

set TEMP_INDEX_BUILDS=%TEMP%\index_builds.json
set TEMP_ZIP=%TEMP%\SHITSTORM.zip

set LOCAL_INSTALL_DIR=%~dp0SHITSTORM_install
set LOCAL_BUILD_DIR=%LOCAL_INSTALL_DIR%\Standalone
set LOCAL_BUILD_EXE=%LOCAL_BUILD_DIR%\SHITSTORM.exe

:: Check if the local file exists
if not exist "%LOCAL_BUILD_EXE%" goto UPDATE_BUILD

:: Extract the local file's modification date (GMT format)
for /f "delims=" %%i in ('powershell -Command "(Get-Item '%LOCAL_BUILD_DIR%').LastWriteTimeUtc.ToString('R')"') do set LOCAL_BUILD_DATE=%%i
if %errorlevel% neq 0 (
    echo Failed to extract local build date.
    pause
    exit /b %errorlevel%
)
echo Local build: %LOCAL_BUILD_DATE%.

echo Checking remote build... (%URL_INDEX_BUILDS%)
curl -s -L -o "%TEMP_INDEX_BUILDS%" "%URL_INDEX_BUILDS%"
if %errorlevel% neq 0 (
    echo Failed to download JSON index for build.
    pause
    exit /b %errorlevel%
)

:: Extract the "mtime" date from the JSON (PowerShell)
for /f "delims=" %%i in ('powershell -Command "$json = Get-Content -Raw '%TEMP_INDEX_BUILDS%' | ConvertFrom-Json; $json | Where-Object { $_.name -eq 'SHITSTORM.zip' } | Select-Object -ExpandProperty mtime"') do set REMOTE_BUILD_DATE=%%i
if %errorlevel% neq 0 (
    echo Failed to extract remote build date.
    pause
    exit /b %errorlevel%
)
echo Remote build: %REMOTE_BUILD_DATE%.

:: Compare dates
if "%REMOTE_BUILD_DATE%" GTR "%LOCAL_BUILD_DATE%" goto UPDATE_BUILD

echo No update needed. Local build is up to date.
goto LAUNCH_BUILD

:UPDATE_BUILD
echo New build detected!
pause
echo Downloading... (%URL_BUILD%)
curl -s -L -o "%TEMP_ZIP%" "%URL_BUILD%"
if %errorlevel% neq 0 (
    echo Failed to download new build.
    pause
    exit /b %errorlevel%
)
echo Downloaded new build.

echo Removing old build... %LOCAL_BUILD_DIR%
pause
if exist "%LOCAL_BUILD_DIR%" (
    echo 🗑️ Suppression de %LOCAL_BUILD_DIR%...
    rmdir /s /q "%LOCAL_BUILD_DIR%"
    if %errorlevel% neq 0 (
        echo Error deleting the directory.
        echo Code erreur : %errorlevel%
        pause
        exit /b %errorlevel%
    )
)

:: Create the build directory if it doesn't exist
if not exist "%LOCAL_BUILD_DIR%" (
    echo Creating build directory...
    mkdir "%LOCAL_BUILD_DIR%"
    if %errorlevel% neq 0 (
        echo Failed to create build directory.
        pause
        exit /b %errorlevel%
    )
)

:: Extract the zip file
tar -xf "%TEMP_ZIP%" -C "%LOCAL_BUILD_DIR%"
if %errorlevel% neq 0 (
    echo Failed to extract new build.
    pause
    exit /b %errorlevel%
)
echo build update completed.
pause

:LAUNCH_BUILD
:: Launch the updated build
echo Launching build...
start "" "%LOCAL_BUILD_EXE%"

if %errorlevel% neq 0 (
    echo An error occurred...
    pause
)

exit