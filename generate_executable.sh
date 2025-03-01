#!/bin/bash

# Activer l'environnement virtuel
source .venv/bin/activate

# Exécuter pyinstaller
pyinstaller.exe --onefile --icon=icon.ico --noconsole --name=SHITLAUNCHER ./ShitLauncher.py
pyinstaller.exe --onefile --icon=icon.ico --name=SHITLAUNCHER_prompt ./ShitLauncher.py

# Désactiver l'environnement virtuel
deactivate