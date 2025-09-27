#!/bin/bash

# =========================================
# Script: kernel_setup.sh
# Goal: Download, configure, compile and install Linux kernel
# =========================================

# Check if we are in root mode, because to install software and compile the kernel we need to be one

if [ "$(id -u)" -ne 0 ]; then             #if id user notequal to 0 (root)
    echo "This script must be run as root!"
    exit 1
fi

# Variables declaration
STUDENT_LOGIN="ageiser"
KERNEL_VERSION="6.1.54"                # stable and LTS (long time support)
KERNEL_SRC="/usr/src/kernel-$KERNEL_VERSION" #rep for kernel source files
BOOT_DIR="/boot"                             #rep for compiled kernel(boot)
SRC_DIR="/usr/src/kernel_sources"                   #rep for other sources if needed

mkdir -p "$SRC_DIR"                    #other sources rep
mkdir -p "$KERNEL_SRC"                 #compiled kernel rep

# Downloading the kernel
echo "==> [2/...] Downloading Linux kernel $KERNEL_VERSION..."
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz -C "$KERNEL_SRC" --strip-components=1 #extract to KERNEL_SRC and remove the first directory level
cd "$KERNEL_SRC"

# kernel configuration
echo "==> [3/...] Configuring kernel..."
make defconfig    # create a default configuration, menuconfig for more options

# kernel Compiling
echo "==> [4/...] kernel Compiling..."
make -j$(nproc)     # compile with all processors

# kernel and modules Installation
echo "==> [5/...] kernel and modules Installation..."
make modules_install  # installation of the kernel in /boot and /lib/modules
make install

# Copy the kernel compiled in /boot with my login in the name
echo "==> [6/...] Copying kernel image to $BOOT_DIR..."
cp "$KERNEL_SRC/arch/x86/boot/bzImage" "$BOOT_DIR/vmlinuz-$KERNEL_VERSION-$STUDENT_LOGIN"

# Cleanup\
echo "==> [7/...] Cleaning up..."
cd /usr/src
rm -rf "$KERNEL_SRC" linux-$KERNEL_VERSION.tar.xz

echo "==> Kernel $KERNEL_VERSION compiled and installed successfully!"

