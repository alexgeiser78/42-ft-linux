#!/bin/bash

# =========================================
# Script: packages_install.sh
# Goal: Install essential packages for ft_linux
# =========================================

cd /usr/src

# ---------------------------
# 1. Acl used for Access Control Lists on filesystems 
# ---------------------------
wget https://download.savannah.gnu.org/releases/acl/acl-2.3.1.tar.gz -O /tmp/acl-2.3.1.tar.gz
tar -xzf acl-2.3.1.tar.gz
cd acl-2.3.1
./configure --prefix=/usr
make
make install
cd ..
rm -rf acl-2.3.1 acl-2.3.1.tar.gz
echo "==> Acl installed."

# ---------------------------
# 2. Attr used for Extended Attributes on filesystems 
# ---------------------------
wget https://download.savannah.gnu.org/releases/attr/attr-2.5.1.tar.gz
tar -xf attr-2.5.1.tar.gz
cd attr-2.5.1
./configure
make -j$(nproc)
make install
cd ..
rm -rf attr-2.5.1 attr-2.5.1.tar.gz
echo "==> Attr installed."

# ---------------------------
# 3. Autoconf used for generating configuration scripts 
# ---------------------------
wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
tar -xf autoconf-2.71.tar.gz
cd autoconf-2.71
./configure
make -j$(nproc)
make install
cd ..
rm -rf autoconf-2.71 autoconf-2.71.tar.gz
echo "==> Autoconf installed."

# ---------------------------
# 4. Automake used for generating Makefile.in files from Makefile.am 
# ---------------------------
wget https://ftp.gnu.org/gnu/automake/automake-1.17.3.tar.gz
tar -xf automake-1.17.3.tar.gz
cd automake-1.17.3
./configure
make -j$(nproc)
make install
cd ..
rm -rf automake-1.17.3 automake-1.17.3.tar.gz
echo "==> Automake installed."

# ---------------------------
# 5. Bash used for the Bourne Again SHell
# ---------------------------
wget https://ftp.gnu.org/gnu/bash/bash-5.2.15.tar.gz
tar -xf bash-5.2.15.tar.gz
cd bash-5.2.15
./configure
make -j$(nproc)
make install
cd ..
rm -rf bash-5.2.15 bash-5.2.15.tar.gz
echo "==> Bash installed."

# ---------------------------
# 6. BC already done in bootstrap_tools.sh
# ---------------------------

# ---------------------------
# 7. Binutils used for binary tools like ld, as, objdump, etc.
# ---------------------------
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz
tar -xf binutils-2.41.tar.gz
cd binutils-2.41
./configure --prefix=/usr/local  # Install in /usr/local to avoid conflicts with system binutils
make -j$(nproc)
make install
cd ..
rm -rf binutils-2.41 binutils-2.41.tar.gz
echo "==> Binutils installed."

# ---------------------------
# 8. Bzip2 used for .bz2 archives
# ---------------------------
wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
tar -xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make -j$(nproc)
make install PREFIX=/usr/local
cd ..
rm -rf bzip2-1.0.8 bzip2-1.0.8.tar.gz
echo "==> Bzip2 installed."

# ---------------------------
# 9. Check used for running tests
# ---------------------------
wget https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz
tar -xf check-0.15.2.tar.gz
cd check-0.15.2
./configure --prefix=/usr/local
make -j$(nproc)
make install
cd ..
rm -rf check-0.15.2 check-0.15.2.tar.gz
echo "==> Check installed."

# ---------------------------
# 10. Coreutils used for basic file, shell and text manipulation utilities
# ---------------------------
wget https://ftp.gnu.org/gnu/coreutils/coreutils-9.3.tar.xz
tar -xf coreutils-9.3.tar.xz
cd coreutils-9.3
./configure --prefix=/usr/local
make -j$(nproc)
make install
cd ..
rm -rf coreutils-9.3 coreutils-9.3.tar.xz
echo "==> Coreutils installed."

