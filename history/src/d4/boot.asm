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
  mov dx, FATOffsetAddr
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

load_Cluster:
  mov si, dx                                      ; the corresponding item is located in DS:DX
  mov ax, [ds:si + 26]                            ; no. cluster is located with an offset 26
  push ax                                         ; put the cluster no. in the stack in case it
                                                  ; probably be rewritten by readsec
  mov eax, [ds:si + 28]
  push eax                                        ; put the file length into the stack

load_FileAllocationTable:                         ; match found in DS:DX
  mov ax, FATBaseAddr
  mov es, ax
  mov bx, FATOffsetAddr
  mov ax, CFAT12_SecNoOfFAT1                      ; we're going to load the first FAT
  mov bx, CFAT12_SecPerFAT
  call readsec

load_kernel:                                      ; we need to locate the kernel through FAT
  pop ebx                                         ; use EBX to store the file length
  pop ax                                          ; use AX to store the initial cluster no.
  load_kernel_loop:
    ; obtain the current cluster
    call nextcluster
    call dispdebug
    ; debug
    jmp fin
    cmp ax, 0x0ff8
    jb load_kernel_loop                           ; if next cluster < 0x0ff8 we can continue
    
  ; todo 
  ; use a loop to read all clusters, we also need a function to calculate the corresponding
  ; sector

nextcluster:
  push si
  mov ch, 2
  div ch                                          ; AX = AL * 2 + AH
  mov cl, ah                                      ; cl = 0 / 1
  mov ah, 0                                       ; clear AH, so AX = AX / 2 now
  mov ch, 3
  mul ch                                          ; AX = 3 * AX
  mov si, ax                                      ; SI set to the offset of current 3-byte
  mov ch, 0                                       ; let CX = CL
  add si, cx
  mov ax, [es:si]                                 ; read two bytes
  cmp cl, 0
  jne nextcluster_second
  nextcluster_first:
    shl ax, 8
    jmp nextcluster_fin
  nextcluster_second:
    shl ax, 4

nextcluster_fin:
  and ax, 0000111111111111b
  pop si
  ; ax / 2 = al, ax % 2 = ah
  ; ch := ah, ah = 0
  ; ax = ax * 3 ---- Offset

; Compare is used to compare two blocks
; - one is [cs:di]
; - another is [ds:dx]
; - with length bx
compare:
  mov si, dx                  ; initialization, which should be in the write place (not in loop)

compare_loop:
  mov al, [cs:di]             ; obtain a character
  cmp al, [ds:si]             ; compare the current character
  jne compare_fail
  add di, 1
  add si, 1
  sub bx, 1                   ; limit pointer
  cmp bx, 0                   ; check if all comparation have been done
  jne compare_loop            ; continue loop
  mov ah, 0                   ; match found !!
  ret                         ; finish

compare_fail:
  mov ah, 1
  ret

fin_unfound:                  ; NO Kernels Found !!!!!!
  mov dx, NotFoundStr
  call dispstr
  jmp $

fin:                          ; 程序结束
  mov dx, FinishFlag
  call dispstr
  jmp $

; --------------------------------------- import libraries ---------------------------------------

%include "display.asm"
%include "floppy.asm"

; ---------------------------------------- 数据段 ------------------------------------------------
MaxItem     db 0x00

LoadStr     db "Load Root Dir ... ", 0x00
RootStr     db "Done.", 0x0a, "Locate Kernel ... ", 0x00
NotFoundStr db "Not Found.", 0x00
KernalName  db "KERNEL  "
FinishFlag  db " [DONE]", 0x00

TIMES (0x01FE-($-$$)) db 0    ; 填充当前扇区。不知道为何原文给定的填充结束位置为0x7dfe
                              ; 不过这个填充位置显然是错的，因为这样55AA标志便远在引导扇区之外
                              ; 因此我们将填充位置改为 0x01FE，因为 0x01FE + 2 = 0x0200恰好为
                              ; 第一个扇区的长度
DB    0x55, 0xaa
