INCLUDE "introscr.sym"
INCLUDE "endingscr.sym"

intro_screens: dw intro1, intro2, intro3
final_screens: dw ending1, ending2

INTRO_SCR_PAGE: EQU 41
END_SCR_PAGE: EQU 42

intro:
    ; Check if this is the first time the intro is run,
    ; and only run it if we are in level 1
    ld a, INTRO_SCR_PAGE
    ld (slideshow_rom_page), a      ; ROM page for intro screens
    ld a, (current_level)
    and a
    ret nz
    ld a, (intro_shown)
    and a
    ret nz
    ld a, 1
    ld (intro_shown), a
    ; Now do the usual stuff
    ld a, (language)
    and a
    jr nz, intro_english
    ld hl, intro_strings
    jr intro_common
intro_english:
    ld hl, intro_strings_en
intro_common:
    ld de, intro_screens
    ld a, 5
	ld b, 12
    jp slideshow

ending:
    ld a, END_SCR_PAGE
    ld (slideshow_rom_page), a      ; ROM page for ending screens
    ld a, (language)
    and a
    jr nz, end_english
    ld hl, final_strings
    jr end_common
end_english:
    ld hl, final_strings_en
end_common:
    ld de, final_screens
    ld a, 3
	ld b, 14
    call slideshow
	ld b, 90
end_wait:
	halt
	djnz end_wait
	call MUSIC_Stop
    call cls
    jp end_credits

; INPUT:
; A: number of screens
; B: music to load (12 for intro, 14 for ending)
; HL: pointer to strings
; DE: pointer to screen addresses

slideshow:
	push bc
	ld (number_screens), a
	ld (menu_string_list), hl
	ld (menu_screen_list), de

	call VDP_ActDeact
	call load_bkg
    call preload_screens
	call VDP_ActDeact

	pop bc
	ld a, b			
	call MUSIC_Load

	xor a
	ld (intro_var), a
intro_loop:
    ld a, (intro_var)
	call draw_screen

    ld a, (intro_var)
    add a, a
    ld hl, (menu_string_list)
    ld e, a
    ld d, 0
    add hl, de
    ld a, (hl)
    ld iyl, a
    inc hl
    ld a, (hl)
    ld iyh, a
	ld b, 2
	ld c, 18
	call print_string_menu
	call waitloop

    ld a, (intro_var)
    inc a
	ld hl, number_screens
    cp (hl)
	ret nc
    ld (intro_var), a
	call menu_cls
    jr intro_loop


; We want to wait ~290 halts in PAL, which is ~360 in NTSC
waitloop:
    ld a, ($002b)
    and $80         ; The highest bit is 1 for PAL, 0 for NTSC
	jr nz, waitloop_PAL
waitloop_NTSC:
	ld bc, 375
	jr waitloop_loop
waitloop_PAL:
	ld bc, 290	
waitloop_loop:
	xor a
	ld (joystick_state), a	; reset joystick state
    halt
	ld a, (joystick_state)
	bit 4, a
	ret nz
	dec bc
	ld a, c
	or b
	ret z
	jr waitloop_loop

preload_screens:
	ld a, (slideshow_rom_page)
	call setROM2
	ld a, (number_screens)
    and 1
    ld c, a ; save the extra bit in A (may be 1 or 0)
	ld a, (number_screens)
    rrca
    and $7f
    add a, c ; so A/2 + A&1 is the number of SR5 screens to unpack
preload_screens_loop:
    ; A has the screen number
    dec a
    push af
	ld hl, (menu_screen_list)
	add a, a
	ld c, a
	ld b, 0    
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, b
	ld l, c
	ld de, $8000
	call unpackVRAM			; unpack screen into VRAM page 1
    pop af
    push af                 ; We should put it at the 1 + A / 2 screen, at 128 * A&1
    
    rrca
    and $7f
    inc a           ; this is the dest buffer
    ld ixl, a
    ld a, 1
    ld ixh, a       ; source buffer
    ld b, 0
    ld c, 0
    ld d, 0
    ld e, 128
    ld h, 0
    pop af
    push af
    and 1
    rrca            ; A is now either 0 or 128
    ld l, a
    call vdpCopy
    pop af
    and a
    jr nz, preload_screens_loop
	ld a, 1
	call setROM2
    ret
    
load_bkg:
	ld hl, blackpal
	call VDP_SetPalette	; start with a black palette always
	ld hl, intro_bkg
	ld de, $0000
	call unpackVRAM
	ret

; A: screen number
draw_screen:
    push af
	ld hl, blackpal
	call VDP_SetPalette	; start with a black palette always
    pop af
    push af
	and 1
	jr z, draw_screen_even
draw_screnen_odd:
	ld b, 128
	jr draw_screen_common
draw_screen_even:
	ld b, 0
draw_screen_common:
    pop af
    push af
    ; Source page is 1 + A / 4
    rrca
    rrca
    and $f
    inc a
    ld ixh, a
    pop af
    ; Source Y is A&2 << 6
    and $2
    rrca
    rrca
    ld c, a
	ld d, 128
	ld e, 128
	ld h, 64
	ld l, 0
	ld ixl, 0
	call vdpCopy
    call fadeinMSX2
	ret

decPalette:
	ld a, (menu_cls_counter)
	inc a
	ld (menu_cls_counter), a
	and 3
	jr nz, intro_dec_done			; only decrement the palette once every 4 frames
	ld d, 16		; 16 words per palette
	ld hl, currentPal
