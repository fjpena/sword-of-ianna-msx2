; VDP routines

; BIOS definitions

VDPREG    	EQU  $F3DF          	; REG 0 of VDP
WRTVDP		EQU  $0047		; Write B to VDP register C
CHGMOD		EQU $005F		; set screen mode

; VRAM definitions
CHRTBL	equ	#0000
NAMTBL	equ	#1800
CLRTBL	equ	#2000
SPRTBL	equ	#f800	;#3800
SPRATR	equ	#7400	;#1b00

NAME_TBL	equ	NAMTBL		; Name table
COLOR_TBL	equ	CLRTBL		; Color table
PATTERN_TBL	equ	CHRTBL		; Pattern generator table

SPR_ATTR	equ	SPRATR		; Sprite attribute table
SPR_PATTERN	equ	SPRTBL		; Sprite Pattern generator table

SPR_COLOR	equ	#2000		; Sprite Color table
	
VR0_EXTVDP	equ	%00000001	; External VDP disable
VR0_GFX1M	equ	%00000000	; M3 Graphics I mode
VR0_GFX2M	equ	%00000010	; M3 Graphics II mode
VR0_MCOLM	equ	%00000000	; M3 Multicolor mode
VR0_TEXTM	equ	%00000000	; M3 Text mode

VR1_16K_4K	equ	%10000000	; VRAM size (0 = 4k, 1 = 16k)
VR1_ENABLE	equ	%01000000	; Display enable
VR1_DISABLE equ %10111111	; Display disable
VR1_IE		equ	%00100000	; Interrupt enable
VR1_GFX1M	equ	%00000000	; Graphics I mode
VR1_GFX2M	equ	%00000000	; Graphics II mode
VR1_MCOLM	equ	%00001000	; Multicolor mode
VR1_TEXTM	equ	%00010000	; Text mode
VR1_SPRSIZ	equ	%00000010	; Sprite size (0 = 8x8, 1 = 16x16)
VR1_SPRMAG	equ	%00000001	; Sprite magnification ( 0 = 1x, 1 = 2x)

; Offset commands registers
VDP_SX		 EQU 0
VDP_SY		 EQU 2
VDP_DX		 EQU 4
VDP_DY		 EQU 6
VDP_NX		 EQU 8
VDP_NY		 EQU 10
VDP_COLOR	 EQU 12
VDP_ARGUMENT EQU 13
VDP_COMMAND	 EQU 14

; Offset for sprite commands from memory


; VDP Commands
CMD_YMMM	equ	$e0
CMD_HMMM	equ	$d0
CMD_HMMV	equ	$c0
CMD_LMMM	equ	$98
CMD_LMMC	equ $b0
CMD_LMMV    equ $80

; Logical operations
VDP_IMP		equ	%0000
VDP_AND		equ	%0001
VDP_OR		equ	%0010
VDP_XOR		equ	%0011
VDP_NOT		equ	%0100
VDP_TIMP	equ	%1000
VDP_TAND	equ	%1001
VDP_TOR		equ	%1010
VDP_TXOR	equ	%1011
VDP_TNOT	equ	%1100

; Tile
TILE_WIDTH			equ	16
TILE_HEIGHT			equ	16
TILES_PAGE			equ	2		; Page where tiles are stored
TILES_START_ADDR 	equ $8000  ; Tiles in ROM will be loaded at $8000, so we can load them to VRAM
BACK_BUFFER			equ 1		; we will draw to page 1
FRONT_BUFFER		equ 0		; then copy to page 0
; Sprites
SPRITE_WIDTH		equ	24
SPRITE_HEIGHT		equ	32
SPRITE_START_ADDR 	equ $8000
; Font
FONT_PAGE			equ 0
FONT_WIDTH			equ 8
FONT_HEIGHT			equ 8
; Weapon
WEAPON_PAGE			equ 3

; Initalize SCREEN 5 mode, with 16x16 sprites, no magnification, black backdrop, 256x192

init_screen5:
	ld a, 5
	call CHGMOD
    ld bc, $E201
    call WRTVDP	; set 16x16 sprites, no magnification
    ld bc, $0107
    call WRTVDP	; black backdrop
    ld a, ($2b) ; get NTSC/PAL timing
    and $80
    jr nz, init_screen5_PAL
