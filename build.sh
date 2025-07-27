#!/usr/bin/env bash
###############################################################################
##
##       filename: build.sh
##    description:
##        created: 2025/07/27
##         author: ticktechman
##
###############################################################################
set -e

BASE_DIR=$PWD

init_image() {
  truncate -s 32M root.img
  mkfs.ext4 -F root.img
  [[ -d root ]] || mkdir root
  sudo mount ./root.img ./root
}

build_linux_kernel() {
  cd "$BASE_DIR"
  wget https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-6.12.39.tar.xz
  tar Jxf linux-6.12.39.tar.xz
  cd linux-6.12.39
  make defconfig
  make -j4
  cp arch/arm64/boot/Image "$BASE_DIR/"
}

build_busybox() {
  cd "$BASE_DIR"
  cd busybox && make macvm_defconfig -j4
  sudo make CONFIG_PREFIX=../root install
  cd "$BASE_DIR"
  sudo cp -R ./add-ons/* ./root/
}

all_done() {
  cd "$BASE_DIR"
  sudo umount ./root
}

pack() {
  cd "$BASE_DIR"
  rm -rf oss-img && mkdir oss-img
  cp Image root.img oss-img/
  tar Jcvf oss-img.tar.xz oss-img
}

init_image
build_busybox
build_linux_kernel
all_done
pack
cd "$BASE_DIR"
###############################################################################
