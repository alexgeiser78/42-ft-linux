#!/bin/bash
# =========================================
# Script: toolchain_test.sh
# Goal: Test GCC toolchain and libraries
# =========================================

set -euo pipefail

# --------------------------------------------------------
# 0. Define LFS root and target
# --------------------------------------------------------
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH

# --------------------------------------------------------
# 1. Verify GCC
# --------------------------------------------------------
echo ">> Verifying GCC..."
if command -v $LFS_TGT-gcc &> /dev/null; then
    echo "✅ GCC is installed and accessible!"
    $LFS_TGT-gcc --version | head -n1
else
    echo "❌ GCC is not installed or not in PATH!"
fi

# --------------------------------------------------------
# 2. Verify Binutils
# --------------------------------------------------------
echo ">> Verifying Binutils..."
if command -v $LFS_TGT-ld &> /dev/null && command -v $LFS_TGT-as &> /dev/null; then
    echo "✅ Binutils are installed and accessible!"
    $LFS_TGT-ld --version | head -n1
    $LFS_TGT-as --version | head -n1
else
    echo "❌ Binutils are not installed or not in PATH!"
fi

# --------------------------------------------------------
# 3. Verify Linux headers
# --------------------------------------------------------
echo ">> Verifying Linux headers..."
HEADER=$LFS/usr/include/stdio.h
if [ -f "$HEADER" ]; then
    echo "✅ Linux headers are installed ($HEADER exists)"
else
    echo "❌ Linux headers are missing!"
fi

# --------------------------------------------------------
# 4. Verify Glibc
# --------------------------------------------------------
echo ">> Verifying Glibc..."
echo 'int main(){return 0;}' > test.c
if $LFS_TGT-gcc -o test test.c -v; then
    echo "✅ Glibc test program compiled successfully!"
else
    echo "❌ Glibc test program failed to compile!"
fi
rm -f test.c test

# --------------------------------------------------------
# 5. Verify Libstdc++
# --------------------------------------------------------
echo ">> Verifying Libstdc++..."
echo 'int main(){return 0;}' > test.cpp
if $LFS_TGT-g++ -o test test.cpp -v; then
    echo "✅ Libstdc++ test program compiled successfully!"
else
    echo "❌ Libstdc++ test program failed to compile!"
fi
rm -f test.cpp test

echo
echo "✅ Toolchain verification completed!"
