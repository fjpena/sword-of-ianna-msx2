mainmenu:
	xor a
	ld (start_delta), a
	ld (menu_counter), a
	ld (menu_running), a
	ld (menu_option), a
	ld (menu_loops), a
	ld (menu_timer), a
	ld (credit_timer), a
	ld (credit_current), a
	ld (current_level), a
	ld (player_available_weapons+1), a
	ld (player_available_weapons+2), a
	ld (player_available_weapons+3), a
	ld (player_level), a
	ld (player_current_weapon), a
	ld (player_experience), a
	ld (rom_offset_weapon), a
    ld a, ($002b)
    and $80         ; The highest bit is 1 for PAL, 0 for NTSC
	jr z, mainmenu_ntsc
mainmenu_pal:
	ld a, 3
	ld (menu_delay), a
	jr mainmenu_language
mainmenu_ntsc:
	ld a, 4
	ld (menu_delay), a
mainmenu_language:
	ld a, (language)
	and a
	jr z, mainmenu_language_sp
	ld hl, string_list
	ld (current_string_list), hl
	jr mainmenu_language_ok
mainmenu_language_sp:
	ld hl, string_list_es
	ld (current_string_list), hl

mainmenu_language_ok:
	xor a
	ld (menu_in_jukebox), a
	ld hl, blackpal
	call VDP_SetPalette
    call menu_load_screen
	; copy to page 3
	ld a, 3
	call copyPage
	; Cleanup second page
	ld a, $00
	ld b, 0
	ld c, 0
	ld d, 0
	ld e, 128
	ld h, 1
	call fillArea
	ld hl, menu_fondo_letras
	ld de, $8000
	call unpackVRAM
	; copy to second buffer
	ld b, 0
	ld c, 0
	ld d, 80
	ld e, 32
	ld h, 0
	ld l, 32
	ld ix, $0101	
	call vdpCopy
	ld hl, tilespal
	call VDP_SetPalette

	ld b, 3
	ld a, 0
	call copyPage_generic

	ld a, 13
	call MUSIC_Load
	ld hl, menu_ISR
	call INSTALL_ISR
showmenu:
    ; restore the changing part
    ld b, 0
    ld c, 144
    ld d, 256
    ld e, 48
    ld h, 0
    ld l, 144
    ld ix, $0100
    call vdpCopy

	ld a, 1
	ld (menu_running), a

	call mainmenu_printoptions
	
showmenu_loop:
	xor a
	ld (joystick_state), a

	ld a, (credit_timer)
	and a
	jr nz, showmenu_credit_continue
	ld a, (credit_current)
	add a, a
	ld e, a
	ld d, 0
	ld hl, string_credits
	add hl, de
	ld a, (hl)
	inc hl
	ld iyl, a
	ld a, (hl)
	ld iyh, a		; IY points to the current credit
	ld bc, 8*256 + 23
	call print_string3

	ld a, (credit_current)
	inc a
	cp 3
	jr nz, showmenu_credit_nochange
	xor a
showmenu_credit_nochange:
	ld (credit_current), a
showmenu_credit_continue:
	ld a, (credit_timer)
	add a, 4
	ld (credit_timer), a
showmenu_loop_continue:
	halt
	halt
	halt
	halt
	ld a, (joystick_state)
	bit 1, a		; Down
	jp z, showmenu_checkscrolldown
	call showmenu_waitrelease

	xor a
	ld (menu_timer), a
	ld (menu_loops), a ; something pressed, do not go to attract mode

	ld b, 8
showmenu_scrollup_loop:
	push bc
	call scrollup
	; and copy to front buffer
	call mainmenu_composeoptions
	pop bc
	djnz showmenu_scrollup_loop

	ld a, (menu_option)
	inc a
	and 3
	ld (menu_option), a
	call mainmenu_printoptions
	jp showmenu_loop
showmenu_checkscrolldown:
	bit 0, a		; Up
	jp z, showmenu_checkfire
	call showmenu_waitrelease

	xor a
	ld (menu_timer), a
	ld (menu_loops), a ; something pressed, do not go to attract mode

	ld b, 8
