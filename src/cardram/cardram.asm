           ************************************************************************
           ***                                                                  ***
           ***             -= COMMODORE CDTV ROM OPERATING SYSTEM =-            ***
           ***                                                                  ***
           ************************************************************************
           ***                                                                  ***
           ***     CARDRAM - AUTO-ADDMEM CD1401/CD1405                          ***
           ***     Copyright (c) 2023 CDTV Land. Published under GPLv3.         ***
           ***     Written by Captain Future                                    ***
           ***                                                                  ***
           ************************************************************************


  INCLUDE      exec/exec_lib.i
  INCLUDE      exec/execbase.i
  INCLUDE      exec/resident.i
  INCLUDE      exec/memory.i
  INCLUDE      defs.i
  INCLUDE      rev.i


  ; This resident module automatically adds all free memory on the CD1401/CD1405 CDTV 
  ; memory card to the system RAM pool. It needs to be loaded onto the memory card 
  ; and will then automatically be initialized on startup if the CD1000 player is
  ; running off of exec.library 34.1001 or 37.201 (these are the CDTV OS ROM specific
  ; versions of exec that scan $E00000-$E7FFFF for resident modules).


  ; IMPORTANT NOTE:

  ; If multiple resident modules are installed on the memory card, then this cardram
  ; module MUST be the last one in the list!


;************************************************************************************************
;*                                           ROM TAG                                            *
;************************************************************************************************

ROMTag:
  dc.w         RTC_MATCHWORD
  dc.l         ROMTag
  dc.l         EndSkip
  dc.b         RTF_COLDSTART
  dc.b         VERSION
  dc.b         NT_UNKNOWN
  dc.b         111                          ; priority
  dc.l         Name
  dc.l         IDString
  dc.l         Init

IDString:
  VSTRING
  COPYRIGHT

  CNOP         0,2


;************************************************************************************************
;*                                           FUNCTION                                           *
;************************************************************************************************

Init:
  movem.l      a6-a2/d7-d2,-(sp)            ; save registers
  move.l       #CARDBASE,a0                 ; this is where cardmem starts
  move.l       #MAXCARDMEM,d0               ; we support a maximum of 512K
  lea          0(a0,d0.l),a1                ; store the limit address
  lea.l        EndSkip(pc),a2               ; get first free address
  move.l       a2,d0                        ; longword align the address
  addq         #3,d0
  and.l        #$FFFFFFFC,d0
  movea.l      d0,a2                        ; and save it
  bsr.s        CheckSize                    ; determine size of free RAM


  ; Add available card memory to the system free pool

  movea.l      4.w,a6                       ; load ExecBase
  move.l       #MEMF_PUBLIC|MEMF_FAST,d1    ; set memory attributes
  clr.l        d2                           ; priority
  move.l       a2,a0                        ; base address
  lea.l        MemoryName(pc),a1            ; memory name
  jsr          _LVOAddMemList(a6)           ; add the memory
  movem.l      (sp)+,d2-d7/a2-a6            ; restore regs

  rts


;************************************************************************************************
;*                                           FUNCTION                                           *
;************************************************************************************************

CheckSize:

  ; A0 = address start
  ; A1 = address limit

  ; We check for RAM at 1K intervals, starting from the first K boundary after this
  ; resident module's end. This is why cardram needs to be the last resident module
  ; on the memcard. Everything after it gets added to system RAM.

  move.l       (a0),d2                      ; save the first longword

  ; 1K align

  add.l        #INTERVAL-1,d0
  and.l        #BOUNDARY,d0
  sub.l        #INTERVAL,d0                 ; set up for loop
  move.l       d0,a0

  move.l       #TESTPATTERN,d0              ; set our test pattern

.loop:  
  lea          INTERVAL(a0),a0              ; get first/next address to test
  cmp.l        a0,a1                        ; have we reached the limit?
  bls.s        .done                        ; yep, quit

  move.l       d0,(a0)                      ; write test pattern to address
  move.l       (CARDBASE),d1                ; check for wrap around..
  cmp.l        d1,d2                        ; ..by checking if first longword is stll unchanged
  bne.s        .done                        ; we've wrapped around, we're done
  cmp.l        (a0),d0                      ; check if test pattern was written (RAM checK)
  beq.s        .loop                        ; if RAM check OK go to next, else quit

.done:
  move.l       d2,(CARDBASE)                ; restore long word at base
  move.l       a0,d0
  lea.l        EndSkip(pc),a0
  move.l       a0,d1
  sub.l        d1,d0                        ; total free RAM

  rts


;************************************************************************************************
;*                                           DATA                                               *
;************************************************************************************************

Name:
  dc.b         "cardram",0

MemoryName:
  dc.b         "CDTV Memory Card RAM",0

  CNOP         0,2

EndSkip:

  END