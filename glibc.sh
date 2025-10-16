#!/bin/bash
# ========================================================
# Script: glibc-lfs.sh
# Goal: Build and install Glibc + Libstdc++ for the temporary LFS system
# ========================================================

set -euo pipefail

# --------------------------------------------------------
# 0. Define LFS root and environment
# --------------------------------------------------------
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export MAKEFLAGS=-j$(nproc)
export LC_ALL=POSIX

# --------------------------------------------------------
# 1. Ensure we are the lfs user
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

echo ">> Extracting Glibc sources..."
tar -xf "$TARBALL"
cd glibc-*/

# --------------------------------------------------------
# 3. Apply FHS patch (if present)
# --------------------------------------------------------
if ls ../glibc-*-fhs-*.patch 1> /dev/null 2>&1; then
    echo ">> Applying FHS patch..."
    patch -Np1 -i ../glibc-*-fhs-*.patch
fi

# --------------------------------------------------------
# 4. Create build directory
# --------------------------------------------------------
mkdir -v build
cd build

# --------------------------------------------------------
# 5. Configure Glibc for temporary system
# --------------------------------------------------------
../configure --prefix=/usr \
             --host=$LFS_TGT \
             --build=$(../scripts/config.guess) \
             --disable-nscd \
             libc_cv_slibdir=/usr/lib \
             --enable-kernel=5.4

# --------------------------------------------------------
# 6. Build and install Glibc
# --------------------------------------------------------
make -j$(nproc)
make DESTDIR=$LFS install

# --------------------------------------------------------
# 7. Create dynamic linker symlinks
# --------------------------------------------------------
case $(uname -m) in
    i?86)
        ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
    x86_64)
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
esac

# --------------------------------------------------------
# 8. Test the Glibc installation
# --------------------------------------------------------
echo ">> Running dummy compilation to verify Glibc..."
echo 'int main(){}' | $LFS_TGT-gcc -x c - -v -Wl,--verbose &> dummy.log

echo ">> Checking dynamic linker:"
readelf -l a.out | grep ': /lib'

echo ">> Verifying startup files and headers:"
grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log
grep -B3 "^ $LFS/usr/include" dummy.log
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log

rm -v a.out dummy.log

# --------------------------------------------------------
# 9. Clean up Glibc sources
# --------------------------------------------------------
cd $LFS/sources
rm -rf glibc-*/

echo "✅ Glibc installed and verified for temporary system!"
echo

# --------------------------------------------------------
# 10. Build and install Libstdc++ from GCC-15.2.0
# --------------------------------------------------------
echo ">> Building Libstdc++ for temporary system..."
cd $LFS/sources
GCC_SRC=$(ls -d gcc-*/ 2>/dev/null | head -n1)
if [ -z "$GCC_SRC" ]; then
    echo "❌ GCC source directory not found. Extract gcc-*.tar.* first!"
    exit 1
fi
cd "$GCC_SRC"

mkdir -v build-libstdc++
cd build-libstdc++

../libstdc++-v3/configure      \
    --host=$LFS_TGT            \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

make -j$(nproc)
make DESTDIR=$LFS install

# Remove harmful libtool archive files
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la || true

echo "✅ Libstdc++ installed for temporary system!"
echo
echo "Next step: Continue with Binutils/GCC second pass"
