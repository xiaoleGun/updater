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

config() {
apt-get update
apt-get install -y build-essential bc python curl git zip ftp gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
git clone --depth=1 https://github.com/Boos4721/clang.git $CLANG
}

export LD_LIBRARY_PATH="${TOOLDIR}/$CLANG/bin/../lib:$PATH"

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

zip() {
    git clone --depth=1 https://github.com/Boos4721/AnyKernel3.git  -b op6/6t /drone/$NAME
    cp /drone/src/$OUTDIR/arch/arm64/boot/Image.gz-dtb /drone/$NAME/Image.gz-dtb
    cd  /drone/$NAME
    zip -r $NAME-$VER.zip *
}

make() {
    mkdir /drone/$WORK/$NAME
    mv /drone/$NAME/$NAME-$VER.zip /drone/$WORK/$NAME/$NAME-$VER.zip 
}

git_config() {
    git config --global user.email "3.1415926535boos@gmail.com"
    git config --global user.name "Boos4721"
}

push() {
    cd /drone/$WORK/$NAME
    git init
    git add . 
    git commit -sm "? " 
    git remote add origin https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/updater.git 
    git push -uf origin Kernel 
}

config
compile  
zip
make
git_config
push
    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
