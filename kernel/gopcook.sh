#!/bin/bash

$CLASS_COMMON_HEADER
ALL_PARAM=$@
ALL_PARAM_P0=$0
ALL_PARAM_P1=$1
ALL_PARAM_P2=$2
ALL_PARAM_P3=$3
ALL_PARAM_P4=$4

PACKAGE_ROOT=$(pwd)
PACKAGE_NAME="kernel"

function build_a32_kernel() 
{
    local defconf=$1
    local kernel_dtb=$2

    cecho "Building $PACKAGE_NAME (${FUNCNAME[0]}) ..."
    if [ "${defconf}" = "" ]; then
        cechow "WARN: No config file specified! Existing .config will be used!!! "
        cechow "      Make sure you've ever make the config before!"
    else
        # Make the config
        make ${defconf}
    fi

    if [ "${kernel_dtb}" = "" ]; then
        cechow "WARN: No DTB specified!!! "
        cechow "      No DTB will be built!"
    fi

    # Make the kernel
    make $MAKE_THREADS zImage CROSS_COMPILE=$CROSS_COMPILE CC="$CC" LD=$LD
    $CLASS_COMMON_EXIT_ONFAILURE
    cp arch/arm/boot/zImage $OUTPUT_DIR/

    # Process modules...
    # Delete the previous modules folder to avoid multiple modules folder
    # with "-dirty" added by kernel
    rm -rf $OUTPUT_DIR/modules
    if [ ! -e $OUTPUT_DIR/modules ]; then
        mkdir -p $OUTPUT_DIR/modules
    fi
    # Make moduels
    make modules $MAKE_THREADS
    # Install moduels
    make INSTALL_MOD_PATH=$OUTPUT_DIR/modules modules_install


    # Process DTB
    cechoa "Processing all DTB targets in the list..." 
    dtb_list=$(echo ${kernel_dtb})
    for dtb in $dtb_list; do
        cechoa "Processing $dtb"
        make $MAKE_THREADS $dtb 
        $CLASS_COMMON_EXIT_ONFAILURE
    done
    # Copy DTB files to target output folder
    #mkdir -p $OUTPUT_DIR/dtb
    cp  arch/arm/boot/dts/*.dtb $OUTPUT_DIR/
    $CLASS_COMMON_EXIT_ONFAILURE

    return
}

function build_a64_kernel() 
{
    local defconf=$1
    local kernel_dtb=$2

    cecho "Building $PACKAGE_NAME (${FUNCNAME[0]}) ..."
    if [ "${defconf}" = "" ]; then
        cechow "WARN: No config file specified! Existing .config will be used!!! "
        cechow "      Make sure you've ever make the config before!"
    else
        # Make the config
        make ${defconf}
    fi

    if [ "${kernel_dtb}" = "" ]; then
        cechow "WARN: No DTB specified!!! "
        cechow "      No DTB will be built!"
    fi

    # Make the kernel
    make $MAKE_THREADS Image CROSS_COMPILE=$CROSS_COMPILE CC="$CC" LD=$LD LOADADDR=20008000
    $CLASS_COMMON_EXIT_ONFAILURE
    cp arch/arm64/boot/Image $OUTPUT_DIR

    # Process modules...
    # Delete the previous modules folder to avoid multiple modules folder
    # with "-dirty" added by kernel
    rm -rf $OUTPUT_DIR/modules
    if [ ! -e $OUTPUT_DIR/modules ]; then
        mkdir -p $OUTPUT_DIR/modules
    fi
    
    # Make moduels
    cecho "Skip making modules temparary ..."
    #make modules $MAKE_THREADS
    # Install moduels
    #make INSTALL_MOD_PATH=$OUTPUT_DIR/modules modules_install

    # Process DTB
    cechoa "Processing all DTB targets in the list..." 
    dtb_list=$(echo ${kernel_dtb})
    for dtb in $dtb_list; do
        cechoa "Processing $dtb"
        make $MAKE_THREADS $dtb 
        $CLASS_COMMON_EXIT_ONFAILURE
    done
    # Copy DTB files to target output folder
    #mkdir -p $OUTPUT_DIR/dtb
    cp  arch/arm64/boot/dts/freescale/*.dtb $OUTPUT_DIR/
    $CLASS_COMMON_EXIT_ONFAILURE

    return
}

function install_a32_kernel() 
{
    cecho "Installing $PACKAGE_NAME (${FUNCNAME[0]}) ..."
    #cd $OUTPUT_DIR/modules
    # Install kernel moduels to rootfs
    # Do it only if the modules are there
    if [ -e $OUTPUT_DIR/modules/lib/modules ]; then    
        mkdir -p $TARGET_ROOTFS/lib/modules
        rm -rf $TARGET_ROOTFS/lib/modules/*
        cp -a $OUTPUT_DIR/modules/lib/modules/* $TARGET_ROOTFS/lib/modules/
        $CLASS_COMMON_EXIT_ONFAILURE
    fi

    # Install zImage to target rootfs
    # We currently skip this since we're using a 
    # seperate FAT parition for kernel and dtb.
    # No need to install it to rootfs.
    # ---------------------------------------
    #rm $TARGET_ROOTFS/boot/zImage
    #cp arch/arm/boot/zImage $TARGET_ROOTFS/boot/
    #$CLASS_COMMON_EXIT_ONFAILURE

    return                                                   
}

function install_a64_kernel() 
{
    cecho "Installing $PACKAGE_NAME (${FUNCNAME[0]}) ..."
    #cd $OUTPUT_DIR/modules
    # Install kernel moduels to rootfs
    # Do it only if the modules are there
    if [ -e $OUTPUT_DIR/modules/lib/modules ]; then    
        mkdir -p $TARGET_ROOTFS/lib/modules
        rm -rf $TARGET_ROOTFS/lib/modules/*
        cp -a $OUTPUT_DIR/modules/lib/modules/* $TARGET_ROOTFS/lib/modules/
        $CLASS_COMMON_EXIT_ONFAILURE
    fi

    # Install zImage to target rootfs
    # We currently skip this since we're using a 
    # seperate FAT parition for kernel and dtb.
    # No need to install it to rootfs.
    # ---------------------------------------
    #rm $TARGET_ROOTFS/boot/zImage
    #cp arch/arm64/boot/Image $TARGET_ROOTFS/boot/
    #$CLASS_COMMON_EXIT_ONFAILURE

    return                                                   
}

function do_prepare() 
{
    # Prepare for the building
    local defconf=$1

    if [ "${defconf}" = "" ]; then
        cechow "No config file specified!"
        return
    fi

    cechoa "Configure the kernel (default config: ${defconf})..."
    make ${defconf}
    make menuconfig 
    return       
}

function do_build() 
{
    if [ "$ACTIVE_SDK" = "a64" ]; then
        build_a64_kernel "$1" "$2" "$3" "$4" "$5"
    else
        build_a32_kernel "$1" "$2" "$3" "$4" "$5"
    fi
}

function do_install() 
{
    if [ "$ACTIVE_SDK" = "a64" ]; then
        install_a64_kernel "$1" "$2" "$3" "$4" "$5"
    else
        install_a32_kernel "$1" "$2" "$3" "$4" "$5"
    fi
}

function do_clean() 
{
    cecho "Cleaning $PACKAGE_NAME ..."
    make clean
    return   
}


# Check environment setup first, will exit if
# "envsetup" is not properly called before this
$CLASS_COMMON_CHECK_ENV

# Call the default main function
$CLASS_COMMON_MAIN

