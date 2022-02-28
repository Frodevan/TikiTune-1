

;
; Interpereter
;
;	Wait for x 1/125 second ticks			00000000 xx
;	Silence the player				00000001
;	End playing arpeggio				00000010
;	End the song					00000011
;	Play tone n on instrument x			000001xx nn
;	Sweep to tone n on instrumen x in d ticks	000010xx nn dd
;	End any playing tone on instrument x		000011xx
;	Play arpeggio triad a/b/c on instrument x, each
;	tone sounding for t 1/125 second ticks.
;	Instrument 0-2 uses instrument 0-2 respectively
;	Instrument 4-6 uses instrument 0-2 as well, but
;	adds instruments 1, 2 or 0 respectively for a
;	dual-instrument arpeggio.			00010xxx aa bb cc tt
;	Return from waypoint call, discarding x layers	00011xxx
;	Waypoint x marker				001xxxxx
;	Set noise frequency divisor to x		010xxxxx
;	Sweep noise frequency divisor to x in d ticks	011xxxxx dd
;	Define instrument c to Tone, Noise, and swEnv.
;	a zero is disabled, a one is enabled.		100TNEcc
; SwEnv	Set envelope on instrument c to attack level x,
;	sustain level y, attack time a, decay time d,
;	release time r and Attack hold time e.		101eeecc xy aa dd rr
; HwEnv	Set envelope on instrument c to follow mode x
;	(8*"enable" + 4*"round tone" + 2*"add detune" +
;	1*"detune tone instead of env."), HwE follow
;	octave shift a (-8 to 7), HwE time period or
;	HwE follow detune c + b*256 and HwE native
;	mode e (4*"attack" + 2*"alternate" + 1*"hold")	101eeecc x0 0a bb cc
;	Call waypoint x					110xxxxx
;	Jump to waypoint x				111xxxxx
;
doinstruction:
	ld	hl,(pointer)
	ld	a,(hl)
	inc	hl
	ld	(pointer),hl
	ld	e,a
	ld	d,$00
	ld	hl,playertable
	add	hl,de
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	jp	(hl)

playertable:
	dw	dowait		; 00
	dw	dosilence	; 01
	dw	doendarpg	; 02
	dw	doendsong	; 03
	dw	doplaytone, doplaytone, doplaytone, doplaytone		; 04-07
	dw	dosweeptone, dosweeptone, dosweeptone, dosweeptone	; 08-0B
	dw	doendtone, doendtone, doendtone, doendtone		; 0C-0F
	dw	doplayarpg, doplayarpg, doplayarpg, doplayarpg, doplayarpg, doplayarpg, doplayarpg, doplayarpg	; 10-17
	dw	doretn,	doretn,	doretn,	doretn,	doretn,	doretn,	doretn,	doretn					; 18-1F
	dw	dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint
	dw	dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint
	dw	dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint
	dw	dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint, dowaypoint			; 20-3F
	dw	dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise
	dw	dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise
	dw	dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise
	dw	dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise, dosetnoise			; 40-5F
	dw	dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise
	dw	dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise
	dw	dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise
	dw	dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise, dosweepnoise	; 60-7F
	dw	dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst
	dw	dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst
	dw	dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst
	dw	dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst, dosetinst				; 80-9F
	dw	dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv
	dw	dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv
	dw	dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv
	dw	dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv, dosetenv					; A0-BF
	dw	docall, docall, docall, docall, docall, docall, docall, docall
	dw	docall, docall, docall, docall, docall, docall, docall, docall
	dw	docall, docall, docall, docall, docall, docall, docall, docall
	dw	docall, docall, docall, docall, docall, docall, docall, docall							; C0-DF
	dw	dojump, dojump, dojump, dojump, dojump, dojump, dojump, dojump
	dw	dojump, dojump, dojump, dojump, dojump, dojump, dojump, dojump
	dw	dojump, dojump, dojump, dojump, dojump, dojump, dojump, dojump
	dw	dojump, dojump, dojump, dojump, dojump, dojump, dojump, dojump							; E0-FF

dowait:
	ld	hl,(pointer)
	ld	a,(hl)
	ld	(wait),a
	inc	hl
	ld	(pointer),hl
	ret
dosilence:
	jp	shutup
doendarpg:
	jp	endArpeggio
