����                                        
; Corso Asm - LEZIONE xx:  ** MODULARE IN AMPIEZZA UN'ARMONICA IN STEREO**

	SECTION	LEZIONExx7a2,CODE

Start:

	lea	modvol1,a0
	moveq	#0,d0
	moveq	#65-1,d7
.Lp1:	move.w	d0,(a0)+
	addq.w	#1,d0
	dbra	d7,.lp1
	subq.w	#1,d0
.Lp2:	move.w	d0,(a0)+
	dbra	d0,.lp2

	lea	modvol2,a0
	moveq	#65,d0
	moveq	#65-1,d7
.Lp3:	subq.w	#1,d0
	move.w	d0,(a0)+
	dbra	d7,.lp3
	moveq	#65-1,d7
.Lp4:	move.w	d0,(a0)+
	addq.w	#1,d0
	dbra	d7,.lp4

_LVODisable	EQU	-120
_LVOEnable	EQU	-126

	move.l	4.w,a6
	jsr	_LVODisable(a6)

	bset	#1,$bfe001		;spegne il filtro passa-basso

	lea	$dff000,a6
	move.w	$2(a6),d7		;salva DMA dell'OS
	move.w	$10(a6),d6		;salva ADKCON dell'OS

Clock	equ	3546895

	move.l	#armonica,$b0(a6)
	move.w	#16/2,$b4(a6)
	move.w	#clock/(16*440),$b6(a6)	;LA2
	move.l	#armonica,$d0(a6)
	move.w	#16/2,$d4(a6)
	move.w	#clock/(16*440),$d6(a6)	;LA2

	move.l	#modvol1,$a0(a6)
	move.w	#(modvol1_end-modvol1)/2,$a4(a6)
	move.w	#clock/((modvol1_end-modvol1)/2),$a6(a6)
	move.l	#modvol2,$c0(a6)
	move.w	#(modvol2_end-modvol2)/2,$c4(a6)
	move.w	#clock/((modvol2_end-modvol2)/2),$c6(a6)

	move.w	#$8005,$9e(a6)		;imposta USE0V1 e USE2V3

	move.w	#$820f,$96(a6)		;accende AUD0-AUD3 in DMACONW

WLMB:	btst	#6,$bfe001		;aspetta il pulsante sinistro del mouse
	bne.s	WLMB

	move.w	#$0005,$9e(a6)		;spegne USE0V1 e USE2V3
	or.w	#$8000,d6		;accende il bit 15 (SET/CLR)
	move.w	d6,$9e(a6)		;reimposta ADKCON dell'OS
	move.w	#$000f,$96(a6)		;spegne AUD0-AUD3
	or.w	#$8000,d7		;accende il bit 15 (SET/CLR)
	move.w	d7,$96(a6)		;reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	_LVOEnable(a6)
	rts

	SECTION	Sample,DATA_C	;venendo letta dal DMA deve essere in CHIP

Armonica:	;armonica di 16 valori creata col'IC del trash'm-one
	DC.B	$19,$46,$69,$7C,$7D,$6A,$47,$1A,$E8,$BB,$97,$84,$83,$95,$B8,$E5
ModVol1:
	blk.w	65*2
ModVol1_end:
ModVol2:
	blk.w	65*2
ModVol2_end:
	END


Questa volta abbiamo creato 2 tabelle "sfasate": la prima, letta dal canale 0,
modula in volume il canale 1 da 0 a 64, e da 64 a 0; la seconda, letta dal
canale 2, modula ugualmente in ampiezza il canale 3 da 64 a 0, e da 0 a 64.
Ci� provoca un effetto di apparente "decentramento" dell'uscita del suono
in un'impianto STEREO.
Qui la lettura delle tabelle avviene alla frequenza di "mezzo" Hz, in quanto
viene letta met� tabella ad 1 Hz.

N.B.:	se avete un'impianto MONO, dovreste sentire una nota continua senza
	alcuna modulazione, in quanto al calare del volume di una cassa
	l'altra si alza e ne compensa l'output.
