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
export LC_ALL=POSIX


# --------------------------------------------------------
# 4. Setup shell environment files
# --------------------------------------------------------
#echo ">> Creating LFS environment files..."

#cat > ~/.bash_profile << "EOF"
# LFS login shell profile
# Note: do NOT exec here to allow script continuation
#EOF

#cat > ~/.bashrc << "EOF"
#set +h
#umask 022
#LFS=/mnt/lfs
#LC_ALL=POSIX
#LFS_TGT=$(uname -m)-lfs-linux-gnu
#PATH=/usr/bin
#if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
#PATH=$LFS/tools/bin:$PATH
#CONFIG_SITE=$LFS/usr/share/config.site
#export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
#export MAKEFLAGS=-j$(nproc)
#EOF

#echo "✅ Environment initialized for LFS user."
#echo

# --------------------------------------------------------
# 5. Build Binutils (Pass 1)
# --------------------------------------------------------
#echo ">> Building Binutils (Pass 1)..."

#cd $LFS/sources

# Verify that the Binutils tarball exists
#TARBALL=$(ls binutils-*.tar.* 2>/dev/null | head -n1)
#if [ -z "$TARBALL" ]; then
    #echo "❌ Binutils tarball not found in $LFS/sources"
    #exit 1
#fi

# Clean any previous attempt
#rm -rf binutils-*/

# Extract source
#tar -xf "$TARBALL"
#cd binutils-*/

# Create build directory
#mkdir -v build
#cd build

# Configure
#../configure --prefix=$LFS/tools \
#             --with-sysroot=$LFS \
#             --target=$LFS_TGT \
#             --disable-nls \
#             --enable-gprofng=no \
#             --disable-werror \
#             --enable-new-dtags \
#             --enable-default-hash-style=gnu

# Build
#make -j$(nproc)

# Install
#make install

# Clean up sources
#cd $LFS/sources
#rm -rf binutils-*/

# Verify installation
#echo
#echo "✅ Binutils Pass 1 built successfully!"
#echo "Checking installed binaries:"
#$LFS/tools/bin/x86_64-lfs-linux-gnu-ar --version | head -n1
#$LFS/tools/bin/x86_64-lfs-linux-gnu-as --version | head -n1
#$LFS/tools/bin/x86_64-lfs-linux-gnu-ld --version | head -n1


#echo
#echo "Next step: GCC Pass 1"

# --------------------------------------------------------
# 6. Build GCC (Pass 1)
# --------------------------------------------------------
#cd $LFS/sources

#echo ">> Extracting GCC sources..."
#tar -xf gcc-*.tar.* -C $LFS/sources
#cd $LFS/sources/gcc-*/

# Extract prerequisites (MPFR, GMP, MPC)
#tar -xf ../mpfr-*.tar.* 
#mv -v mpfr-* mpfr
#tar -xf ../gmp-*.tar.* 
#mv -v gmp-* gmp
#tar -xf ../mpc-*.tar.* 
#mv -v mpc-* mpc

#case $(uname -m) in
#  x86_64)
#    sed -e '/m64=/s/lib64/lib/' \
#        -i.orig gcc/config/i386/t-linux64
# ;;
#esac

#mkdir -v build
#cd build

#../configure --target=$LFS_TGT \
#             --prefix=$LFS/tools \
#             --with-glibc-version=2.42 \
#             --with-sysroot=$LFS \
#             --with-newlib \
#             --without-headers \
#             --enable-default-pie      \
#             --enable-default-ssp      \
#             --disable-nls             \
#             --disable-shared          \
#             --disable-multilib        \
#             --disable-threads         \
#             --disable-libatomic       \
#             --disable-libgomp         \
#             --disable-libquadmath     \
#             --disable-libssp          \
#             --disable-libvtv          \
#             --disable-libstdcxx       \
#             --enable-languages=c,c++

#make
#make install



# Cleanup
#cd $LFS/sources
#rm -rf gcc-*/

#echo "✅ GCC Pass 1 built successfully!"
#echo

# Vérif rapide de la présence du compilateur
#ls -l $LFS/tools/bin/$LFS_TGT-gcc
#$LFS/tools/bin/$LFS_TGT-gcc --version | head -n1
#echo "Next step: Linux API Headers + Glibc (temporary system)"

# --------------------------------------------------------
# 7. Install Linux API Headers
# --------------------------------------------------------
cd $LFS/sources

# Vérifie la présence du tarball du kernel
TARBALL=$(ls linux-*.tar.* 2>/dev/null | head -n1)
if [ -z "$TARBALL" ]; then
    echo "❌ Linux kernel source tarball not found in $LFS/sources"
    exit 1
fi

echo ">> Extracting Linux kernel sources..."
tar -xf "$TARBALL"
cd linux-*/

echo ">> Installing Linux API headers..."
make mrproper   # Clean any previous build artifacts
make headers_install INSTALL_HDR_PATH=$LFS/usr

# Supprimer les fichiers non-headers
find usr/include -type f ! -name '*.h' -delete

# Copier les headers propres dans $LFS/usr
cp -rv usr/include $LFS/usr

# Clean up sources
cd $LFS/sources
rm -rf linux-*/

# check
if [ -f $LFS/usr/include/stdio.h ]; then
    echo "✅ Verification passed: stdio.h exists in $LFS/usr/include"
else
    echo "❌ Verification failed: stdio.h missing in $LFS/usr/include"
fi

echo "✅ Linux API headers installed successfully!"
echo
echo "Next step: Build Glibc for the temporary system"
