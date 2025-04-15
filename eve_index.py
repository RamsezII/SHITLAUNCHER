import os, json

def index_recursive(path):
    entries = []
    for entry in os.scandir(path):
        if entry.is_dir():
            entries.append({
                "name": entry.name,
                "type": "directory",
                "children": index_recursive(entry.path)
            })
        else:
            entries.append({
                "name": entry.name,
                "type": "file"
            })
    return entries

base_path = "/var/www/paragon/eve"
index = index_recursive(base_path)

with open("/var/www/paragon/eve_index.json", "w") as f:
    json.dump(index, f, indent=2)
