#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="lineageos_land_defconfig"
KERNEL="Image.gz-dtb"

# Reloaded Kernel Details
BASE_VER="Reloaded™-"
VER="$(date +"%Y-%m-%d"-%H%M)"
K_VER="$BASE_VER$VER-land"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Ritesh"
export KBUILD_BUILD_HOST="MonsterMachine"
export TZ="Asia/Calcutta"

# Paths
KERNEL_DIR=`pwd`
ANYKERNEL_DIR="$KERNEL_DIR/build"
TOOLCHAIN_DIR="$KERNEL_DIR/../7.x"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$KERNEL_DIR/kernel_out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"


# Functions
function make_kernel {
		make $DEFCONFIG $THREAD
                make savedefconfig
		make $KERNEL $THREAD
                make dtbs $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		cd $KERNEL_DIR
		make modules $THREAD
                mkdir $MODULES_DIR
		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
		cd $MODULES_DIR
        $STRIP --strip-unneeded *.ko && mkdir pronto && mv wlan.ko pronto_wlan.ko && mv pronto_wlan.ko pronto
        cd $KERNEL_DIR
}

function make_zip {
		cd $REPACK_DIR
                zip -r `echo $K_VER`.zip *
                mkdir $ZIP_MOVE
		mv  `echo $K_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

		export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/lib/
                STRIP=$TOOLCHAIN_DIR/bin/aarch64-linux-android-strip
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		cd $ANYKERNEL_DIR
		rm -rf zImage
                cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Reloaded Kernel Using Linaro 7.2 Toolchain"

echo -e "${restore}"

		make_kernel
                #make_modules
		make_zip

echo -e "${green}"
echo $K_VER.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
cd $ZIP_MOVE
ls
