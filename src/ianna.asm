org $4000
; MSX Cartridge header
        defb     $41
        defb     $42
        defw     start
        defw     $0000
        defw     $0000
        defw     $0000
        defw     $0000
        defw     $0000
        defw     $0000

start:
    di
    im 1
    ld      sp, $f380
	; avoid issues in certain MSX combinations (disk drive in slot 1, cart in slot 2 for example)
	; thanks to Armando Pérez!
    LD      A,#C9
    LD      (#FD9A),A
    LD      (#FD9F),A
	; Page ROM into $8000 - $BFFF

ENAP2:
    CALL   RSLREG      ;read primary slot #
    RRCA         ;move it to bit 0,1 of [Acc]
    RRCA
    AND   00000011B
    LD   C,A
    LD   B,0
    LD   HL,EXPTBL   ;see if this slot is expanded or not
    ADD   HL,BC
    LD   C,A      ;save primary slot #
    LD   A,(HL)      ;See if the slot is expanded or not
    AND   $80
    OR   C      ;set MSB if so
    LD   C,A      ;save it to [C]
    INC   HL      ;Point to SLTTBL entry
    INC   HL
    INC   HL
    INC   HL
    LD   A,(HL)      ;Get what is currently output
                     ;to expansion slot register
    AND   00001100B
    OR   C      ;Finally form slot address
    ld (slot2address), A   ; save it!
    LD   H,80H
    CALL   ENASLT      ;enable page 2

; Disable keyboard click
    xor a
    LD      (CLIKSW), A
; Select very basic configuration of ROM banks
; We will use an ASCII16 mapping
;       Bank 1: Page 0 ($4000 - $7FFF) - no changes if possible
;       Bank 2: Page 1 ($8000 - $BFFF)
	ld ($6000), a
    inc a
    ld ($7000), a
    EI
    jp main

main:
	call check_msx1
	call init_screen5
	call initVDPBuffers
	call initROMbanks
	call MUSIC_Init
	call init_ISR
	call LoadFONT
	call LoadFONT_menu
	xor a
	ld (language), a
	ld (action_ack), a
	ld (wait_alternate), a
	ld (intro_shown), a
	ld hl, 123
	ld (randData), hl
	ld a, 6
	ld (delay60HZ), a
	ld hl, score_password_string_rom
	ld de, score_password_string
	ld bc, 20
	ldir
    ld hl, start_player
    ld de, MUSIC_CODE
    ld bc, end_player-start_player
    ldir

	ld hl, string_1
	ld (string_list), hl
	ld hl, string_1_es
	ld (string_list_es), hl
	ld hl, string_2
	ld (string_list+2), hl
	ld (string_list_es+2), hl
	ld hl, string_3
	ld (string_list+4), hl
	ld hl, string_3_es
	ld (string_list_es+4), hl
	ld hl, string_4_1
	ld (string_list+6), hl
	ld (string_list_es+6), hl
game_loop:
	call cls
	call mainmenu
	ld hl, ISR
	call INSTALL_ISR
begin_level:
	call MUSIC_Stop
	call cls
	call intro
	call MUSIC_Stop
	call cls
	call InitVariables
	call InitSprites
	call InitEntities
	call InitObjectTable
	call InitPlayer
	call LoadScoreWeapons
	call LoadLevel
	ld a, 1
	ld (show_passwd), a
	call SaveCheckpoint
internal_loop:
	call game
	call MUSIC_Stop
	ld a, (current_level)
	cp 8
	jr z, internal_loop_attract
	call draw_gameover_string
internal_loop_attract:
	ld a, (player_dead)
	;cp 2
	sub 2
	jr z, game_loop     ; back to main menu
	;cp 3
	dec a
	jr z, begin_level   ; new level
    ; cp 4
    dec a
    jp z, end_game      ; game completed!
	jr internal_loop
game:
	call InitTiles
	call RestoreCheckpoint
;	call load_player_weapon_sprite
	ld a, (current_levely)
	and a
	jr z, LoadScreen_addx
	ld c, a			; C has current_levely
	ld a, (level_width)
	ld b, a			; B has level_width
	xor a
LoadScreen_loop:
	add a, c
	djnz LoadScreen_loop	; so we multiply current_levely*level_width
LoadScreen_addx:
	ld hl, current_levelx
	add a, (hl)

	call LoadScreen
	ld ix, CURRENT_SCREEN_OBJECTS
	call LoadObjects
	ld hl, CURRENT_SCREEN_OBJECTS
	call load_script

	ld a, (current_level)
	call MUSIC_Load
	call load_scorearea
	call DrawScreen

	ld ix, (ENTITY_PLAYER_POINTER)
	ld a, (initial_coordx)
	ld b, a
	ld a, (initial_coordy)
	ld c, a
	call UpdateSprite
	call RedrawScreen
	ld a, (current_level)
	and a
	jr z, mainloop		; do not show password in level 1 (makes no sense)
	cp 8
	jr nc, mainloop		; in attract mode and secret level, do not show password
	ld a, (show_passwd)
	and a
	jr z, mainloop
	xor a
	ld (show_passwd), a
	call draw_password
mainloop:
	ld a, (current_level)
	cp 8
	jr nz, mainloop_go		; only check this if we are in attract mode
	ld a, (joystick_state)
	bit 4, a			; BIT 4 is FIRE
    jr z, mainloop_go
	; Pressed fire while in attract mode, let's get out of here!
	ld a, 2
	ld (player_dead), a
mainloop_go:
	; Press H for pause menu
	ld hl, KEY_H
	call get_keyboard
    and a
	jr z, mainloop_nopause
	ld a, FX_PAUSE
	call FX_Play
	call pause_menu
	ld a, FX_PAUSE
	call FX_Play
mainloop_nopause:
	ld a, (animate_tile)
	inc a
	ld (animate_tile), a
	and 1
	jr nz, no_animate_tiles
	call AnimateSTiles
no_animate_tiles:
	; Run scripts
	call RunScripts
	; Check gravities
	call CheckGravities
	; And redraw
	call RedrawScreen_part1
	call waitforVBlank
	call RedrawScreen_part2

	ld a, (player_dead)
	and a
	ret nz		; if the player is dead, exit
	; tick global timer
	ld a, (global_timer)
	and a
	jp z, mainloop
	dec a
	ld (global_timer), a
	jp mainloop

end_game:
	call MUSIC_Stop
	call cls
	call ending
	call cls
    jp game_loop

waitforVBlank:
	push af
	push bc
	push de
	push hl
	push ix
	push iy
waitforVBlank_loop:
	ld a, (frames_noredraw)
    ld hl, frames_lock
	cp (hl)			; wait until we have spent at least 5 (PÂL) or 6 (NTSC) frames without redrawing
	jr nc, vblank_done
waitforVBlank_score:
	ld a, (score_semaphore)
	and a
	jr nz, waitforvblank_halt_go	; if the score_semaphore is taken, do nothing!
	ld a, (inv_refresh)
	and a
	jr z, waitforVBlank_noscore
	call draw_score_inventory
waitforVBlank_noscore:
	ld a, (inv_what_to_print)
	and a
	jr nz, waitforvblank_check1
waitforvblank_0:
	call draw_barbarian_state
	ld a, 1
	jr waitforvblank_halt
waitforvblank_check1:
	;cp 1
	dec a
	jr nz, waitforvblank_2
waitforvblank_1:
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, 24
	call draw_enemy_state
	ld a, 2
	jr waitforvblank_halt
waitforvblank_2:
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, 27
	call draw_enemy_state
	xor a
waitforvblank_halt:	
	ld (inv_what_to_print), a
waitforvblank_halt_go:	
	halt
	jr waitforVBlank_loop
vblank_done:
	xor a
	ld (frames_noredraw), a ; 0 frames without a redraw
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret


; Initialize variables:
InitVariables:
	xor a
	ld hl, joystick_state
	ld (hl), a
	ld de, level_nscreens
	ld bc, player_dead-joystick_state
	ldir
	ld a, 1
	ld (player_available_weapons), a
	xor a
;	ld (player_available_weapons+1), a
;	ld (player_available_weapons+2), a
;	ld (player_available_weapons+3), a
	ld (screen_changed), a
;	ld a, 15
;	ld (player_experience), a ; FIXME this is a cheat
	ret

; Go to new screen
; INPUT:
;	- A: new screen, in the format expected by LoadScreen
ChangeScreen:
	call LoadScreen
	call ReInitSprites	
	call ReInitEntities
	ld ix, CURRENT_SCREEN_OBJECTS
	call LoadObjects
	ld hl, CURRENT_SCREEN_OBJECTS
	call load_script
	call draw_score_status

	; invalidate the whole area to force a full redraw
	; And copy the actual tiles
	ld bc, 0
	ld de, 16*256+12
	call InvalidateSTiles
	call RedrawScreen

	ld a, 4
	ld (frames_noredraw), a ; 4 frames without a redraw, this means redraw on the next frame!
	ld (screen_changed), a	; any value != 0 means we changed screen
	ret


; Save checkpoint
SaveCheckpoint:
	; We have to save
	; 1- The sprite and entity data areas (224 bytes)
	halt

	ld hl, SPDATA
	ld de, CHECKPOINT_AREA
	ld bc, 224
	ldir			; and copy 
	; 2- Current status (up to 32 bytes, currently 27)
	ld hl, global_timer
	ld de, CHECKPOINT_AREA + 224
	ld bc, player_current_weapon-global_timer+1
	ldir			; and copy
	; 3- And the object data (256 bytes)
	ld hl, OBJECT_DATA
	ld de, CHECKPOINT_AREA + 256
	ld bc, 256
	ldir	
	ret

; Restore checkpoint
RestoreCheckpoint:
	; 1- The sprite and entity data areas ( 224 bytes)
	halt
	ld hl, CHECKPOINT_AREA
	ld de, SPDATA
	ld bc, 224
	ldir			; and copy 
	; 2- Current status (up to 32 bytes, currently 27)
	ld hl, CHECKPOINT_AREA + 224
	ld de, global_timer
	ld bc, player_current_weapon-global_timer+1
	ldir			; and copy
	; 3- And the object data (256 bytes)
	ld hl, CHECKPOINT_AREA + 256
	ld de, OBJECT_DATA
	ld bc, 256
	ldir	
	call ReInitSprites	
	jp ReInitEntities
;	call ReInitEntities
;	ret


; Load level
; No parameters.
; The basic map structure is:
;	Byte 0-7: 	LEVELXXX, where XXX will be a level-specific key
;	Byte 8-9:	offset_strings_english
;	Byte 10-11:	offset_strings
;	Byte 12:	level_nscreens
;	Byte 13: 	level_width
;	Byte 14:	level_height
;	Byte 15:	level_nscripts
;	Byte 16:	level_strings
;	Byte 17-18:	initial screen (x,y)
;	Byte 19-20:	initial coords in first screen (x,y)
;	Byte 21:	reserved
;	Byte 22-XXX:	addresses of compressed screens (level_width * level_height * 2 bytes). For now, maximum 64 screens per level (128 bytes)
;	XXX-YYY:	compressed screens
	
			;   level1,level2,level3,level4,level5,level6,level7,level8,level0,level9
LEVEL_PAGE:	  db    22,    24,    26,    28,    30,    32,    34,    36,    43,    38
LEVEL_TILE_PAGE: db 23,    25,    27,    29,    31,    33,    35,    37,    23,    39  
LEVEL_OFFSET: dw $8000, $8000, $8000, $8000, $8000, $8000, $8000, $8000, $8000, $8000

LoadLevel:
    ld a, (current_level)
	ld e, a
	ld d, 0

	ld hl, LEVEL_PAGE
	add hl, de
	ld a, (hl)			; A: ROM bank to set
	call setROM2

	ld a, (current_level)
	add a, a
	ld e, a
	ld d, 0
	ld hl, LEVEL_OFFSET
	add hl, de			; HL points to the level offset
	ld a, (hl)
	ld ixl, a
	inc hl
	ld a, (hl)
	ld ixh, a			; IX: level offset

	ld a, (ix+8)
	ld l, a
	ld a, (ix+9)
	ld h, a	
	ld (level_string_en_addr), hl
	ld a, (ix+10)
	ld l, a
	ld a, (ix+11)
	ld h, a	
	ld (level_string_addr), hl
	ld a, (ix+12)
	ld (level_nscreens), a
	ld a, (ix+13)
	ld (level_width), a
	ld a, (ix+14)
	ld (level_height), a	
	ld a, (ix+15)
	ld (level_nscripts), a
	ld a, (ix+16)
	ld (level_nstrings), a
	ld a, (ix+17)
	ld (current_levelx), a
	ld a, (ix+18)
	ld (current_levely), a
	ld a, (ix+19)
	ld (initial_coordx), a
	ld a, (ix+20)
	ld (initial_coordy), a

	push ix			; save the level address 
	ld a, (language)
	and a
	jr nz, load_strings_en
	ld hl, (level_string_addr)
	jr load_strings_common
load_strings_en:
	ld hl, (level_string_en_addr)
load_strings_common:
	ld de, string_area		; level_strings + scripts
	call depack

	; finally, get the list of screens into RAM
	ld a, (level_nscreens)
	add a, a		; * 2
	ld c, a
	ld b, 0
	pop hl			; restore the level address
	ld de, 22
	add hl, de		; At the beginning+22, we have the first one
	ld de, LEVEL_SCREEN_ADDRESSES
	ldir			; and copy all the stuff

	; Finally, load tiles in VRAM
    ld a, (current_level)
	ld e, a
	ld d, 0
	ld hl, LEVEL_TILE_PAGE
	add hl, de
	ld a, (hl)			; A: ROM bank to set
	call setROM2
	ld hl, TILES_START_ADDR
	ld de, $8000
	call unpackVRAM
	ld a, 2
	call copyPage

	ld a, 1			; Set ROM bank 1
	call setROM2
	; FIXME: this is just meant to be running quick tests without changing the map
	;ld a, 2
	;ld (current_levelx), a
	;ld a, 1
	;ld (current_levely), a
	ret


; Load screen
; INPUT:
;	- A: screen to load

LoadScreen:
	add a, a		; to index the array
	ld c, a
	ld b, 0
	ld hl, LEVEL_SCREEN_ADDRESSES
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE points to the screen address

    ld a, (current_level)
	ld c, a
	ld b, 0

	ld hl, LEVEL_PAGE
	add hl, bc
	ld a, (hl)			; A: ROM bank to set
	call setROM2

	ex de, hl		; HL has the source
	ld de, CURRENT_SCREEN_MAP
	call depack
	; Find the number of animated tiles in the screen!!!
LoadScreen_FindAnimTiles:
	xor a
	ld (curscreen_numanimtiles), a
	ld hl, curscreen_animtiles	; area in memory with the animated tile positions
	ld de, CURRENT_SCREEN_MAP
	ld b, 10		; 10 in Y
load_findanim_loopy:	
	ld c, 16		; 16 in X	
load_findanim_loopx:
	ld a, (de)
	cp 240
	jr c, load_findanim_notfound
load_findanim_found:		; this is an animated tile
	ld a, 16
	sub c			; 16-C is the X position
	ld (hl), a
	inc hl
	ld a, 10
	sub b			; 10-B is the Y position
	ld (hl), a
	inc hl
	ld a, (curscreen_numanimtiles)
	inc a
	ld (curscreen_numanimtiles), a	; We have one more animated tile
load_findanim_notfound:
	inc de
	dec c
	jp nz, load_findanim_loopx
	djnz load_findanim_loopy
	; Find animated foreground tiles
LoadScreen_FindAnimTiles_FG:
	; hl already points to the right position in curscreen_animtiles
	ld de, CURRENT_SCREEN_MAP_FG
	ld b, 10		; 10 in Y
load_findanim_loopy_fg:	
	ld c, 16		; 16 in X	
load_findanim_loopx_fg:
	ld a, (de)
	cp 240
	jr c, load_findanim_notfound_fg
load_findanim_found_fg:		; this is an animated tile
	ld a, 16
	sub c			; 16-C is the X position
	ld (hl), a
	inc hl
	ld a, 10
	sub b			; 10-B is the Y position
	ld (hl), a
	inc hl
	ld a, (curscreen_numanimtiles)
	inc a
	ld (curscreen_numanimtiles), a	; We have one more animated tile
load_findanim_notfound_fg:
	inc de
	dec c
	jp nz, load_findanim_loopx_fg
	djnz load_findanim_loopy_fg
	ld a, 1			; Set ROM bank 1
	call setROM2
	ret


; Pre-flush changes to screen
RedrawScreen_part1:
	call RedrawInvTiles	
	call DrawSpriteList	; then the sprite list
	call RedrawInvTiles_FG
    ret

; Flush changes to screen
RedrawScreen:
	call RedrawInvTiles	
	call DrawSpriteList	; then the sprite list
	call RedrawInvTiles_FG
RedrawScreen_part2:
	; Switch visible screen to the shadow one
	ld a, 1
	call setDisplayPage
	call TransferDirtyTiles	; Transfer dirty tiles to main screen
	; Finally, switch again the visible screen
	xor a
	call setDisplayPage
	ret

; Run scripts for all entities
RunScripts:
	xor a
	ld (screen_changed), a
	ld ix, ENTITY_PLAYER_POINTER
	ld a, (joystick_state)
	ld (entity_joystick), a
	ld iy, scratch_area_player
	ld a, BARBARIAN_ROM_PAGE	; ROM page for barbarian
	ld (sprite_rom_page), a
	call run_script
	ld ix, ENTITY_PLAYER_POINTER
	call script_player
	; If we changed screen, we should stop now!
	ld a, (screen_changed)
	and a
	ret nz
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr z, runs_noenemy1
	xor a
	ld (entity_joystick), a
    call get_enemy_rom_page
	ld iy, scratch_area_enemy1
	call run_script
	ld ix, ENTITY_ENEMY1_POINTER
	call action_joystick
runs_noenemy1:
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr z, runs_noenemy2
	xor a
	ld (entity_joystick), a
    call get_enemy_rom_page
	ld iy, scratch_area_enemy2
	call run_script
	ld ix, ENTITY_ENEMY2_POINTER
	call action_joystick
runs_noenemy2:
	ld b, 5		; 5 objects
	ld ix, ENTITY_OBJECT1_POINTER
	ld iy, scratch_area_obj1
runs_object_loop:
	push iy
	push ix
	push bc
	ld a, (ix+0)
	or (ix+1)
	jr z, runs_noobj	; skip object if absent
	call run_script
runs_noobj:
	pop bc
	pop ix
	pop iy
	ld de, ENTITY_SIZE		; entity size
	add ix, de		; go to next object
	ld de, 8		; scratch area size
	add iy, de
	djnz runs_object_loop
	ret

; Check gravity for player and enemies
CheckGravities:
	ld a, BARBARIAN_ROM_PAGE	; ROM page for barbarian
	ld (sprite_rom_page), a
	ld ix, ENTITY_PLAYER_POINTER
	call entity_gravity
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr z, chkg_noenemy1	
	call get_enemy_rom_page
	call entity_gravity
chkg_noenemy1:
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, (ix+0)
	or (ix+1)
	ret z
	call get_enemy_rom_page
	jp entity_gravity
;	call entity_gravity
;	ret


; Routine to clear screen
; FIXME: implement something cool
cls:
	call fadeMSX2
    ld a, $11
    ld bc, 0
    ld d, 256
    ld e, 192
    ld h, 0
    call fillArea
    ld a, $11
    ld bc, 0
    ld d, 256
    ld e, 192
    ld h, 1
    call fillArea
	ld hl, tilespal
	call VDP_SetPalette
	ret

; Interrupt routine
ISR:
	; simply get the joystick state
	ld a, (ROMBank1)		;System var with the previous value
	push af
	ld a, 1
	call setROM2_DI

	call get_joystick
;	ld b, a
;	ld a, (joystick_state)
;	or b
	ld (joystick_state), a
	; increase the variable defining the number of frames without screen update
	ld a, (frames_noredraw)
	inc a
	ld (frames_noredraw), a
	; and play music, if needed
	ld a, (music_playing)
	and a
	jr z, ISR_end		; if not playing music, do nothing
	call mzk_subroutine
ISR_end:
	pop af
	call setROM2_DI	
	ret

mzk_subroutine:
    ; Find out whether this is a PAL or NTSC MSX (commented out for now, maybe we can force 50/60HZ everywhere)
    ld a, ($002b)
    and $80         ; The highest bit is 1 for PAL, 0 for NTSC
    jr nz, ISR_PAL
ISR_NTSC:
	ld a, (delay60HZ)
	dec a
	ld (delay60HZ), a
	jr nz, ISR_PAL		; for NTSC, skip 1 out of 6 ints
	ld a, 6
	ld (delay60HZ), a
	ret
ISR_PAL:
	call MUSIC_Play
	ret

; Indirect call to the address stored in HL
IndCall:
	jp (hl)

; Random routine from http://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
;-----> Generate a random number
; ouput a=answer 0<=a<=255
; all registers are preserved except: af

random:
        push    hl
        push    de
        ld      hl,(randData)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
        pop     de
        pop     hl
        ret

; Multiply two 8-bit values into a 16-bit value
; INPUT: H - value 1
;		 E - value 2
; OUTPUT: HL: result
Mul8x8:                           ; this routine performs the operation HL=H*E
  ld d,0                         ; clearing D and L
  ld l,d
  ld b,8                         ; we have 8 bits
Mul8bLoop:
  add hl,hl                      ; advancing a bit
  jp nc,Mul8bSkip                ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mul8bSkip:
  djnz Mul8bLoop
  ret

;Divide 8-bit values
;In: Divide E by divider D
;Out: A = result, D = rest
;
Div8:
    xor a
    ld b,8
Div8_Loop:
    rl e
    rla
    sub d
    jr nc,Div8_NoAdd
    add a,d
Div8_NoAdd:
    djnz Div8_Loop
    ld d,a
    ld a,e
    rla
    cpl
    ret

; Divide a 16-bit value by an 8-bit one
; INPUT: HL / C
; OUTPUT: HL: result

Div16_8:
  push de
  ld a,c                         ; checking the divisor; returning if it is zero
  or a                           ; from this time on the carry is cleared
  ret z
  ld de,-1                       ; DE is used to accumulate the result
  ld b,0                         ; clearing B, so BC holds the divisor
Div16_8_Loop:                    ; subtracting BC from HL until the first overflow
  sbc hl,bc                      ; since the carry is zero, SBC works as if it was a SUB
  inc de                         ; note that this instruction does not alter the flags
  jr nc,Div16_8_Loop             ; no carry means that there was no overflow
  ex de, hl                      ; HL gets the result
  pop de
  ret

DECODE:
        ld ix, password_value
        ld a, (ix+0)
        and $0f
        ld (current_level), a
        ld hl, 0
        ld (player_available_weapons), hl
        ld (player_available_weapons+2), hl
        ld iy, player_available_weapons
        ld a, (ix+0)
        bit 7, a
        jr z, decode_2
        ld (iy+0), 1
decode_2:
        bit 6, a
        jr z, decode_3
        ld (iy+1), 1
decode_3:
        bit 5, a
        jr z, decode_4
        ld (iy+2), 1
decode_4:
        bit 4, a
        jr z, decode_end
        ld (iy+3), 1
decode_end:
        ld a, (ix+1)
        ld (player_level), a
        ld a, (ix+2)
        ld (player_experience), a
        ld a, (ix+3)
        ld (player_current_weapon), a
        ret

ENCODE:
        ld e, 0         ; e == checksum
        ld ix, score_password_value
        ld a, (current_level)
        ld b, a
        ld hl, player_available_weapons
        ld c, $80
        call testbyte
        ld c, $40
        call testbyte
        ld c, $20
        call testbyte
        ld c, $10
        call testbyte
        ld a, b
        add a, e
        ld e, a
        ld a, b
        xor $55
        ld (ix+0), a
        ld a, (player_level)
        add a, e
        ld e, a
        ld a, (player_level)
        xor $55
        ld (ix+1), a
        ld a, (player_experience)
        add a, e
        ld e, a
        ld a, (player_experience)
        xor $55
        ld (ix+2), a
        ld a, (player_current_weapon)
        add a, e
        ld e, a
        ld a, (player_current_weapon)
        xor $55
        ld (ix+3), a
        ld (ix+4), e    ; checksum
        ret

; INPUT:
; C: byte to add
; HL: pointer
testbyte:
        ld a, (hl)
        inc hl
        and a
        ret z
        ld a,b
        or c
        ld b,a
        ret

; Convert HEX value into text
; Input: 
;       - A: value to convert
;       - DE: where to put the value, gets incremented

HEX_TO_TEXT:
     ld c,a
     rra
     rra
     rra
     rra
     call HT_CONV
     ld a,c
HT_CONV:
     and 15
     add a,48
     cp 58
     jr c,noletter2
     add a,7
noletter2:
     ld (de), a
     inc de
     ret

INCLUDE "vdp.asm"
INCLUDE "pletter.asm"
INCLUDE "music.asm"
INCLUDE "sprites.asm"
INCLUDE "memory.asm"
INCLUDE "interrupt.asm"
INCLUDE "depack.asm"
INCLUDE "input.asm"
INCLUDE "entities.asm"
INCLUDE "scripts.asm"
INCLUDE "drawsprite.asm"
INCLUDE "intro.asm"

menu_screen: EQU $8000 + 1767

menu_load_screen:
	ld a, 43		; Set ROM bank 43, where the menu_screen is
	call setROM2
	ld hl, menu_screen
	ld de, $8000
	call unpackVRAM
	ld a, 1         ; go back to bank 1
	call setROM2
    ret

END_ROM0:

org $8000
INCLUDE "tiles.asm"
INCLUDE "objects.asm"
INCLUDE "score.asm"
INCLUDE "font.asm"
INCLUDE "menu.asm"
INCLUDE "vdp_data.asm"

blackpal: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
tilespal:  INCBIN "test.plt"
; Barbarian constants
barbarian_level_exp:  db 16, 64, 96, 128, 160, 192, 240, 255
barbarian_max_energy: db  6, 10, 18, 32,  48,  64,  80,  99 

enemy_info:
enemy_info_skeleton: 	DB   2,  7,  14,  25,  35,  50, 65	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  40,  75, 100, 140, 180, 215, 235	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 100, 125, 150, 175	; Blocking probability, per level
		     	DB  13,  14,  12, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_orc:		DB   2,  7,  14,  25,  35,  50, 65
			DB  20,  40,  80, 120, 160, 200, 220
			DB  40,  75, 100, 140, 180, 215, 235
			DB  20,  40,  80, 100, 125, 150, 175	
			DB  13,  16,  15, 0

enemy_info_mummy:	DB   2,  5,   10,  20,  35,  50,  70
			DB  20,  40,  80, 120, 160, 200, 220
			DB  40,  75, 100, 140, 180, 215, 235
			DB  20,  40,  80, 100, 125, 150, 175
			DB  18,  14,  17, 0

enemy_info_troll:	DB   5,  10,  20,  35,  45,  60,  80
			DB  20,  40,  80, 120, 160, 200, 220
			DB  40,  75, 100, 140, 180, 215, 235
			DB  20,  40,  80, 100, 125, 150, 175
			DB  13,  16,  19, 0

enemy_info_rock:	DB 255,  255,  255,  255,  255,  255,  255
			DB   0,  0,  0,  0,  0,  0,  0
			DB   0,  0,  0,  0,  0,  0,  0
			DB   0,  0,  0,  0,  0,  0,  0
			DB  20, 20, 20, 0

enemy_info_knight: 	DB   7,  12,  20,  30,  45,  55,  70	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  40,  75, 100, 140, 180, 215, 235	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  22,  23,  21, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_dalgurak: 	DB   99,  99,  99,  99,  99,  99, 99; 99	; Energy per level
		     	DB  80,  80,  80, 80, 80, 80, 80	; Probability of long-range attack, per level
		     	DB  40,  75, 100, 140, 180, 215, 235	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  12,  30, 29, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_golem: 	DB  10,  20,  35,  50,  65,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  40,  80,  120, 160, 200, 220, 240	; Blocking probability, per level
		     	DB  16,  13,  19, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_ogre: 	DB  10,  20,  35,  50,  65,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  25,  26,  24, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_minotaur: 	DB 10,  20,  35,  50,  65,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  25,  26,  12, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_demon: 	DB 10,  20,  35,  48,  60,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  28,  24,  27, 0			; short1, short2, far attack, 0 padding to make it 32 bytes


FONT: INCBIN "font.SR5.plet1"

start_player:
INCBIN "arkos.bin"
end_player:

; Pause menu data
pause_string0: DB 42, 43, 43, 43, 43, 43,'P','A','U','S','E', 40, 40, 40, 40, 40, 41,0
pause_string1: DB 60, 91, 92, 32,'I','N','V','E','N','T','A','I','R','E', 32, 32, 60,0
pause_string2: DB 60, 93, 94, 32,'U','T','I','L','I','S','E','R',' ','O','B','J', 60,0
pause_string3: DB 60, 64, 32, 32,'C','H','A','N','G','E','R',' ','A','R','M','E', 60,0
pause_string4: DB 61,'H',' ',' ','C','O','N','T',' ',' ','X',' ','Q','U','I','T', 61,0
pause_string5: DB 42, 43, 43, 43, 43, 43, 43, 43,' ', 40, 40, 40, 40, 40, 40, 40, 41,0

pause_string0_en: DB 42, 43, 43, 43, 43, 43,'P','A','U','S','E', 40, 40, 40, 40, 40, 41,0
pause_string1_en: DB 60, 91, 92, 32,'I','N','V','E','N','T','O','R','Y', 32, 32, 32, 60,0
pause_string2_en: DB 60, 93, 94, 32,'U','S','E',' ','O','B','J','E','C','T', 32, 32, 60,0
pause_string3_en: DB 60, 64, 32, 32,'P','I','C','K', 32,'W','E','A','P','O','N', 32, 60,0
pause_string4_en: DB 61,'H',' ',' ','B','A','C','K',' ',' ','X',' ','Q','U','I','T', 61,0
pause_string5_en: DB 42, 43, 43, 43, 43, 43, 43, 43,' ', 40, 40, 40, 40, 40, 40, 40, 41,0

intro_strings: dw string01, string02, string03, string04, string05
intro_strings_en: dw string01_en, string02_en, string03_en, string04_en, string05_en
final_strings: dw end_string01, end_string02, end_string03
final_strings_en: dw end_string01_en, end_string02_en, end_string03_en

string01: db 'IL Y A BIEN LONGTEMPS, LE MONDE ?TAIT DOMIN? PAR LE SEIGNEUR DU CHAOS.',0
string02: db "FACE % CE FL?AU, LA D?ESSE IANNA CHOISIT TUKARAM POUR BRANDIR L'?P?E SACR?E QUI POURRAIT VAINCRE LE MAL.",0
string03: db 'TUKARAM APPORTA LA PAIX SUR NOS TERRES, ET SES DESCENDANTS FURENT D?SIGN?S SERVITEURS DE LA D?ESSE.',0
string04: db 'MAIS LE MAL NE MEURT JAMAIS, ET APR$S DES SI$CLES IL ESSAIE DE REFAIRE SURFACE.',0
string05: db "EN TANT QU'H?RITIER DE TUKARAM, C'EST TON DEVOIR SACR? D'ALLER VAINCRE LE CHAOS ET RESTAURER L'ORDRE.",0

string01_en: db 'A LONG TIME AGO, THE WORLD WAS RULED BY THE NOCUOUS LORD OF CHAOS.',0
string02_en: db 'THE GODDESS IANNA APPOINTED TUKARAM TO WIELD THE SACRED SWORD THAT COULD DEFEAT EVILNESS.',0
string03_en: db 'TUKARAM BROUGHT PEACE TO OUR LANDS, AND HIS LINEAGE WAS BLESSED AS SERVANTS OF THE GODDESS.',0
string04_en: db 'BUT EVIL DOES NOT REST, AND SOME CENTURIES LATER IT TRIES TO RECOVER.',0
string05_en: db 'AS AN HEIR OF TUKARAM, IT IS YOUR SWORN DUTY TO GO NOW, OVERCOME CHAOS AND RESTORE ORDER.',0

end_string01: db 'LE SEIGNEUR DU CHAOS A ?T? VAINCU, ET LA D?ESSE IANNA EST RECONNAISSANTE.',0
end_string02: db "RETROUVE TON VILLAGE, FID$LE GUERRIER, ET VIS EN PAIX. JE VAIS VEILLER SUR L'?P?E, CAR LE MAL NE MEURT JAMAIS.",0
end_string03: db 'RENTRER AU PAYS EST LA PLUS GRANDE DES R?COMPENSES, ET LA PAIX LE PLUS PR?CIEUX DES BIENS.',0

end_string01_en: db 'THE LORD OF CHAOS HAS BEEN DEFEATED, AND IANNA IS WELL PLEASED.',0
end_string02_en: db 'GO BACK TO YOUR VILLAGE AND ENJOY A PEACEFUL LIFE. I WILL KEEP THE SWORD, FOR EVIL DOES NOT REST.',0
end_string03_en: db 'RETURNING HOME IS THE HIGHEST REWARD, AND PEACE THE MOST PRECIOUS POSSESSION.',0

; If this is a MSX1, display an error message and halt
MSX1_MSG: db 'SORRY, YOU NEED AN MSX2 OR HIGHER TO          PLAY THE SWORD OF IANNA.',0
;GRPPRT: EQU $008D
CHPUT: EQU $00A2
;INIGRP: EQU $0072
INITXT: EQU $006C

check_msx1:
	ld a,($2d)		; read MSX version
	or a			; is it MSX1?
	ret nz
check_msx1_msg:
	call INITXT
	ld hl, MSX1_MSG
check_msx1_msg_loop:
	ld a, (hl)
	and a
	jr z, check_msx1_msg_crash
	push hl
	call CHPUT
	pop hl
	inc hl
	jr check_msx1_msg_loop
check_msx1_msg_crash:
	di
	halt

; Update offset for Barbarian rom page
UpdatePlayerWeapon:
    ; First check if we are in the additional page,
    ; and ignore in that case
    ld ix, ENTITY_PLAYER_POINTER
	ld e, (ix+0)
	ld d, (ix+1)    ; Sprite in DE
    inc de
    inc de          ; Go to DE+2
    ld a, (de)
    and $7f
    cp BARBARIAN_ADDITIONAL_ROM_PAGE
    ret z
	ld a, (player_current_weapon)
    and a
    jr z, UpdatePlayerWeapon_noinc
    inc a
UpdatePlayerWeapon_noinc:
    add a, BARBARIAN_ROM_PAGE
    ld c, a         ; C is the new bank
    ld a, (de)      ; get sprtype + ROM Bank
    and $80
    or c
    ld (de), a      ; and store
    ret

pause_menu:
	; first, wait until the H key is released
	ld hl, KEY_H
	call get_keyboard
	and a
	jr nz, pause_menu
pause_menu_print:
	ld a, (language)
	and a
	jr nz, pause_menu_en
	ld iy, pause_string0
	jr pause_menu_print_go
pause_menu_en:
	ld iy, pause_string0_en
pause_menu_print_go:
	ld bc, 8*256 + 8
	ld a, 6
pause_menu_print_loop:
	push bc
	push iy
	push af
	call print_string2		
	pop af
	pop iy
	pop bc
	ld de, 18
	add iy, de
	inc c
	dec a
	jr nz, pause_menu_print_loop

	ld bc, $0404			; Invalidate the whole area
	ld de, $0903
	call InvalidateSTiles
	call TransferDirtyTiles

pause_menu_inner_loop:
	ld a, (joystick_state)
	bit 4, a			; BIT 4 is FIRE
	jr nz, pause_menu_inner_use_object
	bit 2, a			; BIT 2 is left
	jr z, pause_menu_inner_check_right
	; pressed left. wait until it is depressed, change object left
pause_menu_inner_left_loop:
	call pause_menu_waitkey
	bit 2, a
	jr nz, pause_menu_inner_left_loop
	ld a, FX_INVENTORY_MOVE
	call FX_Play
	ld a, (inv_current_object)
	and a
	jp z, pause_menu_inner_done	; cannot reduce the current object
	dec a
	ld (inv_current_object),a
	jr pause_menu_inner_updateinv
pause_menu_inner_check_right:
	bit 3, a			; BIT 3 is right
	jr z, pause_menu_inner_check_down
pause_menu_inner_right_loop:
	call pause_menu_waitkey
	bit 3, a
	jr nz, pause_menu_inner_right_loop
	ld a, FX_INVENTORY_MOVE
	call FX_Play
	ld a, (inv_current_object)
	cp INVENTORY_SIZE - 1
	jr z, pause_menu_inner_done	; cannot increase the current object
	inc a
	ld (inv_current_object),a
pause_menu_inner_updateinv:
	call force_inv_redraw
	xor a
pause_menu_inner_check_down:
	bit 1, a
	jr z, pause_menu_inner_done
	; pressed down. wait until it is depressed, change weapon if available
pause_menu_inner_down_loop:
	call pause_menu_waitkey
	bit 1, a
	jr nz, pause_menu_inner_down_loop
pause_menu_change_weapon:
	ld a, FX_INVENTORY_MOVE
	call FX_Play
	ld a, (player_current_weapon)
	inc a				
	and $3
	ld (player_current_weapon), a
	ld hl, player_available_weapons
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)
	and a
	jr z, pause_menu_change_weapon	; weapon not available, check next
    call UpdatePlayerWeapon
	call draw_weapon
	call RedrawScreen
	jr pause_menu_inner_done
pause_menu_inner_use_object:
	call pause_menu_waitkey
	bit 4, a			; BIT 4 is FIRE
	jr nz, pause_menu_inner_use_object
	ld a, (inv_current_object)
	ld e, a
	ld d, 0
	ld hl, inventory
	add hl, de
	ld a, (hl)	; get object
	cp OBJECT_HEALTH	; the health potion. For now, it is the only one we can use as such
	jr nz, pause_menu_inner_done
	; set maximum health
	ld iy, ENTITY_PLAYER_POINTER
	call get_entity_max_energy	 ; get the maximum energy
	ld (ENTITY_PLAYER_POINTER+4), a				; and set it!
	ld a, FX_INVENTORY_SELECT
	call FX_Play
	ld a, OBJECT_HEALTH
	call remove_object_from_inventory
	jr pause_menu_inner_updateinv
pause_menu_inner_done:
	xor a			
	ld (joystick_state), a	; reset joystick state
pause_menu_check_for_exit:
	ld hl, KEY_H
	call get_keyboard
	and a
	jr nz, pause_menu_wait_for_exit_depressed
pause_menu_check_for_end:
	ld hl, KEY_X
	call get_keyboard
	and a
	jp z, pause_menu_inner_loop
pause_menu_wait_for_end_depressed:
	ld a, 2
	ld (player_dead), a
	ld hl, KEY_H
	call get_keyboard
	and a
	jr nz, pause_menu_wait_for_end_depressed
pause_menu_wait_for_exit_depressed:
	ld hl, KEY_H
	call get_keyboard
	and a
	jr nz, pause_menu_wait_for_exit_depressed
	; invalidate the whole area to force a full redraw
	ld bc, 0
	ld de, 32*256 + 20
	call InvalidateTiles
	jp RedrawAllSprites
;	call RedrawAllSprites
;	ret
pause_menu_waitkey:
	xor a
	ld (joystick_state), a
	halt
	ld a, (joystick_state)
	ret
    

intro_bkg: INCBIN "intro_marco.SR5.plet1"


END_CODE:

org $C000:
	INCLUDE "vars.asm"
