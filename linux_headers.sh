#!/bin/bash
# ========================================================
# Script: linux_headers.sh
# Goal: Install Linux API headers for LFS
# ========================================================

set -euo pipefail

export LFS=/mnt/lfs

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root!"
    exit 1
fi
cd $LFS/sources

# Vérifie la présence du tarball du kernel
TARBALL=$(ls linux-*.tar.* 2>/dev/null | head -n1)
if [ -z "$TARBALL" ]; then
    echo "❌ Linux kernel source tarball not found in $LFS/sources"
    exit 1
fi

echo ">> Extracting Linux kernel sources..."
tar -xf "$TARBALL"
cd linux-*/

echo ">> Installing Linux API headers..."

# Cette étape doit être faite en root pour éviter les erreurs de permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ You must run this section as root!"
    exit 1
fi

make mrproper   # Clean any previous build artifacts
make headers_install INSTALL_HDR_PATH=$LFS/usr

# Supprimer les fichiers non-headers générés par le kernel
find $LFS/usr/include -type f ! -name '*.h' -delete

# Vérification rapide
if [ -f $LFS/usr/include/stdio.h ]; then
    echo "✅ Verification passed: stdio.h exists in $LFS/usr/include"
else
    echo "❌ Verification failed: stdio.h missing in $LFS/usr/include"
fi

# Clean up sources
cd $LFS/sources
rm -rf linux-*/

echo "✅ Linux API headers installed successfully!"
echo
echo "Next step: Build Glibc for the temporary system"
