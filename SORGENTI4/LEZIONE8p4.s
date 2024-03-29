
; Lezione8p4.s	Funzionamento dei Condition Codes con le istruzioni
;		logiche AND, NOT, OR, EOR

	SECTION	CiriCop,CODE

Inizio:
	not.w	dato1
	not.w	dato2
	move.w	#$ff00,d0
	and.w	dato1,d0
	move.w	#$0003,d0
	and.w	dato2,d0
	move.w	#$8000,d0
	or.w	dato1,d0
	move.w	#$8000,d0
	eor.w	d0,dato3
stop:
	rts

dato1:
	dc.w	$ff00
dato2:
	dc.w	$0f00
dato3:
	dc.w	$c000

	end

;	.----------.
;	�   \||/   �
;	�   (oo)   �
;	`-oO-\/-Oo-'

Le istruzioni logiche modificano i CC allo modo analogo alle istruzioni MOVE
e TST, ovvero:

I flag V e C vengono azzerati
Il flag X non viene modificato
Il flag Z assume il valore 1 se il risultato dell'operazione e` 0
Il flag N assume il valore 1 se il risultato dell'operazione e` negativo.

Lo verifichiamo eseguendo PASSO PASSO il nostro programma, nel quale
presentiamo diversi esempi.

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14 
SSP=07CA304B USP=07CA1F14 SR=0000 -- -- PL=0 ----- PC=07CA4AF4
PC=07CA4AF4 467907CA4B2A	 NOT.W   $07CA4B2A
>

La prima istruzione da eseguire e` una NOT. Il numero $7CA4B2A e` l'indirizzo
"dato1" (naturalmente a voi risultera' un'altra locazione!).

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14 
SSP=07CA3047 USP=07CA1F14 SR=8000 T1 -- PL=0 ----- PC=07CA4AFA
PC=07CA4AFA 467907CA4B2C	NOT.W   $07CA4B2C
>

Il risultato dell'operazione lo possiamo vedere con il comando "M.W DATO1" ,
ed e` $00ff. (nota: il comando "m" puo' essere anche "m.w" o "m.l" per mostrare
una word o una longword alla volta).
Si ratta di un numero positivo diverso da zero, pertanto i flag Z e N sono
azzerati. Eseguiamo ora la seconda NOT:

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8008 T1 -- PL=0 -N--- PC=07CA4B00
PC=07CA4B00 303CFF00		 MOVE.W  #$FF00,D0
>

Questa volta il risultato e` negativo (andate a guardare all'indirizzo DATO2)
e infatti il flag N risulta settato. Ora carichiamo un valore in D0.

D0: 0000FF00 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8000 T1 -- PL=0 ----- PC=07CA4B04
PC=07CA4B04 C07907CA4B2A	 AND.W   $07CA4B2A,D0
>

E facciamo l'AND con il valore "DATO1"

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8004 T1 -- PL=0 --Z-- PC=07CA4B0A
PC=07CA4B0A 303C0003		 MOVE.W  #$0003,D0
>

Il risultato e` zero, e pertanto il flag Z assume il valore 1.
Ora carichiamo un nuovo valore in D0 e facciamo l' AND con DATO2.

D0: 00000003 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8000 T1 -- PL=0 ----- PC=07CA4B0E
PC=07CA4B0E C07907CA4B2C	 AND.W   $07CA4B2C,D0
>

Questa volta otteniamo un risultato positivo, diverso da zero.
Ora passiamo all'OR. Prima carichiamo un valore negativo in D0.

D0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8000 T1 -- PL=0 ----- PC=07CA4B14
PC=07CA4B14 303C8000             MOVE.W  #$8000,D0
>

E poi effettuiamo l'OR con "DATO1"

D0: 00008000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8008 T1 -- PL=0 -N--- PC=07CA4B18
PC=07CA4B18 807907CA4B2A	 OR.W    $07CA4B2A,D0
>

Come vedete otteniamo un valore che e` ancora negativo, perche` il bit
piu` significativo ha ancora il valore 1.

D0: 000080FF 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8008 T1 -- PL=0 -N--- PC=07CA4B1E
PC=07CA4B1E 303C8000		 MOVE.W  #$8000,D0
>

Ora un'ultima prova. Carichiamo ancora $8000 in D0:

D0: 00008000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8008 T1 -- PL=0 -N--- PC=07CA4B22
PC=07CA4B22 B17907CA4B2E	 EOR.W   D0,$07CA4B2E

E facciamo l'EOR con "DATO3":

D0: 00008000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
A0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 07CA1F14
SSP=07CA3047 USP=07CA1F14 SR=8000 T1 -- PL=0 ----- PC=07CA4B28
PC=07CA4B28 4E75		 RTS
>

Questa volta otteniamo un risultato positivo e diverso da zero, come potete
verificare voi stessi.

