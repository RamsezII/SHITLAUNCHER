#!/bin/bash

scp SHITLAUNCHER.sh debian@shitstorm.ovh:/var/www/paragon/launchers/SHITLAUNCHER.sh
if [ $? -ne 0 ]; then
    echo "An error occurred during the file upload."
    echo "Error details:"
    echo $?
    read -p "Press any key to continue..."
fi

if [ ! -d "TESTS" ]; then
    mkdir TESTS
fi

cp SHITLAUNCHER.sh TESTS/SHITLAUNCHER.sh
if [ $? -ne 0 ]; then
    echo "An error occurred during the file upload to TESTS."
    echo "Error details:"
    echo $?
    read -p "Press any key to continue..."
fi