doendsong:
	call	shutup
	ld	a,PLAYER_STOP
	ld	(wait),a
	ld	hl,wpeos
	ld	(wpsp),hl
	ld	hl,tune
	ld	(pointer),hl
	ret
doplaytone:
	and	$03
	ld	hl,(pointer)
	ld	b,(hl)
	inc	hl
	ld	(pointer),hl
	jp	playTone
dosweeptone:
	and	$03
	ld	hl,(pointer)
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	(pointer),hl
	jp	sweepTone
doendtone:
	and	$03
	jp	endTone
doplayarpg:
	and	$07
	ld	hl,(pointer)
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	(pointer),hl
	jp	playArpeggio
doretn:
	and	$07
	ld	hl,(pointer)
	inc	a
	ld	b,a
doretloop:
	push	bc
	call	poplayer
	pop	bc
	djnz	doretloop
	ld	(pointer),hl
	ret
dowaypoint:
	ret
dosetnoise:
	and	$1F
	jp	setNoise
dosweepnoise:
	and	$1F
	ld	hl,(pointer)
	ld	b,(hl)
	inc	hl
	ld	(pointer),hl
	jp	sweepNoise
dosetinst:
	ld	b,$00
	bit	4,a
	jr	nz,dokeept
	ld	b,$FF
dokeept:
	ld	c,$FF
	bit	3,a
	jr	nz,dokeepn
	ld	c,$00
dokeepn:
	ld	d,$00
	bit	2,a
	jr	nz,dokeepe
	ld	d,$FF
dokeepe:
	and	$03
	jp	setInstrument
dosetenv:
	ld	hl,(pointer)
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	(pointer),hl
	ld	h,a
	rra
	rra
	and	$07
	ld	l,a
	ld	a,h
	and	$03
	jp	setEnvelope
docall:
	ld	hl,(pointer)
	ld	b,a
	push	bc
	call	pushlayer
	pop	bc
	ld	a,b
	jr	c,donotjump
dojump:
	and	$1F
	ld	c,a
	ld	b,$00
	sla	c
	ld	hl,wptable
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(pointer),de
donotjump:
	ret


pushlayer:
	ld	(wpoldsp),sp
	ld	sp,(wpsp)
	ld	b,h
	ld	c,l
	ld	hl,(wpsp)
	ld	de,wpstack
	or	a
	sbc	hl,de
	jr	c,layerfail
	push	bc
	ld	h,b
	ld	l,c
	jp	layersuccess
poplayer:
	ld	(wpoldsp),sp
	ld	sp,(wpsp)
	ld	b,h
	ld	c,l
	ld	hl,(wpsp)
	ld	de,wpeos-1
	or	a
	sbc	hl,de
	jr	nc,layerfail
	pop	hl
layersuccess:
	ld	(wpsp),sp
	ld	sp,(wpoldsp)
	or	a
	ret
layerfail:
	ld	h,b
	ld	l,c
	ld	(wpsp),sp
	ld	sp,(wpoldsp)
	or	a
	ccf
	ret

mapWp:
	ld	hl,tune
mwloop:
	ld	a,(hl)
	cp	$03
	ret	z
	ld	c,$01
	ld	b,a
	cp	$00
	jr	nz,mw1
	ld	c,$02
mw1:
	and	$FC
	cp	$04
	jr	nz,mw2
	ld	c,$02
mw2:
	cp	$08
	jr	nz,mw3
	ld	c,$03
mw3:
	and	$F8
	cp	$10
	jr	nz,mw4
	ld	c,$05
mw4:
	and	$E0
	cp	$20
	jr	z,wpfound
	cp	$60
	jr	nz,mw5
	ld	c,$02
mw5:
	cp	$A0
	jr	nz,mw6
	ld	c,$05
mw6:
	ld	b,$00
	add	hl,bc
	jp	mwloop
wpfound:
	ld	a,b
	and	$1F
	ld	b,$00
	ld	c,a
	sla	c
	ex	de,hl
	ld	hl,wptable
	add	hl,bc
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ex	de,hl
	inc	hl
	jp	mwloop

wptable:
	ds	$40

;
; Waypoiny Stack
;
wpsp:
	dw	wpeos
wpoldsp:
	dw	$0000
wpstack:
	ds	PLAYER_WPDEPTH*2
wpeos: