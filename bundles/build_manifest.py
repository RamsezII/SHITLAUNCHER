import json
import os
import zipfile
import shutil


path_this = os.path.abspath(__file__)
root_dir = os.path.dirname(path_this)


if __name__ == "__main__":

    temp_folder = os.path.join(os.path.dirname(root_dir), "_TEMP_")
    if not os.path.exists(temp_folder):
        os.makedirs(temp_folder)

    manifest = {}

    for bundle_name in os.listdir(root_dir):
        bundle_path = os.path.join(root_dir, bundle_name)

        if os.path.isdir(bundle_path):
            print('\t' + bundle_name)
            manifest_bundle = {}

            zip_path = os.path.join(bundle_path, "texts.zip")
            extract_dir = os.path.join(temp_folder, bundle_name)
            if not os.path.exists(extract_dir):
                os.makedirs(extract_dir)

            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(extract_dir)

            for asset_name in os.listdir(extract_dir):
                asset_path = os.path.join(extract_dir, asset_name)

                if os.path.isdir(asset_path):
                    print('\t\t' + asset_name)
                    manifest_asset = []

                    for text_name in os.listdir(asset_path):
                        if text_name.endswith('.txt'):
                            print('\t\t\t' + text_name)
                            manifest_asset.append(text_name)

                    manifest_bundle[asset_name] = manifest_asset

            manifest[bundle_name] = manifest_bundle

    shutil.rmtree(temp_folder)

    json_path = os.path.join(root_dir, "manifest.json.txt")
    with open(json_path, "w", encoding="utf-8") as json_file:
        json.dump(manifest, json_file, indent=4, ensure_ascii=False)
