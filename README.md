# SHITLAUNCHER

Python Environment Setup
========================

Create a separate virtual environment on each OS; do not copy `.venv` between Windows and Linux/macOS. Reuse `requirements.txt` to sync dependencies.

Windows
-------
1. python -m venv .venv
2. PowerShell: .\.venv\Scripts\Activate.ps1
   CMD: .\.venv\Scripts\activate
3. python -m pip install --upgrade pip
4. python -m pip install -r requirements.txt
   (or python -m pip install wxPython if starting from scratch)
5. python -m pip freeze > requirements.txt

Linux/macOS
-----------
1. python3 -m venv .venv
2. source .venv/bin/activate
3. python -m pip install --upgrade pip
4. python -m pip install -r requirements.txt
   (or python -m pip install wxPython)
5. python -m pip freeze > requirements.txt

Daily Usage
-----------
1. Activate the environment for your OS (see above).
2. Run the app: python SHITLAUNCHER_wx.py
3. Deactivate: deactivate