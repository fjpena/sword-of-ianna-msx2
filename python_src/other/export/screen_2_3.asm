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
Screen_2_3:
DB 8, 9, 33, 34, 8, 9, 33, 34, 33, 34, 8, 9, 33, 34, 8, 9
DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
DB 48, 0, 48, 0, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
DB 47, 47, 47, 47, 73, 74, 20, 0, 0, 0, 0, 21, 61, 62, 16, 14
DB 0, 0, 0, 0, 35, 76, 0, 0, 0, 0, 0, 0, 73, 74, 29, 49
DB 0, 0, 0, 0, 73, 74, 150, 0, 0, 0, 0, 126, 66, 65, 66, 50
DB 150, 0, 0, 126, 66, 65, 34, 150, 0, 0, 126, 147, 75, 76, 66, 110
DB 13, 162, 142, 163, 75, 76, 33, 145, 150, 126, 147, 0, 16, 17, 35, 30
DB 17, 61, 62, 61, 16, 17, 0, 146, 0, 0, 146, 34, 29, 18, 14, 15
HardScreen_2_3:
DB 170, 170, 170, 170
DB 0, 0, 0, 0
DB 0, 0, 0, 0
DB 0, 0, 0, 0
DB 85, 88, 2, 85
DB 85, 80, 0, 85
DB 85, 80, 0, 85
DB 85, 80, 0, 85
DB 85, 80, 0, 85
DB 85, 80, 0, 85
Obj_2_3:
DB 1			; PLAYER
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY ENEMY
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY ENEMY
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
