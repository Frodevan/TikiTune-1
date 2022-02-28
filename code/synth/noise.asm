setNoise:
	ld	b,$01
sweepNoise:
	ld	hl,instrN
	and	$1F
	ld	d,$00
	ld	e,a
	ld	a,b
	jp	preparegradient

;
; Updates Tune-sweep on Noise
;
updatenoise:
	ld	hl,instrN
	call	advancegradient
	ret	c
	ld	a,$06
	ld	b,$02
	ld	c,(hl)
	jp	AYdrv


instrN:
	dw	$001F	; current Tune
	dw	$0000	; Sweep t
	dw	$0000	; Sweep dT
	dw	$0000	; Sweep dt
	dw	$0000	; Sweep D
	dw	$0000	; Sweep a