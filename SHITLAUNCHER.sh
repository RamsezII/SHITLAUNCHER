#!/bin/bash

# Define variables
LAUNCHER_NAME=$(basename "$0")
LOCAL_LAUNCHER=$(realpath "$0")

URL_INDEX_LAUNCHERS="https://shitstorm.ovh/launchers"
URL_LAUNCHER="https://shitstorm.ovh/launchers/$LAUNCHER_NAME"

TEMP_INDEX_LAUNCHERS="/tmp/index_launchers.json"
TEMP_LAUNCHER="/tmp/$LAUNCHER_NAME"

URL_INDEX_BUILDS="https://shitstorm.ovh/builds"
URL_BUILD="https://shitstorm.ovh/builds/SHITSTORM_linux.zip"

TEMP_INDEX_BUILDS="/tmp/index_builds.json"
TEMP_ZIP="/tmp/SHITSTORM.zip"

LOCAL_INSTALL_DIR="$(dirname "$0")/SHITSTORM_install"
LOCAL_BUILD_DIR="$LOCAL_INSTALL_DIR/Standalone"
LOCAL_BUILD_EXE="$LOCAL_BUILD_DIR/SHITSTORM.x86_64"

# Cleanup function
cleanup() {
    rm -f "$TEMP_INDEX_LAUNCHERS" "$TEMP_LAUNCHER" "$TEMP_INDEX_BUILDS" "$TEMP_ZIP"
}
trap cleanup EXIT

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "$1"
        read -p "Appuyez sur Entrée pour continuer..."
        exit 1
    fi
}

# Function to download a file
download_file() {
    curl -s -L -o "$1" "$2"
    check_error "Failed to download $2."
}

# Function to get timestamp from file
get_timestamp() {
    local date=$(stat -c %y "$1" | cut -d'.' -f1)
    date -d "$date" +%s
}

# Ensure dependencies are installed
echo "Checking dependencies..."
MISSING_DEPS=""

for dep in jq unzip curl wine; do
    if ! command -v $dep &> /dev/null; then
        MISSING_DEPS+="$dep "
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo "Missing dependencies: $MISSING_DEPS"
    echo "Attempting to install..."
    sudo apt update && sudo apt install -y $MISSING_DEPS || {
        echo "Failed to install dependencies. Please install manually: sudo apt install $MISSING_DEPS"
        exit 1
    }
fi

echo "All dependencies are installed."

# Check for launcher update
LOCAL_TS=$(get_timestamp "$LOCAL_LAUNCHER")
echo "Local launcher: $(date -d @$LOCAL_TS)."

download_file "$TEMP_INDEX_LAUNCHERS" "$URL_INDEX_LAUNCHERS"

REMOTE_DATE=$(jq -r '.[] | select(.name == "SHITLAUNCHER.sh") | .mtime' "$TEMP_INDEX_LAUNCHERS")
REMOTE_TS=$(date -d "$REMOTE_DATE" +%s)
echo "Remote launcher: $(date -d @$REMOTE_TS)."

if [ "$REMOTE_TS" -gt "$LOCAL_TS" ]; then
    echo "Launcher update needed, downloading..."
    download_file "$LOCAL_LAUNCHER" "$URL_LAUNCHER"
    echo "Update completed. Restarting launcher..."
    exec "$LOCAL_LAUNCHER"
fi

echo "Local launcher is up to date."

# Check for build update
if [ ! -f "$LOCAL_BUILD_EXE" ]; then
    UPDATE_BUILD=true
else
    LOCAL_BUILD_TS=$(get_timestamp "$LOCAL_BUILD_DIR")
    echo "Local build: $(date -d @$LOCAL_BUILD_TS)."

    download_file "$TEMP_INDEX_BUILDS" "$URL_INDEX_BUILDS"

    REMOTE_BUILD_DATE=$(jq -r '.[] | select(.name == "SHITSTORM-linux.zip") | .mtime' "$TEMP_INDEX_BUILDS")
    REMOTE_BUILD_TS=$(date -d "$REMOTE_BUILD_DATE" +%s)
    echo "Remote build: $(date -d @$REMOTE_BUILD_TS)."

    if [ "$REMOTE_BUILD_TS" -gt "$LOCAL_BUILD_TS" ]; then
        UPDATE_BUILD=true
    else
        echo "No update needed. Local build is up to date."
    fi
fi

if [ "$UPDATE_BUILD" = true ]; then
    echo "Downloading new build..."
    download_file "$TEMP_ZIP" "$URL_BUILD"
    echo "Downloaded new build."

    if [ -d "$LOCAL_BUILD_DIR" ]; then
        echo "Removing old build directory... $LOCAL_BUILD_DIR"
        rm -rf "$LOCAL_BUILD_DIR"
        check_error "Error deleting the directory."
    fi

    echo "Creating new build directory..."
    mkdir -p "$LOCAL_BUILD_DIR"
    check_error "Failed to create build directory."

    echo "Extracting new build..."
    unzip -o "$TEMP_ZIP" -d "$LOCAL_BUILD_DIR"
    check_error "Failed to extract new build."
    echo "Build update completed."
fi

# Lancer directement l'exécutable Linux
if [ ! -f "$LOCAL_BUILD_EXE" ]; then
    echo "Erreur : l'exécutable du jeu n'a pas été trouvé : $LOCAL_BUILD_EXE"
    exit 1
fi

# S'assurer que l'exécutable a les droits d'exécution
if [ ! -x "$LOCAL_BUILD_EXE" ]; then
    echo "Ajout du droit d'exécution à $LOCAL_BUILD_EXE"
    chmod +x "$LOCAL_BUILD_EXE"
    check_error "Impossible de rendre l'exécutable exécutable."
fi

echo "Lancement du jeu..."
"$LOCAL_BUILD_EXE"
check_error "Une erreur est survenue lors du lancement du jeu."

exit 0