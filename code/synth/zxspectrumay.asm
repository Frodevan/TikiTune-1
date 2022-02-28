;
; AY-3-8912 interface
;
; B:
; 1 In
; 2 Out
; 3 And
; 4 Or
; 5 XOr
;
; AY Register in A, Data in C
;
; Other registers kept unchanged
;
	push	bc
	dec	b
	jr	z,AYin
	dec	b
	jr	z,AYout
	dec	b
	jr	z,AYand
	dec	b
	jr	z,AYor
	dec	b
	jr	z,AYxor
	pop	bc
	or	a
	ccf
	ret

AYin:
	push	af
	ld	bc,$FFFD
	out	(c),a
	in	a,(c)
	ld	d,a
	pop	af
	pop	bc
	or	a
	ret

AYout:
	push	af
	push	de
	ld	d,c
	ld	bc,$FFFD
	out	(c),a
	ld	a,d
	ld	bc,$BFFD
	out	(c),a
	pop	de
	pop	af
	pop	bc
	or	a
	ret

AYand:
	push	af
	push	de
	ld	d,c
	ld	bc,$FFFD
	out	(c),a
	in	a,(c)
	and	d
	ld	bc,$BFFD
	out	(c),a
	pop	de
	pop	af
	pop	bc
	or	a
	ret

AYor:
	push	af
	push	de
	ld	d,c
	ld	bc,$FFFD
	out	(c),a
	in	a,(c)
	or	d
	ld	bc,$BFFD
	out	(c),a
	pop	de
	pop	af
	pop	bc
	or	a
	ret

AYxor:
	push	af
	push	de
	ld	d,c
	ld	bc,$FFFD
	out	(c),a
	in	a,(c)
	xor	d
	ld	bc,$BFFD
	out	(c),a
	pop	de
	pop	af
	pop	bc
	or	a
	ret