
	section	bau,code_c

START:
	move.l	d0,rd0
	move.l	d1,rd1
	move.l	d2,rd2
	move.l	d3,rd3
	move.l	d4,rd4
	move.l	d5,rd5
	move.l	d6,rd6
	move.l	d7,rd7
	move.l	a0,ra0
	move.l	a1,ra1
	move.l	a2,ra2
	move.l	a3,ra3
	move.l	a4,ra4
	move.l	a5,ra5
	move.l	a6,ra6
	move.l	a7,ra7


	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	MOVE.L	$4.W,A6			; Exec pointer to A6
	LEA.L	GfxName(PC),A1		; Set library pointer
	MOVEQ	#0,D0
	JSR	OldOpenLibrary(A6)	; Open graphics.library
	MOVE.L	D0,A1			; Use Base-pointer
	MOVE.L	$26(A1),OLDCOP1		; Store copper1 start addr
	MOVE.L	$32(A1),OLDCOP2		; Store copper1 start addr
	JSR	CloseLibrary(A6)	; Close graphics library
	LEA	$DFF000,A6
	MOVE.W	$1C(A6),INTENA		; Store old INTENA
	MOVE.W	$2(A6),DMACON		; Store old DMACON
	MOVE.W	$10(A6),ADKCON		; Store old ADKCON
	MOVE.W	#$7FFF,$9A(A6)		; Clear interrupt enable
	BSR.w	Wait_Vert_Blank
	MOVE.W	#$7FFF,$96(A6)		; Clear DMA channels
	MOVE.W	#DMASET!$8200,$96(A6)	; DMA kontrol data
	MOVE.L	#NULLCOP,$80(A6)	; Copper1 start address
	move.w	d0,$88(a6)
	move.w	#0,$1fc(a6)

	MOVE.L	$6C.W,OldInter		; Store old inter pointer
	MOVE.L	#INTER,$6C.W		; Set interrupt pointer
	MOVE.W	#$7FFF,$9C(A6)		; Clear request
	MOVE.W	#$C020,$9A(A6)		; Interrupt enable

	BSR	LEGGI_PUNTI
	BSR	SETSCREEN
	BSR	LOADSPRITES
	BSR	SETHSPR

	BSR	SETDSCREENS

;	BSR	LOADSCREEN
;	BSR	SWAPVIDEO

	MOVE.L	#TEXTCOP,A0
	BSR	COPPER_INIT
	

LOOP:	ADD.W	#1,GOINOUT
	CMP.W	#701,GOINOUT	
	BNE.S	NOBACKSTEP
	MOVE.W	#1,VADERETRO
NOBACKSTEP
	BSR	COOL_2D
	BTST	#6,$BFE001
	BEQ.W	EXIT_INTRO
	CMP.W	#1,FHERE
	BNE.S	LOOP

FTY
;	BSR	CLEARSAREA
;	BSR	CLEARTAREA
	bsr	waitof
	MOVE.L	#TEXTCOP2,A0
	BSR	COPPER_INIT


EXIT_INTRO
;	JSR	PR_END
	LEA	$DFF000,A6
	MOVE.W	#$7FFF,$9A(A6)		; Disable interrupts
	BSR.W	Wait_Vert_Blank
	MOVE.W	#$7FFF,$96(A6)
	MOVE.L	OldCop1(PC),$80(A6)	; Restore old copper1
	MOVE.L	OldCop2(PC),$84(A6)	; Restore old copper1
	MOVE.L	OldInter(PC),$6C.W	; Restore inter pointer
	MOVE.W	DMACON,D0		; Restore old DMACON
	OR.W	#$8000,D0
	MOVE.W	D0,$96(A6)		
	MOVE.W	ADKCON,D0		; Restore old ADKCON
	OR.W	#$8000,D0
	MOVE.W	D0,$9E(A6)
	MOVE.W	INTENA,D0		; Restore inter data
	OR.W	#$C000,D0
	MOVE.W	#$7FFF,$9C(A6)
	MOVE.W	D0,$9A(A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	move.l	rd0,d0
	move.l	rd1,d1
	move.l	rd2,d2
	move.l	rd3,d3
	move.l	rd4,d4
	move.l	rd5,d5
	move.l	rd6,d6
	move.l	rd7,d7
	move.l	ra0,a0
	move.l	ra1,a1
	move.l	ra2,a2
	move.l	ra3,a3
	move.l	ra4,a4
	move.l	ra5,a5
	move.l	ra6,a6
	move.l	ra7,a7
	RTS

Wait_Vert_Blank:
	LEA	$DFF000,A6
	BTST	#0,$5(A6)
	BEQ.S	Wait_Vert_Blank
.loop	BTST	#0,$5(A6)
	BNE.S	.loop
	RTS


WAITOF:	move.l	$dff004,d2		;Wait the start of the vertirq
	and.l	#$0001ff00,d2		;and the start of the video scan
	cmp.l	#$0000Ff00,d2
	bne	WAITOF
	rts

rd0	dc.l	0
rd1	dc.l	0
rd2	dc.l	0
rd3	dc.l	0
rd4	dc.l	0
rd5	dc.l	0
rd6	dc.l	0
rd7	dc.l	0
ra0	dc.l	0
ra1	dc.l	0
ra2	dc.l	0
ra3	dc.l	0
ra4	dc.l	0
ra5	dc.l	0
ra6	dc.l	0
ra7	dc.l	0

OldOpenLibrary	= -408
CloseLibrary	= -414

DMASET=	%1000010111100000
;	 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA (if this isn't set, sprites disappear!)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

GfxName		DC.B	'graphics.library',0
		even
DosBase		DC.L	0
OldInter	DC.L	0
OldCop1		DC.L	0
OldCop2		DC.L	0
INTENA		DC.W	0
DMACON		DC.W	0
ADKCON		DC.W	0

GOINOUT		DC.W	0

INTER	MOVEM.L	D0-D7/A0-A6,-(A7)

	LEA.L	$DFF000,A6

	MOVE.W	#$4020,$9C(A6)		; Clear interrupt request
;	JSR	PR_MUSIC

	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTE
	

************************ COPPER HANDLER PROCEDURE *************************

copper_init:
	lea	$dff000,a6
	move.l	a0,$080(a6)		; a0=start copper
	clr.w	$088(a6)
	rts

copper_reset:
	lea	$dff000,a5
	move.l	$4,a6
	move.l	$9c(a6),a6
	move.l	$26(a6),$80(a5)
	clr.w	$88(a5)
	rts


************************** LOAD SCREEN'S PROCEDURE ***********************
CLEARTAREA:
	LEA.L	TEXTAREA1,A0
	LEA.L	TEXTAREA2,A1
	LEA.L	TEXTAREA3,A2
	MOVEQ.L	#0,D0
	MOVE.W	#3559,D1
CTAREA_LOOP
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A2)+
	DBRA	D1,CTAREA_LOOP
	RTS

CLEARSAREA:
	LEA.L	SCREEN1,A0
	LEA.L	SCREEN2,A1
	LEA.L	SCREEN3,A2
	LEA.L	SCREEN4,A3
	LEA.L	SCREEN5,A4
	LEA.L	SCREEN6,A5
	MOVEQ.L	#0,D0
	MOVE.W	#3559,D1
CSAREA_LOOP
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A2)+
	MOVE.L	D0,(A3)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A5)+
	DBRA	D1,CSAREA_LOOP
	RTS

