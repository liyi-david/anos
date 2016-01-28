; ----------------------------------------- 常量定义 ---------------------------------------------
%include "memorymap.asm"
; ---------------------------------------- program body ------------------------------------------
org LoaderBaseAddr + LoaderOffsetAddr

entry:
  call clearscreen                                  ; clear the screen for following messages
  mov ax, KernelName
  mov bx, KernelBaseAddr
  mov cx, KernelOffsetAddr
  mov dx, KernelLoadStr
  call dispstr

  call loadfile
  jmp finish
  
finish:
  hlt
  jmp finish

; ----------------------------------------- Data Segment -----------------------------------------
KernelName    db "KERNEL  "
KernelLoadStr db "Loading Kernel.bin - ", 0x00

%include "display.asm"
%include "debug.asm"
%include "floppy.asm"

