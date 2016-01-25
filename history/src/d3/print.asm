; 这是一个在32-bit 保护模式下运行的程序

; AH 给定属性
; BX 给定显存段选择子
; CX 给定数据段
; EDX 给定数据偏移

print:                           ; 这是一个用来显示字符串的函数
  mov gs, bx                     ; 指定显存段索引
  mov fs, cx                     ; 指定数据段索引
  mov edi, (80 * 0 + 0) * 2      ; EDI初始化为屏幕左上角的显存偏移
  mov esi, edx

printloop:
  mov al, [fs:esi]               ; 获取一个字符
  cmp al, 0x00                 ; 若是0x00，则停止写入
  je printend                  ; 跳到printend处，返回
  mov [gs:edi], AX             ; 写入显存
  add esi, 1                   ; 指针自增
  add edi, 2                   ; 显存指针+2 | todo 显存指针可能溢出
  jmp printloop              ; 反复写入直到字符串结束

printend:
  ret