LOADBITMAP:
	DIVU.W	#8,D1
	MULU.W	D2,D1
	SUB.W	#1,D3
LOADBITMAP_LOOP
	MOVE.W	D0,2(A0)
	SWAP	D0
	ADD.L	#4,A0
	MOVE.W	D0,2(A0)
	SWAP	D0
	ADD.L	#4,A0
	ADD.L	D1,D0
	DBRA	D3,LOADBITMAP_LOOP
	RTS

LOADSPRITES:
	RTS


LOADSPRITESBASE
	MOVE.W	D0,SP0L
	MOVE.W	D1,SP1L
	MOVE.W	D2,SP2L
	MOVE.W	D3,SP3L
	MOVE.W	D4,SP4L
	MOVE.W	D5,SP5L
	MOVE.W	D6,SP6L
	MOVE.W	D7,SP7L
	MOVE.W	D0,SP0L2
	MOVE.W	D1,SP1L2
	MOVE.W	D2,SP2L2
	MOVE.W	D3,SP3L2
	MOVE.W	D4,SP4L2
	MOVE.W	D5,SP5L2
	MOVE.W	D6,SP6L2
	MOVE.W	D7,SP7L2
	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVE.W	D0,SP0H
	MOVE.W	D1,SP1H
	MOVE.W	D2,SP2H
	MOVE.W	D3,SP3H
	MOVE.W	D4,SP4H
	MOVE.W	D5,SP5H
	MOVE.W	D6,SP6H
	MOVE.W	D7,SP7H
	MOVE.W	D0,SP0H2
	MOVE.W	D1,SP1H2
	MOVE.W	D2,SP2H2
	MOVE.W	D3,SP3H2
	MOVE.W	D4,SP4H2
	MOVE.W	D5,SP5H2
	MOVE.W	D6,SP6H2
	MOVE.W	D7,SP7H2
	RTS

SETHSPR:
	RTS


MOVEHSPR
	MOVE.W	TIMETOSTAY,D0
	ADD.W	#1,D0
	MOVE.W	D0,TIMETOSTAY
	CMP.W	#600,D0
	BLE.S	NORST
	MOVE.W	#0,TIMETOSTAY
	TST.W	TIMETOGO
	BEQ.S	CHANGE1
	MOVE.W	#0,TIMETOGO
	BRA	NORST
CHANGE1
	MOVE.W	#1,TIMETOGO
NORST
	MOVE.W	TIMETOSTAY,D0
	LSL.W	#1,D0
	RTS


TIMETOSTAY
	DC.W	0
TIMETOGO
	DC.W	0



endflag:
	dc.w	$0

************************** 2D RITARDATO (MENTALE) ***************************
*					  *
*  by M.A.S.E. of RAM JAM in JANUARY 1993 *
*******************************************

VADERETRO	DC.W	0
ZOOMF	DC.W	200
ROTFATT	DC.W	-4
XYROT	DC.W	0
XYROT1	DC.W	0
DIRFLAG	DC.W	0
FHERE	DC.W	0

COOL_2D:
	BSR	SWAPSCREENS
	BSR	SETSCREEN
	BSR	WAITOF
;	MOVE.W	#$000F,$DFF180
	BSR	CLEARWPLANE
	BSR	ROTATE
	BSR	DRAW_FG
	BSR	FILL_FG
	RTS

SETSCREEN:
	MOVE.L	WSCRPTR1,D0
	MOVE.L	WSCRPTR2,D1
	MOVE.L	WSCRPTR3,D2
	MOVE.L	WSCRPTR4,D3
	MOVE.L	WSCRPTR5,D4
	ADD.W	#4,D0
	ADD.W	#4,D1
	ADD.W	#4,D2
	ADD.W	#4,D3
	ADD.W	#4,D4
	MOVE.L	#PLANES,A0
	MOVE.W	D0,2(A0)
	SWAP	D0
	MOVE.W	D0,6(A0)
	MOVE.W	D1,10(A0)
	SWAP	D1
	MOVE.W	D1,14(A0)
	MOVE.W	D2,18(A0)
	SWAP	D2
	MOVE.W	D2,22(A0)
	MOVE.W	D3,26(A0)
	SWAP	D3
	MOVE.W	D3,30(A0)
	MOVE.W	D4,34(A0)
	SWAP	D4
	MOVE.W	D4,38(A0)
	RTS

SWAPSCREENS:
	MOVE.W	WSCRFLAG,D0
	ADD.W	#1,D0

	CMP.W	#1,D0
	BNE.S	SWAP2
	MOVE.L	#SCREEN3,WSCRPTR1
	MOVE.L	#SCREEN2,WSCRPTR2
	MOVE.L	#SCREEN4,WSCRPTR3
	MOVE.L	#SCREEN5,WSCRPTR4
	MOVE.L	#SCREEN6,WSCRPTR5
	MOVE.L	#SCREEN1,SCRPTR
	MOVE.W	D0,WSCRFLAG

SWAP2:
	CMP.W	#2,D0
	BNE.S	SWAP3
	MOVE.L	#SCREEN2,WSCRPTR1
	MOVE.L	#SCREEN4,WSCRPTR2
	MOVE.L	#SCREEN5,WSCRPTR3
	MOVE.L	#SCREEN6,WSCRPTR4
	MOVE.L	#SCREEN1,WSCRPTR5
	MOVE.L	#SCREEN3,SCRPTR
	MOVE.W	D0,WSCRFLAG

SWAP3	CMP.W	#3,D0
	BNE.S	SWAP4
	MOVE.L	#SCREEN4,WSCRPTR1
	MOVE.L	#SCREEN5,WSCRPTR2
	MOVE.L	#SCREEN6,WSCRPTR3
	MOVE.L	#SCREEN1,WSCRPTR4
	MOVE.L	#SCREEN3,WSCRPTR5
	MOVE.L	#SCREEN2,SCRPTR
	MOVE.W	D0,WSCRFLAG

SWAP4	CMP.W	#4,D0
	BNE.S	SWAP5
	MOVE.L	#SCREEN5,WSCRPTR1
	MOVE.L	#SCREEN6,WSCRPTR2
	MOVE.L	#SCREEN1,WSCRPTR3
	MOVE.L	#SCREEN3,WSCRPTR4
	MOVE.L	#SCREEN2,WSCRPTR5

	MOVE.L	#SCREEN4,SCRPTR
	MOVE.W	D0,WSCRFLAG

SWAP5	CMP.W	#5,D0
	BNE.S	SWAP6
	MOVE.L	#SCREEN6,WSCRPTR1
	MOVE.L	#SCREEN1,WSCRPTR2
	MOVE.L	#SCREEN3,WSCRPTR3
	MOVE.L	#SCREEN2,WSCRPTR4
	MOVE.L	#SCREEN4,WSCRPTR5
	MOVE.L	#SCREEN5,SCRPTR
	MOVE.W	D0,WSCRFLAG

SWAP6	CMP.W	#6,D0
	BNE.S	SEX
	MOVE.L	#SCREEN1,WSCRPTR1
	MOVE.L	#SCREEN3,WSCRPTR2
	MOVE.L	#SCREEN2,WSCRPTR3
	MOVE.L	#SCREEN4,WSCRPTR4
	MOVE.L	#SCREEN5,WSCRPTR5
	MOVE.L	#SCREEN6,SCRPTR
	MOVE.W	#0,WSCRFLAG

SEX	RTS

LEGGI_PUNTI:
	LEA	XY_COORD2,A0
	LEA	X_COORD1,A1
	LEA	Y_COORD1,A2
	MOVE.W	N_XYCOORD,D0
	SUBQ.W	#1,D0
LEGGI_PUNTI_LOOP:
	MOVE.W	(A0)+,(A1)+
	MOVE.W	(A0)+,(A2)+
	DBRA	D0,LEGGI_PUNTI_LOOP

	LEA	LINKL_COORD2,A0
	LEA	S_LINEE,A1
	LEA	E_LINEE,A2
	MOVE.W	N_LINKL,D0
	SUBQ.W	#1,D0
LEGGI_LINK_LOOP:
	MOVE.W	(A0)+,(A1)+
	MOVE.W	(A0)+,(A2)+
	DBRA	D0,LEGGI_LINK_LOOP
	RTS

ROTATE:
	LEA.L	SXY,A0
	MOVEQ	#0,D0
	MOVE.W	XYROT1,D0
	CMP.W	#0,DIRFLAG
	BNE.S	GOBACK
	ADD.W	#60,D0
	CMP.W	#15000,D0
	BLE	AGOBACK
	MOVE.W	#1,DIRFLAG
	BRA	AGOBACK
GOBACK	SUB.W	#60,D0
	CMP.W	#-15000,D0
	BGE	AGOBACK
	MOVE.W	#0,DIRFLAG
AGOBACK:

XYROTOK
	MOVE.W	D0,XYROT1
	DIVS.W	#1000,D0
	MOVE.W	D0,XYROT


	MOVE.W	ROTFATT,D3
	ADD.W	XYROT,D3
	AND.W	#$01FF,D3
	MOVE.W	D3,ROTFATT
	ADD.W	D3,D3

	CMP.W	#1,VADERETRO
	BNE.S	ALL_IS_SO_NORMAL
	MOVE.W	ZOOMF(PC),D0
	CMP.W	#100,D0
	BLE.W	NON_ME_LI_FAR_GIRARE
	SUB.W	#15,D0
	BRA	ZOOMK
ALL_IS_SO_NORMAL
	MOVE.W	ZOOMF(PC),D0
	ADD.W	#10,D0
	CMP.W	#2700,D0	; 3750
	BLS	ZOOMK
	MOVE.W	#2700,D0	; 3750
ZOOMK
	MOVE.W	D0,(A0)
	MOVE.W	D0,2(A0)
	MOVE.W	D0,ZOOMF

	LEA	X_COORD1,A1
	LEA	Y_COORD1,A2
	LEA	X_COORDF,A3
	LEA	Y_COORDF,A4
	LEA	SENO,A5
	LEA	COSENO,A6
	ADD.W	D3,A5
	ADD.W	D3,A6
	MOVE.W	(A5),D0	; sen(w)
	MOVE.W	(A6),D1	; cos(w)
	MOVEQ	#$C,D3

	MOVE.W	N_XYCOORD,D2
	SUBQ.W	#1,D2
ROT_LOOP:
	MOVE.W	(A1)+,D4	; x
	MOVE.W	(A2)+,D5	; y

	MOVE.W	D4,D6
	MULS	D1,D6	; x*cos(w)
	ASR.L	D3,D6
	MOVE.W	D5,D7
	MULS	D0,D7	; y*sen(w)
	ASR.L	D3,D7

	SUB.W	D7,D6	; x*cos(w) + y*sen(w)
	MULS	(A0),d6
	ASR.L	D3,d6
	MOVE.W	D6,(A3)+
	NEG.W	D6
	MOVE.W	D6,$16(A3)


	MOVE.W	D4,D6
	NEG.W	D6
	MULS	D0,D6	; x*sen(w)
	ASR.L	D3,D6

	MOVE.W	D5,D7
	MULS	D1,D7	; y*cos(w)
	ASR.L	D3,D7

	SUB.W	D6,D7	; x*sen(w) + y*cos(w)
	MULS	2(A0),d7
	ASR.L	D3,d7
	MOVE.W	D7,(A4)+	
	NEG.W	D7
	MOVE.W	D7,$16(A4)

	DBRA	D2,ROT_LOOP
	BRA	NOTFHERE
NON_ME_LI_FAR_GIRARE
	MOVE.W	#1,FHERE
NOTFHERE
	RTS	

DRAW_FG:
	LEA.L	$DFF000,A6
	MOVE.L	#-1,$44(A6)
	MOVE.W	#$8000,$74(A6)
	MOVE.W	#40,$60(A6)
	MOVE.W	#$FFFF,$72(A6)

	LEA	MXY,A0
	LEA	X_COORDF,A1
	LEA	Y_COORDF,A2
	LEA	S_LINEE,A3
	LEA	E_LINEE,A4
	MOVE.W	N_LINKL,D6
	SUBQ	#1,D6

DO_LOOP:
	MOVE.W	2(A0),D1
	MOVE.W	2(A0),D3

	MOVE.W	(A3)+,D7
	LSL.W	#1,D7
	MOVE.W	(A1,D7.W),D0
	SUB.W	(A2,D7.W),D1
	
	MOVE.W	(A4)+,D7
	LSL.W	#1,D7
	MOVE.W	(A1,D7.W),D2
	SUB.W	(A2,D7.W),D3

	ADD.W	(A0),D0
	ADD.W	(A0),D2

	cmp.w	d3,d1
	beq	NOL
	cmp.w	d3,d1
	blt	NOSWAP
	EXG	d1,d3
	EXG	d0,d2
NOSWAP:	ADDQ	#1,d1

	move.l	SCRPTR,a5
	bsr.b	drawline

NOL	DBRA	D6,DO_LOOP
	RTS

;********************************
;*          DRAW LINE           *
;*            v2.0              *
;*                              *
;*  coder: EXECUTOR             *
;*  date: xx/04/1991            *
;********************************

;Input:
;	d0.w	[x1]
;	d1.w	[y1]
;	d2.w	[x2]
;	d3.w	[y2]
;Output:
;	d0	[Trashed]
;	d1	[Trashed]
;	d2	[Trashed]
;	d3	[Trashed]
;	a0	[Trashed]


DRAWLINE:

SINGLE = 2		; 2 = SINGLE BIT WIDTH

.WAIT:	BTST	#$E,$2(A6)
	BNE.S	.WAIT
	SUB.W	D3,D1
	MULU	#40,D3		; ScreenWidth * D3
	MOVEQ	#$F,D4
	AND.W	D2,D4		; Get lowest bits from D2

