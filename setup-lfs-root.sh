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
    echo "Must be run as root!"
    exit 1
fi

echo ">> Preparing LFS environment in $LFS"

# --------------------------------------------------------
# 2. Create base directory structure
# --------------------------------------------------------
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
done

mkdir -pv $LFS/{tools,sources}
chmod -v a+wt $LFS/sources

ln -svf $LFS/tools /

# --------------------------------------------------------
# 3. Create the lfs user and group
# --------------------------------------------------------
if ! getent group lfs >/dev/null; then
    groupadd lfs
fi

if ! id lfs >/dev/null 2>&1; then
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo "lfs:lfs" | chpasswd
    echo "User 'lfs' created with password 'lfs'"
else
    echo "User 'lfs' already exists."
fi

# --------------------------------------------------------
# 4. Set ownership
# --------------------------------------------------------
chown -v lfs $LFS/{usr{,/*},var,etc,tools, sources}
case $(uname -m) in
    x86_64) chown -v lfs $LFS/lib64 ;;
esac

# --------------------------------------------------------
# 5. Summary and next step
# --------------------------------------------------------
cat << EOF

✅ Base environment prepared!

Next steps:
1. Switch to user 'lfs' :
     su - lfs

2. Then run the next script:
     bash toolchain-lfs.sh

EOF
