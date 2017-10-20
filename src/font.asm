; Load font in VRAM (bank 0, address $6000)

LoadFONT:
	ld hl, FONT
	ld de, $6000
	call unpackVRAM
	ret

LoadFONT_menu:
	ld hl, menu_font
	ld de, $6800
	call unpackVRAM
	ret

; Print a string, terminated by 0
; INPUT:
;       IY: pointer to string
;       B: X in chars
;       C: Y in chars

print_string:
        push iy
        call next_word
        pop iy
        ld a, d
        and a
        ret z           ; return on NULL

        add a, b
        cp 32
        jr c, print_str_nonextline
print_str_nextline:     ; go to next line
        ld b, 1
        inc c
        ld a, c
        cp 24
        jr nz, print_str_nonextline
        push iy
        push de
        call wait_till_read
        call clean_scorearea
        pop de
        pop iy
        ld bc, 256+21
print_str_nonextline:
        ; now print word
        call print_word
        jr print_string
        ret


; Print a string, terminated by 0
; INPUT:
;       IY: pointer to string
;       B: X in chars
;       C: Y in chars

print_string_menu:
        push iy
        call next_word
        pop iy
        ld a, d
        and a
        ret z           ; return on NULL

        add a, b
        cp 32
        jr c, print_str_nonextline_menu
print_str_nextline_menu:        ; go to next line
        ld b, 2
        inc c
print_str_nonextline_menu:
        ; now print word
        call print_word_menu
        jr print_string_menu
        ret


; Print a string on screen, not controlling line breaks
; INPUT:
;       IY: pointer to string
;       B: X in chars
;       C: Y in chars
print_string2:
        ld a, (iy+0)
        and a
        ret z           ; return on NULL
        push iy
        push bc
        call drawChar
        pop bc
        pop iy
        inc iy
        inc b
        jr nz, print_string2
        ret


; Print a string on screen, directly on the front buffer, not controlling line breaks
; INPUT:
;       IY: pointer to string
;       B: X in chars
;       C: Y in chars
print_string3:
        ld a, (iy+0)
        and a
        ret z           ; return on NULL
        push iy
        push bc
        call drawCharFront
        pop bc
        pop iy
        inc iy
        inc b
        jr nz, print_string3
        ret


; Print a string on front buffer, with transparency
; INPUT:
;       IY: pointer to string
;       B: X in chars
;       C: Y in chars
print_string4:
        ld a, (iy+0)
        and a
        ret z           ; return on NULL
        push iy
        push bc
        call drawCharTrans
        pop bc
        pop iy
        inc iy
        inc b
        jr nz, print_string4
        ret

; Print a string on front buffer, with transparency and double size
; INPUT:
;       IY: pointer to string
;       B: X in chars
;       C: Y in chars
print_string_double:
        ld a, (iy+0)
        and a
        ret z           ; return on NULL
        push iy
        push bc
        call drawCharTrans_Double
        pop bc
        pop iy
        inc iy
        inc b
        jr nz, print_string_double
        ret

; Find next word
; INPUT:
;       IY: pointer to string
; OUTPUT:
;       D: word length
next_word:
        ld d, 0
next_word_loop:
        ld a, (iy+0)
        and a
        ret z
        cp ' '
        jr z, next_word_finished
        cp ','
        jr z, next_word_finished
        cp '.'
        jr z, next_word_finished
        inc d
        inc iy
        jr next_word_loop
next_word_finished:
        inc d
        ret

; Print a word on screen
; INPUT:
;       - B: X in chars
;       - C: Y in chars
;       - D: word length
print_word:
        ld a, (iy+0)
        push de
        push iy
        push bc

        call drawChar

        pop bc
        push bc
        ld a, (wait_alternate)
        xor 1
        ld (wait_alternate), a
        and a
        call z, waitforVBlank

        pop bc
        push bc


        ld de, $0101
		call InvalidateTiles
		call TransferDirtyTiles

        pop bc
        pop iy
        pop de

        inc iy
        inc b
        ld a, d
        dec a
        ld d, a
        jr nz, print_word
        ret


; Print a word on screen, just for the menu
; INPUT:
;       - B: X in chars
;       - C: Y in chars
;       - D: word length
print_word_menu:
    halt
        ld a, (iy+0)
        push de
        push iy
        push bc
;        call drawCharFront
		call drawCharTrans_front
        pop bc
        pop iy
        pop de
        inc iy
        inc b
        ld a, d
        dec a
        ld d, a
        jr nz, print_word_menu
        ret

