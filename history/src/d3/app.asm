org 0xc400                          ; 这部分程序将被载入到0xc200位置
                                    ; 由于org主要影响的是jmp指令，因此这里不加实际上也算OK

mov AL, 0x03                        ; colorful textual display mode
mov AH, 0x00
int 0x10                            ; reset display mode

entry:
  mov AX, psmsg
  mov BP, AX
  mov CX, lenpsmsg
  mov DX, 0                   ; DH = 行数, DL = 列数，此处显示位置为 0,0
  call display                ; show 'loading finished'
  mov AX, tipmsg
  mov BP, AX
  mov CX, lentipmsg
  mov DH, 0x01                ; DH = 行数, DL = 列数，此处显示位置为 0,0
  mov DL, 0x00
  call display                ; show 'calling passed'
                              ; difference between call and jmp should be noticed properly

protected:                    ; try to switch into protected mode
  xor EAX, EAX                ; 清空EAX寄存器
  mov AX, CS                  ; 以下三行计算fin所在线性地址并将其存储到EAX中
  shl EAX, 4
  add EAX, fin
  mov word [GDT + 10], ax     ; 将fin线性地址转换为保护模式下的段, 前16位基址写入第二个GD的16-31位
  shr eax, 16
  mov byte [GDT + 12], al     ; 16-23位基址写入32-39位
  mov byte [GDT + 15], ah     ; 24-32位基址写入55-63位 (每个GD) 共64位

  lgdt [GDTR]                 ; 加载全局段描述表
  cli                         ; 关闭中断

  in al, 92h
  or al, 00000010b            ; 打开A20地址线
  out 92h, al

  mov eax, cr0                ; cr0的第0位代表了CPU的工作状态
  or  eax, 1                  ; 将第0位设为1
  mov cr0, eax                ; 进入保护模式

  jmp dword codeselector:0    ; jump to a 32-bit section todo

display:
  mov AX, 0                   ; 不可以使用0x7c00, 由于本程序使用了 org 0x7c00指令，因此 succmsg
                              ; 或者errmsg已经从文件中的相对位置向后偏移了0x7c00
  mov ES, AX                  ; 将会显示从ES:BP开始的字符串
  mov AL, 0x01                ; 目标位置包含字符，且属性在BL中包含，参见
                              ; http://blog.csdn.net/pdcxs007/article/details/43378229
  mov BH, 0                   ; 视频区页数
  mov BL, 0x02
  mov AH, 0x13                ; 显示中断参数：显示字符串
  int 0x10                    ; 调用显示中断
  ret                         ; return to the corresponding 'call'

psmsg:
  db "loading finished."
lenpsmsg equ $ - psmsg
tipmsg:
  db "preparing for protected mode (32-bit)."
lentipmsg equ $ - tipmsg

; ------------------------------------- Global Descriptor -------------------------------------
; 位置 功能
; 07     段基址的25-31位
; 06     由低到高分别为: 4位段限（16-19），1位AVL标志，1位常数0, 1为D/B标志，1位G标志
; 05     由低到高分别为: 4位TYPE，1位S标志，2位DPL标志，1位P标志
; 04 \
; 03  |- 段基址的0-24位
; 02 /
; 01 \   段限的0-15位
; 00 /
; 更多描述参见 http://blog.sina.com.cn/s/blog_6730a3aa01010liv.html
; ---------------------------------------------------------------------------------------------

GDT:                                     ; GD Table是由一系列的GD组成的，每个描述符8字节，共64位
                                         ; GD : Global Descriptor
  dw 0,0,0,0                             ; 第零个GD是null

CODE_SEG:

  dw 0xffff                              ; 记录前16位限长，不在此处初始化 
  dw 0x0000                              ; 记录段基址，不在此处初始化
  dw 0x9a00                              ; 前8位记录基址，不在此处初始化
                                         ; 后8位记录：a(type) - 执行，可读；9 - 有效段，最高特权
  dw 0x00cf                              ; 后8位记录段基址，前4位记录限长的最高4位 
                                         ; c = 1100，代表最大限长取实际限长*2^12 (补齐32位)
VIDEO_SEG:

  dw 0x0010  
  dw 0x8000                              ; 可读/写  
  dw 0x920B                              ; 显存地址为0x0B8000  
  dw 0x00cf  

  codeselector  equ CODE_SEG - GDT       ; selector of code segment, = 0x08
  videoselector equ VIDEO_SEG - GDT      ; selector of video memory, = 0x10

LENGDT equ $ - GDT

GDTR:                                    ; GDTR (48bit) is used to store the address of GDT
  dw LENGDT - 1                          ; the lower 16 bits store the length limit of GDT
                                         ; 注意：**前面的**才是低位！！！！
  dd GDT                                 ; the higher 32 bits store the base address of GDT
                                         ; GDTR 顺序错误可能导致致命错误，致使虚拟机不停重启
                                         ; 更多资料参考
                                         ; http://www.brokenthorn.com/Resources/OSDev8.html

[BITS 32]
fin:                                     ; 至此进入32位保护模式
  mov AX, videoselector
  mov GS, AX                             ; GS
  mov EDI, (80*0 + 0) * 2                ; 每个字符占2字节，其中一个是属性
  mov AH, 0x0c                           ; 高字节为属性
  mov AL, 'W'                            ; 低字节为字符 'W'
  mov [gs:edi], AX
  mov edi, (80*0 + 1) * 2
  mov AH, 0x0c  
  mov al, 'I'                            ; 显示 'I' 
  mov [gs:edi], ax  
  mov edi, (80*0 + 2) * 2  
  mov ah, 0x0c  
  mov al, 'N'  
  mov [gs:edi], ax                       ; 显示 'N'
  jmp halt

halt:
  hlt
  jmp halt

