# filename: gdb.cmd
# gdb will read it when starting

# qemu is started in debug mode with local port 1234
target remote localhost:1234

# make gdb run in disassebmle mode, since we have no source code
set disassemble-next-line on

# display disassemble code in intel style
set disassembly-flavor intel

# display /3i

# since sigtrap signal shows up frequently, I decided to totally disable this signal
handle SIGTRAP nostop noprint

# breakpoint: boot sector
b *0x7c00
# breakpoint: the final jump of boot sector
b *0x7c5d
# breakpoint: before jump to kernel
b *0x81c0:0x0000

