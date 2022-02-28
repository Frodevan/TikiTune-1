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
	call	AYselectreg
	call	AYread
	ld	d,c
	pop	af
	pop	bc
	or	a
	ret

AYout:
	push	af
	call	AYselectreg
	ld	a,c
	call	AYwrite
	pop	af
	pop	bc
	or	a
	ret

AYand:
	push	af
	push	de
	ld	d,c
	call	AYselectreg
	call	AYread
	ld	a,c
	and	d
	call	AYwrite
	pop	de
	pop	af
	pop	bc
	or	a
	ret

AYor:
	push	af
	push	de
	ld	d,c
	call	AYselectreg
	call	AYread
	ld	a,c
	or	d
	call	AYwrite
	pop	de
	pop	af
	pop	bc
	or	a
	ret

AYxor:
	push	af
	push	de
	ld	d,c
	call	AYselectreg
	call	AYread
	ld	a,c
	xor	d
	call	AYwrite
	pop	de
	pop	af
	pop	bc
	or	a
	ret

AYread:
	ld	c,a
	ld	b,$F7
	ld	a,$92
	out	(c),a		; 8255 A = Input
	ld	b,$F7
	ld	a,$0D
	out	(c),a		; 8255 C = ReadReg
	ld	b,$F4
	in	a,(c)		; 8255 A = Data
	ld	c,a
	ld	b,$F7
	ld	a,$92
	out	(c),a		; 8255 A = Input
	ret

AYwrite:
	ld	c,a
	ld	b,$F7
	ld	a,$82
	out	(c),a		; 8255 A = Output
	ld	a,c
	ld	b,$F4
	out	(c),a		; 8255 A = Data
	ld	b,$F7
	ld	a,$0F
	out	(c),a		; 8255 C = WriteReg
	ld	b,$F7
	ld	a,$92
	out	(c),a		; 8255 A = Input
	ret

AYselectreg:
	push	bc
	ld	c,a
	ld	b,$F7
	ld	a,$82
	out	(c),a		; 8255 A = Output
	ld	a,c
	ld	b,$F4
	out	(c),a		; 8255 A = Reg
	ld	b,$F7
	ld	a,$0D
	out	(c),a
	ld	a,$0F
	out	(c),a		; 8255 C = SelectReg
	ld	b,$F7
	ld	a,$92
	out	(c),a		; 8255 A = Input
	pop	bc
	ret