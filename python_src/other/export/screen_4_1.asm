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
Screen_4_1:
DB 2, 1, 2, 3, 4, 5, 6, 7, 2, 2, 2, 3, 4, 5, 6, 7
DB 2, 2, 2, 2, 2, 3, 4, 3, 4, 5, 6, 7, 2, 250, 2, 2
DB 4, 5, 80, 81, 2, 2, 2, 2, 89, 90, 2, 2, 80, 81, 2, 2
DB 2, 249, 75, 34, 89, 90, 89, 90, 66, 34, 89, 90, 66, 34, 89, 93
DB 2, 108, 60, 44, 29, 30, 31, 0, 66, 30, 31, 0, 29, 146, 0, 60
DB 9, 2, 59, 0, 18, 5, 6, 29, 65, 3, 4, 66, 0, 0, 147, 75
DB 33, 9, 63, 49, 50, 182, 42, 49, 50, 132, 168, 49, 50, 0, 146, 0
DB 33, 34, 59, 252, 0, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
DB 34, 33, 64, 22, 0, 38, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
DB 14, 15, 14, 15, 14, 15, 14, 15, 14, 15, 14, 15, 14, 15, 14, 15
HardScreen_4_1:
DB 85, 85, 85, 85
DB 85, 85, 85, 85
DB 85, 85, 85, 85
DB 85, 85, 85, 85
DB 85, 85, 85, 85
DB 85, 85, 85, 85
DB 85, 80, 0, 0
DB 85, 80, 0, 0
DB 85, 80, 0, 0
DB 85, 85, 85, 85
Obj_4_1:
DB 1			; PLAYER
DB 3, OBJECT_ENEMY_MUMMY, 6, 7, 1, 33
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY ENEMY
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT
DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT