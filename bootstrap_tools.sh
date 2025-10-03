#!/bin/bash

# ========================================================
# Script: bootstrap_tools.sh
# Goal: Prepare a minimal toolchain in /mnt/lfs/tools
# ========================================================

set -euo pipefail #-e,  Exit on error
                  #-u,  Unset variables are errors
                  #-o pipefail, Catch errors in pipes |


if [ "$(id -u)" -ne 0 ]; then # if not equal to 0 (root)
    echo "This script must be run as root!"
    exit 1
fi

# -----------------------
# Variables LFS
# -----------------------
export LFS=/mnt/lfs # mounting point for the futur LFS system, temporary root folder 
export LFS_TGT=$(uname -m)-lfs-linux-gnu # toolchain target, catch the architecture of the host machine (x86_64, i686, etc.) and append -lfs-linux-gnu, used for GCC and Binutils
export PATH=$LFS/tools/bin:$PATH # priority to the tools in $LFS/tools/bin to prevent conflicts with host tools

mkdir -p $LFS/tools # create the tools directory, where the temporary toolchain will be installed
mkdir -p /usr/src # folder where the sources will be downloaded and compiled
cd /usr/src 

# -----------------------
# Utility functions
# -----------------------
fetch_extract() {
    local url=$1
    local tarball=$(basename $url)
    wget -c $url
    case "$tarball" in
        *.tar.gz) tar xzf $tarball ;;
        *.tar.xz) tar xf $tarball ;;  
        *.tar.bz2) tar xjf $tarball ;;
    esac     
}                           
# download and extract an archive source from a given URL
# catch the first argument (URL) 
# catch the filename from the URL
# download the file with wget, -c to continue an interrupted download
# extract the file based on its extension
# z for gzip
# x for xz
# j for bzip2


build_install() {
    local dir=$1
    local prefix=$2
    local configure_opts=${3:-""}
    mkdir -p build && cd build
    ../$dir/configure --prefix=$prefix $configure_opts
    make -j$(nproc)
    make install
    cd ..
    rm -rf build $dir
}
# configure, compile and install a tool from its source directory
# catch the first argument (source directory)
# catch the second argument (installation prefix) ($LFS/tools)
# catch the third argument (configure options), --disable-nls...
# launch the configure script with the given options
# compile the source using all available CPU cores

# -----------------------
# Bootstrap tools to compile
# -----------------------
declare -A tools
tools=(
    ["binutils"]="https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz --with-sysroot=$LFS --disable-nls --disable-werror"  
    ["gcc"]="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz --disable-multilib --enable-languages=c,c++"
    ["make"]="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
    ["bison"]="https://ftp.gnu.org/gnu/bison/bison-4.8.2.tar.xz"   
    ["flex"]="https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"   
    ["gzip"]="https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz"
    ["xz"]="https://tukaani.org/xz/xz-5.4.2.tar.xz"
    ["bc"]="https://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz"
    
)

# provides as (assembler), ld (linker), ar (archiver), ranlib (indexer), strip (symbol stripper)...
# syntax analyzer generator, needed for building GCC
# lexical analyser generator, needed for building GCC
# calculator for building GCC

# -----------------------
# Tool compilation loop
# -----------------------
for tool in "${!tools[@]}"; do
    IFS=" " read -r url opts <<< "${tools[$tool]}"
    echo "### Compilation of $tool ###"
    fetch_extract $url
    dir=$(tar -tf $(basename $url) | head -1 | cut -f1 -d"/")
    
    if [ "$tool" == "gcc" ]; then
        cd $dir
        ./contrib/download_prerequisites
        cd ..
    fi

    build_install $dir $LFS/tools "$opts"
done
# loop over [@] = ["binutils"...]
# internal field separator, split the value into URL and options, tells to "read" to split the string in spaces, url and opts are set
# ex: dir=gcc-13.2.0, get the directory name by listing the contents of the tarball, taking the first line and cutting at the first "/"
    # For GCC, launch the script to download its prerequisites (GMP (big numbers), MPFR(floating point arithmetic), MPC(complex numbers))

# -----------------------
# End
# -----------------------
echo "### Bootstrap done ###"
echo "Temporary tools are in $LFS/tools"
