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
WORK="PY"
ZIP="AnyKernel3"
CONFIG_FILE="hentai_defconfig"
DEVELOPER="boos"
HOST="hentai"
OUTDIR="out"
CLANG="clang10"
VER="v219-`date +%m%d`"
QWQ="-j$(grep -c ^processor /proc/cpuinfo)"
PUT="~/$NAME-$VER.zip"

############################################################
# Download Files
############################################################
apt-get update
apt-get install -y build-essential bc python curl git zip ftp gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
git clone --depth=1 https://github.com/Boos4721/clang.git $CLANG

############################################################
# Configs
############################################################
export LD_LIBRARY_PATH="${TOOLDIR}/$CLANG/bin/../lib:$PATH"
git config --global user.email "3.1415926535boos@gmail.com"
git config --global user.name "boos4721"

############################################################
# Start Compile
############################################################
BUILD_START=$(date +"%s")
	
        echo " $NAME With Clang.."
        echo " $NAME Starting first build.."

compile() {
    make ARCH=arm64 O="${OUTDIR}" "${CONFIG_FILE}"
    PATH="${TOOLDIR}/$CLANG/bin:${PATH}" \
    make $QWQ O="${OUTDIR}" \
        ARCH=arm64 \
        CC+=clang \
        CLANG_TRIPLE+=aarch64-linux-gnu- \
        CROSS_COMPILE+=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32+=arm-linux-gnueabi- \
        KBUILD_BUILD_USER="${DEVELOPER}" \
        KBUILD_BUILD_HOST="${HOST}"
}

compile

	echo " $NAME Build complete!"

############################################################
# Move file to Anykernel folders
############################################################
    rm -rf $NAME
git clone --depth=1 https://github.com/Boos4721/AnyKernel3.git  /drone/$NAME
    cp /drone/src/$OUTDIR/arch/arm64/boot/Image.gz-dtb /drone/$NAME/Image.gz-dtb
	echo "  File moved to $ZIP directory"

############################################################
# Build the zip for TWRP flashing
############################################################
	cd  /drone/$NAME
	zip -r $NAME-$VER.zip *
    git clone --depth=1 https://github.com/Boos4721/updater.git -b Kernel /drone/$WORK/$NAME
    rm -rf ~/*.zip && rm -rf /drone/$WORK/*.zip
    mv /drone/$NAME/$NAME-$VER.zip /drone/$WORK/$NAME-$VER.zip 
    cd /drone/$WORK
    git remote remove origin && git remote add origin https://github.com/$gayhub_username:%gayhub_passwd@github.com/Boos4721/updater.git
    git add -f * && git commit -sm "? " && git push -uf origin Kernel 
    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
