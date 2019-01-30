# gopbuild
A simple build toolset for Linux BSP.

Originally for "Yocto haters" who want to build a simple system without Yocto environment.
It will use SDK from Yocto or any other source to build the bootloader, kernel and apps.

Notes:
1. Tested only on Freescale/NXP i.MX 6/7/8 platforms.
2. A pre-built base rootfs image will be used as a foundation for customize.
3. A SDCARD image will be made by default at the end of a building. This requires some
   tools installed on the host system:
        mtools, e2fsprogs (>=1.43)

Quick start guide:
-----------------------------------------------------------------------------------------
    --  Setup the environment:
            cd <root-of-gopbuild>
            source envsetup
        It will prompt for selecting board configuration to be built. Choose
        one by input corresponding number or click <ENTER> for default board.

        This should be called before doing anything else. Once for each shell session.

    --  Build everything for the choosen board:
            gmk
        The build output for a board can be found under "output/<device-name>/"

    --  Build specific module for the choosen board. Examples:
            gmk uboot
            gmk kernel
            gmk platform
            gmk rootfs

    --  Print help message:
            gmk help


Enjoy ;)

By Gopise
08/2017

