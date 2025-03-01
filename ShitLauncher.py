
import os


folder_root = os.path.dirname(__file__)
folder_build = os.path.join(folder_root, "build")


def main():
    local_build_path = os.path.join(folder_build, "SHITSTORM.exe")
    date_local = os.path.getmtime(local_build_path)
    print("Local build date: ", date_local)


if __name__ == "__main__":
    main()
