#!/bin/bash

SRC="../src"
DATE_NOW=`date "+%d-%b-%Y_%H:%M:%S"`
OUT="./build-$DATE_NOW"
mkdir $OUT

# assembly & compile
nasm -felf32 $SRC/boot.asm -o $OUT/boot.o
$HOME/opt/cross/bin/i686-elf-gcc -c $SRC/kernel.c -o $OUT/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# linking
$HOME/opt/cross/bin/i686-elf-gcc -T $SRC/linker.ld -o $OUT/jakux.bin -ffreestanding -O2 -nostdlib $OUT/boot.o $OUT/kernel.o -lgcc

# grub it
if grub-file --is-x86-multiboot $OUT/jakux.bin; then
  echo multiboot confirmed
else
  echo the file is not multiboot
  exit
fi

mkdir -p $OUT/isodir/boot/grub
cp $OUT/jakux.bin $OUT/isodir/boot/jakux.bin
cp $SRC/grub.cfg $OUT/isodir/boot/grub/grub.cfg
grub-mkrescue -o $OUT/jakux.iso $OUT/isodir -v > $OUT/grub-mkrescue.log 2>&1

qemu-system-i386 -cdrom $OUT/jakux.iso
