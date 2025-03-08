
$password = Read-Host -Prompt "Enter the password for the certificate"

if (-not $password) {
    throw "Password is required."
}

signtool.exe sign /f "C:\Users\Utilisateur\Desktop\certificat.pfx" /p $password /tr http://timestamp.digicert.com /td sha256 /fd sha256 dist\SHITLAUNCHER.exe
