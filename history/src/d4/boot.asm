ORG   0x7c00          ; 引导区加载位置
                      ; 与之相对的详细内存分区可参考 http://www.bioscentral.com/misc/bda.htm

;--------------------------------------- FAT12 格式描述 ------------------------------------------
; FAT12 引导扇区格式参见 http://blog.sina.com.cn/s/blog_3edcf6b80100cr08.html
jmp entry
nop
%include "fat12.asm"
; ----------------------------------------- 常量定义 ---------------------------------------------
StackBaseAddr    equ 0x0800
FATBaseAddr      equ 0x1000
FATOffsetAddr    equ 0x0000
KernelBaseAddr   equ 0x2400
KernelOffsetAddr equ 0x0000

; todo is FAT space large enough to conatins all possible 224 items ?

;------------------------------------------ 程序主体 ---------------------------------------------
; BIOS中断表参见 http://www.cnblogs.com/walfud/articles/2980774.html
entry:
  mov dx, LoadStr
  call dispstr                                    ; 显示提示信息

  ; 载入根目录文件表
  mov sp, StackBaseAddr                           ; stack initialization
  mov ax, FATBaseAddr                             ; 设置数据缓冲基地址
  mov es, ax
  mov bx, FATOffsetAddr                           ; 设置数据缓冲偏移
  mov ax, CFAT12_SecNoOfRoot                      ; 0 - boot sector, 1 - 9/10 - 18 : FAT1/2
  mov cx, CFAT12_RootSectors                      ; number of sectors
  call readsec                                    ; obtain the root directory items

  mov dx, RootStr
  call dispstr                                    ; notice the users that we've finished the items

  mov dx, FATBaseAddr
  mov ds, dx
  mov dx, FATOffsetAddr                           ; dx is initialized as Offset - Itemlen
  sub dx, CFAT12_RootItemLen
  mov byte [MaxItem], CFAT12_RootEntCnt           ; maximal iteration limit

search_kernel:
  add dx, CFAT12_RootItemLen                      ; jump to next item
  sub byte [MaxItem], 1                           ; decrease the limit counter
  cmp byte [MaxItem], 0
  je fin_unfound                                  ; we have meet the limit
  mov di, KernalName
  mov bx, 7
  call compare
  cmp ah, 0
  jne search_kernel

save_clusterNo:
  mov si, dx                                      ; the corresponding item is located in DS:DX
  mov ax, [ds:si + 26]                            ; no. cluster is located with an offset 26
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

load_kernel:                                      ; we need to locate the kernel through FAT
  mov ax, KernelBaseAddr                          ; initialize base address of kernel
  mov es, ax
  mov bx, KernelOffsetAddr                        ; initialize offset address of kernel
  pop ax
  load_kernel_loop:
    ; obtain the current cluster
    add ax, CFAT12_SecNoClstZero                  ; cluster no. -> sector no.
    mov cx, 1                                     ; one cluster, one time (very important)
    call readsec                                  ; read one sector as a cluster
    add bx, [FAT12_BytesPerSec]                   ; move the address pointer
    sub ax, CFAT12_SecNoClstZero                  ; sector no. -> cluster no. before continuing
    call nextcluster                              ; find the index of the successing cluster
    cmp ax, 0x0ff0                                ; successor < 0x0ff0, that's good sectors
    jb load_kernel_loop                           ; continue reading
    cmp ax, 0x0ff8                                ; if 0x0ff0 <= successor <= 0x0ff7, the cluster is
                                                  ; broken and should not be used
    jb fin_brokencluster
    ; otherwise we have finished kernel loading
    jmp fin
    
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

fin:                          ; 程序结束
  mov dx, FinishFlag
  call dispstr
  jmp halt

halt:
  hlt
  jmp halt

; --------------------------------------- import libraries ---------------------------------------

%include "compare.asm"
%include "display.asm"
%include "floppy.asm"

; ---------------------------------------- 数据段 ------------------------------------------------
MaxItem       db 0x00

LoadStr       db "Load-", 0x00
RootStr       db "Seek-", 0x00
NotFoundStr   db "404", 0x00
BrkClusterStr db "BrkCluster", 0x00
KernalName    db "KERNEL  "
FinishFlag    db "FIN", 0x00

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
