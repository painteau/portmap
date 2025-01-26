#!/bin/bash

# Définir le répertoire du projet comme étant le répertoire courant
PROJECT_DIR=$(pwd)

# Se déplacer dans le répertoire du projet
cd "$PROJECT_DIR" || exit

# Pull les dernières modifications du dépôt Git
echo "Pulling the latest code from Git..."
git pull origin main || { echo "Git pull failed!"; exit 1; }

# Extraire la version à partir du fichier control
PACKAGE_VERSION=$(grep -m 1 '^Version:' "$PROJECT_DIR/DEBIAN/control" | cut -d ' ' -f 2)

# Vérifier si la version a été extraite correctement
if [ -z "$PACKAGE_VERSION" ]; then
    echo "Failed to extract the version from the control file."
    exit 1
fi

echo "Extracted package version: $PACKAGE_VERSION"

# Créer le paquet .deb dans le répertoire courant
echo "Building the .deb package..."
dpkg-deb --build "$PROJECT_DIR" "$PROJECT_DIR" || { echo "Deb creation failed!"; exit 1; }

# Vérifier si le fichier .deb existe dans le répertoire courant
DEB_FILE="$PROJECT_DIR/portmap_${PACKAGE_VERSION}_all.deb"
if [ ! -f "$DEB_FILE" ]; then
    echo "Debian package was not created in the expected location."
    exit 1
fi

# Confirmer la création du paquet
echo "Debian package created successfully: $DEB_FILE"

# Ajouter les modifications au dépôt git (création du paquet)
git add .

# Commit avec un message contenant la version extraite
git commit -m "Release $PACKAGE_VERSION - Create .deb package"

# Pousser les modifications vers le dépôt
git push origin main

echo "Git commit and push completed successfully."
