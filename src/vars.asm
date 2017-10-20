; MSX BIOS definitions
RAM_Start  EQU $C000
ENASLT     EQU $0024      ;enable slot
RSLREG     EQU $0138      ;read primary slot select register
EXPTBL     EQU $FCC1      ;slot is expanded or not
CLIKSW     EQU $F3DB      ; variable to set/reset the keyboard click sound

; Engine variables
string_area: ds 2048
OBJECT_DATA: ds 256				; $C800, keep this in mind when porting!
script_area: EQU string_area+2
LEVEL_SCREEN_ADDRESSES: ds 128
; SFX and music data
music_addr: ds 4096 ; music will be on a fixed location ($C980), and we'll load it from disk/cart
music_sfx:  ds 1100 ; ($D980)
; Music code
MUSIC_CODE: ds 2000 ; it is 1902 for now, but let's play safe
MUSIC_ROM_PAGE EQU 40

; Checkpoint save area
CHECKPOINT_AREA: ds 512

CURRENT_SCREEN_MAP: ds 403
CURRENT_SCREEN_MAP_FG: EQU CURRENT_SCREEN_MAP + 160
CURRENT_SCREEN_HARDNESS_MAP: EQU CURRENT_SCREEN_MAP + 320
CURRENT_SCREEN_OBJECTS: EQU CURRENT_SCREEN_MAP + 360
curscreen_animtiles: ds 30
ndirtyrects: ds 1
tiles_dirty: ds 192
SPDATA: ds 128
ENTITY_DATA: ds 96 ;  12 bytes, 8 entities
simulatedsprite: ds 7
simulated_object: ds 8
newx: ds 1
newy: ds 1
deltax: ds 1
deltay: ds 1
stairy: ds 1	; value to climb up/down the stairs
cannotmove_reason: db 1
checkstair: ds 1
forcemove:  ds 1
ycur: ds 1
y0:   ds 1
y1:   ds 1
adjustx: ds 1
hitting_entity_looking_at: ds 1
self_injury: ds 1
canhang_delta: ds 1
canhang_half: ds 1
slash_deltax_1: ds 1
slash_deltax_2: ds 1
slash_hits_x: ds 1
wait_alternate: ds 1

; Scratch area for player and enemies, used for:
; - Temporary script storage
; - Subscript execution
; - WARNING: bytes 6-7 are reserved for subscript storage!!!!

scratch_area_player: ds 8	; scratch area for player scripts 
scratch_area_enemy1: ds 8	; scratch area for enemy scripts 
scratch_area_enemy2: ds 8	; scratch area for enemy scripts 
scratch_area_obj1:   ds 8	; scratch area for enemy scripts 
scratch_area_obj2:   ds 8	; scratch area for enemy scripts 
scratch_area_obj3:   ds 8	; scratch area for enemy scripts 
scratch_area_obj4:   ds 8	; scratch area for enemy scripts 
scratch_area_obj5:   ds 8	; scratch area for enemy scripts 

; Weapon constants
WEAPON_SWORD: 	EQU 0
WEAPON_ECLIPSE: EQU 1
WEAPON_AXE: 	EQU 2
WEAPON_BLADE: 	EQU 3

; Variables
slot2address: 	 db 1
FrameCounter: 	 ds 2
msx2ISR:		 ds 2
UserISR          ds 2
InterruptBuffer: ds 5
delay60HZ:		 ds 1
frames_lock:     ds 1   ;5:PAL, 6: NTSC

; VDP variables
tileDat: ds 15			; buffer for tile commands
fgtileDat: ds 15		; buffer for foreground tile commands
dirtyTileDat: ds 15		; buffer to transfer dirty tiles
cmdDat: ds 15			; buffer with command data
charDat: ds 15			; buffer for char commands
charDat2: ds 15			; buffer for char commands, when drawing directly on the front buffer
charDat3: ds 15			; buffer for char commands, when drawing with transparency
vdpCmdSprite: ds 15		; buffer for sprite commands
fillDat: ds 15          ; buffer for fill commands
vdpCmdWeapon: ds 15		; buffer for weapon in score area
lineMoveDat: ds 15		; buffer for line moves (used in menu)	
vdpCopyDat: ds 15		; buffer for general copies
scoreDat: ds 15			; buffer for score area usage
currentPal: ds 32		; current palette
; Memory handling vabiables
ROMBank0: ds 1
ROMBank1: ds 1
thisslt:  ds 1

