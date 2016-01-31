; ----------------------------------------- 常量定义 ---------------------------------------------
%include "memorymap.asm"
; ------------------------------------------ 程序主体 --------------------------------------------
; 
org   LoaderOffsetAddr
;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html

[section .text]

call screen_reset                                                     ; 重设屏幕


mov ax, LoaderReadyStr                                                ; 设置起始位置
call printword

call printendl

jmp $
; call dispstr
; todo deal with data segment
; todo make display.asm ready for both two binaries


; --------------------------------------- import libraries ---------------------------------------
%include "floppy.asm"
%include "print.asm"
; ---------------------------------------- 数据段 ------------------------------------------------
[section .data]
DataBaseAddr      equ $$
LoaderReadyStr    db  "Loader online, trying to locate the kernel ... ", 0x00
