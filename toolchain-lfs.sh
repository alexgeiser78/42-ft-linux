#!/bin/bash
# ========================================================
# Script: toolchain-lfs.sh
# Goal: Prepare LFS user environment and build Binutils (Pass 1)
# ========================================================

set -euo pipefail

# --------------------------------------------------------
# 0. Define LFS root
# --------------------------------------------------------
export LFS=/mnt/lfs

# --------------------------------------------------------
# 1. If running as root, mount virtual filesystems and switch to lfs
# --------------------------------------------------------
if [ "$(id -u)" -eq 0 ]; then
    echo ">> Mounting LFS virtual filesystems..."
    mount -v --bind /dev $LFS/dev
    mount -v --bind /dev/pts $LFS/dev/pts
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run

    if [ -h $LFS/dev/shm ]; then
        mkdir -pv $LFS/$(readlink $LFS/dev/shm)
    fi

    echo ">> Switching to user 'lfs'..."
    exec su - lfs
fi

# --------------------------------------------------------
# 2. Ensure we are the lfs user
# --------------------------------------------------------
if [ "$(whoami)" != "lfs" ]; then
    echo "❌ You must run this script as the 'lfs' user!"
    exit 1
fi

# --------------------------------------------------------
# 3. Setup environment variables
# --------------------------------------------------------
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS=-j$(nproc)

# --------------------------------------------------------
# 4. Setup shell environment files
# --------------------------------------------------------
echo ">> Creating LFS environment files..."

cat > ~/.bash_profile << "EOF"
# LFS login shell profile
# Note: do NOT exec here to allow script continuation
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

echo "✅ Environment initialized for LFS user."
echo

# --------------------------------------------------------
# 5. Build Binutils (Pass 1)
# --------------------------------------------------------
echo ">> Building Binutils (Pass 1)..."

cd $LFS/sources

# Verify that the Binutils tarball exists
TARBALL=$(ls binutils-*.tar.* 2>/dev/null | head -n1)
if [ -z "$TARBALL" ]; then
    echo "❌ Binutils tarball not found in $LFS/sources"
    exit 1
fi

# Clean any previous attempt
rm -rf binutils-*/

# Extract source
tar -xf "$TARBALL"
cd binutils-*/

# Create build directory
mkdir -v build
cd build

# Configure
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT \
             --disable-nls \
             --enable-gprofng=no \
             --disable-werror \
             --enable-new-dtags \
             --enable-default-hash-style=gnu

# Build
make -j$(nproc)

# Install
make install

# Clean up sources
cd $LFS/sources
rm -rf binutils-*/

# Verify installation
echo
echo "✅ Binutils Pass 1 built successfully!"
echo "Checking installed binaries:"
$LFS/tools/bin/x86_64-lfs-linux-gnu-ar --version | head -n1
$LFS/tools/bin/x86_64-lfs-linux-gnu-as --version | head -n1
$LFS/tools/bin/x86_64-lfs-linux-gnu-ld --version | head -n1


echo
echo "Next step: GCC Pass 1"
