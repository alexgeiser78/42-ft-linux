#!/bin/bash

# =========================================
# Script: filesystem_setup.sh
# Goal: Create the filesystem hierarchy for ft_linux compliant with the Filesystem Hierarchy Standard (FHS)
# =========================================
echo "==> [8/...] Creating filesystem hierarchy..."

mkdir -p /{bin,boot,dev,etc,home,lib,lib64,media,mnt,opt,proc,root,run,sbin,srv,tmp,usr,var}
chmod 1777 /tmp
mkdir -p /usr/{bin,lib,sbin,local}
mkdir -p /var/{log,mail,spool,tmp}
mkdir -p /media/{cdrom,floppy}

echo "==> Filesystem hierarchy created."