# ---------------------------
# 11. DejaGNU used for testing other packages
# ---------------------------
wget https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.7.3.tar.gz
tar -xf dejagnu-1.7.3.tar.gz
cd dejagnu-1.7.3
./configure --prefix=/usr/local
make -j$(nproc)
make install
cd ..
rm -rf dejagnu-1.7.3 dejagnu-1.7.3.tar.gz
echo "==> DejaGNU installed."

# ---------------------------
# 12. Diffutils used for comparing files
# ---------------------------
wget https://ftp.gnu.org/gnu/diffutils/diffutils-3.9.tar.xz
tar -xf diffutils-3.9.tar.xz
cd diffutils-3.9
./configure --prefix=/usr/local
make -j$(nproc)
make install
cd ..
rm -rf diffutils-3.9 diffutils-3.9.tar.xz
echo "==> Diffutils installed."

# ---------------------------
# 13. Python 3 used for scripting and building some packages
# ---------------------------
wget https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tgz
tar -xf Python-3.12.2.tgz
cd Python-3.12.2
./configure --prefix=/usr/local --enable-optimizations # Enable optimizations for better performance
make -j$(nproc)
make altinstall   # altinstall to avoid overwriting system python
cd ..
rm -rf Python-3.12.2 Python-3.12.2.tgz
echo "==> Python 3 installed."

# ---------------------------
# 14. Meson build system used for building eudev
# ---------------------------
wget https://github.com/mesonbuild/meson/releases/download/1.3.1/meson-1.3.1.tar.gz
tar -xf meson-1.3.1.tar.gz
cd meson-1.3.1
python3 setup.py install --prefix=/usr/local
cd ..
rm -rf meson-1.3.1 meson-1.3.1.tar.gz
echo "==> Meson installed."

# ---------------------------
# 15. Ninja build system used for building eudev
# ---------------------------
wget https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip
unzip ninja-linux.zip
chmod +x ninja
mv ninja /usr/local/bin/
rm ninja-linux.zip
echo "==> Ninja installed."

# ---------------------------
# 16. Eudev used for managing DEVICES in /dev
# ---------------------------
wget https://github.com/systemd/systemd/releases/download/v252/eudev-252.tar.gz
tar -xf eudev-252.tar.gz
cd eudev-252
mkdir build
cd build
meson --prefix=/usr/local ..
ninja
ninja install
cd ../..
rm -rf eudev-252 eudev-252.tar.gz
echo "==> Eudev installed."

# ---------------------------
# 17. E2fsprogs used for ext2/3/4 filesystems
# ---------------------------
wget https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.46.5/e2fsprogs-1.46.5.tar.gz
tar -xf e2fsprogs-1.46.5.tar.gz
cd e2fsprogs-1.46.5
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf e2fsprogs-1.46.5 e2fsprogs-1.46.5.tar.gz
echo "==> E2fsprogs installed."

# ---------------------------
# 18. Expat used for XML parsing
# ---------------------------
wget https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz
tar -xf expat-2.5.0.tar.gz
cd expat-2.5.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf expat-2.5.0 expat-2.5.0.tar.gz
echo "==> Expat installed."

# ---------------------------
# 19. Expect used for automating interactive applications
# ---------------------------
wget https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz
tar -xf expect5.45.4.tar.gz
cd expect5.45.4
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf expect5.45.4 expect5.45.4.tar.gz
echo "==> Expect installed."

# ---------------------------
# 20. File used for determining file types
# ---------------------------
wget https://astron.com/pub/file/file-5.42.tar.gz
tar -xf file-5.42.tar.gz
cd file-5.42
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf file-5.42 file-5.42.tar.gz
echo "==> File installed."

# ---------------------------
# 21. File used for determining file types
# ---------------------------
wget https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.gz
tar -xf findutils-4.9.0.tar.gz
cd findutils-4.9.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf findutils-4.9.0 findutils-4.9.0.tar.gz
echo "==> Findutils installed."

# ---------------------------
# 22. Flex used for generating scanners (tokenizers)
# ---------------------------
wget https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf flex-2.6.4 flex-2.6.4.tar.gz
echo "==> Flex installed."

