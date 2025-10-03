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
fetch_extract() { # download and extract an archive source from a given URL
    local url=$1 # catch the first argument (URL) 
    local tarball=$(basename $url) # catch the filename from the URL
    wget -c $url # download the file with wget, -c to continue an interrupted download
    case "$tarball" in # extract the file based on its extension
        *.tar.gz) tar xzf $tarball ;;   # z for gzip
        *.tar.xz) tar xf $tarball ;;    # x for xz
        *.tar.bz2) tar xjf $tarball ;;  # j for bzip2
    esac                                # end of case
}

build_install() { # configure, compile and install a tool from its source directory
    local dir=$1 # catch the first argument (source directory)
    local prefix=$2 # catch the second argument (installation prefix) ($LFS/tools)
    local configure_opts=${3:-""} # catch the third argument (configure options), --disable-nls...
    mkdir -p build && cd build
    ../$dir/configure --prefix=$prefix $configure_opts # launch the configure script with the given options
    make -j$(nproc) # compile the source using all available CPU cores
    make install
    cd ..
    rm -rf build $dir
}

# -----------------------
# Bootstrap tools to compile
# -----------------------
declare -A tools
tools=(
    ["binutils"]="https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz --with-sysroot=$LFS --disable-nls --disable-werror"
    # provides as (assembler), ld (linker), ar (archiver), ranlib (indexer), strip (symbol stripper)...
    ["gcc"]="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz --disable-multilib --enable-languages=c,c++"
    ["make"]="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
    ["bison"]="https://ftp.gnu.org/gnu/bison/bison-4.11.tar.xz"
    # syntax analyzer generator, needed for building GCC
    ["flex"]="https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
    # lexical analyser generator, needed for building GCC
    ["gzip"]="https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz"
    ["xz"]="https://tukaani.org/xz/xz-5.4.2.tar.xz"
    ["bc"]="https://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz"
    # calculator for building GCC
)

# -----------------------
# Tool compilation loop
# -----------------------
for tool in "${!tools[@]}"; do # loop over [@] = ["binutils"...] 
    IFS=" " read -r url opts <<< "${tools[$tool]}" # internal field separator, split the value into URL and options, tells to "read" to split the string in spaces, url and opts are set
    echo "### Compilation of $tool ###"
    fetch_extract $url
    dir=$(tar -tf $(basename $url) | head -1 | cut -f1 -d"/") # ex: dir=gcc-13.2.0, get the directory name by listing the contents of the tarball, taking the first line and cutting at the first "/"
    
    # For GCC, launch the script to download its prerequisites (GMP (big numbers), MPFR(floating point arithmetic), MPC(complex numbers))
        cd $dir
        ./contrib/download_prerequisites
        cd ..
    fi

    build_install $dir $LFS/tools "$opts"
done

# -----------------------
# End
# -----------------------
echo "### Bootstrap done ###"
echo "Temporary tools are in $LFS/tools"
