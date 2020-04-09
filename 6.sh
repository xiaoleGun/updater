#!/usr/bin/env bash

# Kernel CI Builder
# Copyright (C) 2019 @Boos4721(Telegram and Github)  
# Default Settings
export ARCH=arm64
export SUBARCH=arm64
export HOME=/drone
export TZ=":Asia/China"

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
VER="`date +%m%d-%H%S`"
rel_date=$(date "+%Y%m%e-%H%S"|sed 's/[ ][ ]*/0/g')
short_commit="$(cut -c-8 <<< "$(git rev-parse HEAD)")"
QWQ="-j$(grep -c ^processor /proc/cpuinfo)"

config() {
    apt-get update
    apt-get update && apt-get install -y sudo cpio clang liblz4-dev zipalign p7zip fakeroot liblz4-tool liblz4-1 gcc make bc curl git zip zstd flex libc6 libstdc++6 libgnutls30 ccache gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
}

clean(){
	make mrproper
	make $QWQ mrproper
	rm -rf ~/$ZIP
        rm -rf ~/$WORK
}

ssh-keygen -t rsa -C"3.1415926535boos@gmai.com" 
boos
boos
cat /drone/.ssh/id_rsa.pub

clone() {
#    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/clang.git -b clang-11 $CLANG
    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/clang.git $CLANG
    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/AnyKernel3.git ~/$ZIP
    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/updater.git -b Kernel ~/$WORK
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
    cp -f $OUTFILE ~/$ZIP/
    cd ~/$ZIP
    zip -r $NAME-$VER.zip *
    mv -f ~/$ZIP/$NAME-$VER.zip ~/$WORK/$NAME/$NAME-$VER.zip 
}

push() {
    cd ~/$WORK
    git config --global --unset credential.helper
    git config --unset credential.helper
    git config --global user.email 3.1415926535boos@gmail.com
    git config --global user.name boos4721
    git add  -f --a
    git remote set-url origin https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/updater.git
    git commit -m "[CI Build-$rel_date] $short_commit"
    git push -u origin Kernel
}

config
clean
clone
compile 
push

    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
