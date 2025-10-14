#!/bin/bash
# ========================================================
# Script: setup-lfs-root.sh
# Goal: Prepare the base LFS environment (run as root, idempotent)
# ========================================================

set -euo pipefail

# --------------------------------------------------------
# 1. Basic variable setup
# --------------------------------------------------------
export LFS=/mnt/lfs

if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Must be run as root!"
    exit 1
fi

echo ">> Preparing LFS environment in $LFS"

# --------------------------------------------------------
# 2. Check if $LFS is mounted
# --------------------------------------------------------
if mountpoint -q $LFS; then
    echo "✅ $LFS is mounted"
else
    echo "❌ $LFS is not mounted! Please mount it before running this script."
    echo "Example: mount /dev/sdXN /mnt/lfs"
    exit 1
fi

# --------------------------------------------------------
# 3. Create base directory structure
# --------------------------------------------------------
echo ">> Creating base directory structure..."

mkdir -pv $LFS/{etc,var}
mkdir -pv $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
    if [ -L $LFS/$i ] || [ -e $LFS/$i ]; then
        echo "⚠️  $LFS/$i already exists, skipping link..."
    else
        ln -sv usr/$i $LFS/$i
    fi
done

# --------------------------------------------------------
# 4. Handle /tools symlink cleanly
# --------------------------------------------------------
echo ">> Checking /tools link integrity..."

# Clean bad symlink inside LFS if exists
if [ -L $LFS/tools ]; then
    echo "Removing invalid symlink $LFS/tools"
    rm -f $LFS/tools
fi

mkdir -pv $LFS/tools

# Fix or create the /tools link
if [ -L /tools ]; then
    LINK_TARGET=$(readlink /tools)
    if [ "$LINK_TARGET" != "$LFS/tools" ]; then
        echo "Fixing existing /tools symlink (was pointing to: $LINK_TARGET)"
        rm -f /tools
        ln -sv $LFS/tools /
    else
        echo "✅ /tools link already correct → $LFS/tools"
    fi
elif [ -d /tools ]; then
    echo "⚠️  /tools exists as a directory, removing it"
    rm -rf /tools
    ln -sv $LFS/tools /
else
    ln -sv $LFS/tools /
fi

# --------------------------------------------------------
# 5. Create the lfs user and group
# --------------------------------------------------------
echo ">> Checking user 'lfs'..."

if ! getent group lfs >/dev/null; then
    groupadd lfs
    echo "✅ Group 'lfs' created."
fi

if ! id lfs >/dev/null 2>&1; then
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo "lfs:lfs" | chpasswd
    echo "✅ User 'lfs' created with password 'lfs'"
else
    echo "⚠️  User 'lfs' already exists."
fi

# --------------------------------------------------------
# 6. Set ownership
# --------------------------------------------------------
echo ">> Setting ownership of $LFS directories..."
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 && chown -v lfs $LFS/lib64 ;;
esac

# --------------------------------------------------------
# 7. Summary and next step
# --------------------------------------------------------
cat << "EOF"

✅ Base environment prepared successfully!

Next steps:
1. Switch to user 'lfs':
     su - lfs

2. Then run the next script:
     bash toolchain-lfs.sh

(If you need to stop later, remember to umount cleanly with:
     umount -Rv /mnt/lfs )

EOF
