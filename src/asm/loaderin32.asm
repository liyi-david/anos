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

  mov edx, DoneStr
  call print

  ; 分析ELF格式的内核（现已经被载入到内存中）
  mov edx, AnalyzeElfStr
  call print

  jmp $

%include "print32.asm"

[section .data]
AnalyzeElfStr     db  "Analyzing elf kernel binary ... ", 0x00
