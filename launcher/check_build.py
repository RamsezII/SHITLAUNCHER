from datetime import datetime, timezone
import os
import requests

from launcher.Util import *


def check_build():

    dir_game_OLD = os.path.join(ROOT_DIR, "SHITSTORM_standalone")
    if os.path.exists(dir_game_OLD):
        print(f"🗑️ Removing {dir_game_OLD}")
        import shutil
        shutil.rmtree(dir_game_OLD)

    dir_install = os.path.join(ROOT_DIR, "SHITSTORM_install")
    dir_game = os.path.join(dir_install, "SHITSTORM_standalone")

    url_build = URL_PARAGON + "/builds"
    print(f"🔗 GET {url_build}")
    response = requests.get(url_build, timeout=5)

    if response.status_code != 200:
        print(f"Error: {response.status_code}")
        return

    builds_index = response.json()
    print(f"📦 {len(builds_index)} builds found:\n", builds_index)

    build_index = builds_index[0]
    name_zip = build_index['name']
    zip_file_date = datetime.strptime(build_index['mtime'], "%a, %d %b %Y %H:%M:%S GMT").replace(tzinfo=timezone.utc)
    print(f"📅 Latest build: {zip_file_date}")

    update = False
    path_exe = os.path.join(dir_game, "SHITSTORM.exe")

    if not os.path.exists(dir_game):
        print("📂 Folder not found:", dir_game)
        update = True
    else:
        print(f"📂 Local executable: {path_exe}")
        exe_mod_time = datetime.fromtimestamp(os.path.getmtime(path_exe), timezone.utc)
        print(f"📅 Local executable time: {exe_mod_time}")

        if exe_mod_time < zip_file_date:
            print("🔄 Update needed")
            import shutil
            shutil.rmtree(dir_game)
            update = True
        else:
            print("✅ No update needed")

    if update:
        os.makedirs(dir_game)

        path_zip = os.path.join(dir_install, "temp.zip")
        url_build = url_build + "/" + name_zip

        print(f"🔗 GET {url_build},n📦 Downloading {name_zip} to {path_zip}")
        with requests.get(url_build, stream=True) as r:
            with open(path_zip, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)

        print(f"📦 Extracting {path_zip} to {dir_game}")
        import zipfile
        with zipfile.ZipFile(path_zip, 'r') as zip_ref:
            zip_ref.extractall(dir_game)

        print(f"🗑️ Removing {path_zip}")
        os.remove(path_zip)

    print(f"🚀 Launching {path_exe}")
    os.startfile(path_exe)
