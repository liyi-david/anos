; ----------------------------------------- 常量定义 ---------------------------------------------
%include "memorymap.asm"
; ------------------------------------------ 程序主体 --------------------------------------------
; ORG 代表了初始偏移量
org   BootLoaderOffsetAddr
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
  ; 检查返回值
  cmp ah, 0
  jne failed

finish:                          ; 程序结束
  mov dx, FinishFlag
  call dispstr
  jmp LoaderBaseAddr:LoaderOffsetAddr

failed:
  mov dx, FailFlag
  call dispstr
  jmp $

; ---------------------------- 显示信息：公用代码 ------------------------------------------------
clearscreen:
  push ax
  push bx
  push cx
  mov al, 0
  mov bh, 0x3F
  mov cx, 0
  mov dl, 80                  ; column number of the right below corner
  mov dh, 25                  ; row number of ....
  mov ah, 6                   ; function set to `roll up`
  int 0x10                    ; call the interruption
  pop cx
  pop bx
  pop ax
  ret

; dispstr
; - dx 在屏幕显示起始位置为sp:dx的字符串
dispstr:
  push ax                     ; NOTE these registers must be stored !!!!!!!!!!!!!!!!!!!!!!!!!!
  push bx
  push si
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
  pop si
  pop bx
  pop ax
  ret

%include "floppy.asm"
; ---------------------------------------- 数据段 ------------------------------------------------
FinishFlag    db "FINISH", 0x00
FailFlag      db "FAILED", 0x00
LoaderName    db "LOADER  "

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
