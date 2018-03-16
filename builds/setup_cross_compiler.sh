#!/bin/bash

sudo apt-get update
sudo apt-get upgrade

#install dependecis
sudo apt-get --yes --force-yes install nasm

sudo apt-get --yes --force-yes install libgmp3-dev
sudo apt-get --yes --force-yes install libmpfr-dev
sudo apt-get --yes --force-yes install libisl-dev
sudo apt-get --yes --force-yes install libcloog-isl-dev
sudo apt-get --yes --force-yes install libmpc-dev
sudo apt-get --yes --force-yes install texinfo
sudo apt-get --yes --force-yes install grub-pc-bin
sudo apt-get --yes --force-yes install gcc

sudo apt-get --yes --force-yes install efibootmgr
sudo apt-get --yes --force-yes install libefiboot-dev
sudo apt-get --yes --force-yes install libefiboot1
sudo apt-get --yes --force-yes install grub-coreboot
sudo apt-get --yes --force-yes install xorriso

sudo apt-get --yes --force-yes install qemu-system-i386

$PWD_local=pwd
SRC=~/src
BINUTILS_VERSIOM=2.30
GCC_VERSIOM=7.3.0

#delete old src
rm -R -f $SRC

#download binutils and gcc
mkdir $SRC
wget ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSIOM.tar.xz -O $SRC/binutils.tar.xz
wget ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSIOM.tar.xz.sig -O $SRC/binutils.tar.xz.sig
tar --directory=$SRC -xf $SRC/binutils.tar.xz

wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSIOM/gcc-$GCC_VERSIOM.tar.gz  -O $SRC/gcc.tar.gz
tar --directory=$SRC -xf $SRC/gcc.tar.gz

#build binutils
PREFIX="$HOME/opt/cross"
TARGET=i686-elf
PATH="$PREFIX/bin:$PATH"

mkdir $SRC/build-binutils
cd $SRC/build-binutils
$SRC/binutils-$BINUTILS_VERSIOM/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

#build gcc
cd $HOME/src

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc
../gcc-$GCC_VERSIOM/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc


#check export and return
$HOME/opt/cross/bin/$TARGET-gcc --version
export PATH="$HOME/opt/cross/bin:$PATH"
cd $PWD_local
