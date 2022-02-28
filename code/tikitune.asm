;
; TikiTune - AY-3-8912 Player/Interface for Tiki-100
;
; The player (music.asm) must be compiled separately as MUSIC.BIN. All
; communications to the player is done by using the equates in player.inc,
; and it is crucial that MUSIC.BIN is compiled to the address defined by
; the PLAYER equate.
;
; Calls to the player are done by storing an operation equate in A
; and calling MUSIC. Some operations may require additional data in
; other registers. All operation-equates, together with the MUSIC
; address are defined by the player.inc include file as well.
;
; The entire content of PLAYER.BIN is loaded into it's proper location
; in RAM at the start of this program. After this is done, it should be
; safe to perform player operations.
;
; Allthough this program provides a fixed, simple, CP/M-based interface
; hardwiered to the player, the player works independent from the interface.
; It is in fact possible to keep it running on it's own when excecuting
; other programs, as long as it can keep it's own memory for itself. If a
; standalone interface wants to check for the players presence, the first
; 8 bytes at PLAYER should read "MUSICxyy" where xyy is the player version
; number and revision number.
;

include		tiki100.inc
include		cpm\bdos.inc
include		cpm\ascii.inc
include		player\player.inc

		org	$100

		ld	hl,playerbin			; Install player in solid RAM
		ld	de,PLAYER
		ld	bc,eoplayerbin-playerbin
		ldir

		di					; Set Stack to just below player
		ld	(oldsp),sp
		ld	sp,PLAYER
		ei
		ld	a,i				; Hook timer interrupt
		ld	h,a
		ld	l,TIKI_TIMERINT
		ld	a,MUSIC_SETUP
		call	MUSIC

		call	printLn				; Print title
		ld	hl,title
		call	printStr

		ld	a,'T'				; Force input file extension .TKT
		ld	(DEFAULT_FCB + FCB_T1),a
		ld	(DEFAULT_FCB + FCB_T3),a
		ld	a,'K'
		ld	(DEFAULT_FCB + FCB_T2),a
		xor	a				; Start from beginning of file
		ld	(DEFAULT_FCB + FCB_CR),a
		ld	(DEFAULT_FCB + FCB_EX),a
		ld	(DEFAULT_FCB + FCB_RC),a
		ld	de,DEFAULT_FCB
		ld	c,BDOS_F_OPEN			; Open file
		call	BDOS
		cp	$FF
		jp	z,wrongfile
		ld	de,filedata			; Set load address
		ld	c,BDOS_F_DMAOFF
		call	BDOS
		ld	de,DEFAULT_FCB			; Load metadata
		ld	c,BDOS_F_READ
		call	BDOS
		or	a
		jp	nz,readend
		ld	(filedata+$3F),a		; Print metadata, making sure it's terminated first
		ld	(filedata+$7F),a
		ld	hl,namestr
		call	printStr
		ld	hl,filedata
		call	printStr
		call	printLn
		ld	hl,composerstr
		call	printStr
		ld	hl,filedata+$40
		call	printStr
		call	printLn
		call	printLn
loadloop:	ld	de,DEFAULT_FCB			; Load music bytecode data
		ld	c,BDOS_F_READ
		call	BDOS
		or	a
		jp	nz,readend
		ld	hl,(filesize)			; 128 bytes of data read, increase size
		ld	de,FILE_READSIZE
		add	hl,de
		ld	(filesize),hl
		ld	de,filedata			; ... and point to next load location
		add	hl,de
		bit	7,h
		jr	nz,readend			; ... but quit if it gets into the player-routines.
		ex	de,hl
		ld	c,BDOS_F_DMAOFF
		call	BDOS
		jp	loadloop

readend:						; Prepare song for the player
		ld	hl,(filesize)			; Force end at end of song.
		ld	de,filedata
		add	hl,de
		ld	a,BYTECODE_SONG_END
		ld	(hl),a
		ld	a,MUSIC_GETENTRY		; Get song-in-player entry point
		call	MUSIC
		push	hl
		ld	bc,(filesize)			; Check size, song should not be empty
		ld	a,b
		or	c
		jp	z,emptyfile
		inc	bc				; inc for the added end-bytecode
		ld	(filesize),bc
		add	hl,bc				; Check size, must not overwrite the OS
		ld	de,(BDOSLOC)
		or	a
		sbc	hl,de
		pop	hl
		jp	nc,toobig
		ex	de,hl				; Send song to player
		ld	hl,filedata
		ld	bc,(filesize)
		ldir

goplay:
		ld	a,TDV2115_ERLINE
		call	printChrA
		ld	a,MUSIC_START			; Play song
		call	MUSIC
songpl:		ld	a,MUSIC_GETWAIT			; Wait for song to finish
		call	MUSIC
		cp	PLAYER_STOP
		jr	z,songdone
		ld	c,BDOS_C_STAT
		call	BDOS
		or	a
		jr	z,songpl
		ld	c,BDOS_C_READ
		call	BDOS
		or	$60
		push	af
		ld	a,ASCII_CARTRET
		call	printChrA
		pop	af
		cp	'r'
		jr	z,goplay
		cp	'e'
		jr	z,songdone
		cp	'p'
		jr	z,gopause
		jp	songpl

