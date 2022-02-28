TDV2115_CUROFF		equ	$01	; * Skru av markør
TDV2115_VIDOFF		equ	$02	; Video av
TDV2115_VIDON		equ	$03	; Video på
TDV2115_ERLINE		equ	$04	; Slett hele linja, flytt markøren til linjestart
TDV2115_ERRLIN		equ	$05	; * Sletter resten av linja, markør flyttes ikke
TDV2115_FRGSK		equ	$06	; * Skift farge på teksten
TDV2115_BELL		equ	$07	; (ASCII) Lydsignal
TDV2115_CURLFT		equ	$08	; (ASCII) Markør til hvenstre
TDV2115_TAB		equ	$09	; (ASCII) [Brukes ikke]
TDV2115_LF		equ	$0A	; (ASCII) Linjeskift (med eventuell scroll)
TDV2115_CURDN		equ	$0B	; (ASCII) Linjeskift (uten scroll)
TDV2115_ROLLUP		equ	$0C	; Rull en linje opp, markør flyttes ikke
TDV2115_CR		equ	$0D	; (ASCII) Til starten av linja
TDV2115_ULINE		equ	$0E	; Underlinje
TDV2115_NORMAL		equ	$0F	; Reset alle modus til vanlig skrift
TDV2115_CURLD		equ	$10	; Flytt markør, etterfølges av Y og X
TDV2115_CUROLD		equ	$11	; * Flytt markør, Y/X offset på 32
TDV2115_IMODE		equ	$12	; * Svart tekst på hvit bakgrunn
TDV2115_INSLIN		equ	$14	; Sett inn ny linje
TDV2115_USASC		equ	$15	; * US-ASCII tegnsett
TDV2115_NASC		equ	$16	; * Norsk-ASCII tegnsett
TDV2115_ROLLDN		equ	$17	; Rull en linje ned, markør flyttes ikke
TDV2115_CURRGT		equ	$18	; Flytt markør til høyre
TDV2115_ERPAGE		equ	$19	; Slett skjerm, markør øverst til venstre
TDV2115_ERRPAG		equ	$1A	; Slett resten av sida, markør flyttes ikke
TDV2115_CURUP		equ	$1C	; Flytt markøren en linje opp
TDV2115_CURHOM		equ	$1D	; Flytt markør øverst til venstre
TDV2115_DELLIN		equ	$1E	; Slett linje
TDV2115_GETMAX		equ	$1F	; Returnerer $1E, linjer+$20, kolonner+$20

TIKI_TIMERINT		equ	$16

TIKI_SECS		equ	$FF92
TIKI_MINS		equ	$FF93
TIKI_HRS		equ	$FF94