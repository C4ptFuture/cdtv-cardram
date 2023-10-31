# CDTV cardram resident module

This repo contains the source code to the CDTV cardram resident module that is part of the _CDTV OS 2.35 for Memory Cards_ update.

## Background

This resident module can be placed on a CDTV memory card (CD1401 or CD1405) and will the automatically add all the memory card space after this module to the system pool as Fast RAM. It needs to be loaded onto the memory card and will then automatically be initialized on startup if the CD1000 player is running off of exec.library 34.1001 or 37.201 (these are the CDTV OS ROM specific versions of exec that scan $E00000-$E7FFFF for resident modules) in combination with a Kickstart ROM version that does not exceed the corresponding exec.library in the CDTV OS ROM, i.e. only Kickstart 1.3 + CDTV OS 1.0 or Kickstart 2.x + CDTV OS 2.x is supported. Kickstart 3 is not supported. (See the CDTV OS 2.35 FAQ for more detailed information on why it does not work with Kickstart 3.x).


## Important Notes

- If multiple resident modules are installed on the memory card, then this cardram module MUST be the last one in the list, because all the free memory after it will be used as Fast RAM.

- If you add this to a a memory card, be sure to also mark the magic word at the beginning of the memoy card, otherwise cardmark.device will wipe your pretty resident module on system startup. Alternatively you can simply add the CDTV Land mcheader resident module at the beginning of your buildlist, which will take care of this for you.

- Again, this (currently) does not work with Kickstart 3.x (see above).

## Binary

The loadable module can be downloaded from the [Releases](https://github.com/C4ptFuture/cdtv-cardram/releases/) page.


## How to build

Alternatively, you can build the module yourself from source and modify it as you see fit. You will need vasm, vlink and the Amiga NDK. To build the resident module issue the following command:

```sh
ENVIRONMENT=release make cardram
```