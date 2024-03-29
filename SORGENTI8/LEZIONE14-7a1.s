����                                        
; Corso Asm - LEZIONE xx:  ** MODULARE IN AMPIEZZA UN'ARMONICA **

	SECTION	LEZIONExx1,CODE

Start:

	lea	modvol,a0
	moveq	#0,d0
	moveq	#65-1,d7
.Lp1:	move.w	d0,(a0)+
	addq.w	#1,d0
	dbra	d7,.lp1
	subq.w	#1,d0
.Lp2:	move.w	d0,(a0)+
	dbra	d0,.lp2

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
	move.w	#clock/(16*880),$b6(a6)

	move.l	#modvol,$a0(a6)
	move.w	#(modvol_end-modvol)/2,$a4(a6)
	move.w	#clock/(modvol_end-modvol),$a6(a6)

	move.w	#$8001,$9e(a6)		;imposta USE0V1

	move.w	#$8203,$96(a6)		;accende AUD0 e AUD1 in DMACONW

WLMB:	btst	#6,$bfe001		;aspetta il pulsante sinistro del mouse
	bne.s	WLMB

	move.w	#$0001,$96(a6)		;spegne USE0V1
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
ModVol:
	blk.w	65*2
ModVol_end:
	END


Molto semplicemente, abbiamo innanzitutto generato una tabella di 130 valori
da 0 a 64 e da 64 a 0 per i volumi dell'AUD1VOL, che abbiamo fatto leggere al
canale 0, mentre il canale 1 leggeva l'armonica alla frequenza del LA3 (880 Hz
di frequenza d'onda).
Come periodo del canale modulatore abbiamo fatto finta che stesse leggendo un
normale sample e gli abbiamo fornito la velocit� di lettura: perch� la tabella
venga tutta letta in 1 secondo il periodo di campionamento deve essere pari
alla costante di clock divisa per la lunghezza in byte della tabella = 1 Hz.

N.B.:	notate che non � stato impostato il volume del canale 0 (AUD0VOL),
	poich� non � neccessario, in quanto il suo output non viene
	deamplificato (64 = -0 dB) e finisce direttamente nel registro AUD1VOL.
	Nemmeno AUD1VOL � stato impostato all'inizio, poich� viene subito
	modificato dal modulatore.
