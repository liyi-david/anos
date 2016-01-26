ORG   0x7c00          ; 引导区加载位置
                      ; 与之相对的详细内存分区可参考 http://www.bioscentral.com/misc/bda.htm

;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html
jmp entry
nop
%include "fat12.asm"
; ----------------------------------------- 常量定义 ---------------------------------------------
StackBaseAddr    equ 0x0800
KernelBaseAddr   equ 0x1000
KernelOffsetAddr equ 0x0000

;------------------------------------------ 程序主体 ---------------------------------------------
; BIOS中断表参见 http://www.cnblogs.com/walfud/articles/2980774.html
entry:
  mov dx, LoadStr
  call dispstr                                    ; 显示提示信息
  ; 载入根目录文件表
  mov sp, StackBaseAddr                           ; stack initialization
  mov ax, KernelBaseAddr                          ; 设置数据缓冲基地址
  mov es, ax
  mov bx, KernelOffsetAddr                        ; 设置数据缓冲偏移
  mov ax, 20                                      ; 1 - boot sector, 2 - 9, 10 - 18 : FAT
                                                  ; todo why 20/19 ???????
  mov cx, CFAT12_RootEntCnt*32/512                ; number of sectors
  call readsec
  mov dx, RootStr
  call dispstr
  mov dx, KernelBaseAddr
  add dx, CFAT12_RootItemLen
  call dispstr

  mov dx, KernelBaseAddr
  mov ds, dx
  mov dx, KernelOffsetAddr
  add dx, CFAT12_RootItemLen
  call dispstr
  jmp fin

fin:                          ; 程序结束
  hlt
  jmp 0xc400                  ; 跳入app.sys
                              ; todo 为什么跳转地址是这个?
                              ; 原书所述地址是0xc200，然而实际上由于计算机顺序向后执行命令，因此只
                              ; 要在跳转地址和实际地址之间没有多余的jmp指令，就可以正常运行。但是
                              ; 若跳转地址大于实际地址则无法正常执行

%include "display.asm"
%include "floppy.asm"

; ---------------------------------------- 数据段 ------------------------------------------------
LoadStr     db "Loading Floppy ... ", 0x0a, 0x00
RootStr     db "Root Directory Loaded.", 0x0a, 0x00
FinishFlag  db " [DONE]", 0x00

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
