#!/bin/bash

# Define variables
LAUNCHER_NAME=$(basename "$0")
LOCAL_LAUNCHER=$(realpath "$0")

URL_INDEX_LAUNCHERS="https://shitstorm.ovh/launchers"
URL_LAUNCHER="https://shitstorm.ovh/launchers/$LAUNCHER_NAME"

TEMP_INDEX_LAUNCHERS="/tmp/index_launchers.json"
TEMP_LAUNCHER="/tmp/$LAUNCHER_NAME"

URL_INDEX_BUILDS="https://shitstorm.ovh/builds"
# URL_BUILD et autres seront déterminés après le choix plateforme
URL_BUILD=""
BUILD_ARCHIVE_NAME=""

TEMP_INDEX_BUILDS="/tmp/index_builds.json"
TEMP_ZIP="/tmp/SHITSTORM.zip"

LOCAL_INSTALL_DIR="$(dirname "$0")/SHITSTORM_install"
LOCAL_BUILD_DIR=""
# LOCAL_BUILD_EXE sera défini après le choix plateforme
LOCAL_BUILD_EXE=""

# -------------------- Choix plateforme --------------------
read -p "Choisir plateforme (w=Windows, l=Linux) : " choice
case "$choice" in
  w|W)
    IS_WINDOWS=true
    BUILD_ARCHIVE_NAME="SHITSTORM_windows.zip"
    URL_BUILD="https://shitstorm.ovh/builds/$BUILD_ARCHIVE_NAME"
    LOCAL_BUILD_DIR="$LOCAL_INSTALL_DIR/Standalone_windows"
    LOCAL_BUILD_EXE="$LOCAL_BUILD_DIR/SHITSTORM.exe"
    ;;
  l|L|*)
    IS_WINDOWS=false
    BUILD_ARCHIVE_NAME="SHITSTORM_linux.zip"
    URL_BUILD="https://shitstorm.ovh/builds/$BUILD_ARCHIVE_NAME"
    LOCAL_BUILD_DIR="$LOCAL_INSTALL_DIR/Standalone_linux"
    LOCAL_BUILD_EXE="$LOCAL_BUILD_DIR/SHITSTORM.x86_64"
    ;;
esac
echo "Plateforme choisie : $( [ "$IS_WINDOWS" = true ] && echo Windows || echo Linux )"
# ----------------------------------------------------------

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

    # Attention au nom exact dans l'index (on utilise la variable BUILD_ARCHIVE_NAME)
    REMOTE_BUILD_DATE=$(jq -r --arg NAME "$BUILD_ARCHIVE_NAME" '.[] | select(.name == $NAME) | .mtime' "$TEMP_INDEX_BUILDS")
    if [ -z "$REMOTE_BUILD_DATE" ] || [ "$REMOTE_BUILD_DATE" = "null" ]; then
        echo "Impossible de trouver $BUILD_ARCHIVE_NAME dans l'index distant. Mise à jour forcée."
        UPDATE_BUILD=true
    else
        REMOTE_BUILD_TS=$(date -d "$REMOTE_BUILD_DATE" +%s)
        echo "Remote build: $(date -d @$REMOTE_BUILD_TS)."
        if [ "$REMOTE_BUILD_TS" -gt "$LOCAL_BUILD_TS" ]; then
            UPDATE_BUILD=true
        else
            echo "No update needed. Local build is up to date."
        fi
    fi
fi

if [ "$UPDATE_BUILD" = true ]; then
    echo "Downloading new build ($BUILD_ARCHIVE_NAME)..."
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

# Lancer l’exécutable si présent (utile sous Linux ; sous Windows on laisse juste l’exe prêt)
if [ ! -f "$LOCAL_BUILD_EXE" ]; then
    echo "Erreur : l'exécutable du jeu n'a pas été trouvé : $LOCAL_BUILD_EXE"
    exit 1
fi

# S’assurer que l’exécutable Linux a le droit d’exécution
if [ "$IS_WINDOWS" = false ] && [ ! -x "$LOCAL_BUILD_EXE" ]; then
    echo "Ajout du droit d'exécution à $LOCAL_BUILD_EXE"
    chmod +x "$LOCAL_BUILD_EXE"
    check_error "Impossible de rendre l'exécutable exécutable."
fi

echo "Lancement du jeu..."
"$LOCAL_BUILD_EXE"
check_error "Une erreur est survenue lors du lancement du jeu."

exit 0
