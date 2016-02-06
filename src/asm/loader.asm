; ----------------------------------------- 常量定义 ---------------------------------------------
%include "memorymap.asm"
; ------------------------------------------ 程序主体 --------------------------------------------
; 
org   LoaderOffsetAddr
;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html
[section .text]
[bits 16]

call screen_reset                                                     ; 重设屏幕

mov ax, LoaderBaseAddr
mov bx, LoaderReadyStr
call printstr

; 指定输入文件地址
mov ax, LoaderBaseAddr
mov ds, ax
mov ax, KernelName
mov bx, KernelBaseAddr
mov cx, KernelOffsetAddr
call loadfile

; 检查内核载入状况
cmp ah, 0
jne failed_loadingkernel

; 内核载入完成
mov ax, cs
mov bx, DoneStr
call printstr

mov ax, cs
mov bx, ProtectedModeIn
call printstr

; prepare for protected mode

lgdt [cs:gdtr]                                     ; load gdt

cli                                                ; disable interruptions

in al, 92h                                         ; open A20 bus
or al, 10b
out 92h, al

mov eax, cr0                                       ; make cpu working in protected mode
or eax, 1
mov cr0, eax

; jump to protected mode
jmp dword gdtselector_loader32seg:LoaderOffsetAddr + entry32


; --------------------------------------- fail locations ----------------------------------------
failed_loadingkernel:
  mov ax, LoaderBaseAddr
  mov bx, FailLoadingStr
  jmp failed
  
failed:
  call printstr
  jmp $

; --------------------------------------- import libraries ---------------------------------------
%include "floppy.asm"
%include "print.asm"
%include "gdt.asm"
%include "loaderin32.asm"

; ---------------------------------------- 数据段 ------------------------------------------------
[section .data]
LoaderReadyStr     db  "Boot Loader online, trying to locate the kernel ... ", 0x00
DoneStr            db  "DONE.", 0x0a, 0x00
ProtectedModeIn    db  "Jumping into protected mode ... ", 0x00
FailLoadingStr     db  "FAILED", 0x0a, 0x00
KernelName         db  "KERNEL  "
