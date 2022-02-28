
	include	player\player.inc
	include	synth\synth.inc

	org	PLAYER

	db	'MUSIC102'
;
; Calls to 'routine' runs the player, and it should
; therefore be called at even intervalls.
;
; The preffered way to set up the player is to hook the
; timer interrupt and put a pointer to the old timer
; interrupt-handler in (clkvector).
;
; Controll of the player is done by calling music, or
; the signature+8. The signature is typically located
; at $8000.
;
;
; #######################################################
; #							#
; #  AY-3-8912 Player					#
; #							#
; #######################################################
; #							#
; #  signature: (+0)					#
; #	'MUSICxxx', xxx = version			#
; #							#
; #  music: (+8)					#
; #	a = 0: play, 1: pause, 2: continue, 3: data ptr	#
; #	    4: get wait, 5: setup interrupt vector	#
; #	    6: setup/w old vector, 7: restore old v.	#
; #							#
; #	a:5/6						#
; #	hl = pointer to vector				#
; #							#
; #  routine:						#
; #	(clkvector) = jumps to this routine when done	#
; #							#
; #######################################################

	include	player\player.asm
	include	synth\synth.asm


;
; The music data is compromised of the following
;
;
; #######################################################
; #							#
; #  Music data						#
; #							#
; #######################################################
; #							#
; #  00000000	Wait					#
; #  xxxxxxxx	x ticks					#
; #							#
; #######################################################
; #							#
; #  00000001	Silence synth				#
; #							#
; #######################################################
; #							#
; #  00000010	Stop any arpeggio			#
; #							#
; #######################################################
; #							#
; #  00000011	Absolute end of song			#
; #							#
; #######################################################
; #							#
; #  000001xx	Play instrument x			#
; #  yyyyyyyy	with tone y				#
; #							#
; #######################################################
; #							#
; #  000010xx	Tone-sweep instrument x			#
; #  yyyyyyyy	to tone y				#
; #  zzzzzzzz	using z ticks				#
; #							#
; #######################################################
; #							#
; #  000011xx	End tone on instrument x		#
; #							#
; #######################################################
; #							#
; #  00010xxx   Play an arpeggio using instrument(s) x	#
; #		0-2: Inst A-C, 4-6: Inst A-C + B/C/A	#
; #  aaaaaaaa	with tone a				#
; #  bbbbbbbb	tone b					#
; #  cccccccc	and tone c				#
; #  tttttttt	changing tone every t tick		#
; #							#
; #######################################################
; #							#
; #  00011xxx	Return from layer, discarding x levels	#
; #							#
; #######################################################
; #							#
; #  001xxxxx	Waypoint nr. x marker			#
; #							#
; #######################################################
; #							#
; #  010xxxxx	Set noise frequency divisor to x	#
; #							#
; #######################################################
; #							#
; #  011xxxxx	Sweep noise frequency divisor to x	#
; #  yyyyyyyy	using y ticks				#
; #							#
; #######################################################
; #							#
; #  100abcxx	Set inst. x tone a, noise b and SwE c	#
; #							#
; #######################################################
; #							#
; #  101eeexx	Set envelope for inst. x to peak hold e	#
; #  yyyyzzzz	SwE vol. attack to y and sustain to z	#
; #  aaaaaaaa	SwE attack time	in ticks		#
; #  bbbbbbbb	SwE decay time in ticks			#
; #  cccccccc	SwE release time in ticks		#
; #							#
; #  101eeexx	Set env. for inst. x to native mode e	#
; #	||^----	Hold					#
; #	|^-----	Alternate				#
; #	^------	Attack					#
; #  yyyy0000	HwE Follow settings y	 		#
; #  |||^------	Enable					#
; #  ||^-------	round tone				#
; #  |^--------	add detune				#
; #  ^---------	detune tone instead of env.		#
; #  0000aaaa	HwE Follow Octave shift a (signed)	#
; #  bbbbbbbb	HwE freq. div. high/Follow detune high	#
; #  cccccccc	HwE freq. div. low/Follow detune low	#
; #							#
; #######################################################
; #							#
; #  110xxxxx	Call waypoint nr. x marker		#
; #							#
; #######################################################
; #							#
; #  111xxxxx	Jump to waypoint nr. x marker		#
; #							#
; #######################################################

pointer:
	dw	tune
tune:
	db	$03