; Music variables
music_playing: ds 1
music_state: ds 1		; 0: music+fx, 1: music only, 2: fx only
music_save: db 0

; Entity variables
ENTITY_SIZE: EQU 12
ENTITY_PLAYER_POINTER:  EQU ENTITY_DATA
ENTITY_ENEMY1_POINTER:  EQU ENTITY_DATA+12
ENTITY_ENEMY2_POINTER:  EQU ENTITY_DATA+24
ENTITY_OBJECT1_POINTER: EQU ENTITY_DATA+36
ENTITY_OBJECT2_POINTER: EQU ENTITY_DATA+48
ENTITY_OBJECT3_POINTER: EQU ENTITY_DATA+60
ENTITY_OBJECT4_POINTER: EQU ENTITY_DATA+72
ENTITY_OBJECT5_POINTER: EQU ENTITY_DATA+84

; Game variables
joystick_state: db 0
level_nscreens: db 0
level_nscripts: db 0
level_nstrings: db 0
level_width: db 0
level_height: db 0
level_tiles_addr: dw 0
level_stiles_addr: dw 0
level_stilecolors_addr: dw 0
level_string_en_addr: dw 0
level_string_addr: dw 0
curscreen_numanimtiles: db 0
frames_noredraw: db 0
animate_tile: db 0
entity_sprite_base:	dw 0
entity_current:		dw 0
global_timer: db 0
initial_coordx: db 0
initial_coordy: db 0
entity_joystick:	db 0
; Inventory handling variables
inv_current_object: db 0
inv_first_obj:      db 0
inv_refresh:	    db 0	; refresh inventory?
INVENTORY_SIZE	EQU 6
inventory:	    ds INVENTORY_SIZE
inv_what_to_print:  db 0	; 0: barbarian, 1: enemy 1, 2: enemy 2
score_semaphore:    db 0
currentx: db 0
current_levelx: db 0
current_levely: db 0
; Barbarian state
player_dead: db 0
player_available_weapons: db 0,0,0,0
player_level: db 0
player_experience:    db  0
player_current_weapon: db 0

show_passwd: 	ds 1
current_level: 	ds 1
language:		ds 1
screen_changed: ds 1
action_flags: ds 1
action_random_number: ds 1
action_fight_scratch: ds 2
saved_hardness: ds 1
saveA: ds 1
newscreen: ds 1
toggle_amount: ds 1
randData: ds 2
action_ack: ds 1
sprite_rom_page: ds 1
draw_char: ds 1
draw_blank: ds 1
BARBARIAN_ROM_PAGE: EQU 2
BARBARIAN_ADDITIONAL_ROM_PAGE: EQU 3
score_password_value: db 0,0,0,0,0
rom_offset_weapon: ds 1
; Menu variables
save_level: db 0
password_string: db "          ",0
password_value:  db 0, 0, 0, 0, 0       ; current_level | player_available_weapons, player_level, player_exp, player_current_weapon, cksum
score_password_string: db "PASSWORD:1234567890",0
start_delta: db 0
current_delta: db 0
current_y: db 0
menu_counter: db 0
menu_option: db 0
menu_running: db 0
menu_timer: db 0
menu_loops: db 0
credit_timer: db 0
credit_current: db 0
current_string_list: dw 0
string_list: dw string_1, string_2, string_3, string_4_1
string_list_es: dw string_1, string_2, string_3_es, string_4_1
menu_in_jukebox: db 0
menu_delay: db 0
; Intro/ending variables
intro_var: db 0
number_screens: db 0
menu_string_list: dw 0
menu_screen_list: dw 0
menu_cls_counter: db 0
intro_shown: db 0
slideshow_rom_page: db 0
END_VARS:
