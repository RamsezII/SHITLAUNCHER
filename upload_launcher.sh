#!/bin/bash

# Rendre SHITLAUNCHER.sh exécutable
chmod +x ./SHITLAUNCHER.sh

# Convertir le fichier au format Unix (dos2unix)
dos2unix ./SHITLAUNCHER.sh

# Copier SHITLAUNCHER.sh sur le serveur distant
scp ./SHITLAUNCHER.sh debian@shitstorm.ovh:/var/www/paragon/launchers/SHITLAUNCHER.sh

# Générer un hash SHA256 et l'enregistrer dans hash_sh.txt
sha256sum ./SHITLAUNCHER.sh | awk '{print $1}' > hash_sh.txt

# Copier hash_sh.txt sur le serveur distant
scp hash_sh.txt debian@shitstorm.ovh:/var/www/paragon/launchers/hash_sh.txt

# Créer le dossier ./TESTS s'il n'existe pas
mkdir -p ./TESTS

# Copier SHITLAUNCHER.sh dans le dossier ./TESTS
cp ./SHITLAUNCHER.sh ./TESTS/