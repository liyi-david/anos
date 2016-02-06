[section .text]
[bits 32]

entry32:
  ; 堆栈初始化
  ; 务须注意，所有可能用到的段寄存器均须初始化为某个合法段
  mov ax, gdtselector_stackseg
  mov ss, ax
  mov ax, gdtselector_loader32seg
  mov ds, ax
  mov es, ax
  mov gs, ax
  mov esp, Kernel32SegBaseAddr - Stack32BaseAddr - 16
  mov ebp, esp
  mov edx, ProtectedReadyStr
  call print
  jmp $

%include "print32.asm"
