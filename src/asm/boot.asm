; ----------------------------------------- 常量定义 ---------------------------------------------
%include "memorymap.asm"
; ------------------------------------------ 程序主体 --------------------------------------------
; 
org   BootLoaderBaseAddr
;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html
jmp entry
nop
%include "fat12.asm"

; BIOS中断表参见 http://www.cnblogs.com/walfud/articles/2980774.html

entry:
  ; 刷新屏幕
  call clearscreen
  ; 初始化堆栈
  mov ax, StackBaseAddr
  mov ss, ax
  ; 指定输入文件地址
  mov ax, LoaderName
  mov bx, LoaderBaseAddr
  mov cx, LoaderOffsetAddr
  call loadfile

  call dispstr
fin:                          ; 程序结束
  mov dx, FinishFlag
  call dispstr
  jmp $

; --------------------------------------- import libraries ---------------------------------------

%include "display.asm"
%include "floppy.asm"
; ---------------------------------------- 数据段 ------------------------------------------------
FinishFlag    db "F", 0x00
LoaderName    db "LOADER  "

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
