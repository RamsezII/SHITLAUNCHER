
from scripts import check_launcher, check_build


if __name__ == "__main__":
    try:
        check_launcher.check_alt()
        check_launcher.check_launcher()
        check_build.check_build()
    except Exception as e:
        import traceback
        traceback.print_exc()
        input("Press Enter to exit")