# ---------------------------
# 23. Gawk used for pattern scanning and processing language
# ---------------------------
wget https://ftp.gnu.org/gnu/gawk/gawk-5.2.1.tar.xz
tar -xf gawk-5.2.1.tar.xz
cd gawk-5.2.1
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf gawk-5.2.1 gawk-5.2.1.tar.xz
echo "==> Gawk installed."

# ---------------------------
# 24. Gcc already done in bootstrap_tools.sh
# ---------------------------

# ---------------------------
# 25. GDBM used for GNU database manager
# ---------------------------
wget https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz
tar -xf gdbm-1.23.tar.gz
cd gdbm-1.23
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf gdbm-1.23 gdbm-1.23.tar.gz
echo "==> GDBM installed."

# ---------------------------
# 26. Gettext used for internationalization and localization
# ---------------------------
wget https://ftp.gnu.org/gnu/gettext/gettext-0.22.tar.gz
tar -xf gettext-0.22.tar.gz
cd gettext-0.22
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf gettext-0.22 gettext-0.22.tar.gz
echo "==> Gettext installed."

# ---------------------------
# 27. Glibc used for the GNU C Library 
# ---------------------------
wget http://ftp.gnu.org/gnu/libc/glibc-2.39.tar.xz
tar -xf glibc-2.39.tar.xz
cd glibc-2.39
mkdir build && cd build
../configure --prefix=/usr
make -j$(nproc)
make install
cd ../..
rm -rf glibc-2.39 glibc-2.39.tar.xz
echo "==> Glibc installed."

# ---------------------------
# 28. GMP used for arbitrary precision arithmetic (dependency for GCC)
# ---------------------------
wget https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf gmp-6.3.0 gmp-6.3.0.tar.xz
echo "==> GMP installed."

# ---------------------------
# 29. Gperf used for generating perfect hash functions
# ---------------------------
wget https://download.savannah.gnu.org/releases/gperf/gperf-3.1.tar.gz
tar -xf gperf-3.1.tar.gz
cd gperf-3.1
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf gperf-3.1 gperf-3.1.tar.gz
echo "==> Gperf installed."


# ---------------------------
# 30. Grep used for searching text using patterns
# ---------------------------
wget https://ftp.gnu.org/gnu/grep/grep-3.10.tar.xz
tar -xf grep-3.10.tar.xz
cd grep-3.10
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf grep-3.10 grep-3.10.tar.xz
echo "==> Grep installed."

# ---------------------------
# 31. Groff
# ---------------------------
wget https://ftp.gnu.org/gnu/groff/groff-1.22.4.tar.gz
tar -xf groff-1.22.4.tar.gz
cd groff-1.22.4
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf groff-1.22.4 groff-1.22.4.tar.gz
echo "==> Groff installed."

# ---------------------------
# 32. GRUB used for the bootloader
# ---------------------------
wget https://ftp.gnu.org/gnu/grub/grub-2.08.tar.xz
tar -xf grub-2.08.tar.xz
cd grub-2.08
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf grub-2.08 grub-2.08.tar.xz
echo "==> GRUB installed."

# ---------------------------
# 33. Gzip already done in bootstrap_tools.sh
# ---------------------------

# ---------------------------
# 34. Iana-Etc used for IANA time zone and port number data
# ---------------------------
wget https://www.iana.org/time-zones/repository/tzdata-latest.tar.gz -O iana-etc-2025a.tar.gz
tar -xf iana-etc-2025a.tar.gz
cd iana-etc-2025a
make
make install
cd ..
rm -rf iana-etc-2025a iana-etc-2025a.tar.gz
echo "==> Iana-Etc installed."

# ---------------------------
# 35. Inetutils used for basic internet utilities like ftp, telnet, etc.
# ---------------------------
wget https://ftp.gnu.org/gnu/inetutils/inetutils-2.3.tar.xz
tar -xf inetutils-2.3.tar.xz
cd inetutils-2.3
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf inetutils-2.3 inetutils-2.3.tar.xz
echo "==> Inetutils installed."

