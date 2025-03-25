@echo off

if not exist TESTS mkdir TESTS

copy SHITLAUNCHER.bat TESTS\SHITLAUNCHER.bat && copy SHITLAUNCHER.sh TESTS\SHITLAUNCHER.sh || (
    echo An error occurred during the file upload to TESTS.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)