PLAYER			equ	$8000		; Player binary base address

MUSIC			equ	PLAYER+$08	; Player API-call entrypoint
MUSIC_START		equ	$00		; Start tune from the beginning, after clearing/mapping all song sequence waypoints
MUSIC_STOP		equ	$01		; Stop/Pause tune
MUSIC_PLAY		equ	$02		; Continue playing tune (don't use this on a new tune before running MUSIC_START at least once!)
MUSIC_GETENTRY		equ	$03		; Get pointer to tune data (don't upload new data here unless player is stopped!)
MUSIC_GETWAIT		equ	$04		; v1.01 Get number of ticks before next music-sequence update
MUSIC_SETVECT		equ	$05		; v1.01 Set pointer at given address to player-routine
MUSIC_SETUP		equ	$06		; v1.01 Set pointer at given address to player-routine, after saving old value of pointer
MUSIC_CLEANUP		equ	$07		; v1.01 Set pointer at given address to last saved pointer-value

BYTECODE_SONG_END	equ	$03		; Bytecode requiered at end of song data
PLAYER_STOP		equ	$FF		; Value returned by MUSIC_GETWAIT if the player is stopped