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
