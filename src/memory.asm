; Memory (ROM-RAM) management routines


; BIOS functions and variables
RDSLT   EQU $000C		; read a value in another slot. A: slot, HL: address to read
WRSLT	EQU	$0014		; write a value in another slot. A: slot, HL: address to write, E: value


; Initalize MegaROM variables

initROMbanks:
		xor a
		ld (ROMBank0),a
		inc a
		ld (ROMBank1),a
		ret

; Set ASCII16 page 2 to value in A
setROM2:
		di
		ld (ROMBank1), a
		ld ($7000), a
		ei
		ret

; Set ASCII16 page 2 to value in A, assuming interrupts are disabled
setROM2_DI:
		ld (ROMBank1), a
		ld ($7000), a
		ret


; Enable bank specified by slot A in $8000 - $BFFF
enableSLOT2:
		push hl
		ld h, $80
		call ENASLT
		pop hl
		ret

; Same as before, but come back with interrupts enabled
enableSLOT2_EI:
		di
		push hl
		ld h, $80
		call ENASLT
		pop hl
		ei
		ret

; Find RAM at $8000
; Routine borrowed from some code by Ramones (thx!!!)
; OUTPUT
;	A: Slot / Subslot for the RAM page 
;	Carry set if no RAM found

searchramnormal80:
                               ld              c,$80
                               call    checkmem
                               ret              


; ---------------------
; CHECKMEM
; C : Page
; Cy : NotFound
; ----------------------

checkmem:

                               ld      a,$FF
                               ld      (thisslt),a
checkmem0:
                               push    bc
                               call    sigslot
                               pop     bc
                               cp      $FF
                               jr      z,checkmemend

                               push    bc
                               call    checkmemgen
                               pop     bc
                               ld      a,(thisslt)
                               ret     nc
                               jr      checkmem0

checkmemend:
                               scf
                               ret


; --------------------------
; CHECKMEMGEN
; C : Page
; A : Slot FxxxSSPP
; 00 : 0
; 40:  1
; 80 : 2
; Returns :
; Cy = 1 Not found
; -------------------------------


checkmemgen:
                               push    bc
                               push    hl
                               ld      h,c
                               ld      l,$10

checkmemgen1:

                               push    af
                               call    RDSLT
                               cpl
                               ld      e,a
                               pop     af

                               push    de
                               push    af
                               call    WRSLT
                               pop     af
                               pop     de

                               push    af
                               push    de
                               call    RDSLT
                               pop     bc
                               ld      b,a
                               ld      a,c
                               cpl
                               ld      e,a
                               pop     af

                               push    af
                               push    bc
                               call    WRSLT
                               pop     bc
                               ld      a,c
                               cp      b
                               jr      nz,checkmemgen2
                               pop     af
                               dec     l
                               jr      nz,checkmemgen1
                               pop     hl
                               pop     bc
                               or      a
                               ret
checkmemgen2:
                               pop     af
                               pop     hl
                               pop     bc
                               scf
                               ret



; -------------------------------------------------------
; SIGSLOT
; Returns in A the next slot every time it is called.
; For initializing purposes, THISSLT has to be #FF.
; If no more slots, it returns A=#FF.
; --------------------------------------------------------

;       ; this code is programmed by Nestor Soriano aka Konamiman

sigslot:
                               ld              a,(thisslt)             ; Returns the next slot, starting by
                               cp              0FFh                    ; slot 0. Returns #FF when there are not more slots
                               jr              nz,sigslt1              ; Modifies AF, BC, HL.
                               ld              a,(EXPTBL)
                               and             010000000b
                               ld              (thisslt),a
                               ret

sigslt1:
                               ld              a,(thisslt)
                               cp              010001111b
                               jr              z,nomaslt
                               cp              000000011b
                               jr              z,nomaslt
                               bit             7,a
                               jr              nz,sltexp
sltsimp:
                               and             000000011b
                               inc             a
                               ld              c,a
                               ld              b,0
                               ld              hl,EXPTBL
                               add             hl,bc
                               ld              a,(hl)
                               and             010000000b
                               or              c
                               ld              (thisslt),a
                               ret

sltexp:
                               ld              c,a
                               and             000001100b
                               cp              000001100b
                               ld              a,c
                               jr              z,sltsimp
                               add             a,000000100b
                               ld              (thisslt),a
                               ret

nomaslt:
                               ld              a,$FF
                               ret
