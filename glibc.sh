#!/bin/bash
# ========================================================
# Script: glibc-lfs-build.sh
# Goal: Compile Glibc + Libstdc++ for temporary LFS system
# Run as: lfs
# ========================================================

set -euo pipefail

# --------------------------------------------------------
# 0. Environment
# --------------------------------------------------------
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export MAKEFLAGS=-j$(nproc)
export LC_ALL=POSIX

# --------------------------------------------------------
# 1. Ensure user is 'lfs'
# --------------------------------------------------------
if [ "$(whoami)" != "lfs" ]; then
    echo "❌ You must run this script as the 'lfs' user!"
    exit 1
fi

# --------------------------------------------------------
# 2. Extract Glibc sources
# --------------------------------------------------------
cd $LFS/sources
TARBALL=$(ls glibc-*.tar.* 2>/dev/null | head -n1)
if [ -z "$TARBALL" ]; then
    echo "❌ Glibc tarball not found in $LFS/sources"
    exit 1
fi

echo ">> Extracting Glibc..."
tar -xf "$TARBALL"
cd glibc-*/

# Apply FHS patch if present
if ls ../glibc-*-fhs-*.patch 1> /dev/null 2>&1; then
    echo ">> Applying FHS patch..."
    patch -Np1 -i ../glibc-*-fhs-*.patch
fi

# --------------------------------------------------------
# 3. Create build directory
# --------------------------------------------------------
mkdir -v build
cd build

# --------------------------------------------------------
# 4. Configure Glibc
# --------------------------------------------------------
../configure --prefix=/usr \
             --host=$LFS_TGT \
             --build=$(../scripts/config.guess) \
             --disable-nscd \
             libc_cv_slibdir=/usr/lib \
             --enable-kernel=5.4

# --------------------------------------------------------
# 5. Compile Glibc
# --------------------------------------------------------
make -j$(nproc)

echo "✅ Glibc compilation finished. Installation will be done by root."

# --------------------------------------------------------
# 6. Compile Libstdc++ from GCC
# --------------------------------------------------------
cd $LFS/sources
GCC_SRC=$(ls -d gcc-*/ 2>/dev/null | head -n1)
if [ -z "$GCC_SRC" ]; then
    echo "❌ GCC source directory not found. Extract gcc-*.tar.* first!"
    exit 1
fi

cd "$GCC_SRC"/libstdc++-v3
mkdir -v build-libstdc++
cd build-libstdc++

../configure --host=$LFS_TGT \
             --build=$(../config.guess) \
             --prefix=/usr \
             --disable-multilib \
             --disable-nls \
             --disable-libstdcxx-pch \
             --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

make -j$(nproc)

echo "✅ Libstdc++ compilation finished. Installation will be done by root."
