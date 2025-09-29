#!/bin/bash

# =========================================
# Script: system_config.sh
# Goal: Configure basic system files (hostname, hosts, users, groups, fstab)
# =========================================

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

STUDENT_LOGIN="ageiser"

echo "==> [1/6] Setting hostname..." # Set the hostname to the student's login, defines the name of the machine
echo "$STUDENT_LOGIN" > /etc/hostname   

echo "==> [2/6] Configuring /etc/hosts..." # Configure /etc/hosts with localhost and student's login, maps hostnames to IP addresses, (127.0.0.1 localhost) = loopback address, (127.0.1.1 ageiser.localdomain ageiser) = local network address
cat > /etc/hosts << EOF
127.0.0.1   localhost
127.0.1.1   ${STUDENT_LOGIN}.localdomain ${STUDENT_LOGIN}
::1         localhost
EOF

echo "==> [3/6] Creating /etc/passwd..." # Create /etc/passwd with root, bin, nobody, and student user, list of system users
cat > /etc/passwd << EOF
root:x:0:0:root:/root:/bin/bash 
bin:x:1:1:bin:/dev/null:/usr/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/usr/bin/false
${STUDENT_LOGIN}:x:1000:1000:Student User:/home/${STUDENT_LOGIN}:/bin/bash
EOF
#login : motdepasse : UID : GID : info : home : shell


echo "==> [4/6] Creating /etc/group..." # Create /etc/group with root, bin, nogroup, and student group, list of system groups
cat > /etc/group << EOF
root:x:0:
bin:x:1:
nogroup:x:99:
${STUDENT_LOGIN}:x:1000:
EOF

echo "==> [5/6] Configuring /etc/fstab..." # Configure /etc/fstab with root, swap, and boot partitions, defines how disk partitions, various other block devices, or remote filesystems should be mounted into the filesystem, tells to the kernel which filesystems to mount at boot time and how to do so
cat > /etc/fstab << EOF
# <file system> <mount point> <type> <options> <dump> <pass>
/dev/sda1   /      ext4    defaults   1 1
/dev/sda2   swap   swap    pri=1      0 0
/dev/sda3   /boot  ext4    defaults   1 2
EOF

# Create user home directory if not exists and set ownership, permission and password
echo "==> [6/6] Creating user and home directory..."
if [ ! -d "/home/${STUDENT_LOGIN}" ]; then
    mkdir -p "/home/${STUDENT_LOGIN}"
    chown ${STUDENT_LOGIN}:${STUDENT_LOGIN} "/home/${STUDENT_LOGIN}"
fi

# Change the password of the student user to "1234."
echo "${STUDENT_LOGIN}:1234." | chpasswd


echo "==> System configuration completed successfully!"
