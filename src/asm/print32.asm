; 这是一个在32-bit 保护模式下运行的显示库

[bits 32]
; EDX 给定数据偏移

print:                                 ; 这是一个用来显示字符串的函数
  push eax
  push ds
  mov ax, gdtselector_loader32seg
  mov ds, ax                           ; 指定数据段索引
  mov esi, edx                         ; SI初始化为数据偏移位置

printloop:
  mov al, [ds:esi]                     ; 获取一个字符
  cmp al, 0x00                         ; 若是0x00，则停止写入
  je printend                          ; 跳到printend处，返回
  cmp al, 0x0a
  jne printloop_noendl                 ; 如果不是换行符则正常输出
    call putendl
    jmp printloop_continue             ; 若是换行符则先输出换行再继续
  printloop_noendl:
    call putchar
  printloop_continue:
    add esi, 1                         ; 指针自增
    jmp printloop                      ; 反复写入直到字符串结束

printend:
  pop ds
  pop eax
  ret

; putendl 输出一个回车
putendl:
  push bx
  push ax
  call cursorpos
  mov ax, bx
  mov bl, 80                           ; 计算光标位置除以80
  div bl
  inc al                               ; 增加行数
  mul bl                               ; ax = al * bl (80)
  mov bx, ax
  call cursorposset
  pop ax
  pop bx
  ret

; putchar 将AL中的字符输出到显示屏并使光标进位
putchar:
  push bx
  push ax
  push gs
  push si
  push ax                              ; 暂时保存AX
  mov ax, gdtselector_video
  mov gs, ax                           ; 指定显存段索引
  call cursorpos                       ; 保存光标位置到BX
  mov ax, bx
  add ax, ax                           ; 获取应当写入的显存位置
  mov si, ax
  pop ax                               ; 取出保存的字符并写入
  mov [gs:si], al
  inc bx
  call cursorposset
  pop si
  pop gs
  pop ax
  pop bx
  ret

; cursorpos 获取当前光标位置并存入BX
cursorpos:
  push ax
  push cx
  push dx
  mov dx, 0x03d4                       ; 0x03d4是索引端口
  mov al, 0x0e                         ; 索引的0x0e位置存储的是光标位置的高8位
  out dx, al                           ; 指定索引
  inc dx                               ; 0x03d5是数据端口
  in  al, dx                           ; 获取索引指定位置的高8位数据
  mov bh, al                           ; 存入BX的高8位
  dec dx                               ; 这儿开始读取光标位置的低八位放入bl
  mov al, 0x0f                         ; 0fh位置存放着光标位置的低八位
  out dx, al                           ; 设置索引
  inc dx
  in  al, dx                           ; 读取光标位置低8位
  mov bl, al                           ; 将低8位放置到BL
  pop dx
  pop cx
  pop ax
  ret

; cursorposset 将光标位置设置为BX
cursorposset:
  push ax
  push cx
  push dx
  mov dx, 0x03d4                       ; 0x03d4是索引端口
  mov al, 0x0e                         ; 索引的0x0e位置存储的是光标位置的高8位
  out dx, al                           ; 指定索引
  inc dx                               ; 0x03d5是数据端口
  mov al, bh                           ; 存入BX的高8位
  out dx, al                           ; 写入索引指定位置的高8位光标位置
  dec dx                               ; 这儿开始读取光标位置的低八位放入bl
  mov al, 0x0f                         ; 0fh位置存放着光标位置的低八位
  out dx, al                           ; 设置索引
  inc dx
  mov al, bl                           ; 将低8位放置到BL
  out dx, al                           ; 读取光标位置低8位
  pop dx
  pop cx
  pop ax
  ret
