COPYRIGHT MACRO
  dc.b    "Copyright (c) 2023 CDTV Land. ",0
  dc.b    "Published under GPLv3 license. ",0
  dc.b    "Written by Captain Future, CDTV Land.",$a,$d,0  
  ENDM

CARDBASE       equ $00E00000
MAXCARDMEM     equ $00080000 
INTERVAL       equ $00000400
BOUNDARY       equ (INTERVAL-1)^$FFFFFFFF
TESTPATTERN    equ $AAAA5555
