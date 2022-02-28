playArpeggio:
	call	setArpFlags
	ld	a,b
	ld	(artn1),a
	ld	a,c
	ld	(artn2),a
	ld	a,d
	ld	(artn3),a
	ld	a,e
	ld	(ardt),a
	ld	a,$01
	ld	(ardtt),a
	jp	updatearp

endArpeggio:
	ld	a,(arf)
	cp	$20
	ret	c		; Check if an arpeggio actually is playing
	ld	b,a
	ld	a,SYNTH_INSTR_A
	bit	5,b
	call	nz,endTone
	ld	a,SYNTH_INSTR_B
	bit	6,b
	call	nz,endTone
	ld	a,SYNTH_INSTR_C
	bit	7,b
	call	nz,endTone
	bit	4,b
	jp	z,arresetdone
	ld	a,SYNTH_INSTR_B
	bit	5,b
	call	nz,endTone
	ld	a,SYNTH_INSTR_C
	bit	6,b
	call	nz,endTone
	ld	a,SYNTH_INSTR_A
	bit	7,b
	call	nz,endTone
arresetdone:
	xor	a
	ld	(arf),a
	ret


;
; Check if instrument is used by an Arpeggio
;
; a = reg (A=0, B=1, C=2)
; sets CF if true
;
checkarpeggio:
	push	af
	cp	SYNTH_INSTR_A
	jr	z,carpA
	cp	SYNTH_INSTR_B
	jr	z,carpB
	ld	a,(arf)
	bit	7,a
	jr	nz,carpfail
	and	$F0
	cp	$50
	jr	z,carpfail
	jp	carpdone
carpA:
	ld	a,(arf)
	bit	5,a
	jr	nz,carpfail
	and	$F0
	cp	$90
	jr	z,carpfail
	jp	carpdone
carpB:
	ld	a,(arf)
	bit	6,a
	jr	nz,carpfail
	and	$F0
	cp	$30
	jr	z,carpfail
carpdone
	pop	af
	or	a
	ret
carpfail:
	pop	af
	or	a
	ccf
	ret


;
; Updates the Arpeggio
;
; This only maintains the Arpeggio for it's duration
; Arpeggios are initiated
;
; Call arpgover before initiating any arpeggio!
;
updatearp:
	ld	a,(arf)
	cp	$20
	ret	c		; Check if an arpeggio actually is playing
	ld	a,(ardtt)
	dec	a
	ld	(ardtt),a	; count dt
	ret	nz		; No update yet
	ld	a,(ardt)
	ld	(ardtt),a	; reset dt
	ld	a,(arf)		; continue update tune
	and	$07
	cp	$03
	jr	c,arfirstloop
	sub	$03
arfirstloop:
	ld	c,a
	ld	b,$00
	ld	hl,artn1
	add	hl,bc
	ld	e,(hl)		; e = relevant tone
	ld	a,(arf)		; find register
	bit	4,a
	jr	z,arponech
	bit	0,a
	jr	z,arponech
	bit	5,a
	jr	nz,archb
	bit	6,a
	jr	nz,archc
	jp	archa
arponech:
	bit	5,a
	jr	nz,archa
	bit	6,a
	jr	nz,archb
archc:
	ld	b,SYNTH_INSTR_C
	jp	arpchwr
archb:
	ld	b,SYNTH_INSTR_B
	jp	arpchwr
archa:
	ld	b,SYNTH_INSTR_A
arpchwr:			; b = instrument
	inc	a		; increase state counter
	ld	c,a
	and	$07
	cp	$06
	ld	a,c
	jp	c,arnolooped
	and	$F8		; Reset state counter if it's gone full circle
arnolooped:
	ld	(arf),a
	ld	a,b		; Update tune
	ld	b,e
	jp	playTone
	


;
; Sets arpeggio flags
;
; a = reg (0=A, 1=B, 2=C, 4=AB, 5=BC, 6=CA)
;
setArpFlags:
	push	hl
	ld	hl,arf
	ld	(hl),$00
	bit	2,a
	jr	z,pasingle
	set	4,(hl)
pasingle:
	and	$03
	or	a
	jr	z,paA
	dec	a
	jr	z,paB
	set	7,(hl)
	jp	pastedone
paA:
	set	5,(hl)
	jp	pastedone
paB:
	set	6,(hl)

pastedone:
	pop	hl
	ret

artn1:	db	$00	; Tone 1
artn2:	db	$00	; Tone 2
artn3:	db	$00	; Tone 3
ardtt:	db	$00	; dt t
ardt:	db	$00	; dt
arf:	db	$00	; 7 Using C/CA
			; 6 Using B/BC
			; 5 Using A/AB
			; 4 1/2 channel
			; 
			; 2 Ar stage 2
			; 1 Ar stage 1 
			; 0 Ar stage 0