#!/bin/bash
# ========================================================
# Script: toolchain-lfs.sh
# Goal: Configure LFS user environment and build Binutils (Pass 1)
# ========================================================

set -euo pipefail

# --------------------------------------------------------
# 1. Ensure we are the lfs user
# --------------------------------------------------------
if [ "$(whoami)" != "lfs" ]; then
    echo "❌ You must run this script as the 'lfs' user!"
    exit 1
fi

# --------------------------------------------------------
# 2. Setup the shell environment files
# --------------------------------------------------------
echo ">> Creating LFS environment files..."

# ~/.bash_profile
cat > ~/.bash_profile << "EOF"
# LFS login shell profile
# Note: do NOT exec here to allow script continuation
EOF

# ~/.bashrc
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

# Source bashr
