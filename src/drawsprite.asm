; Sprite type definitions

SPR_24x32_NOMIRROR:	EQU 0	; 24x32 sprite, no mirroring
SPR_24x32_MIRROR:	EQU 128	; 24x32 sprite, mirrored
MAX_SPRITES:		EQU 16		; Maximum 16 sprites

; Init sprite structures
; The sprite structure has 8 bytes per sprite, with the following structure:
;
;	spraddress: 2 bytes (sprite address in memory, if 0 there is no sprite)
;	sprtype + ROM bank: 1 bit(sprtype) + 7 bits (ROM Bank)   1 byte  (see srite type definitions above)
;	xpos:	    1 byte  (X position. X / 8 will be the starting char)
;	ypos:	    1 byte  (Y position. Y / 8 will be the starting char)
; 	xmaxchar:   1 byte  (X chars occupied by sprite)
;	ymaxchar:   1 byte  (Y chars occupied by sprite)
;	redraw:     1 byte  (0: sprite does not need to be redrawn; 1: redraw)

; 16 sprites, 8 bytes per sprite = 128 bytes for the sprite data structure

InitSprites:
	ld hl, SPDATA
	ld (hl), 0
	ld de, SPDATA+1
	ld bc, 127		; Just fill the whole structure with zeroes
	ldir
	ret

; Re-initialize sprites after a screen change
; Do it with every sprite, but the player one

ReInitSprites:
	ld hl, SPDATA+8
	ld (hl), 0
	ld de, SPDATA+9
	ld bc, 119		; Just fill the whole structure with zeroes
	ldir
	ret

; Return address of the first available sprite
; It is the responsibility of the calling function to fill the sprite data properly
; INPUT: none
; OUTPUT: 
;	- HL: address of the first available sprite


NewSprite:
	ld hl, SPDATA
	inc hl				; go to spdata + 1
	ld e, MAX_SPRITES
	ld bc, 9
newsprloop:
	ld a, (hl)
	dec hl
	or (hl)
	ret z		; if the first  two bytes are zero, the sprite is available
	dec e
	jr z, nonewsprite ; if no new sprite is found...
	add hl, bc
	jr newsprloop
nonewsprite:
	ld hl, 0
	ret		; return HL=0 as the sprite

; Update sprite. This function will invalidate the sprite tiles, as
; well as force redraw of all sprites overlapping with this one
;
; INPUT: IX: address in sprite list
;	 B: new X position
;	 C: new Y position

UpdateSprite:
	push bc
	ld a, b
	rra
	rra
	rra	
	and $1f		; Get the X char
	ld h, a
	ld a, c
	rra
	rra
	rra	
	and $1f		; Get the Y char
	ld l, a		; save the new position in HL
	ld (ix+7), 1		; Mark sprite to be redrawn
	ld a, (ix+3)
	rra
	rra
	rra	
	and $1f		; Get the X char
	ld b, a
	ld a, (ix+4)
	rra
	rra
	rra	
	and $1f		; Get the Y char
	ld c, a		; B is the first char in X, C is the first char in Y
	ld d, (ix+5)
	ld e, (ix+6)	; D is the nchars in X, E is the nchars in Y
	; if the Y value is the same in the current and new position, extend the dirty rectangle
	; FIXME: this is something we could improve, when changing the Y we are not checking anything!!!
	
	ld a, l
	cp c
	jr nz, Update_differentY
	; same Y, lets adjust X
	ld a, h		; new X position
	cp b		; old X position
	jr z, Update_inv 	; if the same, nothing to do
	jr nc, Update_newhigher		; new X position is higher than the old one
Update_newlower:			; new X position is lower than the old one
    push bc     ; BC= old position
    push hl     ; HL= new position
	ld a, b
	sub h		; A = oldX - newX
	add a, d
	ld d, a		; D = nchars + diff
	ld b, h		; first X is the old one
	jr Update_inv_two
Update_newhigher:
    push bc     ; BC= old position
    push hl     ; HL= new position
	sub b		; A = newX - oldX
	add a, d
	ld d, a		; D = nchars + diff
	jr Update_inv_two
Update_differentY:
	push bc
	push de
	ld b, h
	ld c, l
	call InvalidateTiles
	pop de
	pop bc

Update_inv:
	call InvalidateTiles
;UpdateSprite_CheckOverlap:
;    call MarkOverlappingSprites
update_storenewpos:
	pop bc
	ld (ix+3), b
	ld (ix+4), c
	ret

