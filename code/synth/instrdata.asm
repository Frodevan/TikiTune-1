	dw	$0FFF	; 00 current Tune
	dw	$0000	; 02 TSweep current t
	dw	$0000	; 04 TSweep dT
	dw	$0000	; 06 TSweep dt
	dw	$0000	; 08 TSweep D
	dw	$0000	; 0A TSweep a

	dw	$0000	; 0C current Volume
	dw	$0000	; 0E VSweep current t
	dw	$0000	; 10 VSweep dV
	dw	$0000	; 12 VSweep dt
	dw	$0000	; 14 VSweep D
	dw	$0000	; 16 VSweep a

	db	$01	; 18 SwE t (1) attack
	db	$01	; 19 SwE t (3) decay (to sustain)
	db	$01	; 1A SwE t (0) release (to silent)
	db	$FF	; 1B SwE v attack (7-4) & v sustain (3-0)
	dw	$FFFF	; 1C HwE tune
	db	$01	; 1E 7 Hardware/Software envelope
			;    6 Tone
			;    5 Noise
			;    4 SwE stage 1
			;    3 SwE stage 0
			;    2 HwE attack
			;    1 HwE alternate
			;    0 HwE hold
	db	$00	; 1F SwE t (2) attack hold
	db	$00	; 20 7   HwE follow tone
			;    6   HwE follow round played tone to match
			;    5   HwE follow add HwE detune
			;    0-4 HwE follow octave shift (-4 = min, +4 = same, +12 = max)