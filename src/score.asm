; load the score area in screen
load_scorearea:
	ld hl, scorearea
	ld de, $D000
	call unpackVRAM
	ld bc, $000a
	ld de, $1002
	call InvalidateSTiles
	; draw score status
	call draw_score_status
	ret

; Draw the score status
draw_score_status:
	; Print barbarian status
	call draw_barbarian_state
	; Print current weapon
	call draw_weapon
	; Print enemy 1 energy (in meter and number), print enemy 1 level	
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, 24
	call draw_enemy_state
	; Print enemy 2 energy (in meter and number), print enemy 2 level	
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, 27
	call draw_enemy_state
	; Print inventory
	jp draw_score_inventory



LoadScoreWeapons:
	ld hl, WEAPON_SPRITES
	ld de, $E000
	call unpackVRAM
	ld a, 3
	call copyPage			; copy to VRAM page 3 (currently only used by the score area)
	ret

draw_weapon:
	ld a, (player_current_weapon)
	rlca
	rlca
	rlca
	rlca
	rlca			; a * 32 is the X to use when drawing
	ld b, 14*8
	ld c, 21*8
	call drawWeapon
	; set the area to be invalidated
	ld bc, $070a
	ld de, $0202
	call InvalidateSTiles
	ret	

draw_score_inventory:
        ld a, 3
        ld (currentx), a
        ; if (current_object > first_object + 2) first_object++
        ld a, (inv_first_obj)
        add a, 3
        ld b, a
        ld a, (inv_current_object)
        cp b
        jr c, draw_inv_noincfirst
        ld a, (inv_first_obj)
        inc a
        ld (inv_first_obj), a
        jr draw_inv_draw
draw_inv_noincfirst:
        ; else if current_object < first_object first_object --
        ld a, (inv_first_obj)
        ld b, a
        ld a, (inv_current_object)
        cp b
        jr nc, draw_inv_draw
        ld a, (inv_first_obj)
        dec a
        ld (inv_first_obj), a
draw_inv_draw:
        ld a, (inv_first_obj)
draw_inv_draw_loop:
        push af
        cp 6
        jr nc, draw_inv_draw_loop_blank
        ld hl, inventory
        ld e, a
        ld d, 0
        add hl, de
        ld a, (hl)      ; A has the object
        and a
        jr z, draw_inv_ready
        sub OBJECT_KEY_GREEN ; make it base 0
        ld e, a
        ld d, 0
        ; get the stile
        ld hl, tiles_per_pickable_object
        add hl, de
        ld a, (hl)      ; A has the stile for the object
draw_inv_ready:
        push af
        ld a, (currentx)
		add a, a
		add a, a
		add a, a
        ld b, a
        ld c, 21*8
        pop af
        jr draw_inv_go
draw_inv_draw_loop_blank:
        ld a, (currentx)
		add a, a
		add a, a
		add a, a
        ld b, a
        ld c, 21*8
        xor a
draw_inv_go:
        call drawTile
draw_inv_continueloop:
        ld a, (currentx)
        add a, 3
        cp 12
        jr nc, draw_inv_marker  ; already drew 3 objects 
        ld (currentx), a ; move 3 chars right in the inventory
        pop af
        inc a           ; next item in inventory
        jp draw_inv_draw_loop
draw_inv_marker:
        ; cleanup the markers
        ld a, ' '
        ld bc, 3*256 + 23
        call drawChar
        ld a, ' '
        ld bc, 6*256 + 23
        call drawChar
        ld a, ' '
        ld bc, 9*256 + 23
        call drawChar
        ; now print it
        pop af
        ld a, (inv_first_obj)
        ld b, a
        ld a, (inv_current_object)
        sub b           ; 
        ld b, a
        add a, a
        add a, b        ; (current_obj - first_obj) * 3
        add a, 3        ; 3 + (current_obj - first_obj) * 3
        ld b, a
        ld c, 23
        ld a, 95
        call drawChar
        xor a
        ld (inv_refresh), a
        ; And set the area to be redrawn
