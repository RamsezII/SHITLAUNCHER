@echo off
echo Sending icon.ico and index.html to debian@shitstorm.ovh:/var/www/paragon
scp icon.ico index.html debian@shitstorm.ovh:/var/www/paragon
if %errorlevel% neq 0 (
    echo Error occurred while sending the files.
) else (
    echo Files sent successfully.
)
echo Press any key to exit...
pause >nul