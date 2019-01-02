export SDK_ROOT="$ROOT_DIR/sdk/$ACTIVE_SDK"
export SDK_SYSROOT=$SDK_ROOT/target-rootfs
#export SDK_ROOT=$ROOT_DIR/sdk/toolchain/usr/bin/arm-poky-linux-gnueabi
export PATH=$SDK_ROOT/toolchain/usr/bin/arm-poky-linux-gnueabi:$PATH
export OECORE_NATIVE_SYSROOT="$SDK_ROOT/toolchain"

export COMPILER_PARAM="-march=armv7-a -mfloat-abi=hard -mfpu=neon"
export SYSROOT="--sysroot=$SDK_SYSROOT" 
export CC="arm-poky-linux-gnueabi-gcc"
export CXX="arm-poky-linux-gnueabi-g++"
export CPP="arm-poky-linux-gnueabi-gcc -E"
export AS="arm-poky-linux-gnueabi-as "
export LD="arm-poky-linux-gnueabi-ld"

export ARCH=arm
export CROSS_COMPILE=arm-poky-linux-gnueabi-


# Calling relocation script...
cecho "Checking if we need to relocate the sdk..."
source $SDK_ROOT/relocate_sdk.sh
if [ $? -ne 0 ]; then
    cechoe "\tSDK relocation failed! Check the SDK before doing anything else!"
    # Erase some critical ENV to avoid compiling in a unknown environment.
    export ARCH=""
    export CROSS_COMPILE=""
    return 1
else
    return 0 
fi


