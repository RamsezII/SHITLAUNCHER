@echo off

scp SHITLAUNCHER.bat SHITLAUNCHER.sh debian@shitstorm.ovh:/var/www/paragon/launchers || (
    echo An error occurred during the file upload.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)

for /f "tokens=1" %%i in ('certutil -hashfile SHITLAUNCHER.bat SHA256 ^| find /i /v "hash"') do echo %%i > hash_bat.txt && scp hash_bat.txt debian@shitstorm.ovh:/var/www/paragon/launchers/hash_bat.txt || (
    echo An error occurred during the hash upload.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)

if not exist TESTS mkdir TESTS

copy SHITLAUNCHER.bat TESTS\SHITLAUNCHER.bat && copy SHITLAUNCHER.sh TESTS\SHITLAUNCHER.sh || (
    echo An error occurred during the file upload to TESTS.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)