init_screen5_NTSC:
    ld bc, $0009 ;192 lines, NTSC timing
    ld a, 6
    jr init_screen5_common
init_screen5_PAL:
	ld bc, $0209 ; 192 lines, PAL timing
    ld a, 5
init_screen5_common:
    ld (frames_lock), a ; used by the engine
	call WRTVDP	        ; set 192 lines and required timing
	ld bc, $2A08
	call WRTVDP ; no hardware sprites, color 0 is the palette 0
	ret

;Activate/Deactivate VDP
;IN:N/A
;OUT:N/A

VDP_ActDeact:  	
	LD      A,(VDPREG+1)
   XOR     01000000B
	LD	B, A
	LD      C, 1
	CALL    WRTVDP
    RET

; Write palette
; Warning, it assumes interrupts are enabled on entry!!!!
; HL: palette

VDP_SetPalette:
	ld c, 	$99		; first VDP write register
	di			; interrupts could screw things up
	xor	a		; from color 0
	out	(c),a
	ld	a,128+16	; write R#16
	out	(c),a
	ei
	inc	c		; prepare to write palette data, to port 0x9A
	ld	b,32		; 16 color * 2 bytes for palette data
	otir				
	ret


; Write palette
; Warning, it assumes interrupts are DISabled on entry!!!!
; HL: palette

VDP_SetPalette_DI:
	ld c, 	$99		; first VDP write register
	xor	a		; from color 0
	out	(c),a
	ld	a,128+16	; write R#16
	out	(c),a
	inc	c		; prepare to write palette data, to port 0x9A
	ld	b,32		; 16 color * 2 bytes for palette data
	otir				
	ret


;---------------------------------------------------------------------------
; Init the RAM buffer used to draw a tile
;---------------------------------------------------------------------------
initVDPBuffers:
		ld	hl,tileDatROM
		ld	de,tileDat
		ld	bc,15
		ldir
		ld	hl,fgtileDatROM
		ld	de,fgtileDat
		ld	bc,15
		ldir
		ld	hl,vdpCmdSpriteROM
		ld	de,vdpCmdSprite
		ld	bc,15
		ldir
		ld	hl,dirtyTileDatROM
		ld	de,dirtyTileDat
		ld	bc,15
		ldir
		ld	hl,charDatROM
		ld	de,charDat
		ld	bc,15
		ldir
		ld	hl,charDat2ROM
		ld	de,charDat2
		ld	bc,15
		ldir
		ld	hl,charDat3ROM
		ld	de,charDat3
		ld	bc,15
		ldir
		ld	hl,fillDatROM
		ld	de,fillDat
		ld	bc,15
		ldir
		ld	hl,vdpCmdWeaponROM
		ld	de,vdpCmdWeapon
		ld	bc,15
		ldir
		ld	hl,linemoveDatROM
		ld	de,lineMoveDat
		ld	bc,15
		ldir
		ld	hl,vdpCopyDatROM
		ld	de,vdpCopyDat
		ld	bc,15
		ldir
		ld	hl,scoreDatROM
		ld	de,scoreDat
		ld	bc,15
		ldir
		ret
		

;---------------------------------------------------------------------------
; Draw a tile
; INPUT:
;	A = Tile number
;	B = dest X
;	C = dest Y
;---------------------------------------------------------------------------
drawTile:
		ld	e,a
		and	#f
		rlca
		rlca
		rlca
		rlca
		ld	(tileDat+VDP_SX),a	; X origin
		ld	a,e
		and	#f0
		ld	(tileDat+VDP_SY),a	; Y origin
		ld a, b
		ld  (tileDat+VDP_DX), a	; X destination
		ld a, c
		ld  (tileDat+VDP_DY), a ; Y destination
		ld	hl,tileDat
		jp	VDPcmd


;---------------------------------------------------------------------------
; Draw a foreground tile
; INPUT:
;	A = Tile number
;	B = dest X
;	C = dest Y
;---------------------------------------------------------------------------
drawFGTile:
		ld	e,a
		and	#f
		rlca
		rlca
		rlca
		rlca
		ld	(fgtileDat+VDP_SX),a	; X origin
		ld	a,e
		and	#f0
		ld	(fgtileDat+VDP_SY),a	; Y origin
		ld a, b
		ld  (fgtileDat+VDP_DX), a	; X destination
		ld a, c
		ld  (fgtileDat+VDP_DY), a ; Y destination
		ld	hl,fgtileDat
		jp	VDPcmd

;---------------------------------------------------------------------------
; Draw a weapon in the score area
; INPUT:
;	A = start X
;	B = dest X
;	C = dest Y
;---------------------------------------------------------------------------
drawWeapon:
		ld	(vdpCmdWeapon+VDP_SX),a	; X origin
		ld  a, 192
		ld	(vdpCmdWeapon+VDP_SY),a	; Y origin
		ld a, b
		ld  (vdpCmdWeapon+VDP_DX), a	; X destination
		ld a, c
		ld  (vdpCmdWeapon+VDP_DY), a ; Y destination
		ld	hl,vdpCmdWeapon
		jp	VDPcmd

;---------------------------------------------------------------------------
; Draw a char 
; INPUT:
;	A = Char
;	B = dest X (char)
;	C = dest Y (char)
;---------------------------------------------------------------------------
drawChar:
		sub 32	; make it base 0
		push af
		cp 32
		jr nc, drawChar_morethan32	; higher than 32
		ld a, 192
		jr drawChar_common
drawChar_morethan32:
		ld a, 200
drawChar_common:
		ld	(charDat+VDP_SY), a	; Y origin
		pop af
		add a, a
		add a, a
		add a, a	; *8
		ld	(charDat+VDP_SX),a	; X origin
		ld a, b
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat+VDP_DX), a	; X destination
		ld a, c
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat+VDP_DY), a ; Y destination
		ld	hl, charDat
		jp	VDPcmd

;---------------------------------------------------------------------------
; Draw a char directly to the front buffer
; INPUT:
;	A = Char
;	B = dest X (char)
;	C = dest Y (char)
;---------------------------------------------------------------------------
drawCharFront:
		sub 32	; make it base 0
		push af
		cp 32
		jr nc, drawCharFront_morethan32	; higher than 32
		ld a, 192
		jr drawCharFront_common
drawCharFront_morethan32:
		ld a, 200
drawCharFront_common:
		ld	(charDat2+VDP_SY), a	; Y origin
		pop af
		add a, a
		add a, a
		add a, a	; *8
		ld	(charDat2+VDP_SX),a	; X origin
		ld a, b
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat2+VDP_DX), a	; X destination
		ld a, c
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat2+VDP_DY), a ; Y destination
		ld	hl, charDat2
		jp	VDPcmd


;---------------------------------------------------------------------------
; Draw a char with transparency
; INPUT:
;	A = Char
;	B = dest X (char)
;	C = dest Y (char)
;---------------------------------------------------------------------------
drawCharTrans_front:
		push af
		ld a, FRONT_BUFFER
		jr drawCharTrans_both
drawCharTrans:
		push af
		ld a, BACK_BUFFER
drawCharTrans_both:
		ld (charDat3+VDP_DY+1), a
		pop af
		sub 32	; make it base 0
		push af
		cp 32
		jr nc, drawCharTrans_morethan32	; higher than 32
		ld a, 208
		jr drawCharTrans_common
drawCharTrans_morethan32:
		ld a, 216
drawCharTrans_common:
		ld	(charDat3+VDP_SY), a	; Y origin
		pop af
		add a, a
		add a, a
		add a, a	; *8
		ld	(charDat3+VDP_SX),a	; X origin
		ld a, b
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat3+VDP_DX), a	; X destination
		ld a, c
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat3+VDP_DY), a ; Y destination
		ld a, FONT_HEIGHT
		ld (charDat3+VDP_NY), a
		ld	hl, charDat3
		jp	VDPcmd



;---------------------------------------------------------------------------
; Draw a char with transparency, double size
; INPUT:
;	A = Char
;	B = dest X (char)
;	C = dest Y (char)
;---------------------------------------------------------------------------
drawCharTrans_Double:
		sub 32	; make it base 0
		push af
		cp 32
		jr nc, drawCharTransDouble_morethan32	; higher than 32
		ld a, 208
		jr drawCharTransDouble_common
drawCharTransDouble_morethan32:
		ld a, 216
drawCharTransDouble_common:
		ld	(charDat3+VDP_SY), a	; Y origin
		ld a, BACK_BUFFER
		ld (charDat3+VDP_DY+1), a   ; we are reusing charDat3, remember to use the back buffer here
		pop af
		add a, a
		add a, a
		add a, a	; *8
		ld	(charDat3+VDP_SX),a	; X origin
		ld a, b
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat3+VDP_DX), a	; X destination
		ld a, c
		add a, a
		add a, a
		add a, a	; *8
		ld  (charDat3+VDP_DY), a ; Y destination
		ld a, 1
		ld (charDat3+VDP_NY), a
		ld a, 8
dct_loop:
		push af
		ld	hl, charDat3
		call	VDPcmd
		ld  a, (charDat3+VDP_DY) ; Y destination
		inc a
		ld  (charDat3+VDP_DY), a ; Y destination
		ld	hl, charDat3
		call	VDPcmd
		ld  a, (charDat3+VDP_DY) ; Y destination
		inc a
		ld  (charDat3+VDP_DY), a ; Y destination
		ld  a, (charDat3+VDP_SY) ; Y destination
		inc a
		ld  (charDat3+VDP_SY), a ; Y destination
		pop af
		dec a
		jr nz, dct_loop
		ret

;---------------------------------------------------------------------------
; Copy a dirty tile to the front buffer
; INPUT:
;	B = X tile
;	C = Y tile
;---------------------------------------------------------------------------
CopyTile:
		ld a, b
		rlca
		rlca
		rlca
		rlca
		ld	(dirtyTileDat+VDP_SX),a	; X origin
		ld  (dirtyTileDat+VDP_DX),a	; X destination
		ld a, c
		rlca
		rlca
		rlca
		rlca
		ld	(dirtyTileDat+VDP_SY),a	; Y origin
		ld  (dirtyTileDat+VDP_DY),a ; Y destination
		ld	hl,dirtyTileDat
		jp	VDPcmd

;---------------------------------------------------------------------------
; Move part of a line in the VDP
; INPUT:
;	A = pixel offset (+1, -1, ...)
;	B = X start
;	C = Y start
;---------------------------------------------------------------------------
MoveLine:
	push af
	and $80		; is it a negative number?

	jr z, MoveLine_positive
MoveLine_negative:
	pop af
	neg		; make it positive 
	ld	(lineMoveDat+VDP_SX),a	; X origin
	xor a
	ld  (lineMoveDat+VDP_DX),a	; X destination	
	ld a, c
	ld	(lineMoveDat+VDP_SY),a	; Y origin
	ld  (lineMoveDat+VDP_DY),a ; Y destination
	xor a
	ld	(lineMoveDat+VDP_ARGUMENT),a
	jr MoveLine_common		
MoveLine_positive:
	pop af
	add a, 252
	ld  (lineMoveDat+VDP_DX),a	; X destination	
	ld a, 252
	ld	(lineMoveDat+VDP_SX),a	; X origin
	ld a, c
	ld	(lineMoveDat+VDP_SY),a	; Y origin
	ld  (lineMoveDat+VDP_DY),a ; Y destination
	ld a, 4
	ld	(lineMoveDat+VDP_ARGUMENT),a
MoveLine_common:
	ld	hl,lineMoveDat
	jp	VDPcmd





;---------------------------------------------------------------------------
; Set VDP command
; In: HL = VDP command data
;---------------------------------------------------------------------------
VDPcmdDat:
	ld	hl,cmdDat
VDPcmd:
	di
	ld	a,32		; Primer registro que contiene los datos del comando     
	out	(#99),a
	ld	a,#91		; Control register (R#17)
	out	(#99),a
	ld	bc,#f9b		; B = 15 bytes data, C = VDP port 3
VDPcmd2:
	ld	a,2		; Status register #2
	out	(#99),a
	ld	a,#8f		; Status register pointer
	out	(#99),a		; Set status register to read    
	in	a,(#99)
	rrca
	jp	c,VDPcmd2
	otir			; envia datos y comando a ejecutar
	xor	a		; Status register #0
	out	(#99),a
	ld	a,#8f		; Status register pointer
	out	(#99),a
	ei
	ret

;---------------------------------------------------------------------------
; Set VDP command, assuming interrupts are disabled
; In: HL = VDP command data
;---------------------------------------------------------------------------
VDPcmdDat_DI:
	ld	hl,cmdDat
VDPcmd_DI:
	ld	a,32		; Primer registro que contiene los datos del comando     
	out	(#99),a
	ld	a,#91		; Control register (R#17)
	out	(#99),a
	ld	bc,#f9b		; B = 15 bytes data, C = VDP port 3
VDPcmd2_DI:
	ld	a,2		; Status register #2
	out	(#99),a
	ld	a,#8f		; Status register pointer
	out	(#99),a		; Set status register to read    
	in	a,(#99)
	rrca
	jp	c,VDPcmd2_DI
	otir			; envia datos y comando a ejecutar
	xor	a		; Status register #0
	out	(#99),a
	ld	a,#8f		; Status register pointer
	out	(#99),a
	ret



;--------------------------------------------------------------
; Wait until the VDP finishes an existing command
;--------------------------------------------------------------

waitVDP:
	di
	ld	a,2		; Status register #2
	out	(#99),a
	ld	a,#8f		; Status register pointer
	out	(#99),a		; Set status register to read    
	in	a,(#99)
	and	1
	ld	a,0
	out	(#99),a
	ld	a,#8f
	out	(#99),a
	ei
	jr	nz,waitVDP
	ret

;---------------------------------------------------------------------------
; Set page to display
; INPUT:
;	A: Page to display
;---------------------------------------------------------------------------
setDisplayPage:
	rrca
	rrca
	rrca
	or	%11111
	di
	out	($99),a
	ld	a,$82		; Pattern name table base address register
	out	($99),a
	ei
	ret



;---------------------------------------------------------------------------
; Enable display
;---------------------------------------------------------------------------
screenOn:	
		ld	a,(VDPREG+1)
		or	VR1_ENABLE
		ld	(VDPREG+1),a
		di
		out	(#99),a
		ld	a,#81
		out	(#99),a
		ei
		ret


;---------------------------------------------------------------------------
; Disable display
;---------------------------------------------------------------------------
screenOff:
		ld	a,(VDPREG+1)
		and	VR1_DISABLE
		ld	(VDPREG+1),a
		di
		out	(#99),a
		ld	a,#81
		out	(#99),a
		ei
		ret

;---------------------------------------------------------------------------
; Copy from VRAM page 1 to another one
; in:
;	A = destination
;---------------------------------------------------------------------------
copyPage:
		ei
		halt
		ld	hl, copyPageDat
		call	copyVDPcmd
		ld	(cmdDat+VDP_DY+1),a		; Página de destino
		jp	VDPcmdDat
copyPageDat:
		db	0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, CMD_YMMM

;---------------------------------------------------------------------------
; Copy from VRAM page in B to page in A
; in:
;	A = destination
;   B = source
;---------------------------------------------------------------------------
copyPage_generic:
		ei
		halt
		push bc
		ld	hl, copyPageDat
		call	copyVDPcmd
		ld	(cmdDat+VDP_DY+1),a		; Página de destino
		pop bc
		ld a, b
		ld	(cmdDat+VDP_SY+1),a		; Página de origen
		ld a, 192
		ld (cmdDat+VDP_NY), a
		xor a
		ld (cmdDat+VDP_NY+1), a
		jp	VDPcmdDat

;---------------------------------------------------------------------------
; Copy data between VRAM areas
;	B = source X (in pixels)
;	C = source Y (in pixels)
;   D = number of pixels in X
;   E = number of pixels in Y
;   H = destination X (in pixels)
;   L = destination Y (in pixels)
; IXH = source buffer -> 1: back buffer, 0: front buffer
; IXY = dest buffer   -> 1: back buffer, 0: front buffer
;---------------------------------------------------------------------------
vdpCompose:
	ld a, CMD_LMMM | VDP_TIMP
	ld (vdpCopyDat+VDP_COMMAND),a	; command
	jr vdpCopy_common
vdpCopy:
	ld a, CMD_HMMM
	ld (vdpCopyDat+VDP_COMMAND),a	; command
vdpCopy_common:
	ld a, b
	ld (vdpCopyDat+VDP_SX),a	; X origin
	ld a, h
	ld (vdpCopyDat+VDP_DX),a	; X destination
	ld a, c
	ld (vdpCopyDat+VDP_SY),a	; Y origin
	ld a, l
	ld (vdpCopyDat+VDP_DY),a	; Y destination
	ld a, d
	ld (vdpCopyDat+VDP_NX),a	; number of pixels in X
	ld a, e
	ld (vdpCopyDat+VDP_NY),a	; number of pixels in Y
	ld a, ixh
	ld (vdpCopyDat+VDP_SY+1),a	; source buffer
	ld a, ixl
	ld (vdpCopyDat+VDP_DY+1),a	; destination buffer
	ld hl,vdpCopyDat
	jp	VDPcmd

;---------------------------------------------------------------------------
; Cleanup the buffer used to send a command to the VDP
;---------------------------------------------------------------------------
clearVDPcmd:
		ld	hl,cmdDat-1
		ld	(hl),0
copyVDPcmd:
		ld	de,cmdDat
		ld	bc,15
		ldir
		ret

;---------------------------------------------------------------------------
; Fill an area with a color
;   A = color (we can use two nibbles)
;	B = X (in pixels)
;	C = Y (in pixels)
;   D = number of pixels in X
;   E = number of pixels in Y
;   H = 1: back buffer, 0: front buffer
;---------------------------------------------------------------------------
fillArea_slow:
    push af
    ld a, CMD_LMMV
    jr fillArea_common
fillArea:
    push af
    ld a, CMD_HMMV
fillArea_common:
    ld (fillDat+VDP_COMMAND), a
    pop af
    ld (fillDat+VDP_COLOR), a
    ld a, b
    ld (fillDat+VDP_DX), a
    ld a, c
    ld (fillDat+VDP_DY), a
    ld a, d
    ld (fillDat+VDP_NX), a
    ld a, e
    ld (fillDat+VDP_NY), a
    ld a, h
    ld (fillDat+VDP_DY+1), a
	ld	hl, fillDat
	jp	VDPcmd

;---------------------------------------------------------------------------
; Draw a sprite
;	A = direction: 0-look right, 1-look left
;	B = dest X
;	C = dest Y
;	HL = address in RAM
;---------------------------------------------------------------------------
drawSprite:
		ex af, af'
		ld	a,(hl)
		ld	(vdpCmdSprite+VDP_COLOR),a
		ex af, af'		; restore direction
		rlca
		rlca			; X direction
		ld	(vdpCmdSprite+VDP_ARGUMENT),a
		or	a
		ld	e, 0
		jr	z,drawSprite_noFlip
		ld	e, SPRITE_WIDTH-1
		
drawSprite_noFlip:
		ld	a, b
		add	a, e
		ld	(vdpCmdSprite+VDP_DX),a	; X destination
		ld	a, c
		ld	(vdpCmdSprite+VDP_DY),a	; Y destination
		di
		push	hl
		ld	hl, vdpCmdSprite
		call	VDPcmd_DI
		pop	hl
;		call	sendSpriteGfx
;---------------------------------------------------------------------------
; Send the sprite pixels from ROM to  VDP
;---------------------------------------------------------------------------
sendSpriteGfx:
		ld	a,#80+44	; R#44 = Color register
		out	(#99), a
		ld	a,#80+17
		out	(#99), a
		ld	c, #9b
		
		rld
        out (c), a		; right pixel of the first byte
        inc hl

        ld    e,32        ; NY
sendSpriteGfx_loop:
        REPT    12        ; NX
        rld
        outi         
        out    (c),a
        ENDM     
        dec    e      
        jp    nz, sendSpriteGfx_loop
        ei
        ret

;---------------------------------------------------------------------------
; Draw a score on/off tile
;	A = 0: off, 1:on
;	B = dest X
;	C = dest Y
;---------------------------------------------------------------------------
drawScoreOnOff:
		and a
		jr nz, drawScoreOn		
		ld a, 128
		jr drawScoreOnOff_common
drawScoreOn:
		ld a, 152
drawScoreOnOff_common:
		ld	(scoreDat+VDP_SX),a	; X origin
		ld  a, 192
		ld	(scoreDat+VDP_SY),a	; Y origin
		ld a, b
		ld  (scoreDat+VDP_DX), a	; X destination
		ld a, c
		ld  (scoreDat+VDP_DY), a ; Y destination
		ld	hl, scoreDat
		jp	VDPcmd

;---------------------------------------------------------------------------
; Fade out
;---------------------------------------------------------------------------
fadeMSX2:
	ld hl, tilespal	; copy the default palette
	ld de, currentPal
	ld bc, 32
	ldir
	ld e, 7			; do it 7 times
loop_fademsx2:
	ld d, 16		; 16 words per palette
	ld hl, currentPal
decpalette:	
	ld a, (hl)	
	ld b, a			
	and $f0		; get the high nibble
	jr z, nodecrement2
	sub $10		; substract 1 from the high nibble		
nodecrement2:
	ld c, a			; and store it on C
	ld a, b
	and $0f		; get the low nibble
	jr z, nodecrement3	
	dec a			; decrement if not 0
nodecrement3:	
	or c			; combine the high and low nibbles
	ld (hl), a		; and send it back to the array	
	inc hl	
	ld a, (hl)		; this time we need 2 nibbles	
	or a			; is a == 0?
	jr z, nodecrement
	dec a
	ld (hl), a		; write the decremented value
nodecrement:
	inc hl
	dec d
	jr nz, decpalette 	; same for all 16 words
	halt
	halt
	halt
	halt	
	ld hl, currentPal
	call VDP_SetPalette	; write the new palette
	dec e
	jr nz, loop_fademsx2	
	ret


;---------------------------------------------------------------------------
; Fade in
;---------------------------------------------------------------------------
fadeinMSX2:
	ld hl, blackpal	; copy the black palette
	ld de, currentPal
	ld bc, 32
	ldir
	ld e, 7			; do it 7 times
loop_fadeinmsx2:
    push de
	ld a, 16		; 16 words per palette
	ld de, currentPal
    ld hl, tilespal ; end palette
incpalette:	
    push af
	ld a, (hl)	; target palette
	and $f0		; get the high nibble
	ld b, a	    ; high nibble in A
    ld a, (de)  ; current palette
    and $f0
    cp b        ; if A < B, we need to increment it
    jr nc, noincrement2
	add a, $10		; add 1 to the high nibble		
noincrement2:
	ld c, a			; and store it on C
	ld a, (hl)	; target palette
	and $0f		; get the low nibble
	ld b, a	    ; low nibble in A
    ld a, (de)  ; current palette
    and $0f
    cp b        ; if A < B, we need to increment it
    jr nc, noincrement3
	inc a			; increment if target not reached
noincrement3:	
	or c			; combine the high and low nibbles
	ld (de), a		; and send it back to the array	
	inc hl	
    inc de
	ld a, (de)		; this time we need 2 nibbles	
    cp (hl)			; have we reached the target?
	jr z, noincrement
	inc a
	ld (de), a		; write the decremented value
noincrement:
	inc hl
    inc de
    pop af
	dec a
	jr nz, incpalette 	; same for all 16 words
	halt
	halt
	halt
	halt	
	ld hl, currentPal
	call VDP_SetPalette	; write the new palette
    pop de
	dec e
	jr nz, loop_fadeinmsx2	
	ret

; Set line for horizontal interrupt
; A: line (0-255)
; Disable interrupts before doing this!!!

SetHorInterruptLine:
        ld c,   $99             ; first VDP write register
        out     (c),a           ; write line
        ld      a,128+19        ; write R#19
        out     (c),a
        ex      af, af'
        ret

; Enable/disable horizontal interrupts
; A: 16 (enable) or 0 (disable)
; Disable interrupts before doing this!!!

RG0SAV: EQU $F3DF

EnDisHorInterrupts:
        ld c, a
        ld a, (RG0SAV)
        or c
        ld c, $99
        out (c), a              ; write value
        ld a, 128               ; write R#0
        out (c), a
        ret

