; Init tiles
; Initialize the dirty tiles area. Will just zero it out.
;
; Now each dirty rectangle will have a simple 4-byte schema:
;
; Byte 0: X char (min)
; Byte 1: Y char (min)
; Byte 2: X char (max)
; Byte 3: Y char (max)
;
; Potentially, we can have up to 48 dirty rectangles, so 48x4=192 bytes
 

InitTiles:
	ld hl, tiles_dirty
	ld bc, 191		; Just fill the whole structure with zeroes
	ld (hl), b
	ld de, tiles_dirty+1
	ldir
	xor a
	ld (ndirtyrects), a	; no dirty tiles.
	ret


; Draw initial screen from tile map
DrawScreen:
	xor a
	ld (ndirtyrects), a	; no dirty tiles.

	ld c, 10
drawsc_y_loop:
	ld b, 16
drawsc_x_loop:
	push bc
	exx
	pop bc
	call DrawTile
	exx
	djnz drawsc_x_loop
	dec c
	jr nz, drawsc_y_loop

	ld c, 10
drawsc_y_loop_fg:
	ld b, 16
drawsc_x_loop_fg:
	push bc
	exx
	pop bc
	call DrawFGTile
	exx
	djnz drawsc_x_loop_fg
	dec c
	jr nz, drawsc_y_loop_fg

	; Switch visible screen to the shadow one
	ld a, 1
	call setDisplayPage
	; And copy the actual tiles
	ld bc, 0
	ld de, 16*256+12
	call InvalidateSTiles
	call TransferDirtyTiles
	; Finally, switch again the visible screen
	xor a
	call setDisplayPage
	ret


; Draw a 16x16 stile
;
; INPUT:
;	B: x stile + 1
;	C: y stile + 1

DrawTile:
	ld a, c
	cp 11
	ret nc			; avoid drawing outside the lower border

	dec b
	dec c

	; We need to index the CURRENT_SCREEN_MAP array
	; the address is CURRENT_SCREEN_MAP + Y*16 + X
	ld a, c
	rlca
	rlca
	rlca
	rlca
	and $f0		; A has Y * 16
	ld c, a		; store for the drawTile routine
	add a, b	; A has Y*16 + X
	ld e, a
	ld a, b
	rlca
	rlca
	rlca
	rlca
	ld b, a		; store for the drawTile routine
	ld d, 0
	ld hl, CURRENT_SCREEN_MAP
	add hl, de
	ld a, (hl)
	jp drawTile


; Draw a 16x16 foreground stile
;
; INPUT:
;	B: x stile + 1
;	C: y stile + 1

DrawFGTile:
	ld a, c
	cp 11
	ret nc			; avoid drawing outside the lower border

	dec b
	dec c

	; We need to index the CURRENT_SCREEN_MAP_FG array
	; the address is CURRENT_SCREEN_MAP_FG + Y*16 + X
	ld a, c
	rlca
	rlca
	rlca
	rlca
	and $f0		; A has Y * 16
	ld c, a		; store for the drawTile routine
	add a, b	; A has Y*16 + X
	ld e, a
	ld a, b
	rlca
	rlca
	rlca
	rlca
	ld b, a		; store for the drawTile routine
	ld d, 0
	ld hl, CURRENT_SCREEN_MAP_FG
	add hl, de
	ld a, (hl)
	and a
	ret z		; exclude tiles == 0
	jp drawFGTile



