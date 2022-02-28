IF NOT DEFINED BDOS
include	cpm\bdos.inc
ENDIF

printHL:
	push	af
	ld	a,h
	call	printA
	ld	a,l
	call	printA
	pop	af
	ret

printChrA:
	ld	c,BDOS_C_WRITE
	ld	e,a
	jp	BDOS

printStr:
	push	af
	push	bc
	push	de
	push	hl
prtstrloop:
	ld	a,(hl)
	or	a
	jr	z,prtend
	push	hl
	call	printChrA
	pop	hl
	inc	hl
	jp	prtstrloop

printA:
	push	af
	push	bc
	push	de
	push	hl
	call	hexAscii
	ld	c,BDOS_C_WRITE
	ld	e,b
	push	af
	call	BDOS
	pop	af
	ld	c,BDOS_C_WRITE
	ld	e,a
	call	BDOS
	jr	prtend

printSp:
	push	af
	push	bc
	push	de
	push	hl
	ld	c,BDOS_C_WRITE
	ld	e,' '
	call	BDOS
	jp	prtend

printLn:
	push	af
	push	bc
	push	de
	push	hl
	ld	c,BDOS_C_WRITE
	ld	e,ASCII_CARTRET
	call	BDOS
	ld	c,BDOS_C_WRITE
	ld	e,ASCII_LINEFEED
	call	BDOS
prtend:
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret

hexAscii:
	ld	b,a
	sra	a
	sra	a
	sra	a
	sra	a
	and	$0F
	ld	hl,hextable
	ld	c,a
	ld	a,b
	ld	b,$00
	or	a
	adc	hl,bc
	ld	d,(hl)
	and	$0F
	ld	hl,hextable
	ld	c,a
	or	a
	adc	hl,bc
	ld	a,(hl)
	ld	b,d
	ret

hextable:
	db	$30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46