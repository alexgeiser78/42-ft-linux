#!/bin/bash

# =========================================
# Script: init_setup.sh
# Goal: Configure SysVinit and Eudev
# =========================================

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

echo "==> [1/5] Creating LFS user..."
# Création de l'utilisateur lfs (si non existant)
if ! id lfs &>/dev/null; then
    useradd -m -s /bin/bash lfs
    echo "LFS user created."
else
    echo "LFS user already exists."
fi


echo "==> [2/5] Configuring inittab..." # Configure /etc/inittab for SysVinit, sets the default runlevel to 3 (multi-user mode without GUI)
cat > /etc/inittab << "EOF"
id:3:initdefault:

si::sysinit:/etc/rc.d/rc.S
l0:0:wait:/etc/rc.d/rc.0
l1:S1:wait:/etc/rc.d/rc.1
l2:2:wait:/etc/rc.d/rc.2
l3:3:wait:/etc/rc.d/rc.3
l6:6:wait:/etc/rc.d/rc.6
EOF
echo "==> inittab configured."

# The format is: id:runlevels:action:process
# si = system initialization
# lo = runlevel 0 (halt the system)
# l1 = runlevel 1 (single-user mode(maintenance), no network)
# l2 = runlevel 2 (multi-user mode without network)
# l3 = runlevel 3 (multi-user mode with network)  (by default set by inittab(id:3:initdefault:))
# l6 = runlevel 6 (reboot the system)

echo "==> [3/5] Creating /etc/rc.d directory..." # Create /etc/rc.d directory and basic rc scripts for SysVinit
mkdir -p /etc/rc.d

# Script for system initialization (mount filesystems and start udev)
echo "==> [4/5] Creating rc.S (system initialization)..."
cat > /etc/rc.d/rc.S << "EOF"
#!/bin/sh
echo "Mounting filesystems..."
mount -a


echo "Mounting /proc, /sys, and /dev..."
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

echo "Starting udev daemon..."
/usr/local/libexec/udevd --daemon
udevadm trigger --action=add

echo "Basic system initialization complete."
EOF
chmod +x /etc/rc.d/rc.S

echo "==> [5/5] Creating runlevel scripts (0,1,2,3,6)..."
for n in 0 1 2 3 6; do
    case $n in
        0)
            cat > /etc/rc.d/rc.0 << "EOF"
    #!/bin/sh
    echo "Shutting down system..."
    sync
    umount -a
    halt
    EOF
            ;;
        1)
            cat > /etc/rc.d/rc.1 << "EOF"
    #!/bin/sh
    echo "Entering single-user mode..."
    mount -t proc proc /proc
    mount -t sysfs sysfs /sys
    mount -t devtmpfs devtmpfs /dev
    EOF
            ;;
        2|3)
            cat > /etc/rc.d/rc.$n << "EOF"
    #!/bin/sh
    echo "Entering multi-user mode for runlevel $n ..."
    EOF
            ;;
        6)
            cat > /etc/rc.d/rc.6 << "EOF"
    #!/bin/sh
    echo "Rebooting system..."
    sync
    umount -a
    reboot
    EOF
            ;;
    esac
    chmod +x /etc/rc.d/rc.$n
done

echo "==> [4/4] Adding udev rules directory..." 
mkdir -p /etc/udev/rules.d

echo "==> [4/4] Init system configured (SysVinit + Eudev ready)."
