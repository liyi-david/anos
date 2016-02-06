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

; todo need rewrite !!!!!!!!!!

SectorSize            equ 0x0200

BootLoaderOffsetAddr  equ 0x7c00

StackBaseAddr         equ 0x0000
StackOffsetAddr       equ 0x7e00                    ; 0x7c00 + SectorSize
FATBaseAddr           equ 0x8000                    ; 0x80000
FATOffsetAddr         equ 0x0000
LoaderBaseAddr        equ 0x81c0                    ; FATBaseAddr + SectorSize * 14 / 0x000F
LoaderOffsetAddr      equ 0x0000
KernelBaseAddr        equ 0x8240                    ; LoaderBaseAddr + SectorSize * 4 / 0x000F
KernelOffsetAddr      equ 0x0000

Stack32BaseAddr       equ 0x00010000
Kernel32SegBaseAddr   equ 0x00020000                ; Kernel in 32 bit would be located outside 1MB