;--------- SELECT OCTANT ---------

	SUB.W	D2,D0
	BLT.S	DRAW_DONT0146
	TST.W	D1
	BLT.S	DRAW_DONT04

	CMP.W	D0,D1
	BGE.S	DRAW_SELECT0
	MOVEQ	#$11+SINGLE,D7		; Select Oct 4
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT0:
	MOVEQ	#1+SINGLE,D7		; Select Oct 0
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED

DRAW_DONT04:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT1
	MOVEQ	#$19+SINGLE,D7		; Select Oct 6
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT1:
	MOVEQ	#5+SINGLE,D7		; Select Oct 1
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED


DRAW_DONT0146:
	NEG.W	D0
	TST.W	D1
	BLT.S	DRAW_DONT25
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT2
	MOVEQ	#$15+SINGLE,D7		; Select Oct 5
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT2:
	MOVEQ	#9+SINGLE,D7		; Select Oct 2
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED
DRAW_DONT25:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT3
	MOVEQ	#$1D+SINGLE,D7		; Select Oct 7
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT3:
	MOVEQ	#$D+SINGLE,D7		; Select Oct 3
	EXG	D0,D1

;---------   CALCULATE START   ---------

DRAW_OCTSELECTED:
	ADD.W	D1,D1			; 2*dy
	ASR.W	#3,D2			; x=x/8
	EXT.L	D2
	ADD.L	D2,D3			; d3 = x+y*40 = screen pos
	MOVE.W	D1,D2			; d2 = 2*dy
	SUB.W	D0,D2			; d2 = 2*dy-dx
	BGE.S	DRAW_DONTSETSIGN
	ORI.W	#$40,D7			; dx < 2*dy
DRAW_DONTSETSIGN:

;---------   SET BLITTER   ---------

	MOVE.W	D2,$52(A6)		; 2*dy-dx
	MOVE.W	D1,$62(A6)		; 2*d2
	SUB.W	D0,D2			; d2 = 2*dy-dx-dx
	MOVE.W	D2,$64(A6)		; 2*dy-2*dx

;---------   MAKE LENGTH   ---------

	ASL.W	#6,D0			; d0 = 64*dx
	ADD.W	#$0042,D0		; d0 = 64*(dx+1)+2

;---------   MAKE CONTROL 0+1   ---------

	ROR.W	#4,D4
	ORI.W	#$B4A,D4		; $B4A - DMA + Minterm
	SWAP	D7
	MOVE.W	D4,D7
	SWAP	D7
	ADD.L	A5,D3		; SCREEN PTR

	MOVE.L	D7,$40(A6)		; BLTCON0 + BLTCON1
	MOVE.L	D3,$48(A6)		; Source C
	MOVE.L	D3,$54(A6)		; Destination D
	MOVE.W	D0,$58(A6)		; Size
	RTS

* /-------------------/ *


FILL_FG	LEA	$DFF000,A6
	MOVE.L	SCRPTR,A1
	ADD.W	#40*277-2,A1
FFG1	BTST.B	#6,$02(A6)
	BNE.S	FFG1
	MOVE.W	#0,$60(A6)
	MOVE.W	#0,$64(A6)
	MOVE.L	#$FFFFFFFF,$44(A6)
	MOVE.W	#$09F0,$40(A6)
	MOVE.W	#$0012,$42(A6)	;	$12=EXCLUSIVE \ $A=INCLUSIVE
	MOVE.L	A1,$50(a6)
	MOVE.L	A1,$54(a6)
	MOVE.W	#277*64+20,$58(a6)
	RTS

CLEARWPLANE
	BTST.B	#14,$02(A6)
	BNE.S	CLEARWPLANE
        MOVE.L  SCRPTR,A0
;        ADD.W	#10,A0
        MOVE.W	#0,$60(A6)
        MOVE.W	#0,$64(A6)
        MOVE.L	#$01000000,$dff040
	MOVE.L	A0,$dff054
	MOVE.W	#277*64+20,$dff058
        RTS

SETDSCREENS:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.L	#TEXTAREA1,D0
	MOVE.L	#TEXTAREA2,D1
	MOVE.L	#TEXTAREA3,D2
	LEA.L	PLANES1,A0

	MOVE.W	D0,10(A0)
	SWAP	D0
	MOVE.W	D0,14(A0)

	MOVE.W	D1,26(A0)
	SWAP	D1
	MOVE.W	D1,30(A0)

	MOVE.W	D2,42(A0)
	SWAP	D2
	MOVE.W	D2,46(A0)
	RTS


RT_AUXBUF
	DS.W	6


* /-------------------/ *

* VARIABILI *

AX	DC.W	0
AY	DC.W	0
AZ	DC.W	0

;TRASFORMAZIONE IN RAD DELL'ANGOLO DI ROTAZIONE
R1X	DC.W 	16
R1Y	DC.W 	8
R1Z	DC.W 	4

MX	DC.W	30
MY	DC.W	30

ZOOM	DC.W	30000

N_SPRF	DC.W	6
N_SPRF2	DC.W	0

N_XYZCOORD	DC.W	8

	;-------------------------------
X_coord:
	dc.w	-90,90,90,-90
	dc.w	-90,-90,90,90
Y_coord:
	dc.w	-90,-90,90,90
	dc.w	-90,90,90,-90	
Z_coord:
	dc.w	90,90,90,90
	dc.w	-90,-90,-90,-90

SPRFC	dc.w	3,	4,1,4,4,3,3,2,2,1
	dc.w	2,	4,2,3,3,7,7,8,8,2
	dc.w	3,	4,8,7,7,6,6,5,5,8
	dc.w	2,	4,5,6,6,4,4,1,1,5
	dc.w	1,	4,5,1,1,2,2,8,8,5
	dc.w	1,	4,4,6,6,7,7,3,3,4


	;-------------------------------


SPRFC2	DS.W	1000	; Successivamente: tutte le superfici da tracciare


X_COORD2	DS.W	100
Y_COORD2	DS.W	100
Z_COORD2	DS.W	100

X_SCR	DS.W	100
Y_SCR	DS.W	100

VIDFLAG	DC.W	0

VIDPTR	DC.L	SCREEN
VIDPTR2	DC.L	FBUFFER