; Invalidate tiles
; INPUT:
;	B: First tile to invalidate in X
;	C: First tile to invalidate in Y
;	D: Number of tiles to invalidate in X
;	E: Number of tiles to invalidate in Y
InvalidateTiles:
	ld a, d
	add a, b	; A = last X tile
	dec a
	rrca
	and $1f		; A = max stile
	ld d, a	
	ld a, b
	rrca
	and $1f
	ld b, a		; B = min stile
	ld a, d
	sub b
	inc a
	ld d, a		; D = number of stiles

	ld a, e
	add a, c	; A = max Y tile
	dec a
	rrca
	and $1f		; A = max Y stile
	ld e, a
	ld a, c
	rrca
	and $1f
	ld c, a		; C = min Y stile
	ld a, e
	sub c
	inc a
	ld e, a		; E = number of stiles

    push bc
    push de
    push ix
    ld a, d
    add a, a    ; turn stiles into tiles
    ld d, a
    ld a, e
    add a, a    ; turn stiles into tiles
    ld e, a
    call AnimStile_CheckSprites
    pop ix
    pop de
    pop bc


; Invalidate supertiles
; INPUT:
;	B: First supertile to invalidate in X
;	C: First supertile to invalidate in Y
;	D: Number of supertiles to invalidate in X
;	E: Number of supertiles to invalidate in Y

InvalidateSTiles:
	push de
	ld a, (ndirtyrects)
	add a, a	
	add a, a		; a*4
	ld e, a
	ld d, 0
	ld hl, tiles_dirty
	add hl, de		; HL points to the dirty rectangle area
	pop de
	ld (hl), b
	inc hl
	ld (hl), c	
	inc hl
	ld (hl), d
	inc hl
	ld (hl), e
	ld a, (ndirtyrects)
	inc a
	ld (ndirtyrects),a	; we now have one more dirty rect
	ret


; Transfer all dirty tiles from the shadow to the real screen
;
;	INPUT: none
;	OUTPUT: none

TransferDirtyTiles:
	ld a, (ndirtyrects)
	and a
	ret z			; no dirty tiles, just exit
	ld b, a
	ld hl, tiles_dirty 	; get the dirty tiles list
dirtyrectloop_2:
	push bc
	ld b, (hl)		; Xmin
	inc hl
	ld c, (hl)		; Ymin
	inc hl
	ld d, (hl)		; Xcount
	inc hl
	ld e, (hl)		; Ycount
	inc hl
	push hl			; save pointer

dirty_y_loop_2:
	push de
	push bc
dirty_x_loop_2:
	push bc
	exx
	pop bc
	call CopyTile
	exx
	inc b
	dec d
	jr nz, dirty_x_loop_2
	pop bc
	pop de
	inc c
	dec e
	jr nz, dirty_y_loop_2	

	pop hl			; restore pointer to dirty rect list
	pop bc			; restore loop counter
	djnz dirtyrectloop_2	; loop!

	xor a
	ld (ndirtyrects), a	; set dirtyrects number to 0
	ret


; Redraw all invalidated tiles
; No input

RedrawInvTiles:
	ld a, (ndirtyrects)
	and a
	ret z			; no dirty tiles, just exit
	ld b, a
	ld hl, tiles_dirty 	; get the dirty tiles list
dirtyrectloop:
	push bc
	ld b, (hl)		; Xmin
	inc hl
	ld c, (hl)		; Ymin
	inc hl
	ld d, (hl)		; Xcount
	inc hl
	ld e, (hl)		; Ycount
	inc hl
	push hl			; save pointer

dirty_y_loop:
	push de
	push bc
dirty_x_loop:
	push bc
	exx
	pop bc
	inc b
	inc c
	call DrawTile
	exx
	inc b
	dec d
	jr nz, dirty_x_loop
	pop bc
	pop de
	inc c
	dec e
	jr nz, dirty_y_loop	

	pop hl			; restore pointer to dirty rect list
	pop bc			; restore loop counter
	djnz dirtyrectloop	; loop!
	ret


; Redraw all invalidated foreground tiles
; No input

RedrawInvTiles_FG:
	ld a, (ndirtyrects)
	and a
	ret z			; no dirty tiles, just exit
	ld b, a
	ld hl, tiles_dirty 	; get the dirty tiles list
dirtyrectloop_fg:
	push bc
	ld b, (hl)		; Xmin
	inc hl
	ld c, (hl)		; Ymin
	inc hl
	ld d, (hl)		; Xcount
	inc hl
	ld e, (hl)		; Ycount
	inc hl
	push hl			; save pointer

