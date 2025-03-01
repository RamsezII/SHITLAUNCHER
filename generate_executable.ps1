# Activer l'environnement virtuel
. .\.venv\Scripts\Activate

# Exécuter PyInstaller
pyinstaller --onefile --icon=icon.ico --noconsole --name=SHITLAUNCHER_noconsole .\ShitLauncher.py
pyinstaller --onefile --icon=icon.ico --name=SHITLAUNCHER .\ShitLauncher.py

# Désactiver l'environnement virtuel
deactivate
