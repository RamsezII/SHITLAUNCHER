import os
import sys
import requests
from datetime import datetime, timezone


url_paragon = "https://www.shitstorm.ovh"
url_builds = url_paragon + "/builds"

path_exe = os.path.abspath(sys.argv[0])
dir_root = os.path.dirname(path_exe)
dir_game = os.path.join(dir_root, "game")


def main():
    print(f"🔗 GET {url_builds}")
    response = requests.get(url_builds, timeout=5)

    if response.status_code != 200:
        print(f"Error: {response.status_code}")
        return

    builds_index = response.json()
    print(f"📦 {len(builds_index)} builds found:\n", builds_index)

    build_index = builds_index[0]
    zip_file_date = datetime.strptime(build_index['mtime'], "%a, %d %b %Y %H:%M:%S GMT").replace(tzinfo=timezone.utc)
    print(f"📅 Latest build: {zip_file_date}")

    update = False

    # get local infos
    if not os.path.exists(dir_game):
        print("📂 Game folder not found")
        update = True
    else:
        path_exe = os.path.join(dir_game, "SHITSTORM.exe")
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

        path_zip = os.path.join(dir_root, "temp.zip")
        url_build = url_builds + "/" + build_index['name']

        print(f"🔗 GET {url_build},n📦 Downloading {build_index['name']} to {path_zip}")
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

    path_exe = os.path.join(dir_game, os.listdir(dir_game)[0], "SHITSTORM.exe")
    print(f"🚀 Launching {path_exe}")
    os.startfile(path_exe)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        import traceback
        traceback.print_exc()
        input("Press Enter to exit")
