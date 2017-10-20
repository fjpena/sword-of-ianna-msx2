; Interrupt-related routines


; Initialize ISR hook, set frame counter

init_ISR:
; Initialize variables
		ld hl, 0
		ld (FrameCounter), hl
		ld (UserISR), hl
		ld (msx2ISR), hl

; Initialize ISR
		; first, copy the old hook, so that it can be called
		ld de, InterruptBuffer
		ld hl, $fd9a
		ld bc, 5
		ldir	

		; now, set up the new one
		ld a, $c3	; opcode for JP
		ld hl, MSX_ISR	; the ISR will call this function
		di
		ld ($fd9a), a
		ld ($fd9b), hl
		ei		
		ret


; Run a user-defined ISR
; Executed every frame, through the $fd9a hook

MSX_ISR:
;		CALL	InterruptBuffer		
		ld a,($2d)		; read MSX version
		or a		; is it MSX1?
		jp z, MSXISR_msx1
; if this is a MSX2, check if we have been interrupted by a horizontal line interrupt
; not in use right now...
		ld	a,1
		out	($99),a
		ld	a,15+128
		out	($99),a
		ld	a,(de)		;wait 7 t-states
		in	a,($99)
		ex	af,af'
		xor	a		;ld a,0
		out	($99),a
		ld	a,15+128
		out	(#99),a
		ex	af,af'
		; A has the value of the VDP status register 1. If bit 0 is 1, we hit the horizontal retrace
		and 1
		jp z, MSXISR_msx1
callmsx2_ISR:
		LD HL, (msx2ISR)
		ld a, h
		or l	; if h | l is zero, that is because both h and l are zero
		ret z
		jp (hl)
		ret
MSXISR_msx1:
                in      a,($99)                         ; Reseteamos el bit de interrupcion
                bit     7,a                             ; Si la interrupcion no fue provocada por el VDP
                ret     z                               ; Volvemos
		LD HL, (FrameCounter)
		INC HL
		LD (FrameCounter), HL
		LD HL, (UserISR)
		; if the value of UserISR is 0, we should return
		ld a, h
		or l	; if h | l is zero, that is because both h and l are zero
		ret z
		JP (HL)
		RET

; Install a user-defined ISR
; 
; INPUT
;	HL: pointer to the user-defined ISR

INSTALL_ISR:
		ld (UserISR), HL
		ret

; Install a user-defined ISR for horizontal retrace IRQs (MSX2 and later only)
; 
; INPUT
;	HL: pointer to the user-defined ISR
INSTALL_HORISR:
		ld (msx2ISR), HL
		ret


