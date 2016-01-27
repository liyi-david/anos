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

