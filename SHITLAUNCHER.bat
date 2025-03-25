@echo off

setlocal
cd /d "%~dp0"

set LAUNCHER_NAME=%~nx0
set LOCAL_LAUNCHER=%~dp0%~nx0

:: Hash check URLS
set URL_REMOTE_HASH=https://shitstorm.ovh/launchers/hash_bat.txt
set URL_LAUNCHER=https://shitstorm.ovh/launchers/%LAUNCHER_NAME%
set TEMP_REMOTE_HASH=%TEMP%\remote_hash.txt

:: Get local file hash
for /f "tokens=1" %%i in ('certutil -hashfile "%LOCAL_LAUNCHER%" SHA256 ^| find /i /v "SHA256" ^| find /i /v "certutil"') do set LOCAL_HASH=%%i
set LOCAL_HASH=%LOCAL_HASH: =%
echo Local hash: %LOCAL_HASH%

:: Get remote hash
curl -s -L -o "%TEMP_REMOTE_HASH%" "%URL_REMOTE_HASH%"
if %errorlevel% neq 0 (
    echo Failed to download remote hash.
    pause
    exit /b %errorlevel%
)
set /p REMOTE_HASH=<"%TEMP_REMOTE_HASH%"
set REMOTE_HASH=%REMOTE_HASH: =%

echo Remote hash: %REMOTE_HASH%
del /q "%TEMP_REMOTE_HASH%"

:: Compare hashes
if /i not "%REMOTE_HASH%"=="%LOCAL_HASH%" (
    echo Remote launcher is newer
    pause
    echo Updating...
    curl -s -L -o "%LOCAL_LAUNCHER%" "%URL_LAUNCHER%"
    if %errorlevel% neq 0 (
        echo Failed to update launcher.
        pause
        exit /b %errorlevel%
    )
    echo Update completed. Restarting launcher...
    start "" "%LOCAL_LAUNCHER%"
    exit
) else (
    echo Local launcher is up to date.
)

:CHECK_BUILD
set URL_INDEX_BUILDS=https://shitstorm.ovh/builds
set URL_BUILD=https://shitstorm.ovh/builds/SHITSTORM.zip

set TEMP_INDEX_BUILDS=%TEMP%\index_builds.json
set TEMP_ZIP=%TEMP%\SHITSTORM.zip

set LOCAL_INSTALL_DIR=%~dp0SHITSTORM_install
set LOCAL_BUILD_DIR=%LOCAL_INSTALL_DIR%\Standalone
set LOCAL_BUILD_EXE=%LOCAL_BUILD_DIR%\SHITSTORM.exe

if not exist "%LOCAL_BUILD_EXE%" goto UPDATE_BUILD

for /f "delims=" %%i in ('powershell -Command "(Get-Item '%LOCAL_BUILD_DIR%').LastWriteTimeUtc.ToFileTimeUtc()"') do set LOCAL_BUILD_TS=%%i
curl -s -L -o "%TEMP_INDEX_BUILDS%" "%URL_INDEX_BUILDS%"

powershell -Command "$json = Get-Content -Raw '%TEMP_INDEX_BUILDS%' | ConvertFrom-Json; $json | Where-Object { $_.name -eq 'SHITSTORM.zip' } | Select-Object -ExpandProperty mtime" > "%TEMP%\remote_build_time.txt"
for /f "delims=" %%i in ('powershell -Command "[datetime]::Parse((Get-Content -Path '%TEMP%\remote_build_time.txt')).ToFileTimeUtc()"') do set REMOTE_BUILD_TS=%%i

powershell -Command "$r=[long]::Parse('%REMOTE_BUILD_TS%'); $l=[long]::Parse('%LOCAL_BUILD_TS%'); if ($r -gt $l) { exit 1 } else { exit 0 }"
if %errorlevel% equ 1 goto UPDATE_BUILD

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

if not exist "%LOCAL_BUILD_DIR%" (
    echo Creating new build directory...
    mkdir "%LOCAL_BUILD_DIR%"
    if %errorlevel% neq 0 (
        echo Failed to create build directory.
        pause
        exit /b %errorlevel%
    )
)

tar -xf "%TEMP_ZIP%" -C "%LOCAL_BUILD_DIR%"
if %errorlevel% neq 0 (
    echo Failed to extract new build.
    pause
    exit /b %errorlevel%
)
echo build update completed.

:LAUNCH_BUILD
echo Launching build...
start "" "%LOCAL_BUILD_EXE%"

if %errorlevel% neq 0 (
    echo An error occurred...
    pause
)

exit