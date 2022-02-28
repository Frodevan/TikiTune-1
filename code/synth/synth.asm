TIKI			equ	0
SPECTRUM		equ	1
AMSTRAD			equ	2

IF NOT DEFINED SYSTEM
SYSTEM			equ	TIKI
ENDIF

; #######################################################
; #							#
; #  AY-3-8910 Synthesizer for Z80			#
; #							#
; #######################################################
;
; Version 1.01
; by Frode van der Meeren
; January 2015
;
; Overview:
;
; This synthesizer is designed to take full use of the
; AY-3-8910's native features. It presents each of the
; three channels as their own instrument, and it also
; provides additional features like software-envelopes,
; frequency sweeps and an arpeggiator.
;
; There is two full chromatic scales implemented. A
; regular equal-tempered scale and the scale of its
; perfect fifths. Additional tones for harmonic chord
; progression is also present, but care must be taken
; when using these with the tones from the scales.
;
; The synth can be implemented in a lot of applications.
; It can be used as a music player, for realtime sequencing,
; with external music and MIDI equipment, music in games,
; or with anything at all that should need to use the AY
; soundchip.
;
; Instructions:
;
; To run the synth, first make sure to include the right
; interface for the AY chip under AYdrv below. The interface
; is generalized, and your driver must ensure that the
; data reaches correctly to the chip in your particular.
; system. See the documentation below for a description.
;
; The statement on top of this file also has to be updated
; to include and select the new AY system interface.
;
; When the AY interface is in place, make sure to set up
; code that calls synthcycle at a fixed interval. These
; intervals must be very well and evenly timed for best
; performance. The synthcycle routine will keep the
; software envelopes, frequency sweeps and the arpeggiator
; going.
;
; After that is done, call shutup and the synth is ready
; to use. Instruments are by default set to use the hardware
; envelope, so you might want to start by setting up the
; instruments and envelopes. Finally it's time to send music
; messages to play music.
;
; It's always a good idea to call shutup to reset everything
; when the performance is done.
;
;
; PS: Keep interrupts disabled when calling anything in the synth!!
;
;
; #######################################################
; #							#
; #  Control						#
; #							#
; #######################################################
; #							#
; #  synthcycle:					#
; #	n/a						#
; #							#
; #  shutup:						#
; #	n/a						#
; #							#
; #######################################################

synthcycle:
	call	updatenoise
	ld	a,SYNTH_INSTR_A
	call	updateinst
	ld	a,SYNTH_INSTR_B
	call	updateinst
	ld	a,SYNTH_INSTR_C
	call	updateinst
	jp	updatearp



shutup:
	call	endArpeggio
shutup2:
	push	ix
	ld	a,SYNTH_INSTR_A
	call	resetInstrument
	ld	a,SYNTH_INSTR_B
	call	resetInstrument
	ld	a,SYNTH_INSTR_C
	call	resetInstrument
	ld	ix,instrN
	ld	(ix+0),$00
	ld	(ix+1),$00
	ld	a,$06
	ld	b,$02
	ld	c,$00
	call	AYdrv
	ld	(ix+2),$00
	ld	(ix+3),$00
	pop	ix
	ret



;
; The synth has three instruments, where each instrument
; corresponds to one hardware-channel of the AY chip. Each
; instrument has its own proper fully programmable ADSR
; amplitude envelope in software, but it's also possible to
; let an instrument use the hardware envelopes. All the
; instruments also has individual frequency sweep functions.
; 
; When using the hardware envelope, you can choose to have it
; steady at a fixed speed, or you can have it "follow" the
; frequency of the tones played. This can be used to emulate
; a sawtooth-like bass sound. In this "follow" mode a few
; additional options are available, like octave transpose of
; the envelope and detuning of either the squarewave tone or
; the tone of the envelope. It's also possible to round the
; frequency of the tone played to match the closest possible
; envelope frequency.
;
; Any instrument can be set to use the hardware synth, but
; only a single instrument can perform with it at any given
; instant of time. If a new tone is played using the hardware
; envelope, any previously playing tones with hardware envelope
; will be terminated.
;
; Software envelopes trigger on playTone, and if the previous
; tone was not complete, the volume will start from the curent
; volume and not zero for the attack. endTone will however
; always bring the volume towards zero. playTone trigger the
; sequence of attack>hold>decay>sustain, and endTone will
; trigger release from sustain. Attack and sustain volume can
; be set to any of the 16 possible levels.
;
; Envelopes can be updated realtime, but updates will only
; take effect on the first trigger after the update is
; performed. A trigger is an advance in the SwE sequence,
; or any call to playTone or endTone, including calls made
; by the Arpeggiator. The parameters of setEnvelopes varies
; depending on the envelope type selected as well; if HwE is
; active the HwE parameters are updated and when SwE is active
; the SwE parameters are updated.
;
; The parameters for HwE and SwE are stored separately, so
; switching between hardware and software envelopes will not
; destroy previous envelope settings. When an instrument is
; redefined with setInstrument, any tone payed by it will be
; automatically terminated immediately.
;
; Each instrument also has it's own individual frequency
; sweep. This is disabled when the instrument is used in an
; arpeggio though.
;
; Skip to the tone table routines towards the end of this
; file for an overview of the tone-byte format.
;
;
; #######################################################
; #							#
; #  Instrumental					#
; #							#
; #######################################################
; #							#
; #  setInstrument:					#
; #	a = inst (A=0, B=1, C=2)			#
; #	b = tone (Yes=0)				#
; #	c = noise (No=0)				#
; #	d = envelope type (SwE=0)			#
; #							#
; #  setEnvelope:					#
; #	a = inst (A=0, B=1, C=2)			#
; #	b = SwE volume (4-7 att, 0-3 sus)		#
; #	    HwE follow (7 en, 6 round, 5 detune>4 tone)	#
; #	c = SwE attack duration in ticks		#
; #	    HwE follow octave (signed, -8 to 7)		#
; #	d = SwE decay duration in ticks			#
; #	    HwE freq high/detune high			#
; #	e = SwE release duration in ticks		#
; #	    HwE freq low/detune low			#
; #	l = SwE attack hold duration			#
; #	    HwE mode (b0-2 of R13)			#
; #							#
; #  playTone:						#
; #	a = inst (A=0, B=1, C=2)			#
; #	b = tone					#
; #							#
; #  endTone:						#
; #	a = inst (A=0, B=1, C=2)			#
; #							#
; #  sweepTone:						#
; #	a = inst (A=0, B=1, C=2)			#
; #	b = tone					#
; #	c = sweep duration in ticks			#
; #							#
; #######################################################

	include	synth\instruments.asm



