import json
import os


path_this = os.path.abspath(__file__)
root_dir = os.path.dirname(path_this)


if __name__ == "__main__":
    manifest = {}

    for bundle_name in os.listdir(root_dir):
        bundle_path = os.path.join(root_dir, bundle_name)

        if os.path.isdir(bundle_path):
            print('bundle: ', bundle_name)
            manifest_bundle = {}

            for asset_name in os.listdir(bundle_path):
                asset_path = os.path.join(bundle_path, asset_name)

                if os.path.isdir(asset_path):
                    print('\tasset: ' + asset_name)
                    manifest_asset = []

                    for text_name in os.listdir(asset_path):
                        if text_name.endswith('.txt'):
                            print('\t\ttext: ' + text_name)
                            manifest_asset.append(text_name)

                    manifest_bundle[asset_name] = manifest_asset

            manifest[bundle_name] = manifest_bundle

    json_path = os.path.join(root_dir, "manifest.json.txt")
    with open(json_path, "w", encoding="utf-8") as json_file:
        json.dump(manifest, json_file, indent=4, ensure_ascii=False)
