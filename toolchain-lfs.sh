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
# 2. Setup the shell environment
# --------------------------------------------------------
echo ">> Creating LFS environment files..."

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

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

# Recharger le nouvel environnement
source ~/.bash_profile

echo "Environment initialized for LFS user."
echo

# --------------------------------------------------------
# 3. Build Binutils (Pass 1)
# --------------------------------------------------------
echo ">> Building Binutils (Pass 1)..."

cd $LFS/sources
tar -xf binutils-*.tar.* -C $LFS/sources
cd $LFS/sources/binutils-*/

mkdir -v build
cd build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT \
             --disable-nls \
             --enable-gprofng=no \
             --disable-werror \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

make
make install

# Nettoyage
cd $LFS/sources
rm -rf binutils-*/

echo "✅ Binutils Pass 1 built successfully!"
echo
echo "Next step: GCC Pass 1"
