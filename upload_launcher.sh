#!/bin/bash

# Define variables
REMOTE_USER="debian"
REMOTE_HOST="shitstorm.ovh"
REMOTE_DIR="/var/www/paragon/launchers"
LOCAL_FILES=("SHITLAUNCHER.bat" "SHITLAUNCHER.sh")
TESTS_DIR="TESTS"

# Make SHITLAUNCHER.sh executable
chmod +x "SHITLAUNCHER.sh"

# Upload files to remote server
scp "${LOCAL_FILES[@]}" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
if [ $? -ne 0 ]; then
    echo "An error occurred during the file upload."
    echo "Error details: $?"
    read -p "Press any key to continue..."
    exit 1
fi

# Create TESTS directory if it doesn't exist
if [ ! -d "$TESTS_DIR" ]; then
    mkdir "$TESTS_DIR"
fi

# Copy files to TESTS directory
cp "${LOCAL_FILES[@]}" "$TESTS_DIR/"
if [ $? -ne 0 ]; then
    echo "An error occurred during the file copy to TESTS."
    echo "Error details: $?"
    read -p "Press any key to continue..."
    exit 1
fi