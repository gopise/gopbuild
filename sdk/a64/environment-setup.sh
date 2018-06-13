export SDK_ROOT="$ROOT_DIR/sdk/$ACTIVE_SDK"
export SDK_SYSROOT=$SDK_ROOT/target-rootfs

export PATH=$SDK_ROOT/toolchain/usr/bin/aarch64-poky-linux:$PATH
export OECORE_NATIVE_SYSROOT="$SDK_ROOT/toolchain"

export COMPILER_PARAM=""
export SYSROOT="--sysroot=$SDK_SYSROOT"
export CC="aarch64-poky-linux-gcc"
export CXX="aarch64-poky-linux-g++"
export CPP="aarch64-poky-linux-gcc -E"
export AS="aarch64-poky-linux-as "
export LD="aarch64-poky-linux-ld"

export ARCH=arm64
export CROSS_COMPILE=aarch64-poky-linux-


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


