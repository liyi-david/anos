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
  xor EAX, EAX                ; assign 0 to EAX
  mov AX, CS                  ; the lower 16-bits of EAX set to the base address of current seg
  shl EAX, 4
  add EAX, fin                ; obtain the 32-bit address of fin
  mov word [GDT + 10], ax
  shr eax, 16
  mov byte [GDT + 12], al
  mov byte [GDT + 15], ah
  lgdt [GDTR]
  cli
  in al, 92h
  or al, 00000010b
  out 92h, al                 ; open A20 to address more memory
  mov eax, cr0                ; todo find what has been done
  or  eax, 1
  mov cr0, eax
  jmp dword codeselector:0    ; jump to a 32-bit section

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
finmsg:
  db "program finished."
lenfinmsg equ $ - finmsg

GDT:                                     ; todo find out what gdt & gdtr is
  dw 0,0,0,0  

  dw 0x0010  
  dw 0x0000                              ; 可执行/写  
  dw 0x9a00                              ; 从右往左写数据  
  dw 0x00cf  

  dw 0x0010  
  dw 0x8000                              ; 可读/写  
  dw 0x920B                              ; 显存地址为0x0B8000  
  dw 0x00cf  

  codeselector  equ 0x08                 ; selectors
  videoselector equ 0x10  

GDTR:                                    ; GDTR (48bit) is used to store the address of GDT
  dw $$                                  ; the higher 32 bits store the base address of GDT
  dw GDT
  dw 0                                   ; the lower 16 bits store the length limit of GDT

[BITS 32]
fin:
  jmp halt

halt:
  hlt
  jmp halt

