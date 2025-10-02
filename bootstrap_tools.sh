#!/bin/bash


# ========================================================
# bootstrap_tools.sh
# Bootstrap des outils LFS / FT_Linux
# ========================================================

set -euo pipefail

# -----------------------
# Vérification root
# -----------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être lancé en root"
    exit 1
fi

# -----------------------
# Variables LFS
# -----------------------
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH

mkdir -p $LFS/tools
mkdir -p /usr/src
cd /usr/src

# -----------------------
# Fonctions utilitaires
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

# -----------------------
# Liste des outils à compiler
# -----------------------
declare -A tools
tools=(
    ["binutils"]="https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz --with-sysroot=$LFS --disable-nls --disable-werror"
    ["gcc"]="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz --disable-multilib --enable-languages=c,c++"
    ["make"]="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
    ["bison"]="https://ftp.gnu.org/gnu/bison/bison-4.11.tar.xz"
    ["flex"]="https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
    ["gzip"]="https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz"
    ["xz"]="https://tukaani.org/xz/xz-5.4.2.tar.xz"
    ["bc"]="https://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz"
)

# -----------------------
# Compilation des outils
# -----------------------
for tool in "${!tools[@]}"; do
    IFS=" " read -r url opts <<< "${tools[$tool]}"
    echo "### Compilation de $tool ###"
    fetch_extract $url
    dir=$(tar -tf $(basename $url) | head -1 | cut -f1 -d"/")
    
    # Pour GCC, lancer le script download_prerequisites
    if [ "$tool" == "gcc" ]; then
        cd $dir
        ./contrib/download_prerequisites
        cd ..
    fi

    build_install $dir $LFS/tools "$opts"
done

# -----------------------
# Fin
# -----------------------
echo "### Bootstrap terminé ###"
echo "Les outils temporaires sont dans $LFS/tools"
echo "Vous pouvez maintenant entrer dans le chroot pour construire le système final"
