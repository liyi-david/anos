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

; ----------------------------------- debug functions -------------------------------------------
dispdebug:
  push bx
  push ax
  push cx
  push dx
  push si
  ; mov al, [es:0]                    ; show debug information
  add al, 0x30
  mov bl, 01
  mov ah, 0x0e
  int 0x10
  pop si
  pop dx
  pop cx
  pop ax
  pop bx
 ret
