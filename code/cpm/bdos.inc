ZEROPAGE		equ	$0000
BDOS_RESET		equ	ZEROPAGE+$00
BDOS			equ	ZEROPAGE+$05
BDOSLOC			equ	ZEROPAGE+$06
DEFAULT_FCB		equ	ZEROPAGE+$5C
FCB_NAME		equ	$01
FCB_T1			equ	$09
FCB_T2			equ	$0A
FCB_T3			equ	$0B
FCB_EX			equ	$0C
FCB_RC			equ	$0F
FCB_CR			equ	$20

FILE_READSIZE		equ	$80


BDOS_P_TERMCPM		equ	$00
BDOS_S_BDOSVER		equ	$0C

BDOS_IO_GET		equ	$07
BDOS_IO_SET		equ	$08

BDOS_C_READ		equ	$01
BDOS_C_WRITE		equ	$02
BDOS_C_RAWIO		equ	$06
BDOS_C_WRITESTR		equ	$09
BDOS_C_READSTR		equ	$0A
BDOS_C_STAT		equ	$0B

BDOS_A_READ		equ	$03
BDOS_A_WRITE		equ	$04
BDOS_L_WRITE		equ	$05

BDOS_DRV_ALLRESET	equ	$0D
BDOS_DRV_SET		equ	$0E
BDOS_DRV_LOGINVEC	equ	$18
BDOS_DRV_GET		equ	$19
BDOS_DRV_ALLOCVEC	equ	$1B
BDOS_DRV_SETRO		equ	$1C
BDOS_DRV_ROVEC		equ	$1D
BDOS_DRV_DPB		equ	$1F
BDOS_DRV_RESET		equ	$25

BDOS_F_OPEN		equ	$0F
BDOS_F_CLOSE		equ	$10
BDOS_F_SFIRST		equ	$11
BDOS_F_SNEXT		equ	$12
BDOS_F_DELETE		equ	$13
BDOS_F_READ		equ	$14
BDOS_F_WRITE		equ	$15
BDOS_F_MAKE		equ	$16
BDOS_F_RENAME		equ	$17
BDOS_F_DMAOFF		equ	$1A
BDOS_F_ATTRIB		equ	$1E
BDOS_F_USERNUM		equ	$20
BDOS_F_READRAND		equ	$21
BDOS_F_WRITERAND	equ	$22
BDOS_F_SIZE		equ	$23
BDOS_F_RANDREC		equ	$24
BDOS_F_WRITEZF		equ	$28