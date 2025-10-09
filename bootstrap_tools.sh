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

echo "### Compiling binutils ###"
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

echo "### Compiling gcc ###"
GCC_PKG="gcc-x86_64-linux-10.2.0.tar.gz"
GCC_URL="https://sourceforge.net/projects/gcc-precompiled/files/${GCC_PKG}/download"
cd /usr/src
wget -c "$GCC_URL" -O "$GCC_PKG"
tar xf "$GCC_PKG"
cd gcc-x86_64-linux-10.2.0

cp -r bin $LFS/tools/
cp -r lib $LFS/tools/
cp -r include $LFS/tools/

cd /usr/src

rm -rf gcc-x86_64-linux-10.2.0 "$GCC_PKG"

om#GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
#wget -c $GCC_URL
#tar xf $(basename $GCC_URL)
#cd gcc-13.2.0
#./contrib/download_prerequisites
#mkdir -p build && cd build
#../configure --prefix=$LFS/tools --disable-multilib --enable-languages=c,c++
#make -j$(nproc)
#make install
#cd ../..
#rm -rf gcc-13.2.0 build

# ========================================================
# MAKE
# ========================================================
echo "### Compiliing make ###"
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
echo "### Compiling xz ###"
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
# BISON
# ========================================================
echo "### Compiling bison ###"
BISON_URL="https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz"
wget -c $BISON_URL
tar xf $(basename $BISON_URL)
cd bison-3.8.2
mkdir -p build && cd build
../configure --prefix=$LFS/tools
make -j$(nproc)
make install
cd ../..
rm -rf bison-3.8.2 build

# ========================================================
# FLEX
# ========================================================
echo "### Compiling flex ###"
FLEX_URL="https://ftp.gnu.org/gnu/flex/flex-2.6.4.tar.gz"
wget -c $FLEX_URL
tar xzf $(basename $FLEX_URL)
cd flex-2.6.4
mkdir -p build && cd build
../configure --prefix=$LFS/tools
make -j$(nproc)
make install
cd ../..
rm -rf flex-2.6.4 build

# ========================================================
# GZIP
# ========================================================
echo "### Compiling gzip ###"
GZIP_URL="https://ftp.gnu.org/gnu/gzip/gzip-1.12.tar.xz"
wget -c $GZIP_URL
tar xf $(basename $GZIP_URL)
cd gzip-1.12
mkdir -p build && cd build
../configure --prefix=$LFS/tools
make -j$(nproc)
make install
cd ../..
rm -rf gzip-1.12 build

# ========================================================
# BC
# ========================================================
echo "### Compiling bc ###"
BC_URL="https://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz"
wget -c $BC_URL
tar xzf $(basename $BC_URL)
cd bc-1.07.1
mkdir -p build && cd build
../configure --prefix=$LFS/tools
make -j$(nproc)
make install
cd ../..
rm -rf bc-1.07.1 build

# ========================================================
# END
# ========================================================
echo "### Bootstrap done ###"
echo "Temporary tools are in $LFS/tools"





    
