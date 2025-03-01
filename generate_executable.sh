#!/bin/bash

# Activer l'environnement virtuel
source .venv/bin/activate

# Exécuter pyinstaller
pyinstaller.exe --onefile --icon=icon.ico --noconsole --name=SHITLAUNCHER_noconsole ./ShitLauncher.py
pyinstaller.exe --onefile --icon=icon.ico --name=SHITLAUNCHER ./ShitLauncher.py

# Désactiver l'environnement virtuel
deactivate