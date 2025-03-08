
param (
    [string]$password
)

if (-not $password) {
    throw "Password is required."
}

. .\.venv\Scripts\Activate

# --noconsole
pyinstaller --onefile --icon=icon.ico --name=SHITLAUNCHER .\ShitLauncher.py

deactivate

signtool.exe sign /f "C:\Users\Utilisateur\Desktop\certificat.pfx" /p $password /tr http://timestamp.digicert.com /td sha256 /fd sha256 dist\SHITLAUNCHER.exe

scp .\dist\SHITLAUNCHER.exe debian@shitstorm.ovh:/var/www/paragon/SHITLAUNCHER.exe