intro_decpalette:	
	ld a, (hl)	
	ld b, a			
	and $f0		; get the high nibble
	jr z, intro_nodecrement2
	sub $10		; substract 1 from the high nibble		
intro_nodecrement2:
	ld c, a			; and store it on C
	ld a, b
	and $0f		; get the low nibble
	jr z, intro_nodecrement3	
	dec a			; decrement if not 0
intro_nodecrement3:	
	or c			; combine the high and low nibbles
	ld (hl), a		; and send it back to the array	
	inc hl	
	ld a, (hl)		; this time we need 2 nibbles	
	or a			; is a == 0?
	jr z, intro_nodecrement
	dec a
	ld (hl), a		; write the decremented value
intro_nodecrement:
	inc hl
	dec d
	jr nz, intro_decpalette 	; same for all 16 words
intro_dec_done:
	ld hl, currentPal
	call VDP_SetPalette_DI	; write the new palette
	call mzk_subroutine
    ld a, 124
    call SetHorInterruptLine
	ld hl, setPaletteMenu
	call INSTALL_HORISR
	ret


setPaletteMenu:
	ld hl, tilespal
	call VDP_SetPalette_DI
    ld a, 192
    call SetHorInterruptLine
    ld hl, decPalette
    call INSTALL_HORISR
	ret

menu_cls:
	xor a
	ld (menu_cls_counter), a
	ld hl, tilespal	; copy the default palette
	ld de, currentPal
	ld bc, 32
	ldir
	di
    ld a, 192
    call SetHorInterruptLine
    ld a, 16
    call EnDisHorInterrupts
    ld hl, decPalette
    call INSTALL_HORISR
	ei
menu_cls_wait:
	ld a, (menu_cls_counter)
	cp 28
	jr c, menu_cls_wait

	di
	xor a
    call EnDisHorInterrupts
	ld hl, blackpal
	call VDP_SetPalette_DI
	ei

	; Clean upper area (image)
    ld a, $11
    ld bc, $2800
    ld d, 176
    ld e, 128
    ld h, 0
    call fillArea

	; Clean lower area (text)
    ld a, $22
    ld bc, $0888
    ld d, 240
    ld e, 48
    ld h, 0
    call fillArea	
    ret

end_credits:
	ld a, (slideshow_rom_page)
	call setROM2
    ld hl, ending_credits
   	ld de, $8000
	call unpackVRAM			; unpack screen into VRAM page 1
	ld a, 1
	call setROM2

	ld a, 15
	call MUSIC_Load

    halt
    ld a, 1
    call setDisplayPage     ; and switch to it

    ld a, $11
    ld b, 0
    ld c, 192
    ld d, 256
    ld e, 32
    ld h, 1
    call fillArea


	ld iy, credits01
	ld b, 37
end_credits_line:
	push iy
	push bc
	call credits_string
	call end_credits_loop
	pop bc
	pop iy
	ld de, 16
	add iy, de
	djnz end_credits_line
	ld b, 14
end_credits_end:
	push bc
	call end_credits_loop
	pop bc
	djnz end_credits_end
	ld bc, 12*256+16
    ld iy, credits_end
    call print_string2
end_credits_wait_loop:
  	xor a
   	ld (joystick_state), a	; reset joystick state
    halt
   	ld a, (joystick_state)
   	bit 4, a
  	jr z, end_credits_wait_loop
	call MUSIC_Stop
    xor a
	call cls
    call setDisplayPage     ; and switch to it
	ret

end_credits_loop:
	ld a, 8
end_credits_loop_inner:
	halt
	halt
	halt
	halt
	push af
	call credits_scrollup
	pop af
	dec a
	jr nz, end_credits_loop_inner
	ret

; IY: string
credits_string:
	ld b, 10
	ld c, 24
    call print_string2
    ret

credits_scrollup:
    ld b, 80
    ld c, 89
    ld d, 120
    ld e, 120
    ld h, 80
    ld l, 88
    ld ix, $0101
    call vdpCopy
    ret

credits01: db 'RETROWORKS 2017',0
credits02: db '               ',0
credits03: db 'CODE:          ',0
credits04: db '        UTOPIAN',0
credits05: db '               ',0
credits06: db 'GFX, LEVELS:   ',0
credits07: db '    PAGANTIPACO',0
credits08: db '               ',0
credits09: db 'MUSIC AND SFX: ',0
credits10: db '         MCALBY',0
credits11: db '               ',0
credits12: db 'MSX SUPPORT:   ',0
credits13: db '       GUILLIAN',0
credits14: db '               ',0
credits15: db 'OPTIMIZATIONS: ',0
credits16: db '     METALBRAIN',0
credits17: db '               ',0
credits18: db 'PROOFREADING:  ',0
credits19: db '  FELIX CLOWDER',0
credits20: db '               ',0
credits21: db 'TESTING:       ',0
credits22: db '         METR81',0
credits23: db '         IVANZX',0
credits24: db 'RETROWORKS TEAM',0
credits25: db '               ',0
credits26: db 'WE WANT TO SAY ',0
credits27: db '  THANK YOU TO:',0
credits28: db '               ',0
credits29: db 'FRIENDWARE AND ',0
credits30: db '   REBEL ACT   ',0
credits31: db '  STUDIOS, FOR ',0
credits32: db '    CREATING   ',0
credits33: db 'BLADE: THE EDGE',0
credits34: db '  OF DARKNESS  ',0
credits35: db '               ',0
credits36: db '  YOU, PLAYER, ',0
credits37: db '  FOR PLAYING  ',0

credits_end: db '    THE END    ',0