;        ld bc, 2*256 + 21
;        ld de, 10*256 + 3
;        jp InvalidateTiles
		ld bc, 1*256 + 10
		ld de, 5*256 + 2
		jp InvalidateSTiles


; print a meter
; INPUT:
;   - B: Value (0..255)
;   - C: X
;	- L: color
draw_meter:
	push bc
    ld a, 21
    ld (draw_blank), a  ; just a safeguard if B=0
	ld a, b
	and a
	jr z, draw_meter_secondhalf
	ld e, b
	ld d, 12
	call Div8	; Value / 12 is in the range 0..21, result in A is the number of lines to draw
	and a
	jr z, draw_meter_secondhalf
	push af
	ld d, a
	ld a, 21
	sub d
;	inc a
	ld (draw_blank), a	; draw_blank is the number of black scans to draw
	pop af
	ld e, a			; E = number of pixels in Y
	ld d, 3			; 6 pixels in X to fill
	ld b, c			; B = starting X
	inc b
	inc b
    inc b
	ld c, a
	ld a, 190
	sub c			; 190 - A is the starting line
	ld c, a			; C = starting Y
	ld a, l			; set color
	ld h, 1			; back buffer
	call fillArea_slow
draw_meter_secondhalf:
	pop bc
	ld a, (draw_blank)
	and a
	ret z			; return if no blank lines to draw
	ld e, a			; E = number of pixels in Y
	ld b, c			; B = starting X
	inc b
	inc b
    inc b
	ld c, 169		; C = starting Y
	ld d, 3		; D = 3 pixels to fill in X
	ld a, $11
	ld h, 1			; back buffer
	jp fillArea_slow

draw_enemy_state:
	ld (draw_char), a 
	ld a, (ix+0)
	or (ix+1)
	jp z, draw_enemy_noenemy
	ld a, (ix+4)
	and a
	jp z, draw_enemy_noenemy
    ld a, (ix+10)   
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
    jp z, draw_enemy_noenemy
	cp OBJECT_ENEMY_SECONDARY*16-OBJECT_ENEMY_SKELETON*16 ; Is it a secondary object?
    jp z, draw_enemy_noenemy
draw_enemy_enemy:
	ld a, (draw_char)
	rlca
	rlca
	rlca
	ld b, a
	ld c, 168
	ld a, 1
	call drawScoreOnOff
	push ix
	pop iy
	call get_entity_max_energy 	; so A is the maximum energy
	ld c, (ix+4)		; and C is the current energy. C*256/A would be the one to use
	ld h, c
	ld l, 0
	dec hl
	ld c, a
	call Div16_8		; result in HL, we will only take L
	ld b, l
	ld a, (draw_char)
	rlca
	rlca
	rlca
	ld c, a
	ld l, $04			; color
	call draw_meter
	ld e, (ix+4)
	ld d, 10
	call Div8		; A is the enemy energy / 10, D is the remainder
	push de
	push af
	ld a, (draw_char)
	inc a
	ld b, a
	ld c, 22
	pop af
	add a, '0'
	call drawChar
	pop de
	ld a, (draw_char)
	add a, 2
	ld b, a
	ld c, 22
	ld a, d
	add a, '0'
	call drawChar
	ld a, (ix+10)
	and $0f		; the level is in the low nibble
	ld d, a
	ld a, (draw_char)
	add a, 2
	ld b, a
	ld c, 23
	ld a, d
	add a, '1'
	call drawChar
	jp draw_enemy_invalidate
draw_enemy_noenemy:
	ld a, (draw_char)
	rlca
	rlca
	rlca
	ld b, a
	ld c, 168
	xor a
	call drawScoreOnOff
draw_enemy_invalidate:
	; And set the area to be redrawn
	ld a, (draw_char)
	rrca
	ld b, a
	ld c, 10
	ld de, 2*256+2
	jp InvalidateSTiles
;	ld c, 21
;	ld de, 3*256 + 3
;	jp InvalidateTiles