showmenu_scrolldown_loop:
	push bc
	call scrolldown
	; and copy to front buffer
	call mainmenu_composeoptions
	pop bc
	djnz showmenu_scrolldown_loop

	ld a, (menu_option)
	dec a
	and 3
	ld (menu_option), a
	call mainmenu_printoptions
	jp showmenu_loop
showmenu_checkfire:
	bit 4, a		; Fire
	jp nz, showmenu_firepressed

showmenu_nothingpressed:
	; Check if the player has found the jukebox key
	ld hl, KEY_J
	call get_keyboard
	and a
	jr z, showmenu_nojukebox
	call jukebox
	call MUSIC_Stop
	call init_ISR			; We reset all interrupt stuff to start again
	jp mainmenu

showmenu_nojukebox:
	ld a, (menu_timer)
	inc a
	ld (menu_timer), a		; anytime the timer reaches 0 (around 5 secs) we change the screen
	jp nz, showmenu_loop
	ld a, (menu_loops)
	inc a
	ld (menu_loops), a
	ld hl, menu_delay
	cp (hl)
	jp z, showmenu_go_attract	; after 3 loops PAL, 4 loops NTSC (1 minute 20 secs, approx) we go to attract mode
	jp showmenu_loop

showmenu_firepressed:	
	call showmenu_waitrelease  ; wait until fire is released
	ld a, (menu_option)
	and a
	jr nz, showmenu_fire_check1
	ret
showmenu_fire_check1:
	dec a
	jr nz, showmenu_fire_check2		; if menu_option is 1, then we are going for password
	call menu_password			;  A == 255 : password not valid
	cp 255 
	jr z, showmenu_p_fail
    cp 253
    jr nz, showmenu_p_ok
    call DECODE_SECRETLEVEL
	ld iy, string_passwordok
	jr showmenu_p_print
showmenu_p_ok:
	; here, set current_level and other stuff 
	call DECODE
	ld iy, string_passwordok
	jr showmenu_p_print
showmenu_p_fail:
	ld iy, string_passwordfail
	call showmenu_p_print
	jp showmenu
showmenu_p_print:
	push iy
	call menu_cleancreditsattr
	pop iy
	ld bc, 8*256 + 23
	call print_string3
showmenu_p_waitfire:
	call check_firepress
	jr nc, showmenu_p_waitfire		; fire not pressed
showmenu_p_waitnofire:
	call check_firepress
	jr c, showmenu_p_waitnofire		; fire not pressed
	ret
showmenu_fire_check2:
	dec a
	jr nz, showmenu_fire_check3		; if menu_option is 2, then we are going for password
	ld a, (language)
	xor 1
	ld (language), a
	and a
	jr z, showmenu_language_sp
	ld hl, string_list
	ld (current_string_list), hl
	jp showmenu
showmenu_language_sp:
	ld hl, string_list_es
	ld (current_string_list), hl
	jp showmenu
showmenu_fire_check3:		; menu_option is 3, Change music info
	ld a, (music_state)
	inc a
	cp 3
	jr z, showmenu_fire_music_fx
	ld (music_state), a
	ld hl, string_list
	ld de, 6
	add hl, de
	push hl
	ld e, (hl)	
	inc hl
	ld d, (hl)
	ld hl, 9
	add hl, de
	ex de, hl
	pop hl
	ld (hl), e
	jr showmenu_fire_music_common	
showmenu_fire_music_fx:
	xor a
	ld (music_state), a
	ld hl, string_list
	ld de, 6
	add hl, de
	ld de, string_4_1
showmenu_fire_music_common:
	ld (hl), e
	inc hl
	ld (hl), d
	ld bc, 7
	add hl, bc
	ld (hl), e
	inc hl
	ld (hl), d
	jp showmenu

showmenu_go_attract:
	ld a, 8
	ld (current_level), a
	ret


showmenu_waitrelease:
	xor a
	ld (joystick_state), a
	halt
	ld a, (joystick_state)
	and a
	jr nz, showmenu_waitrelease
	ret

; Read joysticks, set carry if fire is pressed
check_firepress:
	xor a
	ld (joystick_state), a
	halt
	ld a, (joystick_state)
    bit 4, a
    jr z, check_firepress_no
    scf
    ret
check_firepress_no:
    xor a
    ret




scrollup:
	halt
	halt
	halt
	ld d, 0
	ld e, 1
	ld b, 16
scrollup_loop_up:
	push de
	push bc
	call scroll_line
	pop bc
	pop de
	inc d
	inc e
	djnz scrollup_loop_up

	ld d, 16
	ld e, 18
	ld b, 14
scrollup_loop_middle:
	push de
	push bc
	call scroll_line
	pop bc
	pop de
	inc d
	inc e
	djnz scrollup_loop_middle

	ld d, 30
	ld e, 32
	call scroll_line
	ld d, 31
	ld e, 32
	call scroll_line

	ld d,  32
	ld e, 33
	ld b, 16
scrollup_loop_down:
	push de
	push bc
	call scroll_line
	pop bc
	pop de
	inc d
	inc e
	djnz scrollup_loop_down
	ret


scrolldown:
	halt
	halt
	halt
	ld d, 47
	ld e, 46
	ld b, 16
scrolldown_loop_down:
	push de
	push bc
	call scroll_line
	pop bc
	pop de
	dec d
	dec e
	djnz scrolldown_loop_down
	ld d, 32
	ld e, 30
	ld b, 14
scrolldown_loop_middle:
	push de
	push bc
	call scroll_line
	pop bc
	pop de
	dec d
	dec e
	djnz scrolldown_loop_middle
	ld d, 18
	ld e, 16
	call scroll_line
	ld d, 17
	ld e, 16
	call scroll_line

	ld d, 16
	ld e, 15
	ld b, 16
scrolldown_loop_up:
	push de
	push bc
	call scroll_line
	pop bc
	pop de
	dec d
	dec e
	djnz scrolldown_loop_up
	ret


; Scroll 64 pixels 
; D: destination Y (in pixels)
; E: source Y
scroll_line:
	ld b, 128			; source X
	ld c, e				; source Y
	ld h, 128			; destination X
	ld l, d				; destination Y
	ld d, 64			; number of pixels in X
	ld e, 1				; number of pixels in Y
	ld ix, $0101
	call vdpCopy
	ret

mainmenu_composeoptions:
	; re-print the background
	ld b, 0
	ld c, 32
	ld d, 80
	ld e, 32
	ld h, 0
	ld l, 0
	ld ix, $0101	
	call vdpCopy
	; print current scrolling options on top
	ld b, 120
	ld c, 8
	ld d, 80
	ld e, 32
	ld h, 0
	ld l, 0
	ld ix, $0101
	call vdpCompose
	; and copy to front buffer
	ld b, 0
	ld c, 0
	ld d, 80
	ld e, 32
	ld h, 88
	ld l, 144
	ld ix, $0100
	call vdpCopy
	ret


mainmenu_printoptions:
	; re-print the background
	ld b, 0
	ld c, 32
	ld d, 80
	ld e, 32
	ld h, 0
	ld l, 0
	ld ix, $0101	
	call vdpCopy

	; print menu options
	ld a, (menu_option)
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $0101
	call print_string_double

	ld a, (menu_option)
	inc a
	and 3
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $0103
	call print_string4

	ld a, (menu_option)
	add a, 3
	and 3
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $0100
	call print_string4
	; and copy to front buffer
	ld b, 0
	ld c, 0
	ld d, 80
	ld e, 32
	ld h, 88
	ld l, 144
	ld ix, $0100
	call vdpCopy

	; cleanup the background for scroll 
	ld a, $00
	ld b, 120
	ld c, 0
	ld d, 128
	ld e, 48
	ld h, 1
	call fillArea

	; print menu options
	ld a, (menu_option)
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $1002
	call print_string_double

	ld a, (menu_option)
	inc a
	and 3
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $1004
	call print_string4

	ld a, (menu_option)
	add a, 2
	and 3
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $1005
	push iy
	call print_string4
	pop iy
	ld bc, $1000
	call print_string4


	ld a, (menu_option)
	add a, 3
	and 3
	add a, a
	ld e, a
	ld d, 0
	ld ix, (current_string_list)
	add ix, de
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, $1001
	call print_string4







	ret

menu_cleancreditsattr:
	ld bc, 23
	ld iy, string_long
	jp print_string3

menu_ISR:
	; get joystick state
	call get_joystick
	ld b, a
	ld a, (joystick_state)
	or b
	ld (joystick_state), a
	; play music, if needed
	ld a, (music_playing)
	and a
	jr z, menu_isr_wave		; if not playing music, do nothing

    ld a, ($002b)
    and $80         ; The highest bit is 1 for PAL, 0 for NTSC
    jr nz, menu_ISR_PAL
menu_ISR_NTSC:
	ld a, (delay60HZ)
	dec a
	ld (delay60HZ), a
	jr nz, menu_ISR_PAL		; for NTSC, skip 1 out of 6 ints
	ld a, 6
	ld (delay60HZ), a
	jr menu_ISR_end
menu_ISR_PAL:
	call MUSIC_Play
menu_ISR_end
menu_isr_wave:
	; simply get the joystick state
	ld a, (menu_running)
	and a
	ret z
	ld a, (menu_counter)
	inc a
	and $7
	ld (menu_counter), a
	cp 4
	jp z, waveeffect
	ret
	
waveeffect:
	ld a, (menu_in_jukebox)
	and a
	ret nz
	ld a, (start_delta)
	ld (current_delta), a
	ld bc, $0050	; X=0, Y=80
	ld a, 40
	ld (current_y), a
waveeffect_yloop:
	ld a, (current_delta)			; A will serve as counter for Y
	ld e, a
	ld d, 0
	ld hl, wave_delta
	add hl, de	
	ld a, (hl)						; A == delta for this line
	cp 1
	jr z, waveeffect_plus1
	cp 2
	jr z, waveeffect_plus2
	cp -1
	jr nz, waveeffect_minus2
waveeffect_minus1:
	push bc
	ld a, -1
	call MoveLine
	pop bc
	jr waveeffect_nextline
waveeffect_plus1:
	push bc
	ld a, 1
	call MoveLine
	pop bc
	jr waveeffect_nextline
waveeffect_plus2:
	push bc
	ld a, 2
	call MoveLine
	pop bc
	jr waveeffect_nextline
waveeffect_minus2:
	push bc
	ld a, -2
	call MoveLine
	pop bc
waveeffect_nextline:
	; go to next line
	inc c
	; increment wave counter
	ld a, (current_delta)
	inc a
	and $f
	ld (current_delta), a
	ld a, (current_y)
	dec a
	jr z, waveeffect_end
	ld (current_y), a
	jp waveeffect_yloop
waveeffect_end:
	ld a, (start_delta)
	inc a
	and $f
	ld (start_delta), a
    ret

mainmenu_done:
	ld a, b
    dec a
	ld (current_level), a
	ret

menu_password:
	call menu_cleancreditsattr
	ld bc, 2*256+23
	ld iy, string_enterpassword
	call print_string3

	ld hl, password_string
	ld de, password_string+1
	ld a, ' '
	ld (hl), a
	ld bc, 9
	ldir

	ld b, 0	; B is the counter
	ld hl, password_string

readloop:
	push bc
	push hl
	call SCAN_KEYBOARD		; read keyboard in A
	pop hl
	pop bc
	cp  13				; 13 is ENTER
	jr z, read_finished

	cp '0'
	jr c, readloop		; ignore chars < 0
	cp 'g'
	jr nc, readloop		; ignore chars > F
	cp '9'+1
	jr c, readloop_number	; this is a number
	cp 'a'
	jr c, readloop		; less than A, not a number
readloop_ok:
	sub 32
readloop_number:
	ld (hl), a			; store the new key press
	ld a, b
	cp 10
	jr z, read_continue		; don't go beyond 10 characters
	inc hl
	ld (hl), 0
	inc b
read_continue:
	push bc
	push hl
	ld bc, 18*256+23
	ld iy, password_string
	call print_string3
	pop hl
	pop bc
	ld a, b
	cp 10
	jr nz, readloop
read_finished:
    ; Check if the player knows the secret level password
    ld hl, password_string
    ld de, secret_pass
    ld b, 10
secret_loop:
    ld a, (de)
    cp (hl)
    jr nz, read_nosecret
    inc hl
    inc de
    djnz secret_loop
secret_found:
    ld a, 253   ; go to secret level
    ret
read_nosecret:
	; convert password string into value
	ld hl, password_string
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value), a
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value+1), a
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value+2), a
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value+3), a
	call TEXT_TO_HEX
	ld (password_value+4), a	; the checksum is not XOR-ed
	; check if checksum is valid
	call password_checksum
	ld b, a
	ld a, (password_value+4)
	cp b
	jr z, is_password_valid
	
