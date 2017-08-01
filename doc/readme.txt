/*************************************************************************
 *
 * Readme for "Gopbuild" linux build toolset
 *
 * 
 * Author: Taichun Yuan, taichun.yuan@freescale.com
 * 
 * Date: 08/18/2015
 *************************************************************************/

1. Description
    This is a small toolset for building uboot, kernel and test application 
    out of a complex build environment such as LTIB/Yocto.
    The intention for this tool is ease the pain for building the a full 
    environment and speed up the building.
    This toolset is only a container, the real target components should be
    integrated into this container to form a working environment.
    

2.  Change log:
    v1.2:
        First drop for adding capability of containing SDK from Yocto.

    v1.0:
        First drop for support 3.0.x kernel and toolchain from LTIB.


3.  Component
    --  envsetup
        Script for setup the enironment before doing anything else. 
        It should be called through "source" or "." in a shell.
   
    --  gopbuild
        Major entry for build script. Device/SoC related configurations
        are contained here. It can be called directly without envsetup.
        Note: for how to add new board support, please refer to the section
        below: "How to add new board configuration".

    --  gopcook.sh (in each module)
        Each build-able module should contain this script. It act as a
        agent or bridge between gopbuild environment and the module's original
        "Makefile". The intention of this script is to make the porting
        of module to this environment easier. 
        The source code and Makefile of modules should be kept not changing
        when porting from other environment to this one.

    --  uboot/kernel folder
        These modules should be come from other sources such as GIT or LTI/Yocto

    --  rootfs folder
        Two major components in this folder: 
        "base" folder contains a rootfs tarball (binary) as a base for 
            future customization.
        Other folders are application source or binary for customizing
            the rootfs. The build result for these folders are supposed to
            be placed into target rootfs (customer original one).

    --  sdk folder
        This folder is supposed to hold two sub-components: toolchain 
        and target rootfs.
        Details for how to port a SDK into this environment can be found
        in another "readme.txt" in "sdk" folder. Brief introduction:
        "toolchain": contains the toolchain for cross-compile.
        "current-sdk-location": hold the current SDK location. Don't touch!
        "target-rootfs": contains the target rootfs which is used when
            compiling/linking application in "rootfs" folder.
        Others are some tool scripts for toolchain relocation. Don't touch!

    --  output folder
        All final output for building and log for building will be placed 
        into this folder.


4. How to use
    --  Setup the environment:
            cd <root-of-gopbuild>
            source envsetup
        This should be called before doing anything else. Available for each 
        shell session.

    --  Build everything for default board:
            gmk
        
    --  Build everything for specific board:
            gmk <board-name>
        The <board-name> here is the name for configuration name for the
        board. Note: it's not the name for kernel defconf name nor uboot
        config name. The name defined in major script instead.
    
    --  Build specific module for default board.
        Any one of listed below:
            gmk uboot
            gmk kernel
            gmk rootfs
            gmk all # Build all, same as a direct "gmk"

    --  Build specific module for specific board:
        Example:
            gmk kernel <board-name>

    --  Clean everything:
            gmk all clean
        This will call "clean" sript for all module scripts and delete
        all the contents in "output" folder.

    --  Clean specific module:
        Example:
            gmk uboot clean

    --  Short cut build for seperate moduels:
        If a full build for target board has ever been done and the target
        has been properly configured for target board, you can use shortcut
        build:
            cd <target-module-folder>
            gmk
        Note: do this only if a full build ever done.


5. How to add new board configuration:
    Board configuration is hold in the major script: "gopbuild".
    Please follow the following template when adding new board:
    Example:
        # --------[ sabresd ]--------
        elif [ "$DEVICE" = "sabresd" ]; then
            BUILD_UBOOT=mx6qsabresd_config
            BUILD_KERNEL=imx_v7_defconfig
            BUILD_ROOTFS=""
            KERNEL_DTB_LIST="\
                imx6q-sabresd.dtb \
                imx6q-sabresd-ldo.dtb \


6. Known issues:
   1) N/A
   