draw_barbarian_state:
	; Print barbarian energy
	ld ix, ENTITY_PLAYER_POINTER
	push ix
	pop iy
	ld c, (ix+4)		; and C is the current energy. C*256/A would be the one to use
	ld a, c
	and a
	jr nz, draw_barbarian_state_energynot0
	ld b, a
	jr draw_barbarian_state_energy
draw_barbarian_state_energynot0:
	ld h, c
	ld l, 0
	dec hl
	call get_entity_max_energy    
	ld c, a
	call Div16_8		; result in HL, we will only take L
	ld b, l
draw_barbarian_state_energy:
	ld c, 168
	ld l, $0a
	call draw_meter
	; Print barbarian experience for current level
	ld a, (player_experience)
	and a
	jr nz, draw_barbarian_state_expnot0
	ld b, a
	jr draw_barbarian_state_exp
draw_barbarian_state_expnot0:
	ld c, a
   	call get_player_max_exp ; H*256/A would be the one to use
    ld h, c
    ld l, 0
    dec hl
    ld c, a
	call Div16_8		; result in HL, we will only take L
	ld b, l
draw_barbarian_state_exp:
	ld c, 176
	ld l, $04
	call draw_meter
	; Print barbarian level 
	ld bc, 20*256 + 23
	ld a, (player_level)
	add a, '1'
	call drawChar
	; And set the area to be redrawn
;	ld bc, 20*256 + 21
;	ld de, 3*256 + 3
;	jp InvalidateTiles
	ld bc, 10*256 + 10
	ld de, 2*256 + 2
	jp InvalidateSTiles

; Clean score area, just leaving the outer frame
clean_scorearea:
	ld c, 21	; C is the Y tile
cleansc_y_loop:
	ld b, 1		; B is the X tile
cleansc_x_loop:
	ld a, ' '
	push bc
	call drawChar
	pop bc
	inc b
	ld a, b
	cp 31
	jr nz, cleansc_x_loop
	inc c
	ld a, c
	cp 24
	jr nz, cleansc_y_loop
	ld bc, $000a			; Invalidate the whole score area
	ld de, $1002
	call InvalidateSTiles
	call TransferDirtyTiles
	ret

; Draw password for level
score_password_string_rom: db "PASSWORD:1234567890",0
score_gameover_string_en: db "    PRESS FIRE",0
score_gameover_string:    db "   PULSA DISPARO",0

draw_gameover_string:
        ld a, (language)
        and a
        jr z, draw_gameover_spanish
    	ld iy, score_gameover_string_en
        jr draw_password_common
draw_gameover_spanish:
   		ld iy, score_gameover_string
draw_gameover_common:
        jr draw_password_common

draw_password:
        call ENCODE
        ld de, score_password_string+9
        ld a, (score_password_value)
        call HEX_TO_TEXT
        ld a, (score_password_value+1)
        call HEX_TO_TEXT
        ld a, (score_password_value+2)
        call HEX_TO_TEXT
        ld a, (score_password_value+3)
        call HEX_TO_TEXT
        ld a, (score_password_value+4)
        call HEX_TO_TEXT

        ld iy, score_password_string
draw_password_common:
        ld a, 1
        ld (score_semaphore), a ; the score area is now my precious!!!
        call clean_scorearea
        ld bc, 6*256+22         ; Go print string
        call print_string2
		ld bc, $000a			; Invalidate the whole score area
		ld de, $1002
		call InvalidateSTiles
		call TransferDirtyTiles
        call wait_till_read
        call load_scorearea
        xor a
        ld (score_semaphore), a ; now you can do whatever you want with the score area
        ld a, 2
        ret

; Force an inventory redraw
force_inv_redraw:
        ld a, 1
        ld (inv_refresh), a
        ld (frames_noredraw), a         ; trick to force a redraw
        call waitforVBlank
        jp RedrawScreen


scorearea: INCBIN "marcador.SR5.plet1"
WEAPON_SPRITES: INCBIN "armas.SR5.plet1"