dirty_y_loop_fg:
	push de
	push bc
dirty_x_loop_fg:
	push bc
	exx
	pop bc
	inc b
	inc c
	call DrawFGTile
	exx
	inc b
	dec d
	jr nz, dirty_x_loop_fg
	pop bc
	pop de
	inc c
	dec e
	jr nz, dirty_y_loop_fg	

	pop hl			; restore pointer to dirty rect list
	pop bc			; restore loop counter
	djnz dirtyrectloop_fg	; loop!
	ret

; Go through the animation of animated stiles
; - INPUT: none
; - OUTPUT: none
AnimateSTiles:
	ld a, (curscreen_numanimtiles)
	and a
	ret z	; If there are no animated tiles here, just return
	ld hl, curscreen_animtiles
AnimateSTiles_loop:
	push af
	ld b, (hl)
	inc hl
	ld c, (hl)
	inc hl		; get the X and Y coordinates
	push hl		; save the pointer to 
	ld hl, CURRENT_SCREEN_MAP	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	ld a, (hl)	; THIS is the supertile to increment
	cp 240
	jr nc, AnimateStile_loop_doit		; if this supertile is < 240, there is no need to increment

	ld hl, CURRENT_SCREEN_MAP_FG	; now check the foreground map
	add hl, de
	ld a, (hl)
	cp 240
	jr c, AnimateSTiles_loop_cont		; if this supertile is < 240, there is no need to increment

AnimateStile_loop_doit:
	and $fc		; keep the high 6 bits
	ld e, a		; save it in E
	ld a, (hl)
	inc a
	and $3		; next animation
	or e
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	
	call UpdateSuperTile
AnimateSTiles_loop_cont:
	pop hl
	pop af
	dec a
	jr nz, AnimateSTiles_loop
	ret


; Update a supertile on screen
; Assumes the supertile map has already been updated
; INPUT:
;	- A: stile number
;	- B: X coord of stile
;	- C: Y coord of stile
UpdateSuperTile:
	ld de, $0101
    push bc
    call InvalidateSTiles	; Invalidate tiles
	pop bc
    ld d, 2
    ld e, 2
;	call AnimStile_CheckSprites ; Check overlapping sprites
;	ret

; Check if animated stile overlaps with sprites
; If so, mark them for redraw
; INPUT:
;	- B: X position for stile
;	- C: Y position for stile
;   - D: number of chars used in X
;   - E: number of chars used in Y
; We will abuse the sprite routines...
AnimStile_CheckSprites:
	; We can reenter this function, so we need to save the contents of the simulated sprite
	exx
	ld hl, simulatedsprite
	ld b, (hl)		; +0
	inc hl
	ld c, (hl)		; +1
	inc hl
	push bc
	ld b, (hl)		; +2
	inc hl
	ld c, (hl)		; +3
	inc hl
	push bc
	ld b, (hl)		; +4
	inc hl
	ld c, (hl)		; +5
	inc hl
	push bc
	ld b, (hl)		; +6
	inc hl
	ld c, (hl)		; +7
	push bc
	exx

	ld ix, simulatedsprite
	ld a, b
	rlca
	rlca
	rlca
	rlca
	and $f8
	ld (ix+3), a	; xmin
	ld a, c
	rlca
	rlca
	rlca
	rlca
	and $f8
	ld (ix+4), a	; ymin
	ld (ix+5), d	; number of chars used in X
	ld (ix+6), e	; number of chars used in Y
	call MarkOverlappingSprites
	; and restore the simulated sprite at the end
	exx
	ld hl, simulatedsprite + 7
	pop bc
	ld (hl), c		; +7
	dec hl
	ld (hl), b		; +6
	dec hl
	pop bc
	ld (hl), c		; +5
	dec hl
	ld (hl), b		; +4
	dec hl
	pop bc
	ld (hl), c		; +3
	dec hl
	ld (hl), b		; +2
	dec hl
	pop bc
	ld (hl), c		; +1
	dec hl
	ld (hl), b		; +0
	exx
	ret

