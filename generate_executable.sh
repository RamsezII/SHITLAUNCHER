#!/bin/bash

source .venv/bin/activate

pyinstaller.exe --onefile --icon=icon.ico --noconsole --name=SHITLAUNCHER_noconsole ./ShitLauncher.py
pyinstaller.exe --onefile --icon=icon.ico --name=SHITLAUNCHER ./ShitLauncher.py

deactivate