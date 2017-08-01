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
    local defconf=$1

    cecho "Building $PACKAGE_NAME ..."
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
    cp u-boot.imx $OUTPUT_DIR
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