# ---------------------------
# 36. Intltool used for internationalization support in XML and other files
# ---------------------------
wget https://launchpad.net/intltool/0.51.0/+download/intltool-0.51.0.tar.gz
tar -xf intltool-0.51.0.tar.gz
cd intltool-0.51.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf intltool-0.51.0 intltool-0.51.0.tar.gz
echo "==> Intltool installed."

# ---------------------------
# 37. IPRoute2 used for network management
# ---------------------------
wget https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.5.0.tar.gz
tar -xf iproute2-6.5.0.tar.gz
cd iproute2-6.5.0
make -j$(nproc)
make install
cd ..
rm -rf iproute2-6.5.0 iproute2-6.5.0.tar.gz
echo "==> IPRoute2 installed."

# ---------------------------
# 38. Kbd
# ---------------------------
wget https://www.kernel.org/pub/linux/utils/kbd/kbd-2.6.1.tar.xz
tar -xf kbd-2.6.1.tar.xz
cd kbd-2.6.1
make -j$(nproc)
make install
cd ..
rm -rf kbd-2.6.1 kbd-2.6.1.tar.xz
echo "==> Kbd installed."

# ---------------------------
# 39. Kmod used for managing kernel modules
# ---------------------------
wget https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-32.tar.xz
tar -xf kmod-32.tar.xz
cd kmod-32
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf kmod-32 kmod-32.tar.xz
echo "==> Kmod installed."

# ---------------------------
# 40. Less used for viewing text files
# ---------------------------
wget http://ftp.gnu.org/gnu/less/less-608.tar.gz
tar -xf less-608.tar.gz
cd less-608
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf less-608 less-608.tar.gz
echo "==> Less installed."

# ---------------------------
# 41. Libcap used for POSIX capabilities
# ---------------------------
wget https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.70.tar.xz
tar -xf libcap-2.70.tar.xz
cd libcap-2.70
make -j$(nproc)
make install
cd ..
rm -rf libcap-2.70 libcap-2.70.tar.xz
echo "==> Libcap installed."

# ---------------------------
# 42. Libpipeline used for pipeline handling
# ---------------------------
wget https://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.8.tar.gz
tar -xf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf libpipeline-1.5.8 libpipeline-1.5.8.tar.gz
echo "==> Libpipeline installed."

# ---------------------------
# 43. Libtool used for managing shared libraries
# ---------------------------
wget https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
tar -xf libtool-2.4.7.tar.xz
cd libtool-2.4.7
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf libtool-2.4.7 libtool-2.4.7.tar.xz
echo "==> Libtool installed."

# ---------------------------
# 43. M4 used for macro processing
# ---------------------------
wget https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
tar -xf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf m4-1.4.19 m4-1.4.19.tar.xz
echo "==> M4 installed."

# ---------------------------
# 44. Make already done in bootstrap_tools.sh
# ---------------------------

# ---------------------------
# 45. Man-DB Manual page utilities
# ---------------------------
wget https://download.savannah.gnu.org/releases/man-db/man-db-2.12.0.tar.xz
tar -xf man-db-2.12.0.tar.xz
cd man-db-2.12.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf man-db-2.12.0 man-db-2.12.0.tar.xz
echo "==> Man-DB installed."

# ---------------------------
# 46. Man-pages used for Linux manual pages
# ---------------------------
wget https://www.kernel.org/doc/man-pages/man-pages-6.05.tar.xz
tar -xf man-pages-6.05.tar.xz
cd man-pages-6.05
make install
cd .. 
rm -rf man-pages-6.05 man-pages-6.05.tar.xz
echo "==> Man-pages installed."

# ---------------------------
# 47. MPC used for complex number arithmetic (dependency for GCC)
# ---------------------------
wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
tar -xf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf mpc-1.3.1 mpc-1.3.1.tar.gz
echo "==> MPC installed."

