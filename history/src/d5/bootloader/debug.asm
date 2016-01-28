; ----------------------------------- debug functions -------------------------------------------
dispdebug:
  push bx
  push ax
  push cx
  push dx
  push si
  mov al, [cs:KernelLoadStr - $$]
  mov bl, 01
  mov ah, 0x0e
  int 0x10
  pop si
  pop dx
  pop cx
  pop ax
  pop bx
  ret

disp32bit:
  ; suppose the number is located in cx
  push ax
  push bx
  push cx
  ; global configuration
  mov bl, 01
  mov ah, 0x0e
  mov al, cl
  and al, 00001111b
  add al, 0x30
  int 0x10
  shr cx, 4
  mov al, cl
  and al, 00001111b
  add al, 0x30
  int 0x10
  shr cx, 4
  mov al, cl
  and al, 00001111b
  add al, 0x30
  int 0x10
  shr cx, 4
  mov al, cl
  and al, 00001111b
  add al, 0x30
  int 0x10
  shr cx, 4
  pop cx
  pop bx
  pop ax
  ret
