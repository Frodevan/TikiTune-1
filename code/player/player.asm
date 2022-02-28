PLAYER_WPDEPTH		equ	$10		; Waypoint call-stack depth
PLAYER_STACKSIZE	equ	$40		; Player/Synth regular stack depth

	org	MUSIC
	or	a
	jp	z,playsong
	dec	a
	jp	z,stopsong
	dec	a
	jp	z,continuesong
	dec	a
	jp	z,songstart
	dec	a
	jp	z,getwait
	dec	a
	jp	z,setvector
	dec	a
	jp	z,savevector
	dec	a
	jp	z,resetvector
	ret


getwait:
	ld	a,(wait)
	ret


;
;
;
resetvector:
	di
	ld	hl,(vectorloc)
	ld	de,(clkvector)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	dec	hl
	ei
	ret

;
; HL -> Interrupt Vector
;
savevector:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	hl
	ld	(clkvector),de
	ld	(vectorloc),hl
setvector:
	di
	ld	de,routine
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ei
	ret



;
; Stops the tune
;
stopsong:
	di
	call	shutup2
	ld	a,PLAYER_STOP
	ld	(wait),a
	ei
	ret

;
; Continues a stopped tune
;
continuesong:
	ld	a,(wait)
	cp	PLAYER_STOP
	ret	nz
	di
	call	shutup2
	ei
	call	mapWp
	ld	a,$20
	ld	(wait),a	
	ret

;
; Plays tune from beginning
;
playsong:
	di
	call	endArpeggio
	ei
	call	stopsong
	ld	de,tune
	ld	(pointer),de
	ld	de,wpeos
	ld	(wpsp),de
	call	mapWp
	ld	a,$20
	ld	(wait),a
	ret

;
; Get Pointer to tune start
;
songstart:
	ld	hl,tune
	ret

routine:
	push	hl
	ld	hl,(clkvector)
	ex	(sp),hl
	push	af
	push	bc
	push	de
	push	hl
	ld	(ploldsp),sp
	ld	sp,pleos
chkinstr:
	ld	hl,wait
	ld	a,(hl)
	cp	PLAYER_STOP
	jr	z,stopped
	or	a
	jr	z,ready
	dec	(hl)
	call	synthcycle
stopped:
	ld	sp,(ploldsp)
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
ready:
	call	doinstruction
	jp	chkinstr


dummyret:
	ei
	reti

clkvector:
	dw	dummyret
vectorloc:
	dw	clkvector
wait:
	db	PLAYER_STOP

;
; Stack
;
ploldsp:
	dw	$0000
plstack:
	ds	PLAYER_STACKSIZE*2
pleos:


;
; This advances the instruction pointer by one, and
; operates the synth accordingly. Instructions are taken
; from the "tune" and "pointer" label pair. 
;
; Before any instructions can be run, waypoints has to be
; mapped. This only needs to be done once per uploaded
; song.
;
; #######################################################
; #							#
; #  Interpereter					#
; #							#
; #######################################################
; #							#
; #  mapWp:						#
; #	n/a						#
; #							#
; #  doinstruction:					#
; #	n/a						#
; #							#
; #######################################################

	include	player/interpereter.asm