# ---------------------------
# 48. MPFR used for multiple-precision floating-point computations (dependency for GCC)
# ---------------------------
wget https://www.mpfr.org/mpfr-current/mpfr-4.2.0.tar.xz
tar -xf mpfr-4.2.0.tar.xz
cd mpfr-4.2.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf mpfr-4.2.0 mpfr-4.2.0.tar.xz
echo "==> MPFR installed."

# ---------------------------
# 49. Ncurses used for text-based user interfaces
# ---------------------------
wget https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz
tar -xf ncurses-6.4.tar.gz
cd ncurses-6.4
./configure --prefix=/usr --with-shared --without-debug --without-ada --enable-widec #compile with shared libraries, no debug, and UTF-8 support
make -j$(nproc)
make install
cd /usr/src
rm -rf ncurses-6.4 ncurses-6.4.tar.gz
echo "==> Ncurses installed."

# ---------------------------
# 50. Patch used for applying patches to files
# ---------------------------
wget https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz
tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf patch-2.7.6 patch-2.7.6.tar.xz
echo "==> Patch installed."

# ---------------------------
# 51. Perl used for scripting and building some packages
# ---------------------------
wget https://www.cpan.org/src/5.0/perl-5.38.0.tar.gz
tar -xf perl-5.38.0.tar.gz
cd perl-5.38.0
sh Configure -des -Dprefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf perl-5.38.0 perl-5.38.0.tar.gz
echo "==> Perl installed."

# ---------------------------
# 52. Pkg-config used for managing compile and link flags for libraries
# ---------------------------
wget https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
tar -xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf pkg-config-0.29.2 pkg-config-0.29.2.tar.gz
echo "==> Pkg-config installed."

# ---------------------------
# 53. Procps used for process management utilities like ps, top, etc.
# ---------------------------
wget https://sourceforge.net/projects/procps-ng/files/procps-ng/4.0.0/procps-ng-4.0.0.tar.xz
tar -xf procps-ng-4.0.0.tar.xz
cd procps-ng-4.0.0
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf procps-ng-4.0.0 procps-ng-4.0.0.tar.xz\
echo "==> Procps installed."

# ---------------------------
# 54. Psmisc used for managing processes
# ---------------------------
wget https://github.com/downloads/schilytools/psmisc/psmisc-23.5.tar.gz
tar -xf psmisc-23.5.tar.gz
cd psmisc-23.5
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf psmisc-23.5 psmisc-23.5.tar.gz
echo "==> Psmisc installed."

# ---------------------------
# 55. Readline used for command line editing
# ---------------------------
wget https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz
tar -xf readline-8.2.tar.gz
cd readline-8.2
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf readline-8.2 readline-8.2.tar.gz
echo "==> Readline installed."

# ---------------------------
# 56. Sed used for stream editing
# ---------------------------
wget https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz
tar -xf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf sed-4.9 sed-4.9.tar.xz
echo "==> Sed installed."

# ---------------------------
# 57. Shadow used for managing user accounts and passwords
# ---------------------------
wget https://github.com/shadow-maint/shadow/releases/download/4.14.6/shadow-4.14.6.tar.xz
tar -xf shadow-4.14.6.tar.xz
cd shadow-4.14.6
./configure --prefix=/usr --sysconfdir=/etc --disable-static # Avoid static libraries to save space and set config files in /etc
make -j$(nproc)
make install
cd ..
rm -rf shadow-4.14.6 shadow-4.14.6.tar.xz
echo "==> Shadow installed."

# ---------------------------
# 58. Sysklogd used for logging system messages
# ---------------------------
wget https://sourceforge.net/projects/ezlinux/files/sysklogd-1.5.1.tar.gz
tar -xf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1
make -j$(nproc)
make install
cd ..
rm -rf sysklogd-1.5.1 sysklogd-1.5.1.tar.gz
echo "==> Sysklogd installed."

# ---------------------------
# 59. Sysvinit used for initializing the system (replacing systemd)
# ---------------------------
wget https://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.96.tar.gz
tar -xf sysvinit-2.96.tar.gz
cd sysvinit-2.96
make -j$(nproc)
make install
cd ..
rm -rf sysvinit-2.96 sysvinit-2.96.tar.gz
echo "==> Sysvinit installed."

