# Anos 30天自制操作系统

## Ques.

- when file comes large, it may behave weiredly?

## logs
## learning
- **Jan 23 2016** hello world
- **Jan 27 2016** *Day 4*
  - rewrite the bootloader, make it able to search for the root directory
- **Feb 01 2016** Succeeded in loading *loader.bin*
- **Feb 02 2016** Complete *print.asm*, to help debug asm codes

### debug
I use qemu and gdb to debug my kernel.
#### bochsdbg & gdb
- the source code is checkout from sourceforge.net
- configured by `./configure --enable-disasm --enable-plugins --enable-gdb-stub`
-

#### some note
- `and [bx+si],ah` is equivalent to `0`. when you find the current instruction like this, there must be something wrong with the program.
- bochsdbg is not included in ubuntu default repo
- it's important in *protected mode* that
  - all segement registers are supposed to be correct selectors (even when they are assigned)

### ideas
- it's so important to avoid uncontrolled variation of registers during function calls
- when using memories through [offset], it's important to figure out the default segment register
