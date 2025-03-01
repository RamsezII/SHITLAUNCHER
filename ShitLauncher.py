import os
import requests
import zipfile
from datetime import datetime, timezone


url_paragon = "https://www.shitstorm.ovh"
url_builds = url_paragon + "/builds"

dir_root = os.path.dirname(__file__)
dir_builds = os.path.join(dir_root, "builds")


def main():
    print(f"🔗 GET {url_builds}")
    response = requests.get(url_builds, timeout=5)

    if response.status_code != 200:
        print(f"Error: {response.status_code}")
        return

    builds_index = response.json()
    print(f"📦 {len(builds_index)} builds found:\n", builds_index)

    zip_file_date = datetime.strptime(builds_index[0]['mtime'], "%a, %d %b %Y %H:%M:%S GMT").replace(tzinfo=timezone.utc)
    print(f"📅 Latest build: {zip_file_date}")

    update = False

    # get local infos
    if not os.path.exists(dir_builds):
        print("📂 Builds folder not found")
        update = True
    else:
        path_exe = os.path.join(dir_builds, os.listdir(dir_builds)[0], "SHITSTORM.exe")
        print(f"📂 Local executable: {path_exe}")

        exe_mod_time = datetime.fromtimestamp(os.path.getmtime(path_exe), timezone.utc)
        print(f"📅 Local executable: {exe_mod_time}")

        if exe_mod_time < zip_file_date:
            print("🔄 Update needed")
            os.rmdir(dir_builds)
            update = True
        else:
            print("✅ No update needed")

    return

    if update:
        os.makedirs(dir_builds)

        # download the zip from the server, into a TEMP folder,
        temp_zip_path = os.path.join(os.path.dirname(__file__), "TEMP.zip")
        with requests.get(url_builds + "/latest.zip", stream=True) as r:
            with open(temp_zip_path, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)

        # delete the "builds" folder, recreate it and extract the zip content into it
        os.rmdir(dir_builds)
        os.makedirs(dir_builds)
        with zipfile.ZipFile(temp_zip_path, 'r') as zip_ref:
            zip_ref.extractall(dir_builds)

        # delete the zip
        os.remove(temp_zip_path)

    # launch the executable
    os.startfile(path_exe)


if __name__ == "__main__":
    main()
