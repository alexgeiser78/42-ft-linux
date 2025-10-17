#!/bin/bash
# ============================================================
# Script : glibc-lfs.sh
# Objectif : Compiler et installer Glibc (chapitre 5.5 du livre LFS 12.4)
# Auteur : ChatGPT – version sûre, conforme au livre
# ============================================================

set -euo pipefail

# ------------------------------------------------------------
# 0. Préparer l'environnement LFS
# ------------------------------------------------------------
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export LC_ALL=POSIX

# Vérifie qu'on est bien l'utilisateur lfs
if [ "$(whoami)" != "lfs" ]; then
    echo "❌ Ce script doit être exécuté en tant qu'utilisateur 'lfs' !"
    exit 1
fi

# ------------------------------------------------------------
# 1. Aller dans le dossier sources
# ------------------------------------------------------------
cd $LFS/sources

# ------------------------------------------------------------
# 2. Extraire les sources Glibc
# ------------------------------------------------------------
TARBALL=$(ls glibc-*.tar.* 2>/dev/null | head -n1)
if [ -z "$TARBALL" ]; then
    echo "❌ Archive glibc introuvable dans $LFS/sources"
    exit 1
fi

echo ">> Extraction de $TARBALL..."
tar -xf "$TARBALL"
cd glibc-*/

# ------------------------------------------------------------
# 3. Patch FHS (si disponible)
# ------------------------------------------------------------
if [ -f ../glibc-2.42-fhs-1.patch ]; then
    echo ">> Application du patch FHS..."
    patch -Np1 -i ../glibc-2.42-fhs-1.patch
fi

# ------------------------------------------------------------
# 4. Créer un dossier de build séparé
# ------------------------------------------------------------
mkdir -v build
cd build

# Crée le fichier configparms pour ldconfig/sln
echo "rootsbindir=/usr/sbin" > configparms

# ------------------------------------------------------------
# 5. Configuration
# ------------------------------------------------------------
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.4

# ------------------------------------------------------------
# 6. Compilation (en tant que lfs)
# ------------------------------------------------------------
echo ">> Compilation de Glibc..."
make -j$(nproc)

# ------------------------------------------------------------
# 7. Installation (dans $LFS, pas sur le système hôte)
# ------------------------------------------------------------
echo ">> Installation de Glibc dans \$LFS..."
make DESTDIR=$LFS install

# ------------------------------------------------------------
# 8. Correction du chemin dans ldd (strictement après l'installation)
# ------------------------------------------------------------
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

# ------------------------------------------------------------
# 9. Création des liens symboliques LSB (après installation)
# ------------------------------------------------------------
case $(uname -m) in
    i?86)
        ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
    x86_64)
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
esac

echo "✅ Glibc-2.42 compilée et installée dans \$LFS avec succès !"
echo "➡️  Vous pouvez maintenant passer à la construction de Libstdc++ ou entrer en chroot."
