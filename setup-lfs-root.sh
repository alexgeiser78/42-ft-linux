#!/bin/bash
# ========================================================
# Script: setup-lfs-root.sh
# Goal: Prepare the base LFS environment (run as root)
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
# 2. Create base directory structure
# --------------------------------------------------------
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
    # Create symlinks like /mnt/lfs/bin -> /mnt/lfs/usr/bin
    if [ ! -L $LFS/$i ]; then
        ln -sv usr/$i $LFS/$i || true
    fi
done

# --------------------------------------------------------
# 3. Handle /tools symlink cleanly
# --------------------------------------------------------
echo ">> Checking /tools link integrity..."

# Remove any bad symlink /mnt/lfs/tools
if [ -L $LFS/tools ]; then
    echo "⚠️  Removing invalid symlink $LFS/tools"
    rm -f $LFS/tools
fi

# Ensure /tools does not point to itself or exist as dir
if [ -L /tools ]; then
    LINK_TARGET=$(readlink /tools)
    if [ "$LINK_TARGET" != "$LFS/tools" ]; then
        echo "⚠️  Removing old /tools symlink ($LINK_TARGET)"
        rm -f /tools
    fi
elif [ -d /tools ]; then
    echo "⚠️  Removing existing /tools directory"
    rm -rf /tools
fi

# Create a fresh, clean /mnt/lfs/tools and link it
mkdir -pv $LFS/tools
ln -sv $LFS/tools /tools

# --------------------------------------------------------
# 4. Create the lfs user and group
# --------------------------------------------------------
if ! getent group lfs >/dev/null; then
    groupadd lfs
    echo "✅ Group 'lfs' created."
fi

if ! id lfs >/dev/null 2>&1; then
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo "lfs:lfs" | chpasswd
    echo "✅ User 'lfs' created with password 'lfs'"
else
    echo "ℹ️  User 'lfs' already exists."
fi

# --------------------------------------------------------
# 5. Set ownership
# --------------------------------------------------------
echo ">> Setting ownership of LFS directories..."
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 && chown -v lfs $LFS/lib64 ;;
esac

# --------------------------------------------------------
# 6. Summary and next steps
# --------------------------------------------------------
cat << EOF

✅ Base environment prepared successfully!

Next steps:
1. Switch to the 'lfs' user:
     su - lfs

2. Then run the next script (toolchain build):
     bash toolchain-lfs.sh

You can safely unmount later with:
     umount -Rv \$LFS

EOF
