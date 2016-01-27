; -----------------------------------------------------------------------------------------------
; fat12.asm
; - 这个文件描述了一个标准FAT12的开头
; - 需要注意的是，在引用本文件前，需要有额外的两行
; - jmp (short) entry   指定入口
; - nop                 null operation
; -----------------------------------------------------------------------------------------------
FAT12_OEMName      db    "ANOSIPL "      ; OEM字符串，8字节（通常为格式化本磁盘的操作系统名称及版本）
FAT12_BytesPerSec  dw    512             ; 每个扇区(sector)大小，必须为512(B)
FAT12_SecPerClus   db    1               ; 簇(cluster)的大小，必须为1（个扇区）
FAT12_RsvdSecCnt   dw    1               ; Boot记录所占用的扇区数
FAT12_NumFATs      db    2               ; FAT的个数（必须为2）
FAT12_RootEntCnt   dw    224             ; 根目录的文件数最大值（一般设成224项）
FAT12_TotSec16     dw    2880            ; 该磁盘的大小,即逻辑扇区总数（必须设成2880扇区，即1440KB）
FAT12_Media        db    0xf0            ; 磁盘的种类/媒体描述符（必须为F0）
FAT12_SecPerFAT    dw    9               ; 每个FAT的长度（必须是9扇区）
FAT12_SecPerTrk    dw    18              ; 每个磁道的扇区数（必须是18）
FAT12_NumHeads     dw    2               ; 磁头数（必须是2）
FAT12_HiddSec      dd    0               ; 隐藏扇区数
FAT12_TolSec32     dd    2880            ; 如果BPB_TotSec16是0，则在这里记录扇区总数
FAT12_DrvNum       db    0               ; 中断13的驱动器号
FAT12_Reserved1    db    0               ; 保留字段
FAT12_BootSig      db    29h             ; 扩展引导标记(29h)
FAT12_VolID        dd    0               ; 卷序列号
FAT12_VolLbl       db    "An OS Alpha"   ; 卷标（11字节）
FAT12_FilsSysType  db    "FAT12   "      ; 文件系统类型（8字节）

; ------------------------------------------------------------------------------------------------
; 一些基于FAT12头的常量定义
; ------------------------------------------------------------------------------------------------

CFAT12_SecPerFAT         equ   9                                            ; number of sectors in each FAT
CFAT12_RootSectors       equ   CFAT12_RootEntCnt * CFAT12_RootItemLen / 512 ; number of sectors that contains root items
CFAT12_SecNoOfRoot       equ   CFAT12_SecNoOfFAT1 + 2 * CFAT12_SecPerFAT    ; index of root directory table's starting location
CFAT12_SecNoOfFAT1       equ   1                                            ; index of FAT1's starting section
CFAT12_RootEntCnt        equ   224                                          ; maximal number of items in root directory
CFAT12_SecNoClstZero     equ   CFAT12_SecNoOfRoot + CFAT12_RootSectors - 2  ; the sector index of cluster 0
                                                                            ; since the data cluster starts from cluster 2
                                                                            ; we need to decrease 2 here

CFAT12_RootItemLen       equ   32