COSENO	DC.W	$1000,$1000,$0FFF,$0FFD,$0FFB,$0FF8
	DC.W	$0FF5,$0FF1,$0FEC,$0FE7,$0FE1,$0FDB
	DC.W	$0FD4,$0FCC,$0FC4,$0FBB,$0FB1,$0FA7
	DC.W	$0F9C,$0F91,$0F85,$0F79,$0F6C,$0F5E
	DC.W	$0F50,$0F41,$0F31,$0F21,$0F11,$0EFF
	DC.W	$0EEE,$0EDB,$0EC8,$0EB5,$0EA1,$0E8C
	DC.W	$0E77,$0E61,$0E4B,$0E34,$0E1C,$0E04
	DC.W	$0DEC,$0DD3,$0DB9,$0D9F,$0D85,$0D69
	DC.W	$0D4E,$0D32,$0D15,$0CF8,$0CDA,$0CBC
	DC.W	$0C9D,$0C7E,$0C5E,$0C3E,$0C1E,$0BFC
	DC.W	$0BDB,$0BB9,$0B97,$0B74,$0B50,$0B2D
	DC.W	$0B08,$0AE4,$0ABF,$0A99,$0A73,$0A4D
	DC.W	$0A26,$09FF,$09D8,$09B0,$0988,$095F
	DC.W	$0937,$090D,$08E4,$08BA,$088F,$0865
	DC.W	$083A,$080E,$07E3,$07B7,$078B,$075E
	DC.W	$0732,$0705,$06D7,$06AA,$067C,$064E
	DC.W	$061F,$05F1,$05C2,$0593,$0564,$0534
	DC.W	$0505,$04D5,$04A5,$0475,$0444,$0414
	DC.W	$03E3,$03B2,$0381,$0350,$031F,$02EE
	DC.W	$02BC,$028B,$0259,$0227,$01F5,$01C3
	DC.W	$0191,$015F,$012D,$00FB,$00C9,$0097
	DC.W	$0065,$0032,$0000,$FFCF,$FF9C,$FF6A
	DC.W	$FF38,$FF06,$FED4,$FEA2,$FE70,$FE3E
	DC.W	$FE0C,$FDDA,$FDA8,$FD76,$FD45,$FD13
	DC.W	$FCE2,$FCB1,$FC80,$FC4F,$FC1E,$FBED
	DC.W	$FBBD,$FB8C,$FB5C,$FB2C,$FAFC,$FACD
	DC.W	$FA9D,$FA6E,$FA3F,$FA10,$F9E2,$F9B3
	DC.W	$F985,$F957,$F92A,$F8FC,$F8CF,$F8A3
	DC.W	$F876,$F84A,$F81E,$F7F2,$F7C7,$F79C
	DC.W	$F772,$F747,$F71D,$F6F4,$F6CA,$F6A2
	DC.W	$F679,$F651,$F629,$F602,$F5DB,$F5B4
	DC.W	$F58E,$F568,$F542,$F51D,$F4F9,$F4D4
	DC.W	$F4B1,$F48D,$F46A,$F448,$F426,$F405
	DC.W	$F3E3,$F3C3,$F3A3,$F383,$F364,$F345
	DC.W	$F327,$F309,$F2EC,$F2CF,$F2B3,$F298
	DC.W	$F27C,$F262,$F248,$F22E,$F215,$F1FD
	DC.W	$F1E5,$F1CD,$F1B6,$F1A0,$F18A,$F175
	DC.W	$F160,$F14C,$F139,$F126,$F113,$F102
	DC.W	$F0F0,$F0E0,$F0D0,$F0C0,$F0B1,$F0A3
	DC.W	$F095,$F088,$F07C,$F070,$F065,$F05A
	DC.W	$F050,$F046,$F03D,$F035,$F02D,$F026
	DC.W	$F020,$F01A,$F015,$F010,$F00C,$F009
	DC.W	$F006,$F004,$F002,$F001,$F001,$F001
	DC.W	$F002,$F004,$F006,$F009,$F00C,$F010
	DC.W	$F015,$F01A,$F020,$F026,$F02D,$F035
	DC.W	$F03D,$F046,$F050,$F05A,$F065,$F070
	DC.W	$F07C,$F088,$F095,$F0A3,$F0B1,$F0C0
	DC.W	$F0D0,$F0E0,$F0F0,$F102,$F113,$F126
	DC.W	$F139,$F14C,$F160,$F175,$F18A,$F1A0
	DC.W	$F1B6,$F1CD,$F1E5,$F1FD,$F215,$F22E
	DC.W	$F248,$F262,$F27D,$F298,$F2B3,$F2D0
	DC.W	$F2EC,$F309,$F327,$F345,$F364,$F383
	DC.W	$F3A3,$F3C3,$F3E4,$F405,$F426,$F448
	DC.W	$F46B,$F48D,$F4B1,$F4D4,$F4F9,$F51D
	DC.W	$F542,$F568,$F58E,$F5B4,$F5DB,$F602
	DC.W	$F629,$F651,$F679,$F6A2,$F6CB,$F6F4
	DC.W	$F71D,$F747,$F772,$F79C,$F7C7,$F7F3
	DC.W	$F81E,$F84A,$F876,$F8A3,$F8CF,$F8FC
	DC.W	$F92A,$F957,$F985,$F9B3,$F9E2,$FA10
	DC.W	$FA3F,$FA6E,$FA9D,$FACD,$FAFC,$FB2C
	DC.W	$FB5C,$FB8C,$FBBD,$FBED,$FC1E,$FC4F
	DC.W	$FC80,$FCB1,$FCE2,$FD13,$FD45,$FD76
	DC.W	$FDA8,$FDDA,$FE0C,$FE3E,$FE70,$FEA2
	DC.W	$FED4,$FF06,$FF38,$FF6A,$FF9D,$FFCF
	DC.W	$0000,$0032,$0065,$0097,$00C9,$00FB
	DC.W	$012D,$015F,$0192,$01C4,$01F5,$0227
	DC.W	$0259,$028B,$02BC,$02EE,$031F,$0350
	DC.W	$0382,$03B2,$03E3,$0414,$0445,$0475
	DC.W	$04A5,$04D5,$0505,$0535,$0564,$0593
	DC.W	$05C2,$05F1,$0620,$064E,$067C,$06AA
	DC.W	$06D7,$0705,$0732,$075E,$078B,$07B7
	DC.W	$07E3,$080F,$083A,$0865,$088F,$08BA
	DC.W	$08E4,$090D,$0937,$095F,$0988,$09B0
	DC.W	$09D8,$09FF,$0A27,$0A4D,$0A73,$0A99
	DC.W	$0ABF,$0AE4,$0B08,$0B2D,$0B50,$0B74
	DC.W	$0B97,$0BB9,$0BDB,$0BFD,$0C1E,$0C3E
	DC.W	$0C5E,$0C7E,$0C9D,$0CBC,$0CDA,$0CF8
	DC.W	$0D15,$0D32,$0D4E,$0D69,$0D85,$0D9F
	DC.W	$0DB9,$0DD3,$0DEC,$0E04,$0E1C,$0E34
	DC.W	$0E4B,$0E61,$0E77,$0E8C,$0EA1,$0EB5
	DC.W	$0EC8,$0EDB,$0EEE,$0EFF,$0F11,$0F21
	DC.W	$0F31,$0F41,$0F50,$0F5E,$0F6C,$0F79
	DC.W	$0F85,$0F91,$0F9C,$0FA7,$0FB1,$0FBB
	DC.W	$0FC4,$0FCC,$0FD4,$0FDB,$0FE1,$0FE7
	DC.W	$0FEC,$0FF1,$0FF5,$0FF8,$0FFB,$0FFD
	DC.W	$0FFF,$1000,$0000,$0000,$0000,$0000

