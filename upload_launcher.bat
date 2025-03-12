@echo off

echo scp SHITLAUNCHER.bat debian@shitstorm.ovh:/var/www/paragon/launchers/SHITLAUNCHER.bat

scp SHITLAUNCHER.bat debian@shitstorm.ovh:/var/www/paragon/launchers/SHITLAUNCHER.bat || (
    echo An error occurred during the file upload.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)

copy SHITLAUNCHER.bat TESTS\SHITLAUNCHER.bat || (
    echo An error occurred during the file upload to TESTS.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)