@echo off

scp bundles/build_manifest.py debian@shitstorm.ovh:/var/www/paragon/bundles/build_manifest.py || (
    echo An error occurred during the file upload.
    echo Error details:
    echo %errorlevel%
    echo Press any key to continue...
    pause >nul
)