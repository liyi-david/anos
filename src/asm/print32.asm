; 这是一个在32-bit 保护模式下运行的显示库

[bits 32]
; EDX 给定数据偏移

print:                                 ; 这是一个用来显示字符串的函数
  push eax
  push gs
  push ds
  mov ax, gdtselector_video
  mov gs, ax                           ; 指定显存段索引
  mov ax, gdtselector_loader32seg
  mov ds, ax                           ; 指定数据段索引
  mov eax, 0
  mov edi, eax                         ; DI初始化为显存偏移，其中高位表示列偏移，低位表示行偏移
  mov esi, edx                         ; SI初始化为数据偏移位置

printloop:
  mov al, [ds:esi]                     ; 获取一个字符
  cmp al, 0x00                         ; 若是0x00，则停止写入
  je printend                          ; 跳到printend处，返回
  mov [gs:edi], al                     ; 写入显存
  add esi, 1                           ; 指针自增
  add edi, 2                           ; 显存指针+2 | todo 显存指针可能溢出
  jmp printloop                        ; 反复写入直到字符串结束

printend:
  pop ds
  pop gs
  pop eax
  ret
