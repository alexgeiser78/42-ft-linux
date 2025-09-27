#!/bin/bash

# =========================================
# Script: bootstrap_tools.sh
# Goal: Build & install essential tools from source for ft_linux
# =========================================

# Check if we are in root mode, because to install software and compile the kernel we need to be one

if [ "$(id -u)" -ne 0 ]; then             #if id user notequal to 0 (root)
    echo "This script must be run as root!"
    exit 1
fi

cd /usr/src
apt update                             #standard linux update




# Bootstrap Essentials Packages Setup
echo "==> [1/...] Bootstrap installation"

# ---------------------------
# 1. WGET   used to download the kernel source code
# ---------------------------
wget https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz
tar xf wget-1.21.4.tar.gz
cd wget-1.21.4
./configure --prefix=/usr     # configure scipt used to prepare the comiplation, will be installed in /usr 
make -j$(nproc)               # compile with all processors 
make install
cd ..
rm -rf wget-1.21.4 wget-1.21.4.tar.gz

# ---------------------------
# 2. CURL   used to download other scripts or dependencies
# ---------------------------
wget https://curl.se/download/curl-8.4.0.tar.xz
tar xf curl-8.4.0.tar.xz
cd curl-8.4.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf curl-8.4.0 curl-8.4.0.tar.xz
                    
# ---------------------------
# 3. TAR    used for .tar archives
# ---------------------------
wget https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
tar xf tar-1.35.tar.xz
cd tar-1.35
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf tar-1.35 tar-1.35.tar.xz

# ---------------------------
# 4. GZIP    used for .gz archives
# ---------------------------
wget https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz
tar xf gzip-1.13.tar.xz
cd gzip-1.13
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf gzip-1.13 gzip-1.13.tar.xz

# ---------------------------
# 5. XZ-UTILS    used for .xz archives (kernel is .tar.xz)
# ---------------------------
wget https://tukaani.org/xz/xz-5.4.5.tar.xz
tar xf xz-5.4.5.tar.xz
cd xz-5.4.5
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf xz-5.4.5 xz-5.4.5.tar.xz

# ---------------------------
# 6. MAKE    used for make
# ---------------------------
wget https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
tar xf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf make-4.4.1 make-4.4.1.tar.gz

# ---------------------------
# 7. GCC    used for compilation  (GMP/MPFR/MPC dependencies needed) (GNU Multiple Precision Arithmetic Library) (Multiple Precision Floating-Point Reliable Library) MPC (Multiple Precision Complex Library)
# ---------------------------
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
tar xf gcc-13.2.0.tar.xz
cd gcc-13.2.0
./contrib/download_prerequisites   # download gmp, mpfr, mpc
mkdir build && cd build
../configure --prefix=/usr --enable-languages=c,c++ --disable-multilib #(only c and c++ to compile the kernel and only for 64 bits)
make -j$(nproc)
make install
cd ../..
rm -rf gcc-13.2.0 gcc-13.2.0.tar.xz	

# ---------------------------
# 8. BISON   used by the kernel as a syntax analyser generator
# ---------------------------
wget https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz
tar xf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf bison-3.8.2 bison-3.8.2.tar.xz	

# ---------------------------
# 9. FLEX  used by the kernel as a lexical analyser generator
# ---------------------------
wget https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
tar xf flex-2.6.4.tar.gz
cd flex-2.6.4
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf flex-2.6.4 flex-2.6.4.tar.gz		       

# ---------------------------
# 10. BC used by the kernel as a calculator in some scripts
# ---------------------------
wget https://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz
tar xf bc-1.07.1.tar.gz
cd bc-1.07.1
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf bc-1.07.1 bc-1.07.1.tar.gz	

# ---------------------------
# 11. LINUX KERNEL HEADERS
# ---------------------------
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.6.tar.xz
tar xf linux-6.6.6.tar.xz
cd linux-6.6.6
make mrproper                        # clean the source directory of the kernel
make INSTALL_HDR_PATH=dest headers_install  # install the kernel headers in temporary repo dest
find dest/include \( -name .install -o -name ..install.cmd \) -delete  # remove unnecessary files added during the installation (install and install.cmd)
cp -rv dest/include/* /usr/include          # copy the headers to the system directory
cd ..
rm -rf linux-6.6.6 linux-6.6.6.tar.xz

gcc --version
make --version
wget --version
curl --version


echo "==> Bootstrap tools installation finished successfully!"