Update_inv_two: ; here we have to check the old and new position, which takes some more effort
	call InvalidateTiles
    pop hl
    pop bc
	ld l, b
	add hl, hl
	add hl, hl
	add hl, hl
    jr update_storenewpos

;UpdateSprite_two_CheckOverlap:
;	ld iy, SPDATA
;	ld a, MAX_SPRITES
;checkoverlap_two_loop:	
;	push af
;   ld (ix+3), l            ; start with the old position
;	call CheckSprOverlap	; Check if sprites DO overlap
;	jr c, overlap
;
;   ld (ix+3), h            ; now check with the new position
;	call CheckSprOverlap	; Check if sprites DO overlap
;    jr nc, nooverlap_two
	; if they overlap, just mark the sprite for redraw	
;overlap:
;    ld (iy+7), 1	; mark for redraw
;nooverlap_two:
;	pop af
;	dec a
;	jr z, update_storenewpos			; return after checking all sprites
;	ld de, 8
;	add iy, de
;	jp checkoverlap_two_loop	; continue loop



; Mark all sprites to be redrawn
RedrawAllSprites:
	ld ix, SPDATA
	ld b, MAX_SPRITES
    ld de, 8
RedrawAllSprites_loop:
	ld a, (ix+0)
	or (ix+1)
	jr z, RedrawAllSprites_cont
	ld (ix+7), 1	; set the redraw flag
RedrawAllSprites_cont:
    add ix, de
	djnz RedrawAllSprites_loop
	ret
	


; Check if two sprites overlap
; 
; INPUT: IX: pointer to sprite 1
;	 IY: pointer to sprite 2
;
; OUTPUT: CY flag = 0: no overlap
;	      CY flag = 1: overlap

CheckSprOverlap:
	; first, check if this sprite is enabled
	ld a, (iy+0)
	or (iy+1)
	ret z			        ; AND sets the CY flag to zero!
	; then if it needs to be redrawn anyway
	ld a, (iy+7)		    ; get the spredraw flag
	and 1
	ret nz			        ; If 1, already needs to be redrawn, and CY flag is zero anyway
    call check_sprite_overlap ; this function does the rest of the checks for us!
    ccf                     ; however, the carry flag output is complemented
    ret


; Check for all overlapping sprites with the current one,
; and mark them for redraw if needed
; 
; INPUT: IX: address in sprite list
MarkOverlappingSprites:
	ld iy, SPDATA
	ld a, MAX_SPRITES
checkoverlap_loop:	
	push af
	call CheckSprOverlap	; Check if sprites DO overlap
	jr nc, nooverlap	; If CY=1, sprites overlap, otherwise they don't
    ld a, (iy+7)
    and a
    jr nz, nooverlap    ; we've already marked it , so don't do it again
	; if they overlap, just mark the sprite for redraw	
    ld (iy+7), 1	; mark for redraw
    ; And invalidate its tiles
	ld a, (iy+3)
	rra
	rra
	rra	
	and $1f		; Get the X char
	ld b, a
	ld a, (iy+4)
	rra
	rra
	rra	
	and $1f		; Get the Y char
	ld c, a		; B is the first char in X, C is the first char in Y
	ld d, (iy+5)
	ld e, (iy+6)	; D is the nchars in X, E is the nchars in Y
    push iy
    call InvalidateTiles
    pop iy
nooverlap:
	pop af
	dec a
	ret z 			; return after checking all sprites
	ld de, 8
	add iy, de
	jp checkoverlap_loop	; continue loop
;    ret

; Check if two sprites overlap (useful for collision detection!)	
; INPUT:
; 	- IX: pointer to sprite1
; 	- IY: pointer to sprite2
; RETURNS:
;	- Carry flag on: no overlap
;	- Carry flag off: overlap
check_sprite_overlap:
	ld b, (ix+3)	; left side of sprite1
	ld a, (iy+5)
	add a, a	
	add a, a
	add a, a	; a*8
	add a, (iy+3)	; right side of sprite2
	dec a
	cp b
	ret c

	ld b, (iy+3)	; left side of sprite2
	ld a, (ix+5)
	add a, a	
	add a, a
	add a, a	; a*8
	add a, (ix+3)	; right side of sprite1
	dec a
	cp b
	ret c

	ld b, (ix+4)	; top side of sprite1
	ld a, (iy+6)
	add a, a
	add a, a
	add a, a	; a*8
	add a, (iy+4)	; bottom side of sprite2
	dec a
	cp b
	ret c
	
	ld b, (iy+4)	; top side of sprite2
	ld a, (ix+6)
	add a, a
	add a, a
	add a, a	; a*8
	add a, (ix+4)	; bottom side of sprite1
	dec a
	cp b
	ret