;	jr nz, menu_password_invalid
	; check if resulting values are valid
;	call is_password_valid
;	and a
;	jr nz, menu_password_invalid
;menu_password_valid:
;	xor a
;	ret
menu_password_invalid:
;	ld a, 255
;	ret
	
password_invalid:
	ld a, 255
	ret
		
is_password_valid:
	; save player level
	ld a, (player_level)
	ld (save_level), a
	ld a, (password_value)	; current level
	and $0f			; low nibble is current level
	cp 8
	jr nc, password_invalid	; level cannot be > 7
	ld (player_level), a
	ld a, (password_value)	; high nibble is available_weapons
	and $80			; at least the basic sword must be there
	jr z, password_invalid
	ld a, (password_value+1); player_level
	cp 8
	jr nc, password_invalid	; player level cannot be > 7
	call get_player_max_exp ; get max experience for saved level in A
	ld hl, password_value+2
	cp (hl)			; compare with the experience
	jr c, password_invalid	; if the saved value is > the max experience for this level, fail!
	ld a, (password_value+3); player_current_weapon, it has to be one of the available_weapons
	ld hl, weapon_masks
	ld e, a
	ld d, 0
	add hl, de
	ld b, (hl)		; B contains the mask
	ld a, (password_value)	; high nibble is available_weapons
	and b
	ld a, (save_level)
	ld (player_level), a	; restore value
	jr z, password_invalid	; the weapon is not available, so the password is not valid
	xor a
	ret



DECODE_SECRETLEVEL:
    ld a, 2
    ld (player_level), a
    ld a, 9
	ld (current_level), a
	ld iy, player_available_weapons
	ld (iy+0), 1
	ld (iy+1), 1
	ld (iy+2), 1
	ld (iy+3), 0	; all weapons are available, except Blade
	xor a
	ld (player_experience), a
	ld (player_current_weapon), a    
    ret

; Convert text into hex value
; INPUT:
;	- HL: pointer to char
; OUTPUT:
;	- A: value 

TEXT_TO_HEX:
     	ld e, 0
     	call TH_CONV

	rla
	rla
	rla
	rla		;Set it in bits 7-4
	ld e,a	;Store first digit in E

TH_CONV:
	ld a,(hl)
	inc hl
	sub 48
	cp 10
	jr c,noletter
	sub 7
noletter:
	or e
	ret


; Run a quick checksum of the 4 initial values in password_value
; OUTPUT:
;	- A: checksum

password_checksum:
	xor a
	ld hl, password_value
	ld b, 4
password_checksum_loop
	add a, (hl)
	inc hl
	djnz password_checksum_loop
	ret

string_enterpassword: db "ENTER PASSWORD:",0
string_passwordok: db   "  PASSWORD OK",0
string_passwordfail: db "INVALID PASSWORD",0
string_presskey: db "PRESS KEY FOR  ",0
string_credits: dw string_code, string_art, string_music
string_code:	db "  CODE: UTOPIAN ",0
string_art:   	db "ART: PAGANTIPACO",0
string_music:   db "  SOUND: MCALBY ",0
string_long: db "                                ",0
string_1: db "  PLAY  ",0
string_1_es: db " JUGAR  ",0
string_2: db "PASSWORD",0
string_3: db "ENGLISH ",0
string_3_es: db "ESPA$OL ",0
string_4_1:  db "MUSIC/FX",0
string_4_2:  db " MUSIC  ",0
string_4_3:  db "   FX   ",0
weapon_masks: db $80, $40, $20, $10
secret_pass: db '0CAFECAFE0'
wave_delta: db 2, 2, 1, 1, -1, -1, -2, -2, -2, -2, -1, -1, 1, 1, 2, 2
keys_jump: dw KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8 ,KEY_9
menu_fondo_letras: INCBIN "menu_fondo_letras.SR5.plet1"
menu_font: INCBIN "menu_font.SR5.plet1"


jukebox_1: db "      THE SWORD OF IANNA OST    ",0
jukebox_2: db "            BY MCALBY           ",0
jukebox_3: db "            ---------           ",0
jukebox_4: db "                                ",0
jukebox_5: db "  A: MENU            B: INTRO   ",0
jukebox_6: db "  C: LEVEL 1         D: LEVEL 2 ",0
jukebox_7: db "  E: LEVEL 3         F: LEVEL 4 ",0
jukebox_8: db "  G: LEVEL 5         H: LEVEL 6 ",0
jukebox_9: db "  I: LEVEL 7         J: LEVEL 8 ",0
jukebox_a: db "                                ",0
jukebox_b: db " PRESS X TO GO BACK TO THE MENU ",0

jukebox:
	call cls_primary
	ld a, 1
	ld (menu_in_jukebox), a
	ld iy, jukebox_1
	ld de, 33
	ld bc, $0006
	ld a, 11
jukebox_print_loop:
	push af
	push bc
	push de
	push iy
	call print_string3
	pop iy
	pop de
	pop bc
	pop af
	add iy, de
	inc c
	dec a
	jr nz, jukebox_print_loop
jukebox_wait_loop:
	ld hl, KEY_A
	call get_keyboard
	and a
	jr nz, jukebox_play_a
	ld hl, KEY_B
	call get_keyboard
	and a
	jr nz, jukebox_play_b
	ld hl, KEY_C
	call get_keyboard
	and a
	jr nz, jukebox_play_c
	ld hl, KEY_D
	call get_keyboard
	and a
	jr nz, jukebox_play_d
	ld hl, KEY_E
	call get_keyboard
	and a
	jr nz, jukebox_play_e
	ld hl, KEY_F
	call get_keyboard
	and a
	jr nz, jukebox_play_f
	ld hl, KEY_G
	call get_keyboard
	and a
	jr nz, jukebox_play_g
	ld hl, KEY_H
	call get_keyboard
	and a
	jr nz, jukebox_play_h
	ld hl, KEY_I
	call get_keyboard
	and a
	jr nz, jukebox_play_i	
	ld hl, KEY_J
	call get_keyboard
	and a
	jr nz, jukebox_play_j
	ld hl, KEY_X
	call get_keyboard
	and a
	ret nz
	jr jukebox_wait_loop
jukebox_play_a:
	ld hl, KEY_A
	call get_keyboard
	and a
	jr nz, jukebox_play_a
	ld a, 13
	jr jukebox_play_common
jukebox_play_b:
	ld hl, KEY_B
	call get_keyboard
	and a
	jr nz, jukebox_play_b
	ld a, 12
	jr jukebox_play_common
jukebox_play_c:
	ld hl, KEY_C
	call get_keyboard
	and a
	jr nz, jukebox_play_c
	xor a
	jr jukebox_play_common
jukebox_play_d:
	ld hl, KEY_D
	call get_keyboard
	and a
	jr nz, jukebox_play_d
	ld a, 1
	jr jukebox_play_common
jukebox_play_e:
	ld hl, KEY_E
	call get_keyboard
	and a
	jr nz, jukebox_play_e
	ld a, 2
	jr jukebox_play_common
jukebox_play_f:
	ld hl, KEY_F
	call get_keyboard
	and a
	jr nz, jukebox_play_f
	ld a, 3
	jr jukebox_play_common
jukebox_play_g:
	ld hl, KEY_G
	call get_keyboard
	and a
	jr nz, jukebox_play_g
	ld a, 4
	jr jukebox_play_common
jukebox_play_h:
	ld hl, KEY_H
	call get_keyboard
	and a
	jr nz, jukebox_play_h
	ld a, 5
	jr jukebox_play_common
jukebox_play_i:
	ld hl, KEY_I
	call get_keyboard
	and a
	jr nz, jukebox_play_i
	ld a, 6
	jr jukebox_play_common
jukebox_play_j:
	ld hl, KEY_J
	call get_keyboard
	and a
	jr nz, jukebox_play_j
	ld a, 7
	jr jukebox_play_common
jukebox_play_common:
	push af
	call MUSIC_Stop
	pop af
	call MUSIC_Load
	jp jukebox_wait_loop

; Routine to clear screen
cls_primary:
	call fadeMSX2
    ld a, $11
    ld bc, 0
    ld d, 256
    ld e, 192
    ld h, 0
    call fillArea
	ld hl, tilespal
	call VDP_SetPalette
	ret
