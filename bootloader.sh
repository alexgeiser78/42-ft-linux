#!/bin/bash

# =========================================
# Script: bootloader.sh
# Goal: Install and configure GRUB bootloader
# =========================================

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

echo "==> [1/4] Creating /boot/grub directory..."
mkdir -p /boot/grub

echo "==> [2/4] Creating GRUB configuration file..."
cat > /boot/grub/grub.cfg << EOF
set default=0
set timeout=5

menuentry "ft_linux" {
    linux /boot/vmlinuz root=/dev/sda1 ro
    initrd /boot/initramfs.img
}
EOF
echo "==> grub.cfg file created."

echo "==> [3/4] Installing GRUB bootloader to the disk in /dev/sda..."
grub-install /dev/sda
echo "==> GRUB installed to /dev/sda."

echo "==> [4/4] Bootloader setup completed..."





