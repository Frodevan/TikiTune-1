SYNTH_INST_TUNE		equ	$00
SYNTH_INST_VOLUME	equ	$0C
SYNTH_INST_ATTACK	equ	$18
SYNTH_INST_HOLD		equ	$1F
SYNTH_INST_DECAY	equ	$19
SYNTH_INST_RELEASE	equ	$1A
SYNTH_INST_LEVELS	equ	$1B
SYNTH_INST_HWTUNE	equ	$1C
SYNTH_INST_FLAGS	equ	$1E
SYNTH_INST_HWFOLLOW	equ	$20

setInstrument:
	call	checkarpeggio
	jp	nc,sinoarp
	call	endArpeggio
sinoarp:
	push	ix
	call	pointtodata
	ld	e,a
	xor	a
	set	6,(ix+SYNTH_INST_FLAGS)
	cp	b
	jr	z,sitone
	res	6,(ix+SYNTH_INST_FLAGS)
sitone:
	res	5,(ix+SYNTH_INST_FLAGS)
	cp	c
	jr	z,sinonoise
	set	5,(ix+SYNTH_INST_FLAGS)
sinonoise:
	set	7,(ix+SYNTH_INST_FLAGS)
	cp	d
	jr	z,siswe
	res	7,(ix+SYNTH_INST_FLAGS)
siswe:
	ld	a,e
	call	resetInstrument
	pop	ix
	ret

setEnvelope:
	push	ix
	call	pointtodata
	bit	7,(ix+SYNTH_INST_FLAGS)
	call	z,setHwE
	call	nz,setSwE
	pop	ix
	ret

;
; Updates an instrument
;
; Tune-sweep is updated
; SwE is updated, and the following is handled:
;	Attack end / Decay start
;	Decay end / Sustain start
;	Release end / Instrument reset
;
;	Attack start, Sustain end / Release start
;	and HwE is handled by Note on/off events
;	
; AY chip is updated if there is any changes.
;
; a = reg (A=0, B=1, C=2)
;
updateinst:
	push	ix
	call	pointtodata
	call	updinst
	pop	ix
	ret

updinst:
	push	ix
	pop	hl
	ld	d,a
	call	advancegradient			; Update Tune-Sweep
	jr	c,notchange
	sla	a				; Set AY Ch Tune
	ld	b,$02				; We will be outputing to AY 
	ld	c,(ix+SYNTH_INST_TUNE)
	call	AYdrv
	inc	a
	ld	c,(ix+SYNTH_INST_TUNE+1)
	call	AYdrv
notchange:
	ld	a,(ix+SYNTH_INST_FLAGS)		; Update SwE
	bit	7,a
	ret	z				; Leave SwE alone if HwS
	push	ix
	pop	hl
	ld	bc,SYNTH_INST_VOLUME		; Update SwE Volume
	add	hl,bc
	call	advancegradient
	jr	c,novchange
	ld	a,d
	add	a,$08
	ld	b,$02				; We will be outputing to AY 
	ld	c,(ix+SYNTH_INST_VOLUME)
	call	AYdrv
novchange:
	ld	a,(ix+SYNTH_INST_VOLUME+$02)
	ld	h,(ix+SYNTH_INST_VOLUME+$03)
	or	h
	ret	nz				; SwE not done with a sequence
	ld	a,(ix+SYNTH_INST_FLAGS)
	and	$18
	ret	z				; Release over = silence (do nothing)
	cp	$18
	ret	z				; Decay over = sustain (do nothing)
	cp	$10
	jr	z,holdover			; Hold over, to decay
	ld	a,(ix+SYNTH_INST_FLAGS)		; Else Attack over, to hold
	and	$E7
	or	$10
	ld	(ix+SYNTH_INST_FLAGS),a		; update to hold
	ld	a,(ix+SYNTH_INST_LEVELS)
	rra
	rra
	rra
	rra
	and	$0F
	ld	e,a
	ld	d,$00				; Keep attack volume
	push	ix
	pop	hl
	ld	bc,SYNTH_INST_VOLUME
	add	hl,bc
	ld	a,(ix+SYNTH_INST_HOLD)		; hold period
	or	a
	jr	z,holdover			; Skip hold-phase alltogether if zero
	jp	preparegradient
holdover:
	ld	a,(ix+SYNTH_INST_FLAGS)
	or	$18
	ld	(ix+SYNTH_INST_FLAGS),a		; update to decay
	ld	a,(ix+SYNTH_INST_LEVELS)
	and	$0F
	ld	e,a
	ld	d,$00				; decay volume destination = sustain volume
	push	ix
	pop	hl
	ld	bc,SYNTH_INST_VOLUME
	add	hl,bc
	ld	a,(ix+SYNTH_INST_DECAY)		; decay period
	jp	preparegradient

