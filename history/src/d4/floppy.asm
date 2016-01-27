; 这个文件是用来存放软盘读写的 API
; http://blog.csdn.net/littlehedgehog/article/details/2147361

; 中断13，AH = 2 - 读取
; 读磁盘
;   AL=扇区数
;   CH,CL=磁盘号,扇区号
;   DH,DL=磁头号,驱动器号
;   ES:BX=数据缓冲区地址  
; Return Value
;   读成功:AH=0
;   AL=读取的扇区数
;   读失败:AH=出错代码

; readsec 读逻辑扇区
; AX 起始扇区 (ranges from 0 to 2879)
; CX 待读个数
; ES:BX 数据缓冲区地址
readsec:
  push dx
  push cx                             ; since bx is used in following lines, we need to store its
  push bx                             ; value temporarily
  mov bl, [cs:FAT12_SecPerTrk]
  div bl                              ; AX % BL = AH, AX / BL = AL
  pop bx
  mov dh, al                          ; 求磁头号
  and dh, 0x01                        ; 若是偶数，则磁头号为0，否则为1
  shr al, 1
  mov ch, al                          ; 柱面号 or 磁道号 
  mov cl, ah                          ; 起始扇区号
  add cl, 1                           ; obviously cl in [0, 17] and we need it to be [1, 18]
  mov dl, [FAT12_DrvNum]
  pop ax                              ; 将待读个数CX弹到AX中，用AX为计数器


readsec_loop:
  push ax
  mov al, 1                           ; 每次只读1个扇区
  mov ah, 2                           ; 设定为读取磁盘模式
  tryread:
    ; call dispdebug                  ; dispdebug函数用来输出调试信息
    int 0x13
    jc tryread                        ; 若失败则重新读取
  pop ax
  add bx, 512                         ; 指针向后一个扇区
  call readsec_secinc                 ; 扇区自增
  sub ax, 1                           ; 计数器 -1
  cmp ax, 0
  je readsec_end
  jmp readsec_loop

; 子函数，使得逻辑扇区+1并计算对应的柱面-磁头-扇区表示
readsec_secinc:
  add cl, 1
  cmp cl, 19
  jne readsec_secinc_end              ; 若扇区号尚不足19，自增后可直接退出
                                      ; 扇区范围为 1-19 [重要!!!!!!!!!!!!!!!!!]
    mov cl, 1                         ; 否则变化磁头号
    cmp dh, 0                         ; 若磁头号为0, 则磁道号加1
    jne readsec_secinc_cyninc         ; 若磁头号已经为1, 则磁道号清零并增加柱面号
    mov dh, 1                         ; 若磁头号尚未0, 则磁道号+1并退出
    jmp readsec_secinc_end
  readsec_secinc_cyninc:              ; 柱面号需+1
    mov dh, 0
    add ch, 1
  readsec_secinc_end:
    ret

readsec_end:
  pop dx
  ret

