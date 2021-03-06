org $0000
; Object types
OBJECT_NONE		EQU 0
OBJECT_SWITCH		EQU 1
OBJECT_DOOR		EQU 2
OBJECT_DOOR_DESTROY	EQU 3
OBJECT_FLOOR_DESTROY	EQU 4
OBJECT_WALL_DESTROY	EQU 5
OBJECT_BOX_LEFT	EQU 6
OBJECT_BOX_RIGHT	EQU 7
OBJECT_JAR		EQU 8
OBJECT_TELEPORTER	EQU 9
; Pickable object types
OBJECT_KEY_GREEN	EQU 11
OBJECT_KEY_BLUE    EQU 12
OBJECT_KEY_YELLOW	EQU 13
OBJECT_BREAD		EQU 14
OBJECT_MEAT	    EQU 15
OBJECT_HEALTH		EQU 16
OBJECT_KEY_RED		EQU 17
OBJECT_KEY_WHITE   EQU 18
OBJECT_KEY_PURPLE	EQU 19
; Object types for enemies
OBJECT_ENEMY_SKELETON	EQU 20
OBJECT_ENEMY_ORC	EQU 21
OBJECT_ENEMY_MUMMY	EQU 22
OBJECT_ENEMY_TROLL	EQU 23
OBJECT_ENEMY_ROCK	EQU 24
OBJECT_ENEMY_KNIGHT EQU 25
OBJECT_ENEMY_DALGURAK EQU 26
OBJECT_ENEMY_GOLEM  EQU 27
OBJECT_ENEMY_OGRE   EQU 28
OBJECT_ENEMY_MINOTAUR EQU 29
OBJECT_ENEMY_DEMON    EQU 30
OBJECT_ENEMY_SECONDARY EQU 31
Screen_8_4:
DB 128, 148, 149, 128, 128, 128, 128, 128, 148, 149, 128, 128, 128, 128, 129, 128
DB 128, 128, 128, 128, 148, 149, 130, 131, 131, 130, 131, 128, 128, 128, 128, 128
DB 148, 149, 130, 131, 149, 130, 131, 2, 2, 2, 7, 149, 130, 131, 148, 149
DB 130, 131, 5, 7, 131, 2, 2, 7, 2, 3, 2, 131, 2, 4, 130, 131
DB 2, 2, 2, 2, 134, 135, 135, 136, 2, 4, 2, 7, 2, 2, 2, 3
DB 134, 135, 136, 2, 159, 138, 139, 143, 2, 2, 134, 135, 136, 4, 2, 2
DB 159, 138, 143, 2, 159, 5, 3, 143, 134, 136, 159, 139, 143, 2, 2, 2
DB 159, 4, 143, 2, 159, 3, 5, 143, 159, 143, 159, 3, 143, 134, 135, 136
DB 159, 7, 143, 2, 159, 5, 4, 143, 159, 143, 159, 7, 143, 159, 138, 143
DB 14, 15, 14, 15, 14, 14, 15, 14, 15, 14, 15, 14, 14, 15, 14, 15
HardScreen_8_4:
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 0, 0, 0, 1
DB 85, 85, 85, 85
Obj_8_4:
DB 32			; PLAYER
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY ENEMY
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY ENEMY
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
