#!/bin/bash
# ========================================================
# Script: toolchain-lfs.sh
# Goal: Configure LFS user environment and build Binutils (Pass 1)
# ========================================================

set -euo pipefail

# --------------------------------------------------------
# 1. Ensure we are the lfs user
# --------------------------------------------------------
if [ "$(whoami)" != "lfs" ]; then
    echo "❌ You must run this script as the 'lfs' user!"
    exit 1
fi

# --------------------------------------------------------
# 2. Setup the shell environment files
# --------------------------------------------------------
echo ">> Creating LFS environment files..."

# ~/.bash_profile
cat > ~/.bash_profile << "EOF"
# LFS login shell profile
# Note: do NOT exec here to allow script continuation
EOF

# ~/.bashrc
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF

# --- Définitions locales pour le script ---
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS=-j$(nproc)


echo "✅ Environment initialized for LFS user."
echo

# --------------------------------------------------------
# 3. Build Binutils (Pass 1)
# --------------------------------------------------------
echo ">> Building Binutils (Pass 1)..."

cd $LFS/sources

# Vérifie que le tarball existe
TARBALL=$(ls binutils-*.tar.* 2>/dev/null | head -n1)
if [ -z "$TARBALL" ]; then
    echo "❌ Binutils tarball not found in $LFS/sources"
    exit 1
fi

tar -xf "$TARBALL" -C $LFS/sources
cd $LFS/sources/binutils-*/

mkdir -v build
cd build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT \
             --disable-nls \
             --enable-gprofng=no \
             --disable-werror \
             --enable-new-dtags \
             --enable-default-hash-style=gnu

make -j$(nproc)
make install

# Cleanup
cd $LFS/sources
rm -rf binutils-*/

echo "✅ Binutils Pass 1 built successfully!"
echo
echo "Next step: GCC Pass 1"
