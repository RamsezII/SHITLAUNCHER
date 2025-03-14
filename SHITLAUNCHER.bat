@echo off

:: sets the local environment for the batch file execution.
setlocal

:: Change the current directory to the directory of the batch file.
:: The /d switch is used to change the drive as well as the directory.
:: %~dp0 is a special variable that expands to the drive and path of the batch file.
cd /d "%~dp0"

:: Define variables
set LAUNCHER_NAME=%~nx0
set LOCAL_LAUNCHER=%~dp0%~nx0

set URL_INDEX_LAUNCHERS=https://shitstorm.ovh/launchers
set URL_LAUNCHER=https://shitstorm.ovh/launchers/%LAUNCHER_NAME%

set TEMP_INDEX_LAUNCHERS=%TEMP%\index_launchers.json
set TEMP_LAUNCHER=%TEMP%\%LAUNCHER_NAME%


:: Extract the local file's modification date
for /f "delims=" %%i in ('powershell -Command "(Get-Item '%LOCAL_LAUNCHER%').LastWriteTimeUtc.ToString('R')"') do set LOCAL_DATE=%%i
if %errorlevel% neq 0 (
    echo Failed to extract local date.
    pause
    exit /b %errorlevel%
)
for /f "delims=" %%i in ('powershell -Command "[datetime]::Parse('%LOCAL_DATE%').ToFileTimeUtc()"') do set LOCAL_TS=%%i
echo Local launcher: %LOCAL_DATE% (timestamp: %LOCAL_TS%).

:: Download the JSON index from the server
curl -s -L -o "%TEMP_INDEX_LAUNCHERS%" "%URL_INDEX_LAUNCHERS%"
if %errorlevel% neq 0 (
    echo Failed to check for remote launcher.
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
for /f "delims=" %%i in ('powershell -Command "[datetime]::Parse('%REMOTE_DATE%').ToFileTimeUtc()"') do set REMOTE_TS=%%i
echo Remote launcher: %REMOTE_DATE% (timestamp: %REMOTE_TS%).

:: Comparer les timestamps
for /f %%i in ('powershell -Command "[long]$r=%REMOTE_TS%; [long]$l=%LOCAL_TS%; if ($r -gt $l) { echo 1 } else { echo 0 }"') do set COMPARE_RESULT=%%i
if %COMPARE_RESULT% == 1 goto UPDATE_LAUNCHER

echo Local launcher is up to date.
goto CHECK_BUILD

:UPDATE_LAUNCHER
echo Launcher update needed, downloading...
curl -s -L -o "%LOCAL_LAUNCHER%" "%URL_LAUNCHER%"
if %errorlevel% neq 0 (
    echo Failed to update launcher.
    pause
    exit /b %errorlevel%
)
echo Update completed. Restarting launcher...
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
for /f "delims=" %%i in ('powershell -Command "[datetime]::Parse('%LOCAL_BUILD_DATE%').ToFileTimeUtc()"') do set LOCAL_BUILD_TS=%%i
echo Local build: %LOCAL_BUILD_DATE% (timestamp: %LOCAL_BUILD_TS%).

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
for /f "delims=" %%i in ('powershell -Command "[datetime]::Parse('%REMOTE_BUILD_DATE%').ToFileTimeUtc()"') do set REMOTE_BUILD_TS=%%i
echo Remote build: %REMOTE_BUILD_DATE% (timestamp: %REMOTE_BUILD_TS%).

:: Compare timestamps
for /f %%i in ('powershell -Command "[long]$r=%REMOTE_BUILD_TS%; [long]$l=%LOCAL_BUILD_TS%; if ($r -gt $l) { echo 1 } else { echo 0 }"') do set COMPARE_RESULT=%%i
if %COMPARE_RESULT% == 1 goto UPDATE_BUILD

echo No update needed. Local build is up to date.
goto LAUNCH_BUILD


:UPDATE_BUILD
echo Downloading... (%URL_BUILD%)
curl --progress-bar -L -o "%TEMP_ZIP%" "%URL_BUILD%"
if %errorlevel% neq 0 (
    echo Failed to download new build.
    pause
    exit /b %errorlevel%
)
echo Downloaded new build.

if exist "%LOCAL_BUILD_DIR%" (
    echo Removing old build directory... %LOCAL_BUILD_DIR%
    rmdir /s /q "%LOCAL_BUILD_DIR%"
    if %errorlevel% neq 0 (
        echo Error deleting the directory, code: %errorlevel%
        pause
        exit /b %errorlevel%
    )
)

:: Create the build directory if it doesn't exist
if not exist "%LOCAL_BUILD_DIR%" (
    echo Creating new build directory...
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


:LAUNCH_BUILD
:: Launch the updated build
echo Launching build...
start "" "%LOCAL_BUILD_EXE%"

if %errorlevel% neq 0 (
    echo An error occurred...
    pause
)

exit