#!/bin/bash

# Activer l'environnement virtuel
source .venv/bin/activate

# Exécuter pyinstaller
pyinstaller.exe --onefile --noconsole --icon=icon.ico --name=SHITLAUNCHER ./ShitLauncher.py

# Désactiver l'environnement virtuel
deactivate