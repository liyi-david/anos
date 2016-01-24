ORG   0x7c00          ; 引导区加载位置
                      ; 与之相对的详细内存分区可参考 http://www.bioscentral.com/misc/bda.htm

;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html
JMP   entry
DB    0x90
DB    "ANOSIPL "      ; OEM字符串，8字节（通常为格式化本磁盘的操作系统名称及版本）
DW    512             ; 每个扇区(sector)大小，必须为512(B)
DB    1               ; 簇(cluster)的大小，必须为1（个扇区）
DW    1               ; FAT的起始扇区数（一般从第一个扇区开始）
DB    2               ; FAT的个数（必须为2）
DW    224             ; 根目录的大小（一般设成224项）
DW    2880            ; 该磁盘的大小（必须设成2880扇区，即1440KB）
DB    0xf0            ; 磁盘的种类（必须为F0）
DW    9               ; FAT的长度（必须是9扇区）
DW    18              ; 每个磁道的扇区数（必须是18）
DW    2               ; 磁头数（必须是2）
DD    0               ; 不使用分区（必须是0）
DD    2880            ; 重写一次磁盘大小
DB    0,0,0x29        ; 意义不名
DD    0xffffffff      ; （可能是）卷标号码
DB    "WHATTHEFUCK"   ; 磁盘的名称（11字节）
DB    "FAT12   "      ; 磁盘格式名称（8字节）
RESB  18              ; 先空出18字节


;------------------------------------------ 程序主体 ---------------------------------------------
; BIOS中断表参见 http://www.cnblogs.com/walfud/articles/2980774.html
entry:
  mov AX, 0
  mov SS, AX
  mov SP, 0x7c00
  mov DS, AX

  mov AX, 0x0820
  mov ES, AX                  ; ES无法被赋值为立即数, 参见
                              ; http://blog.sina.com.cn/s/blog_9407914801017rw3.html
  mov BX, 0                   ; ES:BX 表示数据缓冲区地址
  mov CH, 0                   ; 柱面 0
  mov DH, 0                   ; 磁头 0
  mov CL, 2                   ; 扇区 2
  mov AL, 1                   ; 读入扇区数
  mov BX, 0
  mov DL, 0x00                ; A驱动器
  mov AH, 0x02                ; 中断参数：读操作
  int 0x13                    ; 0x13 ：磁盘读写中断
  jc error
  jmp success

fin:                          ; 程序结束
  hlt
  jmp fin                     ; 死循环

success:                      ; 成功读取
  mov AX, succmsg
  mov BP, AX
  mov CX, succmsglen
  jmp display
error:                        ; 出现错误
  mov AX, errmsg
  mov BP, AX
  mov CX, errmsglen

; ---------------------------- 显示信息：公用代码 ------------------------------------------------

display:
  mov AX, 0                   ; 不可以使用0x7c00, 由于本程序使用了 org 0x7c00指令，因此 succmsg
                              ; 或者errmsg已经从文件中的相对位置向后偏移了0x7c00
  mov ES, AX                  ; 将会显示从ES:BP开始的字符串
  mov AL, 0x01                ; 目标位置包含字符，且属性在BL中包含，参见
                              ; http://blog.csdn.net/pdcxs007/article/details/43378229
  mov BH, 0                   ; 视频区页数
  mov DX, 0                   ; DH = 行数, DL = 列数，此处显示位置为 0,0
  mov BL, 0xFC
  mov AH, 0x13                ; 显示中断参数：显示字符串
  int 0x10                    ; 调用显示中断
  jmp fin

; ---------------------------------------- 数据段 ------------------------------------------------

errmsg:
  db "error found while reading"
  db 0x0a
errmsglen equ $ - errmsg
succmsg:
  db "finished reading"
  db 0x0a
succmsglen equ $ - succmsg

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
