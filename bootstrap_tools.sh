#!/bin/bash
# ========================================================
# Script: bootstrap_tools.sh
# Goal: Prepare a minimal toolchain in $LFS/tools
# ========================================================

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root!"
    exit 1
fi

export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH

mkdir -p $LFS/tools
mkdir -p /usr/src
cd /usr/src

# ========================================================
# BINUTILS
# ========================================================
echo "### Compilation de binutils ###"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz"
wget -c $BINUTILS_URL
tar xf $(basename $BINUTILS_URL)
cd binutils-2.41
mkdir -p build && cd build
../configure --prefix=$LFS/tools --with-sysroot=$LFS --disable-nls --disable-werror
make -j$(nproc)
make install
cd ../..
rm -rf binutils-2.41 build

# ========================================================
# GCC
# ========================================================
echo "### Compilation de gcc ###"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
wget -c $GCC_URL
tar xf $(basename $GCC_URL)
cd gcc-13.2.0
./contrib/download_prerequisites
mkdir -p build && cd build
../configure --prefix=$LFS/tools --disable-multilib --enable-languages=c,c++
make -j$(nproc)
make install
cd ../..
rm -rf gcc-13.2.0 build

# ========================================================
# MAKE
# ========================================================
echo "### Compilation de make ###"
MAKE_URL="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
wget -c $MAKE_URL
tar xzf $(basename $MAKE_URL)
cd make-4.4.1
mkdir -p build && cd build
../configure --prefix=$LFS/tools
make -j$(nproc)
make install
cd ../..
rm -rf make-4.4.1 build

# ========================================================
# XZ
# ========================================================
echo "### Compilation of xz ###"
XZ_URL="https://tukaani.org/xz/xz-5.4.2.tar.xz"
wget -c $XZ_URL
tar xf $(basename $XZ_URL)
cd xz-5.4.2
mkdir -p build && cd build
../configure --prefix=$LFS/tools
make -j$(nproc)
make install
cd ../..
rm -rf xz-5.4.2 build

# ========================================================
# END
# ========================================================
echo "### Bootstrap done ###"
echo "Temporary tools are in $LFS/tools"




#bison flex gzip bc"
    
