#!/bin/bash
# ========================================================
# Script: toolchain.sh
# Goal: Set up the LFS toolchain environment and build the first tool
# ========================================================

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root!"
    exit 1
fi

# Var definition
export LFS=/mnt/lfs

# cross toolchain target
export LFS_TGT=$(uname -m)-lfs-linux-gnu # defines the target triplet(platform that will be compiled and npot the host) LFS_TGT = x86_64-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH # add the tools bin directory LFS to the PATH

# ========================================================
# 1. Mounting virtual filesystems
# ========================================================

echo ">> Mounting virtual filesystems..."
mount -v --bind /dev $LFS/dev # use the actual host to provide devices files
mount -v --bind /dev/pts $LFS/dev/pts # for pseudo terminal devices like ssh sessions
mount -vt proc proc $LFS/proc # for process and kernel information, like ps, top, free
mount -vt sysfs sysfs $LFS/sys # for hardware information, like lspci, lsusb, dmidecode
mount -vt tmpfs tmpfs $LFS/run # mount a tmpfs to hold runtime variable data like PIDs and sockets, allocating ram for it

if [ -h $LFS/dev/shm ]; then
    mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi
# create a directory for shared memory if /dev/shm is a symbolic link used by POSIX

# ========================================================
# 2. Setting up the toolchain environment
# ========================================================

echo ">> Creating tools directory..."
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin} # create essential directories
for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done
mkdir -pv $LFS/tools # create the tools directory where the temporary toolchain will be installed
ln -svf $LFS/tools / # create a symlink from /tools to $LFS/tools for easier access
echo ">> Setting ownership..."
chown -v root:root $LFS/{usr,lib,var,etc,bin,sbin,tools} # set ownership of critical directories to root

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac
# if the host is x86_64, create a lib64 directory for 64-bit libraries

# ========================================================
# Adding the LFS User
# ========================================================
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
passwd lfs
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac
su - lfs

# ========================================================
# Setting up the environnemt
# ========================================================
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
EOF
[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
export Makeflags='-j6' # Adjust according to your CPU cores
cat >> ~/.bashrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF
source ~/.bash_profile

# ========================================================
# 3. Compiling the first temporary tool : Binutils - Pass 1
# ========================================================

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
             --disable-werror

make
make install

cd $LFS/sources
rm -rf binutils-*/

echo ">> Binutils Pass 1 built successfully!"

# ========================================================
# 4. (Prochaine étape)
# ========================================================
#echo
#echo "=== NEXT STEP: GCC Pass 1 ==="
#echo "You can now append the GCC build steps here or run a separate script."
#echo
#echo "Remember: you can enter the chroot environment later with:"
#echo "  chroot \"$LFS\" /usr/bin/env -i HOME=/root TERM=\"\$TERM\" PS1='(lfs chroot) \u:\w\$ ' PATH=/usr/bin:/usr/sbin /bin/bash --login +h"
