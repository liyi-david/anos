# Anos 30天自制操作系统

## Ques.

- when file comes large, it may behave weiredly?

## logs
## learning
- **Jan 23 2016** hello world
- **Jan 27 2016** *Day 4*
  - rewrite the bootloader, make it able to search for the root directory

### debug
I use qemu and gdb to debug my kernel.

#### some note
- `and [bx+si],ah` is equivalent to `0`. when you find the current instruction like this, there must be something wrong with the program.
- 
-

### ideas
- it's so important to avoid uncontrolled variation of registers during function calls