;
; Resets an instrument
;
; Turns off an instrument, and makes sure all
; its features are inactive.
;
; a = reg (A=0, B=1, C=2)
;
resetInstrument:
	push	af
	push	bc
	push	de
	push	ix
	call	pointtodata
	ld	d,a
	ld	b,$02
	add	a,$08
	ld	c,$00
	call	AYdrv				; Turn off volume
	ld	a,d
	sla	a
	ld	c,(ix)
	call	AYdrv				; Set frequency to current
	inc	a
	ld	c,(ix+$01)
	call	AYdrv
	ld	(ix+SYNTH_INST_TUNE+$02),$00	; Stop any action
	ld	(ix+SYNTH_INST_TUNE+$03),$00
	ld	(ix+SYNTH_INST_VOLUME),$00
	ld	(ix+SYNTH_INST_VOLUME+$01),$00
	ld	(ix+SYNTH_INST_VOLUME+$02),$00
	ld	(ix+SYNTH_INST_VOLUME+$03),$00
	ld	a,(ix+SYNTH_INST_FLAGS)		; Reset SwE
	and	$E7
	ld	(ix+SYNTH_INST_FLAGS),a
	ld	e,a
	ld	a,d
	ld	c,$01				; Shift bitmask
	ld	d,$FE
rishiftloop:
	or	a
	jr	z,ritesttone
	sla	c
	sla	d
	set	0,d
	dec	a
	jp	rishiftloop
ritesttone:
	ld	a,$07				; Set/Reset Tone path
	ld	b,$04
	bit	6,e
	call	z,AYdrv
	ld	b,c
	ld	c,d
	ld	d,b
	ld	b,$03
	bit	6,e
	call	nz,AYdrv
	sla	c				; Shift bitmask more
	sla	d
	set	0,c
	sla	c
	sla	d
	set	0,c
	sla	c
	sla	d
	set	0,c
	ld	b,$03				; Set/Reset Noise path
	bit	5,e
	call	nz,AYdrv
	ld	c,d
	ld	b,$04
	bit	5,e
	call	z,AYdrv
	pop	ix
	pop	de
	pop	bc
	pop	af
	ret

playTone:
	push	ix
	push	af
	call	pointtodata			; Point to data
	call	getTune
	pop	af
	bit	7,(ix+SYNTH_INST_FLAGS)
	call	z,playHwE
	call	nz,playSwE
	pop	ix
	ret

endTone:
	push	ix
	call	pointtodata			; Point to data
	bit	7,(ix+SYNTH_INST_FLAGS)
	call	z,endHwE
	call	nz,endSwE
	pop	ix
	ret


sweepTone:
	call	checkarpeggio
	ret	c
	push	ix
	call	pointtodata
	call	getTune
	push	ix
	pop	hl
	ld	a,c
	call	preparegradient
	pop	ix
	ret

;
; Play a tone using the software envelope
;
; ix => Instrument data block
;
;
playSwE:
	push	ix
	pop	hl
	ld	a,$01
	call	preparegradient			; Change tone next update
	ld	a,(ix+SYNTH_INST_FLAGS)
	and	$E7
	or	$08
	ld	(ix+SYNTH_INST_FLAGS),a		; update to attack
	ld	a,(ix+SYNTH_INST_LEVELS)
	rra
	rra
	rra
	rra
	and	$0F
	ld	e,a
	ld	d,$00				; attack volume destination
	ld	bc,SYNTH_INST_VOLUME
	add	hl,bc
	ld	a,(ix+SYNTH_INST_ATTACK)	; attack period
	jp	preparegradient

;
; Play a tone using the hardware envelope
;
; a = reg (A=0, B=1, C=2)
; ix => Instrument data block
; de = tune
;
playHwE:
	push	af
	push	af
	push	de

	add	a,$08				; Turn off any other use of HwE
	ld	d,a
	ld	bc,$03EF
	cp	d
	call	nz,AYdrv
	inc	a
	cp	d
	call	nz,AYdrv
	inc	a
	cp	d
	call	nz,AYdrv
	ld	a,d				; Turn on HwE for current tone
	ld	bc,$0210
	call	AYdrv
	ld	l,(ix+SYNTH_INST_HWTUNE)	; Get HwFrequency
	ld	h,(ix+SYNTH_INST_HWTUNE+1)
	ld	c,(ix+SYNTH_INST_HWFOLLOW)	; check flags
	pop	de
	bit	7,c				; HwE follow tone?
	jp	z,hwedone
	ld	l,e				; Get tone frequency and ajust for HwE
	ld	h,d
	ld	a,c
	and	$EF				; extend octave shift sign
	bit	3,a
	jr	z,hwoctpos
	or	$10
hwoctpos:
	add	a,$04				; Ajust for HwE being 4 octaves low
	ld	bc,$0000			; Initially no shift
