#!/bin/bash
# ========================================================
# Script: variable_settings.sh
# Goal: Set environment variables for LFS
# ========================================================

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root!"
    exit 1
fi

export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
umask 022
echo $LFS
umask

mkdir -pv $LFS
mount -v -t ext4 /dev/sda3 $LFS
chown root:root $LFS
chmod 755 $LFS

/sbin/swapon -v /dev/sda5

df -h
df -h $LFS


mkdir -p $LFS/tools
mkdir -p /usr/src
cd /usr/src