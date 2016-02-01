; ----------------------------------------- 常量定义 ---------------------------------------------
%include "memorymap.asm"
; ------------------------------------------ 程序主体 --------------------------------------------
; 
org   LoaderOffsetAddr
;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html

call screen_reset                                                     ; 重设屏幕

mov ax, LoaderBaseAddr
mov bx, LoaderReadyStr
call printstr

; 指定输入文件地址
mov ax, KernelName
mov bx, KernelBaseAddr
mov cx, KernelOffsetAddr
call loadfile

; 内核载入完成
mov ax, cs
mov bx, KernelReadyStr
call printstr

jmp $
jmp KernelBaseAddr:KernelOffsetAddr

; call dispstr
; todo deal with data segment
; todo make display.asm ready for both two binaries


; --------------------------------------- import libraries ---------------------------------------
%include "floppy.asm"
%include "print.asm"
; ---------------------------------------- 数据段 ------------------------------------------------
LoaderReadyStr    db  "Boot Loader online, trying to locate the kernel ... ", 0x00
KernelReadyStr    db  "DONE.", 0x0a, 0x00
KernelName        db  "KERNEL  "