; Get the value for the tile in the hardness map
;
; INPUT:
;	- B: X in stile coordinates
;	- C: Y in stile coordinates
; OUTPUT: 
;	- A: value in hardness map
GetHardness:
	ld a, c			; we will need to point to hardness + Y*4 + X/4
	cp 10
	jr nc, gh_fardown	; going below the end of screen
	rlca
	rlca			; Y*4
	ld e, a
	ld d, 0
	ld a, b
	and $0C			; get the two most significant bits
	rrca
	rrca
	or e
	ld e, a			
	ld hl, CURRENT_SCREEN_HARDNESS_MAP
	add hl, de		; HL now points to the correct byte
	ld e, (hl)		; and we keep it in E
	ld a, b			; each pair of bits holds the value for a single tile. We will need to select those
	and $3	
	rlca			; 6 - (B & 3 ) * 2 is the number of shifts to do
	ld b, a
	ld a, 6
	sub b			; A has it
	jr z, gh_noshift
gh_shiftloop:
	rrc e
	dec a
	jr nz, gh_shiftloop	; we are shifting it right
gh_noshift:
	ld a, e			; now load it in A
	and $3			; and keep only the two significant bits
	ret
gh_fardown:
	xor a			; if going down, hardness is 0
	ret

; Set the value for the stile in the hardness map
;
; INPUT:
;	- B: X in stile coordinates
;	- C: Y in stile coordinates
;	- A: value in hardness map to set (0 to 3)

hardness_bitmask: db $3F, $CF, $F3, $FC

SetHardness:
	push bc
	ex af, af'
	ld a, b
	and $3		
	ld e, a
	ld d, 0
	ld hl, hardness_bitmask
	add hl, de
	ld a, (hl)	; so A has the bitmask

	push af			; save the bitmask
	ld a, c			; we will need to point to hardness + Y*4 + X/4
	rlca
	rlca			; Y*4
	ld e, a
	ld d, 0
	ld a, b
	and $0C			; get the two most significant bits
	rrca
	rrca
	or e
	ld e, a			
	ld hl, CURRENT_SCREEN_HARDNESS_MAP
	add hl, de		; HL now points to the correct byte
	ld e, (hl)		; and we keep it in E
	pop af			; restore the bitmask
	and e			; A AND E will ignore the bitmask
	ld e, a			; and store it back on E
	ex af, af'		; restore A, the value to set in the hardness map
	ld d, a			; and save it in D

	ld a, b			; each pair of bits holds the value for a single tile. We will need to select those
	and $3	
	rlca			; 6 - (B & 3 ) * 2 is the number of shifts to do
	ld b, a
	ld a, 6
	sub b			; A has it
	jr z, sh_noshift
sh_shiftloop:
	rlc d
	dec a
	jr nz, sh_shiftloop	; we are shifting it right
sh_noshift:
	ld a, e			; now load the original bits in A
	or d			; and OR it with the new value
	ld (hl), a		; Finally, save it!
	pop bc
	ret

; Set the value for the stile in the map
;
; INPUT:
;	- B: X in stile coordinates
;	- C: Y in stile coordinates
;	- A: stile value to set (0 to 255)
SetStile:
	push af
	ld hl, CURRENT_SCREEN_MAP	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	pop af
	ld (hl), a	; store the new tile
	push hl
	push bc
	push de
	push af
	push ix
	push iy
	call UpdateSuperTile
	pop iy
	pop ix
	pop af
	pop de
	pop bc
	pop hl
	ret

; Supporting function: make a supertile empty
; INPUT:
;	- B: X coordinate
;	- C: Y coordinate

empty_supertile:
	push bc
	xor a
	call SetStile
	pop bc
	xor a
	call SetHardness	; and set the hardness of this stile to "empty"
	ret
