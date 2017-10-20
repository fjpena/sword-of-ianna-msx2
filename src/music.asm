INCLUDE "music_sfx.sym"


;				 level1, level2, level3, level4, level5, level6, level7, level8, attrac, secret, nomus   	gameover		intro       main menu  game end      credits
music_levels: dw music1, music5, music3, music4, music5, music6, music7, music8, music0, music4, music0,  music_gameover, music_intro, music_menu, music_end, music_credits

atInit: equ MUSIC_CODE
atPlay: equ MUSIC_CODE + 3
atStop: equ MUSIC_CODE + 6
atSfxInit: equ MUSIC_CODE + 9
atSfxPlay: equ MUSIC_CODE + 12
atSfxStop: equ MUSIC_CODE + 15


; Initialize music variables
MUSIC_Init:
	xor a
	ld (music_playing), a
	ld (music_state), a
	ld (music_save), a
	ret

; Load music
; INPUT:
;	- A: music number

MUSIC_Load:
	di
	ld l, a
	ld a, (music_state)
	and 2
	jr z, MUSIC_Load_music
	ld a, 10
	jr MUSIC_Load_nomusic
MUSIC_Load_music:
	ld a, l
MUSIC_Load_nomusic:
	push af
	call MUSIC_setbank
	ld hl, music_levels
	pop af
	add a, a
	ld e, a
	ld d, 0
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld de, music_addr		
	call depack
	ld hl, SFX_ADDR
	ld de, music_sfx
	call depack
	ld de, music_addr
	call atInit
	ld de, music_sfx
	call atSfxInit
	ld a, 1
	ld (music_playing), a	; music is now playing
	call MUSIC_restorebank
	ei
	ret

MUSIC_restorebank:
	ld a, (music_save)
	call setROM2_DI		; set previous rom bank
	ret

MUSIC_setbank:
	ld a, (ROMBank1)		;System var with the previous value
	ld (music_save), a
	ld a, MUSIC_ROM_PAGE
	call setROM2_DI
	ret

; Play music

MUSIC_Play:
	jp atPlay

; Stop music
MUSIC_Stop:
	call atStop
	call atSfxStop
	xor a
	ld (music_playing), a
	ret
; Play FX
FX_SWORD1 			EQU 1
FX_DESTROY_BLOCK 	EQU 2
FX_BLOCK_HIT		EQU 3
FX_HIT				EQU 4
FX_LEVER			EQU 5
FX_SKELETON_FALL	EQU 6
FX_PICKUP			EQU 7
FX_GROUND			EQU 8
FX_GRIP				EQU 9
FX_UNSHEATHE		EQU 10
FX_SHEATHE			EQU 11
FX_INVENTORY_MOVE	EQU 12
FX_INVENTORY_SELECT	EQU 13
FX_OPEN_DOOR		EQU 14
FX_CLOSE_DOOR		EQU 15
FX_ENTER_DOOR		EQU 16
FX_TEXT				EQU 17
FX_PAUSE			EQU 18
FX_LONGJUMP			EQU 19
FX_EMPTY		    EQU 20
FX_LEVEL_UP			EQU 21

; Input:
;	A: sound effect to play

FX_Play:
	push hl
	ld l, a
	ld a, (music_state)
	and 1
	jr nz, FX_Play_nofx
	ld a, l
	pop hl
	push bc
	push de
	push hl
	push ix
	push iy

	ld l, a			; effect
	ld a, 1			; channel B
	ld h, 15		; volume
	ld e, 36		; C4 ??
	ld d, 0
	ld bc, 0
	call atSfxPlay

	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	ret
FX_Play_nofx:
	pop hl
	ret
