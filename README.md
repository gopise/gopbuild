# gopbuild
A simple build toolset for Linux BSP.

Originally for "Yocto haters" who want to build a simple system without Yocto environment.
It will use SDK from Yocto or any other source to build the uboot/kernel and apps.

1. Only tested on Freescale i.MX6 platform.
2. A pre-built base rootfs image will be used as a foundation for customize.


Quick start guide:
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

    --  Print help message:
            gmk help


Enjoy ;)

By Gopise
08/2017

