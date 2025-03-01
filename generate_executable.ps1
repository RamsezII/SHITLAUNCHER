# Activer l'environnement virtuel
. .\.venv\Scripts\Activate

# Exécuter PyInstaller
pyinstaller --onefile --noconsole --icon=icon.ico --name=SHITLAUNCHER .\ShitLauncher.py

# Désactiver l'environnement virtuel
deactivate
