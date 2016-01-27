org 0x9100

mov ah, 0
mov al, 0x04
int 0x10

jmp $

LoaderReadyStr  db "Loader is Loaded", 0x00
