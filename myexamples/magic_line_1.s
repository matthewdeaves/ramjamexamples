; My Program to draw a single line on the screen that moves up and down as well as change colour on the x axis

; Let Amiga decide where to put our code
	SECTION MyCode,CODE

Start:
	move.l	4.w,a6		; Store Execbase in a6
	jsr	-$78(a6)		; Disable multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
				; the libraries, and outputs the base
				; addresss of that library to d0 so we can use offsets
	move.l	d0,GfxBase	; save the GFX base address in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save the address of the system copperlist
					
	move.l	#MyCopperList,$dff080	; COP1LC - point to my copper list
	move.w	d0,$dff088		; COPJMP1 - Start our copperlist

Loop1:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	bne.s	Loop1

	btst	#2,$dff016	; only move the bar when right mouse is clicked
	bne.s	Loop2

	bsr.s	MoveBar

Loop2:
	cmpi.b	#$ff,$dff006	; frame sync again
	beq.s	Loop2

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	Loop1		; if not, back to mouse:

	; Put system cop back and quit
	move.l	OldCop(PC),$dff080	; We target the system cop
	move.w	d0,$dff088	; let's start the cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to close
				; (libraries must be opened and closed !!!)
	jsr	-$19e(a6)	; Closelibrary - close the graphics lib
	rts

MoveBar:
	LEA	BAR,a0 	;Load address of BAR label then work with offsets

	; Should we be adding or subtracting?
	TST.B 	VertDirectionFlag
	beq.w	BarGoDown

	jmp	BarGoUp

BarGoDown:
	addq.b	#1,(a0)	; Add 1 to the Y for the green line
	addq.b	#1,8(a0)	; Add 1 to the Y for setting to black
	addq.b	#1,16(a0)

	cmpi.b	#$ff,8(a0)	; If we reached bottom, need to go up
	beq.s	SetVertFlagUp

	jmp	MoveColour

	rts

BarGoUp
	subq.b	#1,(a0)	; Add 1 to the Y for the green line
	subq.b	#1,8(a0)	; Add 1 to the Y for setting to black
	subq.b	#1,16(a0)

	cmpi.b	#$2c,8(a0) ; if we are at the top, go down
	beq.s 	SetVertFlagDown

	jmp	MoveColour

	rts

MoveColour:

	;LEA	BAR,a0 	;Already loaded into a0

	; Should we be adding or subtracting?
	TST.B 	HorizDirectionFlag
	beq.w	ColourGoRight

	jmp	ColourGoLeft
	rts

ColourGoRight:

	addq.b	#2,9(a0)	; Add 1 to the X for the green line

	cmpi.b	#$e1,9(a0)	;if we reached the end of the line, go left
	beq.s 	SetHorizFlagLeft

	rts

ColourGoLeft:
	subq.b	#2,9(a0)	; Subtract 1 to the X for the green line

	cmpi.b	#$07,9(a0)
	beq.s 	SetHorizFlagRight
	
	rts

SetVertFlagUp
	move.b	#$ff,VertDirectionFlag
	rts

SetVertFlagDown
	clr.b	VertDirectionFlag
	rts

SetHorizFlagLeft
	move.b	#$ff,HorizDirectionFlag
	rts

SetHorizFlagRight
	clr.b	HorizDirectionFlag
	rts

VertDirectionFlag:
	dc.b	0,0

HorizDirectionFlag:
	dc.b 	0,0

GfxName:
	dc.b	"graphics.library",0,0	;Name of library to load

GfxBase:		; Base address for the graphics.library
	dc.l	0	; 

OldCop:			; Address of the old system COP
	dc.l	0

	;Copperlist must be in chipmem
	SECTION MyCopper,CODE_C

MyCopperList:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, only background.
	dc.w	$180,$000	; COLOR0 - start with black

BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79 then draw green line
	dc.w	$180
	dc.w	$0F0

	dc.w	$7981,$FFFE ; WAIT - wait for part way along the green line
	dc.w	$180,$F00		; and set background to red

	dc.w	$7A07,$FFFE ; Wait for line after the green/red line, ($7A on very fist run, then code increments)
	dc.w	$180,$000	; and go back to black background

	dc.w	$FFFF,$FFFE	; END OF COPPERLIST

	end