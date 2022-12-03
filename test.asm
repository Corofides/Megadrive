; ******************************************************************
; Sega Megadrive ROM header
; ******************************************************************
EnableSRAM = 0
BackupSRAM = 1
AddressSRAM = 3
Revision = 1

    org  $0
    dc.l $0010F300            ; Initial SP
    dc.l $00C00402            ; Initial PC
    dc.l $00C00408            ; Bus error
    dc.l $00C0040E            ; Address error
    dc.l $00C0040E            ; Illegal Instruction
    dc.l $0000034C            ; Divide by 0
    dc.l $0000034E            ; CHK Instruction
    dc.l $0000034E            ; TRAPV Instruction
    dc.l $00C0041A            ; Privilege Violation
    dc.l $00C00420            ; Trace
    dc.l $0000034E,$0000034E  ; Emu
    dc.l $00C00426,$00C00426,$00C00426  ; Reserved
    dc.l $00C0042C            ; Uninit. Int. Vector.
    dc.l $00C00426,$00C00426,$00C00426,$00C00426  ; Reserved
    dc.l $00C00426,$00C00426,$00C00426,$00C00426  ; Reserved
    dc.l $00C00432            ; Spurious Interrupt
    dc.l VBlank               ; Level 1
    dc.l IRQ2                 ; Level 2
    dc.l $00C00426            ; Level 3
    dc.l $00C00426,$00C00426,$00C00426,$00C00426  ; Level 4~7
    dc.l $0000056E,$0000056E,$0000056E,$0000056E  ; Traps...
    dc.l $0000056E,$0000056E,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
    dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF


		dc.b "SEGA MEGA DRIVE " ; Hardware system ID (Console name)
		dc.b "(C)SEGA 1991.APR" ; Copyright holder and release date (generally year)
		dc.b "SONIC THE               HEDGEHOG                " ; Domestic name
		dc.b "SONIC THE               HEDGEHOG                " ; International name
		if Revision=0
		dc.b "GM 00001009-00"   ; Serial/version number (Rev 0)
		else
			dc.b "GM 00004049-01" ; Serial/version number (Rev non-0)
		endif
Checksum:
		if Revision=0
		dc.w $264A	; Hardcoded to make it easier to check for ROM correctness
		else
		dc.w $AFC7
		endif
		dc.b "J               " ; I/O support
		dc.l StartOfRom		; Start address of ROM
RomEndLoc:	dc.l EndOfRom-1		; End address of ROM
		dc.l $FF0000		; Start address of RAM
		dc.l $FFFFFF		; End address of RAM
		if EnableSRAM=1
		dc.b $52, $41, $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20 ; SRAM support
		else
		dc.l $20202020
		endif
		dc.l $20202020		; SRAM start ($200001)
		dc.l $20202020		; SRAM end ($20xxxx)
		dc.b "                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
		dc.b "JUE             " ; Region (Country code)
EndOfHeader:

 Loop:
  move #ff,d0 ; Move 15 into register d0
  move.l d0,d1   ; Move contents of register d0 into d1
  jmp Loop        ; Jump back up to 'Loop'
