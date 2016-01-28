; 这个文件是用来存放软盘读写的 API
; http://blog.csdn.net/littlehedgehog/article/details/2147361

loadfile:
  ; 载入根目录文件表
  push cx
  push bx
  mov ax, FATBaseAddr                             ; 设置数据缓冲基地址
  mov es, ax
  mov bx, FATOffsetAddr                           ; 设置数据缓冲偏移
  mov ax, CFAT12_SecNoOfRoot                      ; 0 - boot sector, 1 - 9/10 - 18 : FAT1/2
  mov cx, CFAT12_RootSectors                      ; number of sectors
  call readsec                                    ; obtain the root directory items

  mov dx, RootStr
  call dispstr                                    ; notice the users that we've finished the items

  mov dx, FATOffsetAddr                           ; dx is initialized as Offset - Itemlen
  sub dx, CFAT12_RootItemLen
  mov si, dx
  mov byte [MaxItem], CFAT12_RootEntCnt           ; maximal iteration limit

search_file:
  add si, CFAT12_RootItemLen                      ; jump to next item
  sub byte [MaxItem], 1                           ; decrease the limit counter
  cmp byte [MaxItem], 0
  je fin_unfound                                  ; we have meet the limit
  pop di
  push di                                         ; now di contains the filename
  cmp dword [es:si], "LOAD"                       ; compare first 4 chars
  jne search_file
  cmp dword [es:si+4], "ER  "
  jne search_file

save_clusterNo:
  mov ax, [gs:si + 26]                            ; no. cluster is located with an offset 26
  push ax                                         ; put the cluster no. in the stack in case it
                                                  ; probably be rewritten by readsec
  ; mov eax, [ds:si + 28]                         ; filelength, currently not used

load_FileAllocationTable:                         ; match found in DS:DX
  mov ax, FATBaseAddr
  mov es, ax
  mov gs, ax
  mov bx, FATOffsetAddr
  mov ax, CFAT12_SecNoOfFAT1                      ; we're going to load the first FAT
  mov cx, CFAT12_SecPerFAT
  call readsec


load_filebody:                                    ; we need to locate the kernel through FAT
  pop ax
  pop bx                                          ; initialize base address of loader.bin (line 7)
  mov es, bx
  pop bx                                          ; initialize offset address of loader.bin (line 6)
  load_loader_loop:
    ; obtain the current cluster
    add ax, CFAT12_SecNoClstZero                  ; cluster no. -> sector no.
    mov cx, 1                                     ; one cluster, one time (very important)
    call readsec                                  ; read one sector as a cluster
    add bx, CFAT12_BytesPerSec                    ; move the address pointer
    sub ax, CFAT12_SecNoClstZero                  ; sector no. -> cluster no. before continuing
    call nextcluster                              ; find the index of the successing cluster
    cmp ax, 0x0ff0                                ; successor < 0x0ff0, that's good sectors
    jb load_loader_loop                           ; continue reading
    cmp ax, 0x0ff8                                ; if 0x0ff0 <= successor <= 0x0ff7, the cluster is
                                                  ; broken and should not be used
    jb fin_brokencluster
    ; otherwise we have finished kernel loading
    ret
    
; suppose AX stores the index of current cluster
; *nextcluster* generates the successor cluster index, stored in AX
nextcluster:
  push si                                         ; put two registers in stack
  push bx
  mov cl, al
  and cl, 1                                       ; CL = AX % 2 = 0 / 1
  shr ax, 1                                       ; AX /= 2
  mov bx, ax
  shl ax, 1                                       ; AX = 3 * AX
  add ax, bx
  mov si, ax                                      ; SI set to the offset of current 3-byte
  mov ch, 0                                       ; let CX = CL
  add si, cx                                      ; CX == 0 - pick up the first two bytes, otherwise
                                                  ; the last two bytes (in the 3-byte block)
  mov al, [gs:si]                                 ; read two bytes
  mov ah, [gs:si + 1]                             ; high byte in memory to low byte in ax, vise versa

  cmp cl, 0
  je nextcluster_fin
  shr ax, 4

nextcluster_fin:
  and ax, 0000111111111111b                       ; pick up the lower 12-bit since all cluster
                                                  ; descriptor contains only 12 bit
  pop bx
  pop si
  ret

fin_unfound:                  ; NO Kernels Found !!!!!!
  mov dx, NotFoundStr
  call dispstr
  jmp halt

fin_brokencluster:
  mov dx, BrkClusterStr
  call dispstr
  jmp halt

halt:
  hlt
  jmp halt
; -------------------------------------- Assistant Functions ------------------------------------
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
  push ax
  push dx
  push cx                             ; since bx is used in following lines, we need to store its
  push bx                             ; value temporarily
  mov bl, CFAT12_SecPerTrk
  div bl                              ; AX % BL = AH, AX / BL = AL
  pop bx
  mov dh, al                          ; 求磁头号
  and dh, 0x01                        ; 若是偶数，则磁头号为0，否则为1
  shr al, 1
  mov ch, al                          ; 柱面号 or 磁道号 
  mov cl, ah                          ; 起始扇区号
  add cl, 1                           ; obviously cl in [0, 17] and we need it to be [1, 18]
  mov dl, CFAT12_DrvNum
  pop ax                              ; 将待读个数CX弹到AX中，用AX为计数器


readsec_loop:
  ; call dispdebug                    ; dispdebug函数用来输出调试信息
  push ax
  mov al, 1                           ; 每次只读1个扇区
  mov ah, 2                           ; 设定为读取磁盘模式
  tryread:
    call dispdebug
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
  pop ax
  ret

; -------------------------------------- Data Segment -------------------------------------------
MaxItem       db 0x00                  ; used when searching for certain files
RootStr       db "Seek - ", 0x00
NotFoundStr   db "404", 0x00
BrkClusterStr db "BrkCluster", 0x00

; ------------------------------------------------------------------------------------------------
; 一些基于FAT12头的常量定义
; ------------------------------------------------------------------------------------------------

CFAT12_DrvNum            equ   0
CFAT12_BytesPerSec       equ   512
CFAT12_SecPerFAT         equ   9                                            ; number of sectors in each FAT
CFAT12_SecPerTrk         equ   18                                           ; number of sectors in each Track
CFAT12_RootSectors       equ   CFAT12_RootEntCnt * CFAT12_RootItemLen / 512 ; number of sectors that contains root items
CFAT12_SecNoOfRoot       equ   CFAT12_SecNoOfFAT1 + 2 * CFAT12_SecPerFAT    ; index of root directory table's starting location
CFAT12_SecNoOfFAT1       equ   1                                            ; index of FAT1's starting section
CFAT12_RootEntCnt        equ   224                                          ; maximal number of items in root directory
CFAT12_SecNoClstZero     equ   CFAT12_SecNoOfRoot + CFAT12_RootSectors - 2  ; the sector index of cluster 0
                                                                            ; since the data cluster starts from cluster 2
                                                                            ; we need to decrease 2 here

CFAT12_RootItemLen       equ   32
