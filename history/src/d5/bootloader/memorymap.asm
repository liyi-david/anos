; ------------------------------------------------------------------------------------------------
; memorymap.asm
; - all base addreses and offsets are defined in this section
; ------------------------------------------------------------------------------------------------

; ----------------------------------------- 内存区划 ---------------------------------------------
; 0x0000 - 0x7c00 系统预留
; 0x7c00 - 0x7e00 引导扇区
; 0x7e00 - 0x8000 堆栈(512 Byte)
; 0x8000 - 0x9200 FAT(512 Byte * 9)
; 0x9200 - 0x9A00 Loader.bin
; 0x9A00 -        Kernel.bin

SectorSize         equ 0x00200

BootLoaderBaseAddr equ 0x07c00

StackBaseAddr      equ BootLoaderBaseAddr + SectorSize
FATBaseAddr        equ 0x08000
FATOffsetAddr      equ 0x00000
LoaderBaseAddr     equ FATBaseAddr + SectorSize * 14                ; 8000 - 9c00
LoaderOffsetAddr   equ 0x00000
KernelBaseAddr     equ LoaderBaseAddr + SectorSize * 4              ; 9c00 - ...
KernelOffsetAddr   equ 0x00000
