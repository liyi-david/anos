; print函数在屏幕上显示制定内容
; - 以0x0a作为换行符
; - 以0x00作为终止符
; - 输入字符串的地址由 AX:BX 给出

[section .text]

; --------------------------------------- print a string ----------------------------------------
printstr:
  push ax
  push bx
  push gs
  push si
  mov si, bx
  mov gs, ax

  printstr_loop:
    mov al, [gs:si]
    cmp al, 0
    je printstr_end             ; 若AL = 0 则停止工作. 此处若改为JE entry则可无限向屏幕写入字符串
    cmp al, 0x0a                ; 处理换行符
    jne printstr_noendl
    call printendl
    inc si
    jmp printstr_loop

  printstr_noendl:
    mov bl, 01                  ; 选择前景色。不过不切换显示模式的话貌似无用
    mov ah, 0x0e                ; 选择中断功能：显示字符并后移光标
    int 0x10                    ; 调用显示中断
    add si, 1
    jmp printstr_loop

  printstr_end:
    pop si
    pop gs
    pop bx
    pop ax
    ret

; ----------------------------------------- print memory -----------------------------------------
; AX - base address
; BX - offset
; - in this function, we're going to print ... bytes of memory starting from AX:BX
; - 16 bytes per line
printmemory:
  push gs
  push si
  push ax
  push bx

  call printendl                 ; first we provide a endline
  mov gs, ax                     ; set base address
  mov si, bx                     ; set offset
  mov ax, 0x10                   ; print 16 lines
  printmemory_loop:
    call printmemoryaddr         ; print the address
    call printspace

    ; inner loop: print one line
    push ax
      mov ax, 16
      printmemory_lineloop:
        push ax
        mov al, [gs:si]
        call printbyte
        pop ax
        call printspace
        add si, 1
        dec ax
        cmp ax, 0
        jne printmemory_lineloop
    pop ax

    call printendl

    dec ax
    cmp ax, 0
    jne printmemory_loop

  ; finally, use an endl to split between other messages
  call printendl
  pop bx
  pop ax
  pop si
  pop gs
  ret

printmemoryaddr:
  push ax
  mov ax, gs
  call printword
  mov al, ':'
  call printsymbol
  mov ax, si
  call printword
  pop ax
  ret


; ----------------------------------------- print number -----------------------------------------
; AX/EAX - the word we need to print, e.g. 0x1234
printdword:
  push eax
  shr eax, 16
  call printword
  pop eax
  call printword
  ret

printword:
  push ax
  push ax                          ; preserve ax firstly
  mov al, ah                       ; print the high 8 bits
  call printbyte
  pop ax                           ; restore ax and print the lower 8 bits
  call printbyte
  pop ax
  ret

; the byte should be stored in AL
printbyte:
  push bx
  push ax
  mov bl, 0
  mov ah, 0x0E
  mov bh, al                       ; backup al with bh
  shr al, 4                        ; high 4-bits first
  and al, 00001111b
  call printword_al2chr
  int 0x10
  mov al, bh                       ; restore al
  and al, 00001111b
  call printword_al2chr
  int 0x10
  pop ax
  pop bx
  ret


printword_al2chr:
  add al, 0x30
  cmp al, 57
  jna printword_al2chr_end
    add al, 7
    ret
  printword_al2chr_end:
    ret

; ----------------------------------------- reset screen -----------------------------------------
screen_reset:
  push ax                        ; store the registers
  push bx
  push cx
  push dx
  ; step 1. reset color
  mov al, 0
  mov bh, 0x4F
  mov cx, 0
  mov dl, 80                  ; column number of the right below corner
  mov dh, 25                  ; row number of ....
  mov ah, 6                   ; function set to `roll up`
  int 0x10                    ; call the interruption
  ; step 2. reset position
  mov ah, 2                   ; reset cursor
  mov bh, 0                   ; page number = 0
  mov dx, 0                   ; position reset as dh = 0, dl = 0
  int 0x10
  pop dx
  pop cx
  pop bx
  pop ax
  ret

; ------------------------------------------------------------------------------------------------
printspace:
  push bx
  push ax
  mov bl, 0
  mov ah, 0x0E
  mov al, ' '
  int 0x10
  pop ax
  pop bx
  ret

printhexhead:
  push bx
  push ax
  mov bl, 0
  mov ah, 0x0E
  mov al, '0'
  int 0x10
  mov al, 'x'
  int 0x10
  pop ax
  pop bx
  ret

printsymbol:
  push bx
  push ax
  mov bl, 0
  mov ah, 0x0E
  int 0x10
  pop ax
  pop bx
  ret

; endl 的机制：
; - 读取当前光标位置
; - 重设光标位置，令行数+1，列数清零
printendl:
  push bx
  push ax
  ; 调取当前光标
  mov bh, 0
  mov ah, 3
  int 0x10
  ; 重写当前光标
  inc dh
  mov dl, 0
  mov ah, 2
  int 0x10
  pop ax
  pop bx
  ret
