@echo off
echo scp icon.ico index.html debian@shitstorm.ovh:/var/www/paragon
scp icon.ico index.html debian@shitstorm.ovh:/var/www/paragon || (
    echo An error occurred during the file upload.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)