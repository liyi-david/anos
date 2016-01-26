extern choose                    ; 导入全局函数 choose

[section .data]                  ; 数据段
num1st dd 3
num2nd dd 4

[section .text]                  ; 代码段
global _start
global myprint

_start:
  push num2nd                    ; 压入函数的第二个参数
  push num1st                    ; 压入函数的第一个参数。注意压栈顺序和弹栈顺序相反
  call choose                    ; 调用C语言中的函数
  add esp, 4
  add ebx, 0
  mov eax, 1
  int 0x80                       ; 调用系统中断

myprint:
  mov edx, [esp + 8]
  mov ecx, [esp + 4]
  mov ebx, 1
  mov eax, 4
  int 0x80
  ret
