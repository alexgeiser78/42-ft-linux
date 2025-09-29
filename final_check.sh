#!/bin/bash

# =========================================
# Script: final_check.sh
# Goal: Perform final checks to ensure the system is set up correctly
# =========================================

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

BOOT_DIR="/boot"


echo "==> Final check starting..."

# Check if /boot directory exists
if [ ! -d "$BOOT_DIR" ]; then
    echo "Error: $BOOT_DIR directory does not exist!"
    exit 1
fi

# Check if kernel image exists
if [ ! -f "$BOOT_DIR/vmlinuz" ]; then
    echo "Error: Kernel image (vmlinuz) not found in $BOOT_DIR!"
    exit 1
fi

# Check if initramfs image exists
if [ ! -f "$BOOT_DIR/initramfs.img" ]; then
    echo "Error: Initramfs image (initramfs.img) not found in $BOOT_DIR!"
    exit 1
fi

# Check if GRUB configuration file exists
if [ ! -f "$BOOT_DIR/grub/grub.cfg" ]; then
    echo "Error: GRUB configuration file (grub.cfg) not found in $BOOT_DIR/grub!"
    exit 1
fi

echo "==> Final check completed successfully. System is set up correctly."
