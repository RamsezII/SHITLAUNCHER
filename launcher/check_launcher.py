from datetime import datetime, timezone

import requests

from launcher.Util import *


updater_suffixe = "_update.exe"


def check_alt():

    if not EXE_PATH.endswith(updater_suffixe):
        alt_exe_path = EXE_PATH[:-len(".exe")] + updater_suffixe
        if os.path.exists(alt_exe_path):
            os.remove(alt_exe_path)
        return

    main_exe_path = EXE_PATH[:-len(updater_suffixe)] + ".exe"
    os.remove(main_exe_path)

    main_exe_name = EXE_NAME[:-len(updater_suffixe)] + ".exe"
    url_launcher_exe = URL_PARAGON + "/" + main_exe_name
    print(f"🔗 GET {url_launcher_exe}")
    response = requests.get(url_launcher_exe, timeout=5)

    if response.status_code != 200:
        print(f"Error: {response.status_code}")
        return

    with open(main_exe_path, 'wb') as f:
        f.write(response.content)

    print("🔄 Launcher updated. Restarting...")
    os.execl(main_exe_path, main_exe_name)


def check_launcher():

    local_date = datetime.fromtimestamp(os.path.getmtime(EXE_PATH), timezone.utc)

    print(f"🔗 GET {URL_PARAGON}")
    response = requests.get(URL_PARAGON, timeout=5)

    if response.status_code != 200:
        print(f"Error: {response.status_code}")
        return

    launcher_index = response.json()[0]
    print(f"📅 Latest launcher: {launcher_index['mtime']}")

    launcher_date = datetime.strptime(launcher_index['mtime'], "%a, %d %b %Y %H:%M:%S GMT").replace(tzinfo=timezone.utc)

    if local_date < launcher_date:
        print("🔄 Update needed")

        alt_exe_path = EXE_PATH[:-len(".exe")] + updater_suffixe
        alt_exe_name = EXE_NAME[:-len(".exe")] + updater_suffixe

        with open(EXE_PATH, 'rb') as src, open(alt_exe_path, 'wb') as dst:
            dst.write(src.read())

        print("🔄 Launcher updated. Restarting...")
        os.execl(alt_exe_path, alt_exe_name)

    else:
        print("✅ No update needed")