# ---------------------------
# 60. Tar already done in bootstrap_tools.sh
# ---------------------------

# ---------------------------
# 61. Tcl used for scripting
# ---------------------------
wget https://prdownloads.sourceforge.net/tcl/tcl8.6.13-src.tar.gz
tar -xf tcl8.6.13-src.tar.gz
cd tcl8.6.13
cd unix
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf tcl8.6.13 tcl8.6.13-src.tar.gz
echo "==> Tcl installed."

# ---------------------------
# 62. Texinfo used for creating and reading info documents
# ---------------------------
wget https://ftp.gnu.org/gnu/texinfo/texinfo-7.0.3.tar.xz
tar -xf texinfo-7.0.3.tar.xz
cd texinfo-7.0.3
./configure --prefix=/usr
make -j$(nproc)
make install
cd ..
rm -rf texinfo-7.0.3 texinfo-7.0.3.tar.xz
echo "==> Texinfo installed."

# ---------------------------
# 63. Time Zone Data used for timezone information
# ---------------------------
wget https://www.iana.org/time-zones/repository/tzdata-latest.tar.gz -O tzdata.tar.gz
tar -xf tzdata.tar.gz
cd tzdata
# Copier les fichiers dans /usr/share/zoneinfo
mkdir -p /usr/share/zoneinfo
cp -r * /usr/share/zoneinfo/
cd ..
rm -rf tzdata tzdata.tar.gz
echo "==> Time Zone Data installed."

# ---------------------------
# 64. Udev-lfs Tarball used for device management (additional rules and configs for eudev)
# ---------------------------
cd /usr/src
wget https://www.linuxfromscratch.org/lfs/downloads/11.2/lfs-packages/eudev-lfs-3.2.11.tar.gz
tar xf eudev-lfs-3.2.11.tar.gz
cd eudev-lfs-3.2.11
./configure --prefix=/usr --sysconfdir=/etc # Use /etc for configuration files
make
make install
cd ..
rm -rf eudev-lfs-3.2.11 eudev-lfs-3.2.11.tar.gz
echo "==> Udev-lfs Tarball installed."

# ---------------------------
# 65. Util-linux used for various system utilities
# ---------------------------
wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.38/util-linux-2.38.1.tar.xz
tar xf util-linux-2.38.1.tar.xz
cd util-linux-2.38.1
./configure --prefix=/usr
make
make install
cd ..
rm -rf util-linux-2.38.1 util-linux-2.38.1.tar.xz
echo "==> Util-linux installed."

# ---------------------------
# 66. Vim used for text editing
# ---------------------------
wget https://github.com/vim/vim/archive/refs/tags/v9.0.1234.tar.gz -O vim-9.0.1234.tar.gz
tar xf vim-9.0.1234.tar.gz
cd vim-9.0.1234
./configure --prefix=/usr
make
make install
cd ..
rm -rf vim-9.0.1234 vim-9.0.1234.tar.gz
echo "==> Vim installed."

# ---------------------------
# 67. XML::Parser used for XML parsing in Perl
# ---------------------------
wget https://cpan.metacpan.org/authors/id/I/IS/ISHIGAKI/XML-Parser-2.46.tar.gz
tar xf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46
perl Makefile.PL     # Generate Makefile
make
make install
cd ..
rm -rf XML-Parser-2.46 XML-Parser-2.46.tar.gz
echo "==> XML::Parser installed."

# ---------------------------
# 68. Xz Utils already done in bootstrap_tools.sh
# ---------------------------

# ---------------------------
# 68. Zlib used for compression
# ---------------------------
wget https://zlib.net/zlib-1.2.13.tar.gz
tar xf zlib-1.2.13.tar.gz
cd zlib-1.2.13
./configure --prefix=/usr
make
make install
cd /usr/src
rm -rf zlib-1.2.13 zlib-1.2.13.tar.gz
echo "==> Zlib installed."





