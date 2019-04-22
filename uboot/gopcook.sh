#!/bin/bash

$CLASS_COMMON_HEADER
ALL_PARAM=$@
ALL_PARAM_P0=$0
ALL_PARAM_P1=$1
ALL_PARAM_P2=$2
ALL_PARAM_P3=$3
ALL_PARAM_P4=$4

PACKAGE_ROOT=$(pwd)
PACKAGE_NAME="uboot"

function build_a32_bootloader()
{
    local defconf=$1

    cecho "Building $PACKAGE_NAME (${FUNCNAME[0]}) ..."
    if [ "${defconf}" = "" ]; then
        cecho "WARN: No config file specified! Existing .config will be used!!! "
        cecho "      Make sure you've ever make the config before!"
    else
        make ${defconf}
    fi

    # Call into make
    make $MAKE_THREADS CROSS_COMPILE=$CROSS_COMPILE CC="$CC $SYSROOT"
    $CLASS_COMMON_EXIT_ONFAILURE

    # Do install here, may move to "install" section later.
    cp u-boot-dtb.imx $OUTPUT_DIR/u-boot.imx
}

function build_a64_bootloader() 
{
    local defconf=$1

    cecho "Building $PACKAGE_NAME (${FUNCNAME[0]}) ..."
    if [ "${defconf}" = "" ]; then
        cecho "WARN: No config file specified! Existing .config will be used!!! "
        cecho "      Make sure you've ever make the config before!"
    else
        make ${defconf}
    fi

    # This is to fix the DTC issue.
    # DTC only exists in the toolchain, not on host.
    export PATH=$ROOT_DIR/sdk/toolchain/usr/bin:$PATH

    # Call into make
    make $MAKE_THREADS CROSS_COMPILE=$CROSS_COMPILE CC="$CC $SYSROOT"
    $CLASS_COMMON_EXIT_ONFAILURE

    # Do install here, may move to "install" section later.
    cp u-boot.bin $OUTPUT_DIR/
    cp u-boot.dtb $OUTPUT_DIR/
    cp u-boot-nodtb.bin $OUTPUT_DIR/ 2>/dev/null
    cp spl/u-boot-spl.bin $OUTPUT_DIR/ 2>/dev/null
    cp tools/mkimage $OUTPUT_DIR/mkimage_uboot
}

function do_prepare() 
{
    # Prepare for the building
    local defconf=$1

    if [ "${defconf}" = "" ]; then
        cecho "No config file specified, ignored..."
    fi

    cecho "No configure needed for uboot: ${defconf}..."
}

function do_build() 
{
    if [ "$ACTIVE_SDK" = "a64" ]; then
        build_a64_bootloader "$1" "$2" "$3" "$4" "$5"
    else
        build_a32_bootloader "$1" "$2" "$3" "$4" "$5"
    fi
}

function do_install() 
{
    cecho "No instalation needed for $PACKAGE_NAME ..."
}

function do_clean() 
{
    cecho "Cleaning $PACKAGE_NAME ..."
    make distclean
}


# Check environment setup first, will exit if
# "envsetup" is not properly called before this
$CLASS_COMMON_CHECK_ENV

# Call the default main function
$CLASS_COMMON_MAIN

