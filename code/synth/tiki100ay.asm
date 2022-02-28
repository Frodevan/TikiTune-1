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
	out	($16),a
	in	a,($17)
	ld	d,a
	pop	af
	pop	bc
	or	a
	ret

AYout:
	push	af
	out	($16),a
	ld	a,c
	out	($17),a
	pop	af
	pop	bc
	or	a
	ret

AYand:
	push	af
	out	($16),a
	in	a,($17)
	and	c
	out	($17),a
	pop	af
	pop	bc
	or	a
	ret

AYor:
	push	af
	out	($16),a
	in	a,($17)
	or	c
	out	($17),a
	pop	af
	pop	bc
	or	a
	ret

AYxor:
	push	af
	out	($16),a
	in	a,($17)
	xor	c
	out	($17),a
	pop	af
	pop	bc
	or	a
	ret