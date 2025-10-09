#!/bin/bash
# ========================================================
# Script: packandpat.sh
# Goal: Package and patch source files
# ========================================================

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root!"
    exit 1
fi

export LFS=/mnt/lfs

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

cd $LFS/sources

wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv https://www.linuxfromscratch.org/lfs/view/stable/md5sums

ls -l

less wget-list-sysv
less md5sums

wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources

pushd $LFS/sources
md5sum -c md5sums
popd

chown root:root $LFS/sources/*