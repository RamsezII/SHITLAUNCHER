# Activer l'environnement virtuel
. .\.venv\Scripts\Activate

# Exécuter PyInstaller
pyinstaller --onefile --icon=icon.ico --noconsole --name=SHITLAUNCHER .\ShitLauncher.py
pyinstaller --onefile --icon=icon.ico --name=SHITLAUNCHER_console .\ShitLauncher.py

# Désactiver l'environnement virtuel
deactivate