; Redraw the sprite list
; This function will go through the sprite list, checking which ones need to be redrawn
; If needed, it will call each sprite draw function depending on the sprite type

DrawSpriteList:
	ld ix, SPDATA
	ld iyh, MAX_SPRITES

drawsprlist_loop:
	ld a, (ix+7)	; get the redraw flag
	and a
	jp z, drawsprlist_next ; if no redraw is needed, skip sprite

	; Set sprite ROM page
	ld a, (ix+2)
	and $7f	
	call setROM2

	ld a, (ix+6)	; number of chars in Y
	add a, a		; *2
	add a, a		; *4
	add a, a		; *8, so pixels
	add a, (ix+4)	; get max Y
	cp 160
	jr nc, drawsprlist_loop_clip	; need to clip in Y
	ld a, SPRITE_HEIGHT
	jr drawsprlist_loop_continue
drawsprlist_loop_clip:
	sub 160			; this is how many pixels we need to clip
	neg				; make it negative
	add a, 	SPRITE_HEIGHT ; and this is the number of pixels to draw in Y
drawsprlist_loop_continue:
	ld (vdpCmdSprite+VDP_NY), a
	ld b, (ix+3)	; Load X
	ld c, (ix+4)	; Load Y
	ld h, (ix+1)
	ld l, (ix+0)	; Load sprite address
	xor a
	ld (ix+7), a	; no need to redraw!
	ld a, (ix+2)	; get the sprite type, which is also the direction we're looking at
	rlca
	and 1
	push ix
	push iy
calldrawsprite:
	call drawSprite
	pop iy
	pop ix
drawsprlist_next:
	dec iyh
	jr z, drawsprlist_end
	ld bc, 8
	add ix, bc
	jp drawsprlist_loop
drawsprlist_end:
	ld a, 1
	call setROM2
	ret

; Clean a sprite (remove it). This function will:
;
;	1. Remove the sprite from the sprite list
;	2. Mark all tiles touched by the sprite as dirty
;	3. Mark all overlapping sprites for redraw
; INPUT:
;	- HL: pointer to sprite in sprite list

CleanSprite:
	push hl
	ld (hl), 0
	inc hl
	ld (hl), 0	; spradress=0
	inc hl
	inc hl		; Now pointing at the X position
	ld a, (hl)
	rra
	rra
	rra	
	and $1f		; Get the X char
	ld b, a
	inc hl	
	ld a, (hl)
	rra
	rra
	rra	
	and $1f		; Get the Y char
	ld c, a		; B is the first char in X, C is the first char in Y
	inc hl
	ld d, (hl)
	inc hl
	ld e, (hl)	; D is the nchars in X, E is the nchars in Y
	inc hl
	xor a
	ld (hl), a	; sprite will not be redrawn anymore
	call InvalidateTiles	; Invalidate tiles
	pop ix
	ret
    ;call MarkOverlappingSprites    ; check for any overlapping sprite
	;ret
;	jp MarkOverlappingSprites		; FIXME this shouldn't be needed, should it???

; Get the ROM page for a specific enemy type
; INPUT: 
;	- A: enemy type
; OUTPUT:
;	- A: ROM page
				; skeleton orc mummy troll rock knight dalgurak golem ogre minotaur demon
SpriteROMPages: db   7,     8,   9,   10,   12,   13,      11,    14,   16,   18,     20

GetSpriteROMPage:
	cp OBJECT_ENEMY_SECONDARY	; if this is the secondary, we need to do something different
	jr nz, GetSpriteROMPage_notsecondary
	; this is the secondary enemy. We need to get whatever page the first enemy has, and add 1
	push ix
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+10)
	rrca
	rrca
	rrca
	rrca
	and $0f	; get the enemy type in A
	pop ix
	call GetSpriteROMPage_notsecondary
	inc a
	ret
GetSpriteROMPage_notsecondary:
	push hl
	push de
	sub OBJECT_ENEMY_SKELETON ; make it base 0
	ld hl, SpriteROMPages
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)	; This is the ROM page
	pop de
	pop hl
	ret