leftshiftloop:
	bit	4,a
	jr	z,rightshiftloop
	sla	l				; Shift left till counter++ is zero
	rl	h
	inc	a
	jp	leftshiftloop
rightshiftloop:
	dec	a
	bit	4,a
	jr	nz,shiftdone
	sra	h				; till counter-- is zero, shift right
	rr	l
	rl	c				; save 1/2 digit in c0
	inc	b				; nr of shifts++
	jp	rightshiftloop
shiftdone:
	bit	0,c				; Round HwE count after shift
	jr	z,nohwroundup
	inc	hl
nohwroundup:					; Rounded tone?
	bit	6,(ix+SYNTH_INST_HWFOLLOW)
	jr	z,nohweround
	xor	a
	or	b
	jr	z,nohweround
	ld	d,h				; Shift HwE count back to get rounded tone
	ld	e,l
hwmaskloop:
	sla	e
	rl	d
	djnz	hwmaskloop
nohweround:					; Detune?
	bit	5,(ix+SYNTH_INST_HWFOLLOW)
	jr	z,hwedone
	ld	c,(ix+SYNTH_INST_HWTUNE)	; Add detune
	ld	b,(ix+SYNTH_INST_HWTUNE+1)
	bit	4,(ix+SYNTH_INST_HWFOLLOW)
	jr	z,hwjustadd
	ex	de,hl
	add	hl,bc
	ex	de,hl
	jp	hwedone
hwjustadd:
	add	hl,bc
hwedone:
	ld	a,$0B				; Set HwE frequency
	ld	b,$02
	ld	c,l
	call	AYdrv
	inc	a
	ld	c,h
	call	AYdrv
	pop	af				; Set default AY Ch Tune
	sla	a
	ld	b,$02
	ld	c,e
	call	AYdrv
	inc	a
	ld	c,d
	call	AYdrv
	ld	a,(ix+SYNTH_INST_FLAGS)		; Trigger HwE
	and	$07
	or	$08
	ld	c,a
	ld	a,$0D
	call	AYdrv
	pop	af
	ret

;
; End a tone playing using the software envelope
;
; a = reg (A=0, B=1, C=2)
; ix => Instrument data block
;
endSwE:
	ld	a,(ix+SYNTH_INST_FLAGS)
	and	$E7
	ld	(ix+SYNTH_INST_FLAGS),a		; update to decay
	ld	de,$0000			; release volume = 0
	push	ix
	pop	hl
	ld	bc,SYNTH_INST_VOLUME
	add	hl,bc
	ld	a,(ix+SYNTH_INST_RELEASE)	; release period
	jp	preparegradient

;
; End a tone playing
;
; a = reg (A=0, B=1, C=2)
;
endHwE:
	push	af
	ld	b,$02
	add	a,$08
	ld	c,$00
	call	AYdrv				; Turn off volume
	pop	af
	ret

setSwE:
	ld	(ix+SYNTH_INST_LEVELS),b
	ld	(ix+SYNTH_INST_ATTACK),c
	ld	(ix+SYNTH_INST_DECAY),d
	ld	(ix+SYNTH_INST_RELEASE),e
	ld	(ix+SYNTH_INST_HOLD),l
	ret

setHwE:
	push	af
	ld	a,b
	and	$F0
	ld	b,a
	ld	a,c
	and	$0F
	or	b
	ld	(ix+SYNTH_INST_HWFOLLOW),a
	ld	a,l
	and	$07
	ld	b,a
	ld	a,(ix+SYNTH_INST_FLAGS)
	and	$F8
	or	b
	ld	(ix+SYNTH_INST_FLAGS),a
	ld	(ix+SYNTH_INST_TUNE),e
	ld	(ix+SYNTH_INST_TUNE+1),d
	pop	af
	ret

;
; Points to data block
;
; af saved
;
; a = reg (A=0, B=1, C=2)
;
pointtodata:
	push	af
	call	ptdata
	pop	af
	ret
ptdata:
	ld	ix,instrA
	or	a
	ret	z
	ld	ix,instrB
	dec	a
	ret	z
	ld	ix,instrC
	ret

	;
	; Instrument Data
	;
	; instrA/B/C:
	; 	00-0B:	Tune function Datastructure
	;	0C-17:	Volume function Datastructure
	;	18-1A:	SwE attack/decay/release periods
	;	1B:	SwE v attack (7-4) & v sustain (3-0)
	;	1C-1D:	HwE tune
	;	1E:	Flags
	;		    7 Hardware/Software envelope
	;		    6 Tone
	;		    5 Noise
	;		    4 SwE stage 1/HwE follow tune
	;		    3 SwE stage 0/HwE double
	;		    2 HwE attack
	;		    1 HwE alternate
	;		    0 HwE hold
	;	1F:	SwE attack hold
	;
instrA:
	include	synth\instrdata.asm
instrB:
	include	synth\instrdata.asm
instrC:
	include	synth\instrdata.asm