SENO:
	DC.W	$0000,$0032,$0065,$0097,$00C9,$00FB
	DC.W	$012D,$015F,$0192,$01C4,$01F5,$0227
	DC.W	$0259,$028B,$02BC,$02EE,$031F,$0350
	DC.W	$0382,$03B2,$03E3,$0414,$0445,$0475
	DC.W	$04A5,$04D5,$0505,$0535,$0564,$0593
	DC.W	$05C2,$05F1,$0620,$064E,$067C,$06AA
	DC.W	$06D7,$0705,$0732,$075E,$078B,$07B7
	DC.W	$07E3,$080F,$083A,$0865,$088F,$08BA
	DC.W	$08E4,$090D,$0937,$095F,$0988,$09B0
	DC.W	$09D8,$09FF,$0A27,$0A4D,$0A73,$0A99
	DC.W	$0ABF,$0AE4,$0B08,$0B2D,$0B50,$0B74
	DC.W	$0B97,$0BB9,$0BDB,$0BFD,$0C1E,$0C3E
	DC.W	$0C5E,$0C7E,$0C9D,$0CBC,$0CDA,$0CF8
	DC.W	$0D15,$0D32,$0D4E,$0D69,$0D85,$0D9F
	DC.W	$0DB9,$0DD3,$0DEC,$0E04,$0E1C,$0E34
	DC.W	$0E4B,$0E61,$0E77,$0E8C,$0EA1,$0EB5
	DC.W	$0EC8,$0EDB,$0EEE,$0EFF,$0F11,$0F21
	DC.W	$0F31,$0F41,$0F50,$0F5E,$0F6C,$0F79
	DC.W	$0F85,$0F91,$0F9C,$0FA7,$0FB1,$0FBB
	DC.W	$0FC4,$0FCC,$0FD4,$0FDB,$0FE1,$0FE7
	DC.W	$0FEC,$0FF1,$0FF5,$0FF8,$0FFB,$0FFD
	DC.W	$0FFF,$1000,$1000,$1000,$0FFF,$0FFD
	DC.W	$0FFB,$0FF8,$0FF5,$0FF1,$0FEC,$0FE7
	DC.W	$0FE1,$0FDB,$0FD4,$0FCC,$0FC4,$0FBB
	DC.W	$0FB1,$0FA7,$0F9C,$0F91,$0F85,$0F79
	DC.W	$0F6C,$0F5E,$0F50,$0F41,$0F31,$0F21
	DC.W	$0F11,$0EFF,$0EEE,$0EDB,$0EC8,$0EB5
	DC.W	$0EA1,$0E8C,$0E77,$0E61,$0E4B,$0E34
	DC.W	$0E1C,$0E04,$0DEC,$0DD3,$0DB9,$0D9F
	DC.W	$0D85,$0D69,$0D4E,$0D32,$0D15,$0CF8
	DC.W	$0CDA,$0CBC,$0C9D,$0C7E,$0C5E,$0C3E
	DC.W	$0C1E,$0BFC,$0BDB,$0BB9,$0B97,$0B74
	DC.W	$0B50,$0B2D,$0B08,$0AE4,$0ABF,$0A99
	DC.W	$0A73,$0A4D,$0A26,$09FF,$09D8,$09B0
	DC.W	$0988,$095F,$0937,$090D,$08E4,$08BA
	DC.W	$088F,$0865,$083A,$080E,$07E3,$07B7
	DC.W	$078B,$075E,$0732,$0705,$06D7,$06AA
	DC.W	$067C,$064E,$061F,$05F1,$05C2,$0593
	DC.W	$0564,$0534,$0505,$04D5,$04A5,$0475
	DC.W	$0444,$0414,$03E3,$03B2,$0381,$0350
	DC.W	$031F,$02EE,$02BC,$028B,$0259,$0227
	DC.W	$01F5,$01C3,$0191,$015F,$012D,$00FB
	DC.W	$00C9,$0097,$0065,$0032,$0000,$FFCF
	DC.W	$FF9C,$FF6A,$FF38,$FF06,$FED4,$FEA2
	DC.W	$FE70,$FE3E,$FE0C,$FDDA,$FDA8,$FD76
	DC.W	$FD45,$FD13,$FCE2,$FCB1,$FC80,$FC4F
	DC.W	$FC1E,$FBED,$FBBD,$FB8C,$FB5C,$FB2C
	DC.W	$FAFC,$FACD,$FA9D,$FA6E,$FA3F,$FA10
	DC.W	$F9E2,$F9B3,$F985,$F957,$F92A,$F8FC
	DC.W	$F8CF,$F8A3,$F876,$F84A,$F81E,$F7F2
	DC.W	$F7C7,$F79C,$F772,$F747,$F71D,$F6F4
	DC.W	$F6CA,$F6A2,$F679,$F651,$F629,$F602
	DC.W	$F5DB,$F5B4,$F58E,$F568,$F542,$F51D
	DC.W	$F4F9,$F4D4,$F4B1,$F48D,$F46A,$F448
	DC.W	$F426,$F405,$F3E3,$F3C3,$F3A3,$F383
	DC.W	$F364,$F345,$F327,$F309,$F2EC,$F2CF
	DC.W	$F2B3,$F298,$F27C,$F262,$F248,$F22E
	DC.W	$F215,$F1FD,$F1E5,$F1CD,$F1B6,$F1A0
	DC.W	$F18A,$F175,$F160,$F14C,$F139,$F126
	DC.W	$F113,$F102,$F0F0,$F0E0,$F0D0,$F0C0
	DC.W	$F0B1,$F0A3,$F095,$F088,$F07C,$F070
	DC.W	$F065,$F05A,$F050,$F046,$F03D,$F035
	DC.W	$F02D,$F026,$F020,$F01A,$F015,$F010
	DC.W	$F00C,$F009,$F006,$F004,$F002,$F001
	DC.W	$F001,$F001,$F002,$F004,$F006,$F009
	DC.W	$F00C,$F010,$F015,$F01A,$F020,$F026
	DC.W	$F02D,$F035,$F03D,$F046,$F050,$F05A
	DC.W	$F065,$F070,$F07C,$F088,$F095,$F0A3
	DC.W	$F0B1,$F0C0,$F0D0,$F0E0,$F0F0,$F102
	DC.W	$F113,$F126,$F139,$F14C,$F160,$F175
	DC.W	$F18A,$F1A0,$F1B6,$F1CD,$F1E5,$F1FD
	DC.W	$F215,$F22E,$F248,$F262,$F27D,$F298
	DC.W	$F2B3,$F2D0,$F2EC,$F309,$F327,$F345
	DC.W	$F364,$F383,$F3A3,$F3C3,$F3E4,$F405
	DC.W	$F426,$F448,$F46B,$F48D,$F4B1,$F4D4
	DC.W	$F4F9,$F51D,$F542,$F568,$F58E,$F5B4
	DC.W	$F5DB,$F602,$F629,$F651,$F679,$F6A2
	DC.W	$F6CB,$F6F4,$F71D,$F747,$F772,$F79C
	DC.W	$F7C7,$F7F3,$F81E,$F84A,$F876,$F8A3
	DC.W	$F8CF,$F8FC,$F92A,$F957,$F985,$F9B3
	DC.W	$F9E2,$FA10,$FA3F,$FA6E,$FA9D,$FACD
	DC.W	$FAFC,$FB2C,$FB5C,$FB8C,$FBBD,$FBED
	DC.W	$FC1E,$FC4F,$FC80,$FCB1,$FCE2,$FD13
	DC.W	$FD45,$FD76,$FDA8,$FDDA,$FE0C,$FE3E
	DC.W	$FE70,$FEA2,$FED4,$FF06,$FF38,$FF6A
	DC.W	$FF9D,$FFCF,$0000,$0000,$0000,$0000


