; ---------------------------- 显示信息：公用代码 ------------------------------------------------

; dispinit
dispinit:
  mov byte [Offset], 0x01
  ret

; dispstr
; - dx 在屏幕显示起始位置为sp:dx的字符串
dispstr:
  push ax                     ; NOTE these registers must be stored !!!!!!!!!!!!!!!!!!!!!!!!!!
  push bx
  push cx
  mov si, dx

dispstr_loop:
  mov al, [ds:si]
  cmp al, 0
  je dispstr_end              ; 若AL = 0 则停止工作. 此处若改为JE entry则可无限向屏幕写入字符串
  cmp al, 0x0a                ; if AL = 0x0a, we need an endl
  je dispstr_endl_found  
  dispstr_printchr:
    mov bl, 01                  ; 选择前景色。不过不切换显示模式的话貌似无用
    mov ah, 0x0e                ; 选择中断功能：显示字符并后移光标
    int 0x10                    ; 调用显示中断
  dispstr_endl_finish:
    add si, 1
    call dispstr_offsetinc
    jmp dispstr_loop

dispstr_endl_found:
  cmp byte [Offset], 0
  je dispstr_endl_finish      ; we already have an endline
  mov al, ' '
  sub si, 1
  jmp dispstr_printchr

dispstr_offsetinc:
  add byte [Offset], 1
  cmp byte [Offset], 81
  je dispstr_offsetreset
  ret
  dispstr_offsetreset:
    mov byte [Offset], 0        ; todo find out why 0 works here ?
    ret

dispstr_end:
  pop cx
  pop bx
  pop ax
  ret

dispdebug:
  push bx
  push ax
  push cx
  push dx
  mov al, ch                   ; show debug information
  add al, 0x30
  mov bl, 01
  mov ah, 0x0e
  int 0x10
  pop dx
  pop cx
  pop ax
  pop bx
  ret

; --------------------------------- data segment of video ----------------------------------------
Offset db 1
