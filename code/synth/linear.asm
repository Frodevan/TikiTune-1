;
; Sets up a datastructure in preparation for the slope algorithm.
;
; HL points to the datastructure
; A contains unsigned x length (0 = 256)
; DE contains signed y destination
;
; HL is saved
;
preparegradient:
	push	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)		; get y in bc
	inc	hl		; point to x
	ld	(hl),a						; x = x
	inc	hl
	ld	(hl),$01
	or	a
	jr	z,prepmax1
	dec	(hl)
prepmax1:
	inc	hl		; point to dy
	push	hl		; save pointer to dy
	inc	hl
	inc	hl		; point to dx
	ld	(hl),a						; dx = x
	inc	hl
	ld	(hl),$01	; Store dx
	or	a
	jr	z,prepmax2
	dec	(hl)
prepmax2:
	inc	hl		; point to D
	ld	(hl),$00					; D = 0
	inc	hl
	ld	(hl),$00
	ex	de,hl		; hl = y dest
	or	a
	sbc	hl,bc						; dy = y dest - y current
	or	a
	jr	z,prepmax3
	call	div		; hl = dy/dx, a=dy%dx
preppos:
	jp	prepcont
prepmax3:
	ld	a,l		; hl = dy/256, a=dy%256
	ld	c,$00
	ld	l,h
	ld	h,$00
prepcont:
	ex	de,hl		; de = dy/dx
	inc	hl		; point to d
	ld	(hl),e						; d = dy/dx
	inc	hl
	ld	(hl),d		; Store d
	pop	hl		; restore pointer to dy
	ld	(hl),a						; dy = dy%dx
	inc	hl
	ld	(hl),c		; Store dy
	pop	hl
	ret


;
; Divide HL by A
;
; output:
;  HL = HL/A
;  CA = HL%A
;
;  call div   : HL signed
;  call usdiv : unsigned division
;
div:
	bit	7,h
	jr	nz,HLneg
usdiv:
	ld	c,a
	xor	a
	ld	b,$11
divnext:
	dec	b
	jr	z,divdone
divloop:
	add	hl,hl
	rla
	cp	c
	jr	c,divnext
	sub	c
	inc	l
	djnz	divloop
divdone:
	ld	c,$00
	ret
HLneg:
	call	flipsignHL	; HL is negative
	call	usdiv
	neg
	jr	z,flipsignHL
	ld	c,$FF
	jp	flipsignHL
;
; HL = -HL
;
flipsignHL:
	push	de
	ex	de,hl
	ld	hl,$0000
	or	a
	sbc	hl,de
	pop	de
	ret


;
; Calculate points of a linear function, maintaining an even gradient.
; 
; HL must be pointing to a datastructure:
;
;	hl+0 =  y - (Word) Current value of function
;	hl+2 =  x - (Word) Current remaining points of the function
;	hl+4 = dy - (Word) y ratio of gradient
;	hl+6 = dx - (Word) x ratio of gradient
;	hl+8 =  D - (Word) Current Delta Error
;	hl+A =  a - (Word) Whole-number part of gradient
;
; The gradient of the function is defined by a + dy/dx, where dy < dx
;
; To initiate a function, set the appropriate values for x, y, a, dx, dy,
; and then set D = 0. x is decremented by 1 for every point calculated,
; and no more points will be calculated after x reaches zero. If more
; points are needed, just put a new value into x.
;
; a should have the same sign as dy!
;
; The algorithm used is a variation of the Bresenham Line algorithm:
;
;	Expected initial conditions:
;	dx = x1 - x0 (= x)
;	dy = y1 - y0
;	a  = dy / dx (integer-division)
;	dy = dy % dx
;	D  = 0
;
;
;	Algorithm for next point:
;
;	y = y + d
;	D = D + dy*2
;	if D >= dx
;	  y = y+1
;	  D = D - dx*2
;	else if D <= -dx
;	  y = y-1
;	  D = D + dx*2
;
; This algorithm adds no offset of the point-center, and thus assumes atomic-
; sized points. Using this to draw a line of pixels might therefore result
; in a slight offset in case the coordinate of a pixel can be judged from its
; corner. To fix this, the initial value of D must be calculated from the
; centre of the first pixel.
;
; Registers are saved.
;
advancegradient:
	push	bc
	push	de
	push	hl
	push	af
	ld	e,(hl)
	inc	hl
	ld	d,(hl)		; get y in de
	inc	hl		; point to x
	ld	a,(hl)		; get x in a
	or	a
	jp	nz,grcontinue					; Skip if x is 0
	inc	hl
	ld	a,(hl)
	or	a
	jr	z,grnochange
	dec	(hl)
	dec	hl
