#!/usr/bin/env bash
######################################################
# Copyright (C) 2019 @Boos4721(Telegram and Github)  #
#                                                    #
# SPDX-License-Identifier: GPL-3.0-or-later          #
#                                                    #
######################################################
# Default Settings
export ARCH=arm64
export SUBARCH=arm64

############################################################
# Build Script Variables
############################################################
TOOLDIR="$PWD"
NAME="HenTaiKernel"
WORK="push"
ZIP="AnyKernel3"
CONFIG_FILE="hentai_defconfig"
DEVELOPER="boos"
HOST="hentai"
OUTFILE="/drone/src/out/arch/arm64/boot/Image.gz-dtb"
CLANG="clang"
VER="v219-`date +%m%d`"
QWQ="-j$(grep -c ^processor /proc/cpuinfo)"

config() {
    apt-get update
    apt-get install -y build-essential bc python curl git zip ftp gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
}

clean(){
	make mrproper
	make $QWQ mrproper
	rm -rf ~/$ZIP
        rm -rf ~/$WORK
}

clone() {
    git clone --depth=1 https://github.com/Boos4721/clang.git -b clang-11 $CLANG
    git clone --depth=1 https://github.com/Boos4721/AnyKernel3.git ~/$ZIP
    git clone --depth=1 https://github.com/Boos4721/updater.git ~/$WORK
    }
    
compile() {
    echo " $NAME With Clang.."
    echo " $NAME Starting first build.."
    BUILD_START=$(date +"%s")
    export LD_LIBRARY_PATH="${TOOLDIR}/$CLANG/bin/../lib:$PATH"	
    make ARCH=arm64 O="out" "${CONFIG_FILE}"
    PATH="${TOOLDIR}/$CLANG/bin:${PATH}" \
    make $QWQ O="out" \
    ARCH=arm64 \
    CC+=clang \
    CLANG_TRIPLE+=aarch64-linux-gnu- \
    CROSS_COMPILE+=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32+=arm-linux-gnueabi- \
    KBUILD_BUILD_USER="${DEVELOPER}" \
    KBUILD_BUILD_HOST="${HOST}"	
    echo " $NAME Build complete!"
    mkzip
}

mkzip() {
    git clone --depth=1 https://github.com/Boos4721/AnyKernel3.git ~/$ZIP
    cp -f $OUTFILE ~/$ZIP/
    cd ~/$ZIP
    zip -r $NAME-$VER.zip *
    mkdir ~/$WORK && cd ~/$WORK && mkdir $NAME
    mv -f ~/$ZIP/$NAME-$VER.zip ~/$WORK/$NAME/$NAME-$VER.zip 
}

git_config() {
    git config --global user.email "3.1415926535boos@gmail.com"
    git config --global user.name "Boos4721"
}

push() {
    cd ~/$WORK
    git add .
    git commit -sm "? " 
    git remote add ci https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/updater.git 
    git push -uf ci Kernel 
}

config
clean
clone
compile  
git_config
push

    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
