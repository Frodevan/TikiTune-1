include		player\player.inc

org	$00			; Code entry-point. Pointing to init now to failsafe premature interrupt
	jp	$0100
cr:
	db	$01		; Counters for keeping time with the interrupt
	db	$01

org	$38			; Interrupt - Do something 3 out of 5 times for ~125 ticks per second
	push	hl
	push	af
	ld	hl,cr
	dec	(hl)		; Count first counter
	ld	a,(hl)
	or	a
	jr	nz,nah		; Only do something if first counter is 0
	inc	hl
	dec	(hl)		; Count second counter
	ld	a,(hl)
	jr	nz,nah2		; Reset second counter to 5 if it is 0
	ld	a,$05
	ld	(hl),a
nah2:
	ld	a,$02		; Set first counter to 2 if second counter is odd, else set to 3
	bit	0,(hl)
	jr	nz,nah3
	ld	a,$03
nah3:
	dec	hl
	ld	(hl),a
	pop	af		; Done resetting counter(s), it's time to do something
	pop	hl
	jp	$0000
nah:
	pop	af
	pop	hl
	ei
	reti

;////////////////////////////////////////////////////////////////////////////////////////////////////

	org	$100			; Start

	di
	ld	hl,playerdata		; Load driver to appropriate location in RAM
	ld	de,PLAYER
	ld	bc,$4000
	ldir
	ld	sp,PLAYER		; Set top of stack to just below driver
	ld	a,MUSIC_SETVECT		; Make jump at address zero jump to player-routine 
	ld	hl,$0001
	call	MUSIC			; Enables interrupts

	ld	a,MUSIC_START		; Start playing
	call	MUSIC
songpl:					; Wait for song to play through
	ld	a,MUSIC_GETWAIT
	call	MUSIC
	cp	PLAYER_STOP
	jr	z,songdone
	jp	songpl

songdone:				; Halt when song is done
	jp	songdone

;
; Will be copied to $8000
;
playerdata:
	incbin	MUSIC.BIN		; Replace last byte in binary with tune data of song to play