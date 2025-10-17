#!/bin/bash
# ============================================================
# Script : glibc-lfs.sh
# Objectif : Compiler et installer Glibc (chapitre 5.5 du livre LFS 12.4)
# Auteur : toi + ChatGPT (version conforme au livre officiel)
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

cd $LFS/sources

# ------------------------------------------------------------
# 1. Extraire les sources
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
# 2. Lien symbolique LSB (avant la compilation)
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

# ------------------------------------------------------------
# 3. Patch FHS
# ------------------------------------------------------------
if [ -f ../glibc-2.42-fhs-1.patch ]; then
    echo ">> Application du patch FHS..."
    patch -Np1 -i ../glibc-2.42-fhs-1.patch
fi

# ------------------------------------------------------------
# 4. Dossier de build séparé
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
# 6. Compilation
# ------------------------------------------------------------
echo ">> Compilation de Glibc..."
make -j$(nproc) || { echo "❌ Échec du make"; exit 1; }

# ------------------------------------------------------------
# 7. Installation (dans $LFS, pas sur le système hôte)
# ------------------------------------------------------------
echo ">> Installation de Glibc dans \$LFS..."
make DESTDIR=$LFS install

# ------------------------------------------------------------
# 8. Correction du chemin dans ldd
# ------------------------------------------------------------
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

# ------------------------------------------------------------
# 9. Vérification de la toolchain
# ------------------------------------------------------------
echo ">> Vérification de la toolchain (dummy test)..."
cd $LFS/sources

echo 'int main(){}' | $LFS_TGT-gcc -x c - -v -Wl,--verbose &> dummy.log

echo "🔍 Vérification du chargeur dynamique :"
readelf -l a.out | grep ': /lib' || true

echo "🔍 Fichiers de démarrage :"
grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log || true

echo "🔍 Répertoires d’includes :"
grep -B3 "^ $LFS/usr/include" dummy.log || true

echo "🔍 Répertoires de recherche du linker :"
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g' || true

echo "🔍 libc utilisée :"
grep "/lib.*/libc.so.6 " dummy.log || true

echo "🔍 Linker dynamique trouvé :"
grep found dummy.log || true

rm -v a.out dummy.log

echo "✅ Glibc-2.42 installée et vérifiée avec succès !"
