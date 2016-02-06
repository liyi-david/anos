; debug
;printdebugsym:
  ;push bx
  ;push ax
  ;mov bl, 0
  ;mov ah, 0x0E
  ;mov al, bh
  ;add al, 0x30
  ;int 0x10
  ;mov al, bl
  ;add al, 0x30
  ;int 0x10
  ;mov al, '/'
  ;int 0x10
  ;pop ax
  ;pop bx
  ;ret

; 这个文件是用来存放软盘读写的 API
; http://blog.csdn.net/littlehedgehog/article/details/2147361

; 输入参数:
; AX - 待载入文件的文件名（前8位）地址（所在位置）
; BX - 将要载入到的位置段
; CX - 将要载入到的位置偏移

; 返回值 - AH = 0 (正确载入)
; AH = 1 (出现错误)
loadfile:
  ; 载入根目录文件表
  push cx
  push bx
  push ax
  mov ax, FATBaseAddr                             ; 设置数据缓冲基地址
  mov es, ax
  mov bx, FATOffsetAddr                           ; 设置数据缓冲偏移
  mov ax, CFAT12_SecNoOfRoot                      ; 0 - boot sector, 1 - 9/10 - 18 : FAT1/2
  mov cx, CFAT12_RootSectors                      ; number of sectors
  call readsec                                    ; obtain the root directory items
  ; 根目录载入完毕
  ; 接下来查找根目录中的全部224项，检查是否存在指定名称的字符串
  mov dx, FATOffsetAddr
  sub dx, CFAT12_RootItemLen
  mov si, dx
  mov byte [MaxItem], CFAT12_RootEntCnt           ; maximal iteration limit

; 查找Loader
; 过程中，es:si始终指向当前根目录项的首位值
; 首先我们将文件名地址出到di处
  pop di 

search_file:
  add si, CFAT12_RootItemLen                      ; jump to next item
  sub byte [MaxItem], 1                           ; decrease the limit counter
  cmp byte [MaxItem], 0
  je loader_loader_fail                           ; we have meet the limit
  mov eax, [ds:di]
  cmp dword [es:si], eax                          ; compare first 4 chars
  jne search_file                                 ; 如果不相同，则说明前4位不符
  mov eax, [ds:di+4]
  cmp dword [es:si+4], eax
  jne search_file

; 若找到文件，则马上从项目中取出相应的首簇号
save_clusterNo:
  mov ax, [es:si + 26]                            ; no. cluster is located with an offset 26
  push ax                                         ; put the cluster no. in the stack in case it
                                                  ; probably be rewritten by readsec
  ; mov eax, [ds:si + 28]                         ; filelength, currently not used


load_FileAllocationTable:                         ; match found in DS:DX
  mov bx, FATOffsetAddr
  mov ax, CFAT12_SecNoOfFAT1                      ; we're going to load the first FAT
  mov cx, CFAT12_SecPerFAT
  call readsec

load_filebody:                                    ; we need to locate the kernel through FAT
  mov ax, es
  mov gs, ax                                      ; put the base address of FAT to gs
  pop ax                                          ; 恢复簇号
  pop bx                                          ; initialize base address of loader.bin (line 7)
  mov es, bx
  pop bx                                          ; initialize offset address of loader.bin
  load_loader_loop:
    ; we should check the cluster number FIRSTLY
    cmp ax, 0x0ff8                                ; if 0x0ff0 <= successor <= 0x0ff7, the cluster is
                                                  ; broken and should not be used
    jnb loader_loader_fin
    cmp ax, 0x0ff0                                ; successor < 0x0ff0, that's good sectors
    jnb loader_loader_fail                           ; continue reading
    ; obtain the current cluster
    add ax, CFAT12_SecNoClstZero                  ; cluster no. -> sector no.
      mov cx, 1                                   ; one cluster, one time (very important)
      call readsec                                ; read one sector as a cluster
      add bx, CFAT12_BytesPerSec                  ; move the address pointer
    sub ax, CFAT12_SecNoClstZero                  ; sector no. -> cluster no. before continuing
    call nextcluster                              ; find the index of the successing cluster
    jmp load_loader_loop

  loader_loader_fin:
    ; otherwise we have finished kernel loading
    mov ah, 0
    ret

  loader_loader_fail:        ; NO Kernels Found !!!!!!
    mov ah, 1                ; 设置返回值
    pop bx                   ; [重要] 在任意一个返回过程中都要正确清理堆栈
    pop cx
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

; NOTE: BX若跨越段则可能造成错误！！！
readsec:
  push bx
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
  push ax
  mov al, 1                           ; 每次只读1个扇区
  mov ah, 2                           ; 设定为读取磁盘模式
  tryread:
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
  pop bx
  ret

; -------------------------------------- Data Segment -------------------------------------------
MaxItem       db 0x00                  
; used when searching for certain files
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
