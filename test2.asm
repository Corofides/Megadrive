	DC.L	$FFFFFE00		;SP register value
	DC.L	ProgramStart	;Start of Program Code
	DS.L	7,IntReturn		; bus err,addr err,illegal inst,divzero,CHK,TRAPV,priv viol
	DC.L	IntReturn		; TRACE
	DC.L	IntReturn		; Line A (1010) emulator
	DC.L	IntReturn		; Line F (1111) emulator
	DS.L	4,IntReturn		; Reserverd /Coprocessor/Format err/ Uninit Interrupt
	DS.L	8,IntReturn		; Reserved
	DC.L	IntReturn		; spurious interrupt
	DC.L	IntReturn		; IRQ level 1
	DC.L	IntReturn		; IRQ level 2 EXT
	DC.L	IntReturn		; IRQ level 3
	DC.L	IntReturn		; IRQ level 4 Hsync
	DC.L	IntReturn		; IRQ level 5
	DC.L	IntReturn		; IRQ level 6 Vsync
	DC.L	IntReturn		; IRQ level 7 
	DS.L	16,IntReturn	; TRAPs
	DS.L	16,IntReturn	; Misc (FP/MMU)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Header
	DC.B	"SEGA GENESIS    "	;System Name
	DC.B	"(C)CHBI "			;Copyright
 	DC.B	"2019.JAN"			;Date
	DC.B	"ChibiAkumas.com                                 " ; Cart Name
	DC.B	"ChibiAkumas.com                                 " ; Cart Name (Alt)
	DC.B	"GM CHIBI001-00"	;TT NNNNNNNN-RR T=Type (GM=Game) N=game Num  R=Revision
	DC.W	$0000				;16-bit Checksum (Address $000200+)
	DC.B	"J               "	;Control Data (J=3button K=Keyboard 6=6button C=cdrom)
	DC.L	$00000000			;ROM Start
	DC.L	$003FFFFF			;ROM Length
	DC.L	$00FF0000,$00FFFFFF	;RAM start/end (fixed)
	DC.B	"            "		;External RAM Data
	DC.B	"            "		;Modem Data
	DC.B	"                                        " ;MEMO
	DC.B	"JUE             "	;Regions Allowed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Generic Interrupt Handler
IntReturn:
	rte

vdp_control	= $00C00004; VDP Control Port
vdp_data	= $00C00000; VDP Data Port

ProgramStart:
	move #$2700,sr

ClearRam
	move.l #$00000000,d0
	move.l #$00000000,a0
	move.l #$00003FFF,d1
.clear
	move.l d0,-(a0)
	dbra d1,.clear
	
TMSS
	move.b $00A10001,d0
	andi.b #$0F,d0
	beq    .skip
	move.l #'SEGA',$00A14000
.skip

Z80
	move.w	#$0100,$00A11100
	move.w  #$0100,$00A11200
.wait
	btst	#$0,$00A11101
	bne	.wait
	move.l 	#$00A00000,a1
	move.l	#$00C30000,(a1)
	
	move.w #$0000,$00A11200
	move.w #$0000,$00A11100

	move.l #$9fbfdfff,$00C00011


init_vdp
	move.l	#VDPRegisters,a0
	move.l 	#$18,d0
	move.l 	#$00008000,d1

copy_vdp
	move.b	(a0)+,d1
	move.w 	d1,$00C00004
	add.w 	#$0100,d1
	dbra	d0,copy_vdp

init_controllers
	move.b #$00,$000A10009
	move.b #$00,$000A1000B
	move.b #$00,$000A1000D

cleanup
	move.l #$00000000,a0
	movem.l (a0),d0-d7/a1-a7

main
	jmp __main


__main
	move.l #$40000003,$00C00004
	move.w $8F02,$00C00004
	move.l #$C0000003,$00C00004
	lea Palette,a0
	move.l #$07,d0

loop:
	move.l (a0)+,0x00C00000
	dbra d0,loop

	move.w #$8708,$00C00004 ; Make it Pink!

main_loop
	nop
	jmp main_loop


	;move.w #0,d0
	;move.w #$8F00,vdp_control
	;move.l #$C0000003,vdp_control
	;move.w d0,vdp_data
	;add.w  #1,d0
	;move.w #100,d1
.wait
	;dbra   d1,.wait
	;jmp    loop

VDPRegisters:
   dc.b $20 ; 0: Horiz. interrupt on, plus bit 2 (unknown, but docs say it needs to be on)
   dc.b $74 ; 1: Vert. interrupt on, display on, DMA on, V28 mode (28 cells vertically), + bit 2
   dc.b $30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
   dc.b $40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
   dc.b $05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
   dc.b $70 ; 5: Sprite table at 0xE000 (bits 0-6)
   dc.b $00 ; 6: Unused
   dc.b $00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
   dc.b $00 ; 8: Unused
   dc.b $00 ; 9: Unused
   dc.b $00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
   dc.b $08 ; 11: External interrupts on, V/H scrolling on
   dc.b $81 ; 12: Shadows and highlights off, interlace off, H40 mode (40 cells horizontally)
   dc.b $34 ; 13: Horiz. scroll table at 0xD000 (bits 0-5)
   dc.b $00 ; 14: Unused
   dc.b $00 ; 15: Autoincrement off
   dc.b $01 ; 16: Vert. scroll 32, Horiz. scroll 64
   dc.b $00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
   dc.b $00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
   dc.b $00 ; 19: DMA length lo byte
   dc.b $00 ; 20: DMA length hi byte
   dc.b $00 ; 21: DMA source address lo byte
   dc.b $00 ; 22: DMA source address mid byte
   dc.b $00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)

Palette:
   dc.w 0x0000 ; Colour 0 - Transparent
   dc.w 0x000E ; Colour 1 - Red
   dc.w 0x00E0 ; Colour 2 - Green
   dc.w 0x0E00 ; Colour 3 - Blue
   dc.w 0x0000 ; Colour 4 - Black
   dc.w 0x0EEE ; Colour 5 - White
   dc.w 0x00EE ; Colour 6 - Yellow
   dc.w 0x008E ; Colour 7 - Orange
   dc.w 0x0E0E ; Colour 8 - Pink
   dc.w 0x0808 ; Colour 9 - Purple
   dc.w 0x0444 ; Colour A - Dark grey
   dc.w 0x0888 ; Colour B - Light grey
   dc.w 0x0EE0 ; Colour C - Turquoise
   dc.w 0x000A ; Colour D - Maroon
   dc.w 0x0600 ; Colour E - Navy blue
   dc.w 0x0060 ; Colour F - Dark green
