
. .\.venv\Scripts\Activate

# pyinstaller --onefile --icon=icon.ico --noconsole --name=SHITLAUNCHER_noconsole .\ShitLauncher.py
pyinstaller --onefile --icon=icon.ico --name=SHITLAUNCHER .\ShitLauncher.py

deactivate
