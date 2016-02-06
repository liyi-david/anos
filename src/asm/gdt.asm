; all descriptions of gdt are defined in this file

%include "gdtmicro.asm"

[section .data]

gdt:
  descriptor 0, 0, 0

gdtseg_stackseg:
  descriptor Stack32BaseAddr, \
             Kernel32SegBaseAddr - Stack32BaseAddr, \
             SA_DATA|SA_WRITABLE|SA_STORAGE|SA_32BIT|SA_PRESENT

gdtseg_loader32seg:
  descriptor LoaderBaseAddr << 4, \
             0xfffff, \
             SA_CODE|SA_WRITABLE|SA_STORAGE|SA_32BIT|SA_PRESENT

gdtseg_kernelseg:
  descriptor Kernel32SegBaseAddr, \
             0xfffff, \
             SA_CODE|SA_WRITABLE|SA_STORAGE|SA_32BIT|SA_PRESENT

gdtseg_videoseg:
  descriptor 0x000B8000, \
             0xffff, \
             SA_DATA|SA_WRITABLE|SA_STORAGE|SA_PRESENT

gdtlen                  equ $ - gdt

gdtselector_stackseg    equ gdtseg_stackseg - gdt
gdtselector_loader32seg equ gdtseg_loader32seg - gdt
gdtselector_kernelseg   equ gdtseg_kernelseg - gdt
gdtselector_video       equ gdtseg_videoseg - gdt

gdtr:
  dw gdtlen - 1
  dd (LoaderBaseAddr << 4) + gdt
