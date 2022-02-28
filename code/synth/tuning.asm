;
; Get the tune of a tone
;
; Input tone in b
; Resulting tune in DE
;
getTune:
	sra	b		; Separate tone and octave
	rra
	sra	b
	rra
	sra	b
	rra
	sra	b
	rra
	sra	b
	rra
	rra
	rra
	and	$3E
	ld	d,$00
	ld	e,a
	ld	hl,tonetable	; Get tune
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,b
	and	$07
	ld	b,a		; Shift frequency
	ret	z
	ex	de,hl
	push	af
octaveshift:
	pop	af
	sra	h
	rr	l
	push	af
	djnz	octaveshift
	ld	de,$0000
	pop	af
	adc	hl,de
	ex	de,hl
	ret

tonetable:
;
; All tones in the table are in the 1 scale.
; That is; A = A1 and C = C1
;
;------------------------------------
; 00: Equal-Temperament
;
;	Typical scale, A4 = 438Hz @ 2MHz
;
	dw	$0F00	; C  (EqT)
	dw	$0E28	; C# (EqT)
	dw	$0D5D	; D  (EqT)
	dw	$0C9D	; D# (EqT)
	dw	$0BE8	; E  (EqT)
	dw	$0B3D	; F  (EqT)
	dw	$0A9B	; F# (EqT)
	dw	$0A03	; G  (EqT)
	dw	$0973	; Ab (EqT)
	dw	$08EB	; A  (EqT)
	dw	$086B	; Bb (EqT)
	dw	$07F2	; B  (EqT)

;------------------------------------
; 12: Harmonically correct thirds
;
;	Used for chords
;
	dw	$08FD	; A  (major 3rd F)
	dw	$0C00	; E  (major 3rd C)
	dw	$0802	; B  (major 3rd G)
	dw	$0F1E	; C  (major 3rd Ab)

	dw	$0B23	; F  (minor 3rd D)
	dw	$0EDD	; C  (minor 3rd A)
	dw	$09EC	; G  (minor 3rd E)
	dw	$0C80	; Eb (minor 3rd C)

;------------------------------------
; 20: Perfect fifths
;
;	Used for power-chords and chords
;
	dw	$0A00	; G  (perfect 5th C)
	dw	$0970	; Ab (perfect 5th C#)
	dw	$08E9	; A  (perfect 5th D)
	dw	$0869	; Bb (perfect 5th D#)
	dw	$07F0	; B  (perfect 5th E)
	dw	$0EFC	; C  (perfect 5th F)
	dw	$0E24	; C# (perfect 5th F#)
	dw	$0D59	; D  (perfect 5th G)
	dw	$0C99	; D# (perfect 5th G#)
	dw	$0BE4	; E  (perfect 5th A)
	dw	$0B3A	; F  (perfect 5th A#)
	dw	$0A98	; F# (perfect 5th B)