;
; The hardware noise of the AY can be set and tuned totally
; independent from the rest of the synth, but it is the
; settings of the instruments that define how noise will
; be used.
;
;
; #######################################################
; #							#
; #  Noise Generator					#
; #							#
; #######################################################
; #							#
; #  setNoise:						#
; #	a = tune (0 = bright, 31 = dark)		#
; #							#
; #  sweepNoise:					#
; #	a = tune (0 = bright, 31 = dark)		#
; #	b = sweep duration in ticks			#
; #							#
; #######################################################

	include	synth\noise.asm



;
; One arpeggio can be played at any time. The arpeggio
; will use one or two instruments, and is maintained
; using timed playTone calls. When an arpeggio is ended,
; all involved instruments will be sendt an endTone.
;
; Make sure to use a fast envelope for a fast arpeggio!
;
;
; #######################################################
; #							#
; #  Arpeggiator					#
; #							#
; #######################################################
; #							#
; #  playArpeggio:					#
; #	a = inst (0=A, 1=B, 2=C, 4=AB, 5=BC, 6=CA)	#
; #	b/c/d = tones in arpeggio			#
; #	e =  ticks per tone				#
; #							#
; #  endArpeggio:					#
; #	n/a						#
; #							#
; #######################################################

	include	synth\arpeggio.asm



;
; The tone ranges from C1 to B8. It should be noted that
; the brighter resolution is rather weak, so you might
; not want to use the top octave (C8-B8).
;
; The 5ths scale is a perfect 5th up from the chromatic
; Equal-tempered scale. This is not the same as an equal-
; tempered fifth. These are used mainly for power-chords.
;
; The remaining tones are thirds for harmonic triads.
;
;
; #######################################################
; #							#
; #  Tone-table lookup					#
; #							#
; #######################################################
; #							#
; #  Tone Byte-Format					#
; #	oooTTTTT: o = octave tr. (0-7), T = tone (0-31)	#
; #							#
; #  Tones						#
; #	 0-11 = Chromatic scale from C1 to B1		#
; #	20-31 = 5ths from G1 to F#1 (transposing at C)	#
; #	   12 = A (Major third in F)			#
; #	   13 = E (Major third in C)			#
; #	   14 = B (Major third in G)			#
; #	   15 = C (Major third in Ab)			#
; #	   16 = F (Minor third in D)			#
; #	   17 = C (Minor third in A)			#
; #	   18 = G (Minor third in E)			#
; #	   19 = Eb (Minor third in C)			#
; #							#
; #######################################################

	include synth\tuning.asm



;
; Add a conditional include with your own code for your
; own hardware. The software interface is simple, so this
; should be trivial. Whenever the synth speaks to the
; AY chip, it just calls AYdrv with the given registers
; set. You will need to set equate SYSTEM to one of the
; presented options in the synth.inc file.
;
;
; #######################################################
; #							#
; # AY-3-8912 interface					#
; #							#
; #######################################################
; #							#
; #  AYdrv:						#
; #	a = AY-register					#
; #	b = Operation (1=IN, 2=OUT, 3=AND, 4=OR, 5=XOR)	#
; #	c = Data out					#
; #	ret d = Data in					#
; #							#
; #	All other registers than D are preserved	#
; #							#
; #######################################################

AYdrv:
	IF SYSTEM EQ TIKI
		include	synth\tiki100ay.asm
	ENDIF
	IF SYSTEM EQ SPECTRUM
		include synth\zxspectrumay.asm
	ENDIF
	IF SYSTEM EQ AMSTRAD
		include	synth\amstradcpcay.asm
	ENDIF



;
; Used for frequency skew and the software envelopes.
;
;
; #######################################################
; #							#
; #  Linear function plotter				#
; #							#
; #######################################################

	include	synth\linear.asm