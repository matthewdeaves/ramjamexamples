����                                        
; Corso Asm - LEZIONE xx:  * MODULARE IN AMPIEZZA ED IN FREQUENZA UN'ARMONICA *

	SECTION	LEZIONExx7b,CODE

Start:

	lea	modvolfq,a0
	moveq	#0,d0
	moveq	#123,d1
	move.w	#64-1,d7
.Lp1:	move.w	d0,(a0)+
	addq.w	#1,d0
	move.w	d1,(a0)+
	addq.w	#4,d1
	dbra	d7,.lp1
	move.w	#64-1,d7
.Lp2:	move.w	d0,(a0)+
	subq.w	#1,d0
	move.w	d1,(a0)+
	subq.w	#4,d1
	dbra	d7,.lp2

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

	move.l	#modvolfq,$a0(a6)
	move.w	#(modvolfq_end-modvolfq)/2,$a4(a6)
	move.w	#clock/((modvolfq_end-modvolfq)/2),$a6(a6)

	move.w	#$8011,$9e(a6)		;imposta USE0V1 e USE0P1

	move.w	#$8203,$96(a6)		;accende AUD0 e AUD1 in DMACONW

WLMB:	btst	#6,$bfe001		;aspetta il pulsante sinistro del mouse
	bne.s	WLMB

	move.w	#$0011,$96(a6)		;spegne USE0V1 e USE0P1
	or.w	#$8000,d6		;accende il bit 15 (SET/CLR)
	move.w	d6,$9e(a6)		;reimposta ADKCON dell'OS
	move.w	#$0003,$96(a6)		;spegne AUD0 e AUD1
	or.w	#$8000,d7		;accende il bit 15 (SET/CLR)
	move.w	d7,$96(a6)		;reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	_LVOEnable(a6)
	rts

	SECTION	Sample,DATA_C	;venendo letta dal DMA deve essere in CHIP

Armonica:	;armonica di 16 valori creata col'IC del trash'm-one
	DC.B	$19,$46,$69,$7C,$7D,$6A,$47,$1A,$E8,$BB,$97,$84,$83,$95,$B8,$E5
ModVolFq:
	blk.w	64*2*2
ModVolFq_end:
	END

Ecco come modulare sia in ampiezza che in frequenza un suono: la tabella
consiste di 2 valori alternati, prima una word con il volume a 7 bit per
AUD1VOL e poi una seconda word con il periodo a 16 bit per AUD0PER; con la
mesedima succesione i dati entrano anche in AUD0DAT: prima il volume, poi
il periodo.
Naturalemente, sono stati impostati sia il bit di modulazione di frequenza che
di ampiezza del canale 0 nei confronti del canale 1.
