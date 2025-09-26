#!/bin/bash

# =========================================
# Script: system_setup.sh
# Goal: Install the mandatory softwares and kernel compilation for ft_linux
# =========================================

# Check if we are in root mode, because to install software and compile the kernel we need to be one

if [ "$(id -u)" -ne 0 ]; then             #if id user notequal to 0 (root)
    echo "This script must be launcher in root mode!"
    exit 1
fi

# Var configuration
STUDENT_LOGIN="ageiser"
KERNEL_VERSION="6.1.54"                # stable and LTS (long time support)
KERNEL_SRC="/usr/src/kernel-$KERNEL_VERSION" #rep for kernel source files
BOOT_DIR="/boot"                             #rep for compiled kernel(boot)

# Environnement Setup
echo "==> Environnement Setup..."
apt update                             #standard linux update
apt install -y wget                    #to download the kernel source code  
apt install -y curl 	               #same but for other scripts or dep
apt install -y tar 		       #for .tar archives
apt install -y gzip 		       #for .gz archives
apt install -y xz-utils	               #for .xz archives (kernel is .tar.xz)
apt install -y make		       #for make
apt install -y gcc		       #for compilation 
apt install -y bison		    #syntax analyser generator used by ker 
apt install -y flex		       #same as bison but for lexical
apt install -y bc		       #calculator used in some kernel scr

# Essential Repertory Creation  
mkdir -p "$KERNEL_SRC"

# Downloading and compiling the kernel
echo "==> Downloading and compiling the kernel..."
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz -C "$KERNEL_SRC" --strip-components=1
cd "$KERNEL_SRC"

# Kernel configuration
# make menuconfig  # <-- not useful, maybe to remove because defconfig does the job

make defconfig    # create a default configuration


#to check this part: maybe to remove
# Ajouter le login étudiant dans le nom du kernel (modification du Makefile)
# à adapter selon le kernel
# sed -i "s/EXTRAVERSION =/EXTRAVERSION = -$STUDENT_LOGIN/" Makefile

# Compiling
make -j$(nproc)     # compile with all processors 
make modules_install  # installation of the kernel in /boot and /lib/modules
make install

# Copy the kernel compiled in /boot with my login in the name
cp "$KERNEL_SRC/arch/x86/boot/bzImage" "$BOOT_DIR/vmlinuz-$KERNEL_VERSION-$STUDENT_LOGIN"

# 4️⃣ Installation des paquets essentiels
echo "==> Installation des paquets essentiels..."
apt install -y acl attr autoconf automake bash bc binutils bison bzip2 coreutils \
check dejaGNU diffutils eudev e2fsprogs expat expect file findutils flex gawk gcc \
gdbm gettext glibc gmp gperf grep groff grub gzip iana-etc inetutils intltool \
iproute2 kbd kmod less libcap libpipeline libtool m4 make man-db manpages \
mpc mpfr ncurses patch perl pkg-config procps psmisc readline sed shadow sysklogd \
sysvinit tar tcl texinfo tzdata udev util-linux vim xml-parser xz-utils zlib1g

# 5️⃣ Configuration du bootloader (GRUB)
echo "==> Configuration du bootloader GRUB..."
grub-install /dev/sda
update-grub

# 6️⃣ Vérifications finales
echo "==> Vérifications finales..."
ls "$BOOT_DIR"
uname -r
which bash vim grub udev

echo "==> Installation terminée avec succès !"