* /-------------------/ *

* VARIABILI *

SXY	DC.W	700,700
MXY	DC.W	160,139		;mx,my

SCRFLAG		DC.W	0
WSCRFLAG	DC.W	0

WSCRPTR1	DC.L	SCREEN1
WSCRPTR2	DC.L	SCREEN2
WSCRPTR3	DC.L	SCREEN3
WSCRPTR4	DC.L	SCREEN4
WSCRPTR5	DC.L	SCREEN5

SCRPTR	DC.L	SCREEN1
SCRPTR2	DC.L	SCREEN1



N_XYCOORD	DC.W	12
N_LINKL		DC.W	24

XY_COORD:	DC.W	-140,140,140,140
		DC.W	-120,120,120,120
		DC.W	-100,100,100,100
		DC.W	-80,80,80,80
		DC.W	-60,60,60,60
		DC.W	-40,40,40,40
		DC.W	-20,20,20,20
		DC.W	-10,10,10,10
		DS.W	24

XY_COORD2:	DC.W	-100,0,	-30,30,	0,100,	30,30
		DC.W	-100,-100,-140,0,-100,100,0,140
		DC.W	-170,-170,-170,0,-170,170,0,170
		DS.W	24

XY_COORD3:	DC.W	-100,0,	-30,30,	0,100,	30,30
		DC.W	-100,-100,-140,0,-100,100,0,140
		DC.W	-130,-130,-130,0,-130,130,0,130
		DS.W	24


LINKL_COORD:	DC.W	0,1,	1,12,	12,13,	13,0
		DC.W	2,3,	3,14,	14,15,	15,2
		DC.W	4,5,	5,16,	16,17,	17,4
		DC.W	6,7,	7,18,	18,19,	19,6
		DC.W	8,9,	9,20,	20,21,	21,8
		DC.W	10,11,	11,22,	22,23,	23,10

LINKL_COORD2:	DC.W	0,1,	1,2,	2,3,	3,12
		DC.W	12,13,	13,14,	14,15,	15,0
		DC.W	4,5,	5,6,	6,7,	7,16
		DC.W	16,17,	17,18,	18,19,	19,4
		DC.W	8,9,	9,10,	10,11,	11,20
		DC.W	20,21,	21,22,	22,23,	23,8


X_COORD1	DS.W	60
Y_COORD1	DS.W	60

X_COORDF	DS.W	60
Y_COORDF	DS.W	60

S_LINEE		DS.W	60
E_LINEE		DS.W	60

NULLCOP
	DC.W	$0100,$0200,$0102,$0000,$0104,$0000
	DC.W	$0108,$0000,$010A,$0000
	DC.W	$0180,$0000
	DC.L	$FFFFFFFE

TEXTCOP2
	DC.W	$0100,$6600,$0102,$0000,$0104,$0064
	DC.W	$0108,$0000,$010A,$0000
	DC.W	$008E,$2071,$0090,$35d1
	DC.W	$0092,$0038,$0094,$00D0
PLANES1	DC.W	$00E2,$0000,$00E0,$0000,$00E6,$0000,$00E4,$0000
	DC.W	$00EA,$0000,$00E8,$0000,$00EE,$0000,$00EC,$0000
	DC.W	$00F2,$0000,$00F0,$0000,$00F6,$0000,$00F4,$0000
        DC.W    $0120
SP0H2	DC.W    $0000
        DC.W    $0122
SP0L2	DC.W    $0000
        DC.W    $0124
SP1H2	DC.W    $0000
        DC.W    $0126
SP1L2	DC.W    $0000
        DC.W    $0128
SP2H2	DC.W    $0000
        DC.W    $012A
SP2L2	DC.W    $0000
        DC.W    $012C
SP3H2	DC.W    $0000
        DC.W    $012E
SP3L2	DC.W    $0000
        DC.W    $0130
SP4H2	DC.W    $0000
        DC.W    $0132
SP4L2	DC.W    $0000
        DC.W    $0134
SP5H2	DC.W    $0000
        DC.W    $0136
SP5L2	DC.W    $0000
        DC.W    $0138
SP6H2	DC.W    $0000
        DC.W    $013A
SP6L2	DC.W    $0000
        DC.W    $013C
SP7H2	DC.W    $0000
        DC.W    $013E
SP7L2	DC.W    $0000

	; 2D VECTOR COLORS
COLS2
	DC.W	$0180,$0300,$0182,$0002
	DC.W	$0184,$0014,$0186,$0026
	DC.W	$0188,$0148,$018A,$036A
	DC.W	$018C,$058C,$018E,$07AE
	DC.W	$0190,$0000,$0192,$0111
	DC.W	$0194,$0322,$0196,$0544
	DC.W	$0198,$0766,$019A,$0988
	DC.W	$019C,$0BAA,$019E,$0CCC
	dc.w	$01A0,$0000
	dc.w	$01A2,$0080
	dc.w	$01A4,$0432
	dc.w	$01A6,$0653
	dc.w	$01A8,$0875
	dc.w	$01AA,$0A87
	dc.w	$01AC,$0CB9
	dc.w	$01AE,$0EDC
	dc.w	$01B0,$0F60
	dc.w	$01B2,$0FA8
	dc.w	$01B4,$0FE0
	dc.w	$01B6,$0080
	dc.w	$01B8,$00D0
	dc.w	$01BA,$00CC
	dc.w	$01BC,$006F
	dc.w	$01BE,$0005

	DC.W	$5701,$FFFE
	DC.W	$0180,$0FFF,$0182,$0FFF
	DC.W	$0184,$0FFF,$0186,$0FFF
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF
	DC.W	$0190,$0FFF,$0192,$0FFF
	DC.W	$0194,$0FFF,$0196,$0FFF
	DC.W	$0198,$0FFF,$019A,$0FFF
	DC.W	$019C,$0FFF,$019E,$0FFF

	DC.W	$5801,$FFFE
PLANES2	DC.W	$00E2,$0000,$00E0,$0000
	DC.W	$00EA,$0000,$00E8,$0000
	DC.W	$00F2,$0000,$00F0,$0000,$0180
cols1	DC.W	$0000,$0182,$0888
	DC.W	$0184,$0AAA,$0186,$0CCC
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF
	DC.W	$0190,$0000,$0192,$0D88
	DC.W	$0194,$0A55,$0196,$0722
	DC.W	$0198,$0000,$019A,$0000
	DC.W	$019C,$0000,$019E,$0000

	DC.W	$9201,$FFFE