gopause:
		ld	a,MUSIC_STOP			; Stop song
		call	MUSIC
		ld	hl,pausemsg
		call	printStr
pausing:	ld	c,BDOS_C_STAT
		call	BDOS
		or	a
		jp	z,pausing
		ld	c,BDOS_C_READ
		call	BDOS
		push	af
		ld	a,ASCII_CARTRET
		call	printChrA
		pop	af
		or	$60
		cp	'p'
		jp	nz,pausing
		ld	a,TDV2115_ERLINE
		call	printChrA
		ld	a,MUSIC_PLAY
		call	MUSIC
		jp	songpl
	

songdone:						; Restore timer interrupt
		ld	a,MUSIC_STOP			; Stop song
		call	MUSIC
		ld	a,MUSIC_CLEANUP
		call	MUSIC
		ld	hl,endmsg			; Return to the OS
		ld	a,(needreset)
		or	a
		jr	z,gonoreset
		call	printStr
endemptykb:	ld	c,BDOS_C_STAT
		call	BDOS
		push	af
		ld	c,BDOS_C_READ
		call	BDOS
		pop	af
		or	a
		jr	nz,endemptykb
		call	printLn
		call	printLn
gonoreset:
		di
		ld	sp,(oldsp)
		ei
		ld	a,(needreset)
		or	a
		ret	z
		jp	BDOS_RESET

endmsg:		db	'Sett inn en systemdiskett i A og trykk Retur-knappen...', ASCII_NULL
namestr:	db	'Melodi    : ', ASCII_NULL
composerstr:	db	'Komponist : ', ASCII_NULL
pausemsg:	db	'  Pause!', ASCII_CARTRET, ASCII_NULL
title:		db	ASCII_CARTRET, ASCII_LINEFEED, TDV2115_FRGSK, 'Tiki-Tune v1.02, Musikkspiller for Tiki-100', TDV2115_NORMAL, ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, '   E: Stopp, R: Restart, P: Pause/Spill', ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, ASCII_NULL
		db	'Frode van der Meeren, Januar 2015'
oldsp:		dw	$0000

needreset:	db	$FF

emptyfile:
		ld	a,$00
		ld	(needreset),a
		ld	hl,tosmallmsg
		call	printStr
		jp	songdone
tosmallmsg:
		db	TDV2115_CURUP, TDV2115_CURUP, TDV2115_ERLINE, ASCII_LINEFEED, ASCII_LINEFEED,'Feil: Musikkfilen er tom!', ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, ASCII_NULL

toobig:
		ld	a,$00
		ld	(needreset),a
		ex	de,hl
		or	a
		sbc	hl,de
		ex	de,hl
		ld	hl,toobigmsg
		call	printStr
		ex	de,hl
		call	printHL
		ld	hl,toobigmsg2
		call	printStr
		ld	hl,(filesize)
		call	printHL
		ld	hl,toobigmsg3
		call	printStr
		jp	songdone
toobigmsg:	db	TDV2115_CURUP, TDV2115_CURUP, TDV2115_ERLINE, ASCII_LINEFEED, ASCII_LINEFEED,'Feil: Musikkfilen er for stor!', ASCII_CARTRET, ASCII_LINEFEED,'Det er bare plass til ', ASCII_NULL
toobigmsg2:	db	'h Bytes i bufferen.', ASCII_CARTRET, ASCII_LINEFEED, 'Musikkfilen var hele ', ASCII_NULL
toobigmsg3:	db	'h Bytes...', ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, ASCII_NULL

wrongfile:
		ld	a,$00
		ld	(needreset),a
		ld	hl,DEFAULT_FCB+FCB_NAME
		ld	de,filename
		ld	bc,$0008
		ldir
		ld	a,' '
		ld	hl,filename
		ld	bc,$0008
filecomp:
		cpi
		push	af
		ld	a,b
		or	c
		jr	z,nofile
		pop	af
		jr	z,filecomp
		ld	a,' '
		ld	hl,filename
		ld	bc,$0009
		cpir
		ld	hl,filename+8;
		or	a
		sbc	hl,bc
		ld	(hl),$00
		ld	hl,wrongfilemsg
		call	printStr
		ld	hl,wrongfilemsg2
		call	printStr
		jp	songdone
nofile:
		pop	af
		ld	hl,nofilemsg
		call	printStr
		jp	songdone
	
wrongfilemsg:	db	TDV2115_CURUP, TDV2115_CURUP, TDV2115_ERLINE, ASCII_LINEFEED, ASCII_LINEFEED, 'Feil: Finner ikke filen '
filename:	db	'         '
wrongfilemsg2:	db	'.TKT!', ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, ASCII_NULL
nofilemsg:	db	TDV2115_CURUP, TDV2115_CURUP, TDV2115_ERLINE,'   Syntaks:   TIKITUNE filnavn', ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, 'Feil: Ingen fil valgt!', ASCII_CARTRET, ASCII_LINEFEED, ASCII_LINEFEED, ASCII_NULL



		include	cpm\dbprint.asm

filesize:	dw	$0000
;
; Will be copied to $8000
;
; Reused for loading the file
;
playerbin:
filedata:	incbin	MUSIC.BIN
eoplayerbin: