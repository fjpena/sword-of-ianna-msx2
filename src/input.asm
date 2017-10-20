; BIOS definitions used in this module


GTSTCK	EQU $00d5
GTTRIG	EQU $00d8
SNSMAT	EQU $0141

; Constants

joytrans_table db $00,$01,$09,$08,$0a,$02,$06,$04,$05


; Get joystick state, as an OR of the cursors+z+x  and joystick 1 status
; Returns:  
;		A: joystick state
; Bit #:  76  5    4   3210
;         ||  |    |   ||||
;         XX BUT2 BUT1 RLDU
;
; 1 means pressed, 0 means not pressed

get_joystick:
		xor a
   		call GTSTCK			; call the BIOS routine in charge of the joystick, using the keyboard
   		ld hl, joytrans_table
   		ld c,a
   		ld b,0
   		add hl, bc
   		ld c, (hl)	; c has now the proper bitfield   			
		ld a, 1
		push bc
		call GTSTCK			; now read joystick 1
   		ld hl, joytrans_table
   		ld c,a
   		ld b,0
   		add hl, bc
		pop bc
   		ld a, (hl)	; a has now the proper bitfield   			
		or c
		ld c, a		; C has the OR for joystick and cursors
get_trigger1_kb:
   		push bc		; c has the joystick status
		ld hl, KEY_Z
		call get_keyboard
		pop bc
		and a
		jr z, get_trigger1_joy
   		set 4, c	; button pressed
get_trigger1_joy:
		push bc
		ld a, 1
   		call GTTRIG	; get the status for the fire button
		pop bc
   		and a
   		jr z, get_trigger2_kb
   		set 4, c	; button pressed
get_trigger2_kb:
   		push bc		; c has the joystick status
		ld hl, KEY_X
		call get_keyboard
		pop bc
		and a
		jr z, get_trigger2_kb2
		set 5, c	; button pressed
get_trigger2_kb2:
   		push bc		; c has the joystick status
		ld hl, KEY_M
		call get_keyboard
		pop bc
		and a
		jr z, get_trigger2_joy
		set 5, c	; button pressed
get_trigger2_joy:
		push bc
		ld a, 3
   		call GTTRIG	; get the status for the fire buzzon
		pop bc
   		and a
   		jr z, get_joystick_end
   		set 5, c	; button pressed
get_joystick_end:
;		ld a, (action_ack)
;		and a
;		jr nz, get_joystick_ignoreaction
get_joystick_noaction:

;		xor a
;		ld (action_ack), a			; the action button is not pressed anymore
get_joystick_finish:
		ld a, c		; return value in A
;		ret
		jr get_opqa
get_joystick_ignoreaction:
		bit 5, c
		jr z, get_joystick_noaction
		res 5, c
		jr get_joystick_finish



get_opqa:
		push af
		ld c, 0
		push bc
		ld hl, KEY_Q
		call get_keyboard 
		pop bc
		and a
		jr z, get_opqa_down
		set 0, c
get_opqa_down:
		push bc
		ld hl, KEY_A
		call get_keyboard 
		pop bc
		and a
		jr z, get_opqa_left
		set 1, c
get_opqa_left:
		push bc
		ld hl, KEY_O
		call get_keyboard 
		pop bc
		and a
		jr z, get_opqa_right
		set 2, c
get_opqa_right:
		push bc
		ld hl, KEY_P
		call get_keyboard 
		pop bc
		and a
		jr z, get_opqa_fire1
		set 3, c
get_opqa_fire1:
		push bc
		ld hl, KEY_SPACE
		call get_keyboard 
		pop bc
		and a
		jr z, get_opqa_fire2
		set 4, c
get_opqa_fire2:
		push bc
		ld hl, KEY_SHIFT
		call get_keyboard 
		pop bc
		and a
		jr z, get_opqa_end
		set 5, c
get_opqa_end:
		pop af
		or c
		ld c, a
		ld a, (action_ack)
		and a
		jr nz, get_opqa_ignoreaction
get_opqa_noaction:
		xor a
		ld (action_ack), a			; the action button is not pressed anymore
get_opqa_finish:
		ld a, c		; return value in A
		ret
get_opqa_ignoreaction:
		bit 5, c
		jr z, get_opqa_noaction
		res 5, c
		jr get_opqa_finish

; Get state of a key
;
; Input:
;		HL: key, based on the key definitions below
; Returns: 
;	A = 0: key not pressed, 1: pressed

get_keyboard:
	ld a, l
	push hl
	call SNSMAT
	pop hl
	and h
	jr z, key_pressed
	xor a
	ret
key_pressed:
	ld a, 1
	ret

; Scan the keyboard to find a single keypress
; Input: n/a
; Output: key scan code, in A
; Will block until the key is pressed
KeyCodes:
   defb '0','1','2','3','4','5','6','7'
   defb '8','9','-','=','\','[',']',';'
   defb '"','~',',','.','/',255,'a','b'
   defb 'c','d','e','f','g','h','i','j'
   defb 'k','l','m','n','o','p','q','r'
   defb 's','t','u','v','w','x','y','z'
   defb 255,255,255,255,255,255,255,255 ; F3  F2  F1  CODE  CAPS  GRAPH CTRL  SHIFT
   defb 255,255,255,255,255, 0, 255,13; RET  SELECT  BS  STOP  TAB  ESC  F5  F4 (inverted)
   defb 255,255,255,0, 255,255,255,255 ; →  ↓  ↑  ←  DEL  INS  HOME  SPACE (inverted)
   defb 255,255,255,255,255,255,255,255 ; NUM4  NUM3  NUM2  NUM1  NUM0 NUM/  NUM+  NUM*
   defb 255,255,255,255,255,255,255,255 ; NUM.  NUM,  NUM-  NUM9  NUM8 NUM7  NUM6  NUM5

; Read a keyboard row
; INPUT  -> B: row
; OUTPUT -> A: value read from PPI
 
readkbrow:
    ld a, b
    call SNSMAT
	ret

SCAN_KEYBOARD:
    ld b, 0;	; read 10 lines
	ld ix, KeyCodes
scan_loop:
	call readkbrow

	bit 0, a
	jr z, bitzero
	bit 1, a
	jr z, bitone
	bit 2, a
	jr z, bittwo
	bit 3, a
	jr z, bitthree
	bit 4, a
	jr z, bitfour
	bit 5, a
	jr z, bitfive
	bit 6, a
	jr z, bitsix
	bit 7, a
	jr z, bitseven
	; no key pressed here, go next
	ld de, 8
	add ix, de		; next line of keys
	inc b
	ld a, b
	cp 10
	jr c, scan_loop
	; block until a key is pressed, get back to scan_keyboard!
	jp SCAN_KEYBOARD

bitzero:
	ld a, (ix+0) ; This is the scan code, now wait for the key release
	push af
wait0release:
	call readkbrow
	bit 0, a
	jr z, wait0release
	pop af
	ret
bitone:
	ld a, (ix+1) ; This is the scan code, now wait for the key release
	push af
wait1release:
	call readkbrow
	bit 1, a
	jr z, wait1release
	pop af
	ret
bittwo:
	ld a, (ix+2) ; This is the scan code, now wait for the key release
	push af
wait2release:
	call readkbrow
	bit 2, a
	jr z, wait2release
	pop af
	ret
bitthree:
	ld a, (ix+3) ; This is the scan code, now wait for the key release
	push af
wait3release:
	call readkbrow
	bit 3, a
	jr z, wait3release
	pop af
	ret
bitfour:
	ld a, (ix+4) ; This is the scan code, now wait for the key release
	push af
wait4release:
	call readkbrow
	bit 4, a
	jr z, wait4release
	pop af
	ret
bitfive:
	ld a, (ix+5) ; This is the scan code, now wait for the key release
	push af
wait5release:
	call readkbrow
	bit 5, a
	jr z, wait5release
	pop af
	ret
bitsix:
	ld a, (ix+6) ; This is the scan code, now wait for the key release
	push af
wait6release:
	call readkbrow
	bit 6, a
	jr z, wait6release
	pop af
	ret
bitseven:
	ld a, (ix+7) ; This is the scan code, now wait for the key release
	push af
wait7release:
	call readkbrow
	bit 7, a
	jr z, wait7release
	pop af
	ret


KEY_7			EQU $8000
KEY_6			EQU $4000
KEY_5			EQU $2000
KEY_4			EQU $1000
KEY_3			EQU $0800
KEY_2			EQU $0400
KEY_1			EQU $0200
KEY_0			EQU $0100
KEY_COLON		EQU $8001
KEY_CLOSEBRACKET	EQU $4001
KEY_OPENBRACKET		EQU $2001
KEY_BACKSLASH		EQU $1001
KEY_EQUAL		EQU $0501
KEY_DASH		EQU $0401
KEY_9			EQU $0201
KEY_8			EQU $0101
KEY_B			EQU $8002
KEY_A			EQU $4002
KEY_DEAD		EQU $2002
KEY_FORWARDSLASH	EQU $1002
KEY_DOT			EQU $8002
KEY_COMMA		EQU $4002
KEY_TILDE		EQU $2002
KEY_APOSTROPHE		EQU $1002	
KEY_J			EQU $8003
KEY_I			EQU $4003
KEY_H			EQU $2003
KEY_G			EQU $1003
KEY_F			EQU $0803
KEY_E			EQU $0403
KEY_D			EQU $0203
KEY_C			EQU $0103
KEY_R			EQU $8004
KEY_Q			EQU $4004
KEY_P			EQU $2004
KEY_O			EQU $1004
KEY_N			EQU $0804
KEY_M			EQU $0404
KEY_L			EQU $0204
KEY_K			EQU $0104
KEY_Z			EQU $8005
KEY_Y			EQU $4005
KEY_X			EQU $2005
KEY_W			EQU $1005
KEY_V			EQU $0805
KEY_U			EQU $0403
KEY_T			EQU $0205
KEY_S			EQU $0105
KEY_F3			EQU $8006
KEY_F2			EQU $4006
KEY_F1			EQU $2006
KEY_CODE		EQU $1006
KEY_CAPS		EQU $0806
KEY_GRAPH		EQU $0406
KEY_CTRL		EQU $0206
KEY_SHIFT		EQU $0106
KEY_RET			EQU $8007
KEY_SELECT		EQU $4007
KEY_BACKSPACE		EQU $2007
KEY_STOP		EQU $1007
KEY_TAB			EQU $0807
KEY_ESC			EQU $0407
KEY_F5			EQU $0207
KEY_F4			EQU $0107
KEY_RIGHT		EQU $8008
KEY_DOWN		EQU $4008
KEY_UP			EQU $2008
KEY_LEFT		EQU $1008
KEY_DEL			EQU $0808
KEY_INS			EQU $0408
KEY_HOME		EQU $0208
KEY_SPACE		EQU $0108
KEY_NUM4		EQU $8009
KEY_NUM3		EQU $4009
KEY_NUM2		EQU $2009
KEY_NUM1		EQU $1009
KEY_NUM0		EQU $0809
KEY_NUMSLASH		EQU $0409
KEY_NUMPLUS		EQU $0209
KEY_NUMASTERISK		EQU $0109
KEY_NUMDOT		EQU $800A
KEY_NUMCOMMA		EQU $400A
KEY_NUMMINUS		EQU $200A
KEY_NUM9		EQU $100A
KEY_NUM8		EQU $080A
KEY_NUM7		EQU $040A
KEY_NUM6		EQU $020A
KEY_NUM5		EQU $010A