PLANES3	DC.W	$00E2,$0000,$00E0,$0000
	DC.W	$00EA,$0000,$00E8,$0000
	DC.W	$00F2,$0000,$00F0,$0000
	DC.W	$0180,$0000,$0182,$0080
	DC.W	$0184,$00A0,$0186,$00C0
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF

	DC.W	$CC01,$FFFE
PLANES4	DC.W	$00E2,$0000,$00E0,$0000
	DC.W	$00EA,$0000,$00E8,$0000
	DC.W	$00F2,$0000,$00F0,$0000
	DC.W	$0180,$0000,$0182,$0888
	DC.W	$0184,$0AAA,$0186,$0CCC
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF


	DC.W	$FFE1,$FFFE,$0001,$FFFE
	DC.W	$0180,$0FFF,$0182,$0FFF
	DC.W	$0184,$0FFF,$0186,$0FFF
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF
	DC.W	$0190,$0FFF,$0192,$0FFF
	DC.W	$0194,$0FFF,$0196,$0FFF
	DC.W	$0198,$0FFF,$019A,$0FFF
	DC.W	$019C,$0FFF,$019E,$0FFF

	DC.W	$0101,$FFFE
PLANES5	DC.W	$00E2,$0000,$00E0,$0000
	DC.W	$00EA,$0000,$00E8,$0000
	DC.W	$00F2,$0000,$00F0,$0000
	DC.W	$0180,$0300,$0182,$0002
	DC.W	$0184,$0014,$0186,$0026
	DC.W	$0188,$0148,$018A,$036A
	DC.W	$018C,$058C,$018E,$07AE
	DC.W	$0190,$0000,$0192,$0111
	DC.W	$0194,$0322,$0196,$0544
	DC.W	$0198,$0766,$019A,$0988
	DC.W	$019C,$0BAA,$019E,$0CCC
	DC.L	$FFFFFFFE

TEXTCOP	DC.W	$0100,$4200,$0102,$0000,$0104,$0024
	DC.W	$0108,$0000,$010A,$0000
	DC.W	$008E,$2071,$0090,$35d1
	DC.W	$0092,$0038,$0094,$00D0
PLANES:	DC.W	$00E2,$0000,$00E0,$0000,$00E6,$0000,$00E4,$0000
	DC.W	$00EA,$0000,$00E8,$0000,$00EE,$0000,$00EC,$0000
	DC.W	$00F2,$0000,$00F0,$0000,$00F6,$0000,$00F4,$0000

        DC.W    $0120
SP0H    DC.W    $0000
        DC.W    $0122
SP0L    DC.W    $0000
        DC.W    $0124
SP1H    DC.W    $0000
        DC.W    $0126
SP1L    DC.W    $0000
        DC.W    $0128
SP2H    DC.W    $0000
        DC.W    $012A
SP2L    DC.W    $0000
        DC.W    $012C
SP3H    DC.W    $0000
        DC.W    $012E
SP3L    DC.W    $0000
        DC.W    $0130
SP4H    DC.W    $0000
        DC.W    $0132
SP4L    DC.W    $0000
        DC.W    $0134
SP5H    DC.W    $0000
        DC.W    $0136
SP5L    DC.W    $0000
        DC.W    $0138
SP6H    DC.W    $0000
        DC.W    $013A
SP6L    DC.W    $0000
        DC.W    $013C
SP7H    DC.W    $0000
        DC.W    $013E
SP7L    DC.W    $0000

	; 2D VECTOR COLORS
COLS
	DC.W	$0180,$0300,$0182,$0002
	DC.W	$0184,$0014,$0186,$0026
	DC.W	$0188,$0148,$018A,$036A
	DC.W	$018C,$058C,$018E,$07AE
	DC.W	$0190,$0000,$0192,$0111
	DC.W	$0194,$0322,$0196,$0544
	DC.W	$0198,$0766,$019A,$0988
	DC.W	$019C,$0BAA,$019E,$0CCC
	dc.w	$01A0,$0000
	dc.w	$01A2,$0080
	dc.w	$01A4,$0432
	dc.w	$01A6,$0653
	dc.w	$01A8,$0875
	dc.w	$01AA,$0A87
	dc.w	$01AC,$0CB9
	dc.w	$01AE,$0EDC
	dc.w	$01B0,$0F60
	dc.w	$01B2,$0FA8
	dc.w	$01B4,$0FE0
	dc.w	$01B6,$0080
	dc.w	$01B8,$00D0
	dc.w	$01BA,$00CC
	dc.w	$01BC,$006F
	dc.w	$01BE,$0005

	DC.W	$5701,$FFFE
	DC.W	$0180,$0FFF,$0182,$0FFF
	DC.W	$0184,$0FFF,$0186,$0FFF
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF
	DC.W	$0190,$0FFF,$0192,$0FFF
	DC.W	$0194,$0FFF,$0196,$0FFF
	DC.W	$0198,$0FFF,$019A,$0FFF
	DC.W	$019C,$0FFF,$019E,$0FFF

	DC.W	$5801,$FFFE
	DC.W	$0180,$0000,$0182,$0002
	DC.W	$0184,$0114,$0186,$0226
	DC.W	$0188,$0448,$018A,$066A
	DC.W	$018C,$088C,$018E,$0AAE
	DC.W	$0190,$0200,$0192,$0411
	DC.W	$0194,$0622,$0196,$0844
	DC.W	$0198,$0A66,$019A,$0C88
	DC.W	$019C,$0EAA,$019E,$0FCC


	DC.W	$FFE1,$FFFE,$0001,$FFFE
	DC.W	$0180,$0FFF,$0182,$0FFF
	DC.W	$0184,$0FFF,$0186,$0FFF
	DC.W	$0188,$0FFF,$018A,$0FFF
	DC.W	$018C,$0FFF,$018E,$0FFF
	DC.W	$0190,$0FFF,$0192,$0FFF
	DC.W	$0194,$0FFF,$0196,$0FFF
	DC.W	$0198,$0FFF,$019A,$0FFF
	DC.W	$019C,$0FFF,$019E,$0FFF

	DC.W	$0101,$FFFE
	DC.W	$0180,$0300,$0182,$0002
	DC.W	$0184,$0014,$0186,$0026
	DC.W	$0188,$0148,$018A,$036A
	DC.W	$018C,$058C,$018E,$07AE
	DC.W	$0190,$0000,$0192,$0111
	DC.W	$0194,$0322,$0196,$0544
	DC.W	$0198,$0766,$019A,$0988
	DC.W	$019C,$0BAA,$019E,$0CCC
	DC.L	$FFFFFFFE


SCREEN	BLK.B	40*60*3
FBUFFER BLK.B	40*60*3


TEXTAREA1	BLK.B	40*356
TEXTAREA2	BLK.B	40*356
TEXTAREA3	BLK.B	40*356

	BLK.B	40*100
SCREEN1	BLK.B	40*256
	BLK.B	40*100
SCREEN2	BLK.B	40*256
	BLK.B	40*100
SCREEN3	BLK.B	40*256
	BLK.B	40*100
SCREEN4 BLK.B	40*256
	BLK.B	40*100
SCREEN5 BLK.B	40*256
	BLK.B	40*100
SCREEN6 BLK.B	40*256
	BLK.B	40*100

Z:
