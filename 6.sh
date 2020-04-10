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

###### Telegram Function #####
BOT_API_KEY=$(openssl enc -base64 -d <<< "${bot_token}")
BUILD_FAIL="CAACAgEAAx0CRhgx1QABAT8-XpBDV3twkRxHhq5inot-7YPCJFMAAt0AAxhdAh4v5tyoip5fJhgE"
BUILD_SUCCESS="CAACAgIAAx0CRhgx1QABAT9LXpBD86Cre02Eski1hLdeJ6KyBiUAAjQAA7eWaBsoTrkvia1OJRgE"

sendInfo() {
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$chat_id -d "parse_mode=HTML" -d text="$(
            for POST in "${@}"; do
                echo "${POST}"
            done
        )"
&>/dev/null
}

sendZip() {
	curl -F chat_id="$chat_id" -F document=@"~/$WORK/$NAME/*.zip" https://api.telegram.org/bot$BOT_API_KEY/sendDocument
}

sendStick() {
	curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendSticker -d sticker="${1}" -d chat_id=$chat_id &>/dev/null
}


#####

#########################################################################
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

clone() {
    git config --global user.email 3.1415926535boos@gmail.com
    git config --global user.name boos4721
#    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/clang.git -b clang-11 $CLANG
    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/clang.git $CLANG
    git clone --depth=1 https://$gayhub_username:$gayhub_passwd@github.com/Boos4721/AnyKernel3.git ~/$ZIP
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
    mkdir -p ~/$WORK/$NAME
    mv -f ~/$ZIP/$NAME-$VER.zip ~/$WORK/$NAME/$NAME-$VER.zip 
}

send_Info() {
	sendInfo "<b>---- ${NAME} New Kernel ----</b>" \
                "<b>Kernel Info:</b> <code>[CI Build-$rel_date] $short_commit"\
		"<b>Branch:</b> <code>$(git branch --show-current)</code>" \
 		"<b>Started on:</b> <code>$(hostname)</code>" \
		"<b>Started at</b> <code>$DATE</code>"
}
    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    
config
clean
clone
compile 
sendZip
send_Info
sendInfo 
sendStick

