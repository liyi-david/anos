%macro descriptor 3
  dw (%2) & 0ffffh                   ; 界限值0-15位
  dw (%1) & 0ffffh                   ; 基地址0-15位
  db ((%1) >> 16) & 0ffh             ; 基地址16-23位
  dw (((%2) >> 8) & 0f00h) | (%3)    ; 界限值16-19位，和段属性
  db ((%1) >> 24) & 0ffh             ; 基地址24-31位
%endmacro

SA_BYTES        equ 0 << 15          ; 段粒度：字节, 段限长的20位即位实际限长
SA_PAGES        equ 1 << 15          ; 段粒度：页，段现场的20位乘以2^12凑足32位，最大限长为4GB

SA_16BIT        equ 0 << 14          ; 16位段
SA_32BIT        equ 1 << 14          ; 32位段

; 13 位始终为 0

SA_ABSENT       equ 0 << 7           ; 不存在
SA_PRESENT      equ 1 << 7           ; 存在

SA_DPL_0        equ 0 << 5           ; 段特权级0-3, 表示访问该段时CPU所需处于的最低特权级
SA_DPL_1        equ 1 << 5
SA_DPL_2        equ 2 << 5
SA_DPL_3        equ 3 << 5

SA_SYSTEM       equ 0 << 4           ; 系统段
SA_STORAGE      equ 1 << 4           ; 存储段

SA_DATA         equ 0 << 3           ; 数据段
SA_CODE         equ 1 << 3           ; 代码段

SA_EXTHIGH      equ 0 << 2           ; 向高位扩展（数据段）
SA_EXTLOW       equ 1 << 2           ; 向低位扩展（数据段）
SA_STACK        equ 0 << 2           ; 普通代码段（代码段）
SA_CONFORM      equ 1 << 2           ; 一致代码段（代码段）

SA_READONLY     equ 0 << 1           ; 只读
SA_WRITABLE     equ 1 << 1           ; 可写

SA_UNACCESSED   equ 0 << 0           ; 未访问
SA_ACCESSED     equ 1 << 0           ; 已访问
