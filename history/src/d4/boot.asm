ORG   0x7c00          ; 引导区加载位置
                      ; 与之相对的详细内存分区可参考 http://www.bioscentral.com/misc/bda.htm

;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html
jmp entry
nop
%include "fat12.asm"

; ----------------------------------------- 常量定义 ---------------------------------------------
KernelBaseAddr   equ 0x0800
KernelOffsetAddr equ 0x0000

;------------------------------------------ 程序主体 ---------------------------------------------
; BIOS中断表参见 http://www.cnblogs.com/walfud/articles/2980774.html
entry:
  mov dx, LoadStr
  call dispstr                ; 显示提示信息

  jmp fin

fin:                          ; 程序结束
  hlt
  jmp 0xc400                  ; 跳入app.sys
                              ; todo 为什么跳转地址是这个?
                              ; 原书所述地址是0xc200，然而实际上由于计算机顺序向后执行命令，因此只
                              ; 要在跳转地址和实际地址之间没有多余的jmp指令，就可以正常运行。但是
                              ; 若跳转地址大于实际地址则无法正常执行

; ---------------------------- 显示信息：公用代码 ------------------------------------------------
; dispstr函数：采用dx作为输入，在屏幕显示起始位置为dx的字符串
dispstr:
  mov si, dx

dispstr_loop:
  mov al, [cs:si]
  cmp al, 0
  je dispstr_end              ; 若AL = 0 则停止工作. 此处若改为JE entry则可无限向屏幕写入字符串
  mov bl, 01                  ; 选择前景色。不过不切换显示模式的话貌似无用
  mov ah, 0x0e                ; 选择中断功能：显示字符并后移光标
  int 0x10                    ; 调用显示中断
  add si, 1
  jmp dispstr_loop

dispstr_end:
  ret

; ---------------------------------------- 数据段 ------------------------------------------------
LoadStr db "Locating Kernel ", 0x00

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