grcontinue:
	dec	(hl)						; else continue by counting down x
	inc	hl
	inc	hl		; point to dy
	push	de		; save original y for reference
	push	hl		; save pointer to dy
	ld	bc,$0007
	add	hl,bc		; point to upper a
	ld	b,(hl)
	dec	hl
	ld	c,(hl)		; get a in bc
	ex	de,hl		; hl = y
	add	hl,bc						; y = y + a
	ex	de,hl		; de = y
	dec	hl		; point to D
	ld	b,(hl)
	dec	hl
	ld	c,(hl)		; get D in bc
	pop	hl		; restore pointer to dy
	push	de		; save y
	ld	e,(hl)
	inc	hl
	ld	d,(hl)		; get dy in de
	or	a
	rl	e
	rl	d						; dy = dy*2
	inc	hl		; point to dx
	push	hl		; save pointer to dx
	ld	h,b
	ld	l,c		; hl = D
	add	hl,de						; D = D + dy
	ld	de,$8000
	add	hl,de		; adjust D for signed comparison
	ex	de,hl		; de = D (adj)
	pop	hl		; restore pointer to dx
	ld	c,(hl)
	inc	hl
	ld	b,(hl)		; get dx in bc
	inc	hl		; point to D
	push	hl		; save pointer to D
	push	bc		; save dx
	push	de		; save D (adj)
	ld	h,b
	ld	l,c		; hl = dx
	ld	bc,$8000
	add	hl,bc		; adjust dx for signed comparison
	ex	de,hl		; hl = D (adj), de = dx (adj)
	or	a
	sbc	hl,de						; if D >= dx
	pop	de		; restore D (adj)
	pop	bc		; restore dx
	jr	nc,gradd					; then go add one to y
	ld	hl,$0000
	or	a
	sbc	hl,bc		; hl = -dx
	push	hl		; save -dx
	ld	bc,$8000
	add	hl,bc		; adjust -dx for signed comparison
	or	a
	sbc	hl,de						; if D <= -dx
	pop	bc		; restore -dx
	jr	nc,grsub					; then go subtract one from y
	ex	de,hl
	ld	de,$8000
	or	a
	sbc	hl,de
	ex	de,hl		; undo D signed comparison ajustement
	pop	hl		; restore pointer to D
	pop	bc		; restore y
grdone:
	ld	(hl),e		; Store D
	inc	hl
	ld	(hl),d
	pop	hl		; get original y
	or	a
	sbc	hl,bc		; Any changes?
	jp	z,grnochange	; don't update y then
	pop	af
	pop	hl
	ld	(hl),c		; Store y
	inc	hl
	ld	(hl),b
	dec	hl
	pop	de
	pop	bc
	or	a
	ret

grnochange:
	pop	af
	pop	hl
	pop	de
	pop	bc
	or	a
	ccf
	ret

gradd:								; Add one to y:
	or	a
	sbc	hl,bc
	ex	de,hl						; D = D - 2*dx
	pop	hl		; restore pointer to D
	pop	bc		; restore y
	inc	bc						; y = y+1
	jp	grdone

grsub:								; Subtract one from y:
	add	hl,bc		; hl = -dx - D +(-dx)
	call	flipsignHL	; hl = -(-2*dx - D)
	ex	de,hl						; D = D + 2*dx
	pop	hl		; restore pointer to D
	pop	bc		; restore y
	dec	bc						; y = y-1
	jp	grdone