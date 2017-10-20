;---------------------------------------------------------------------------
; Descompresión a VRAM por Manuel Pazos 2007
;---------------------------------------------------------------------------

uitpakmode EQU 1

unpackVRAM:
	ld iy,.loop
	ld a,128
	exx
	ld de,1
	exx

.looplit
	;ldi
	di
	ex	af,af';'
	ld	a,d
	rlca
	rlca
	and	%11
	out	(#99),a		; VRAM address A14-A15
	ld	a,#80+14
	out	(#99),a		; VRAM access base address register  
	ld	a,e
	out	(#99),a		; VRAM a0-7  
	ld	a,d
	and	%00111111
	or	%01000000	; Write
	out	(#99),a		; VRAM a8-13
	ld	a, (hl)
	out	(#98),a
	inc	hl
	inc	de
	ex	af,af' ;'
	ei
.loop
	add a,a
	jp nz,.hup
	ld a,(hl)
	inc hl
	rla
.hup
	jr nc,.looplit

	exx
	ld l,e
	ld h,d
.getlen
	add a,a
	call z,.getbyteexx
	jr nc,.lenok
	add a,a
	call z,.getbyteexx
	adc hl,hl
	jp nc,.getlen
	exx
	ret
.lenok
	inc hl
	exx

	ld c,(hl)
	inc hl
	ld b,0
	if uitpakmode !=8
	bit 7,c
	jp z,.offsok
	add a,a
	call z,.getbyte
	if uitpakmode !=9
	rl b
	add a,a
	call z,.getbyte
	if uitpakmode !=0
	rl b
	add a,a
	call z,.getbyte
	if uitpakmode !=1
	rl b
	add a,a
	call z,.getbyte
	if uitpakmode !=2
	rl b
	add a,a
	call z,.getbyte
	if uitpakmode !=3
	rl b
	add a,a
	call z,.getbyte
	endif
	endif
	endif
	endif
	endif
	rl b
	add a,a
	call z,.getbyte
	jr nc,.offsok
	or a
	inc b
	res 7,c
.offsok
	endif
	inc bc

	push hl
	exx
	push hl
	exx
	ld l,e
	ld h,d
	sbc hl,bc
	pop bc
	;ldir
	di
	push	af
.repite	
	ld	a,h
	rlca
	rlca
	and	%11
	out	(#99),a		; VRAM address A14-A15
	ld	a,#80+14
	out	(#99),a		; VRAM access base address register  
	ld	a,l
	out	(#99),a		; VRAM a0-7  
	ld	a,h
	and	%00111111	; Read
	out	(#99),a		; VRAM a8-13
	nop
	nop
	in	a,(#98)
	ex	af,af'		;'
	
	ld	a,d
	rlca
	rlca
	and	%11
	out	(#99),a		; VRAM address A14-A15
	ld	a,#80+14
	out	(#99),a		; VRAM access base address register
	ld	a,e
	out	(#99),a		; VRAM a0-7  
	ld	a,d
	and	%00111111
	or	%01000000	; Write
	out	(#99),a		; VRAM a8-13
	ex	af,af'		;'
	out	(#98),a

	inc	hl
	inc	de
	dec	bc
	ld	a,b
	or	c
	jp	nz,.repite
	pop	af
	ei
	pop hl
	jp (iy)

.getbyte
	ld a,(hl)
	inc hl
	rla
	ret

.getbyteexx
	exx
	ld a,(hl)
	inc hl
	exx
	rla
	ret
