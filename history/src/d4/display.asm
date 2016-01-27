; ---------------------------- 显示信息：公用代码 ------------------------------------------------

; dispstr
; - dx 在屏幕显示起始位置为sp:dx的字符串
dispstr:
  push ax                     ; NOTE these registers must be stored !!!!!!!!!!!!!!!!!!!!!!!!!!
  push bx
  mov si, dx

dispstr_loop:
  mov al, [cs:si]
  cmp al, 0
  je dispstr_end              ; 若AL = 0 则停止工作. 此处若改为JE entry则可无限向屏幕写入字符串
  cmp al, 0x0a                ; if AL = 0x0a, we need an endl
  je dispstr_endl_found  
  mov bl, 01                  ; 选择前景色。不过不切换显示模式的话貌似无用
  mov ah, 0x0e                ; 选择中断功能：显示字符并后移光标
  int 0x10                    ; 调用显示中断
  dispstr_endl_finish:
    add si, 1
    jmp dispstr_loop

dispstr_endl_found:             ; 这个函数用于输出一个换行符号
  push bx                       ; 首先将可能调用的寄存器压栈
  push cx
  push dx
  mov ah, 0x03
  mov bh, 0x00                  ; 要读取的页号
  int 0x10                      ; 读取光标位置
  mov ah, 0x02                  ; 写光标位置
  mov dl, 0                     ; 列数清零
  add dh, 1                     ; 行数 +1
  int 0x10
  pop dx
  pop cx
  pop bx                        ; 从栈中依次弹出寄存器的值并返回
  jmp dispstr_endl_finish

dispstr_end:
  pop bx
  pop ax
  ret

; ----------------------------------- debug functions -------------------------------------------
;dispdebug:
  ;push bx
  ;push ax
  ;push cx
  ;push dx
  ;push si
  ;mov si, bx
  ;mov al, [es:3]
  ;; mov al, '%'                    ; show debug information
  ;; add al, 0x30
  ;mov bl, 01
  ;mov ah, 0x0e
  ;int 0x10
  ;pop si
  ;pop dx
  ;pop cx
  ;pop ax
  ;pop bx
;  ret
