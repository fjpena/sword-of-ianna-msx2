org $C000
map_strings: dw string_list
map_scripts: dw current_script_pointer

;LEVEL STRING POINTERS

string_list: dw string0, string1

; STRINGS

string0:	 db "JARKUM, GO TO THE FORTRESS OF KASHGAR, FIND THE MONOLITHS, AND LISTEN TO THE VOICE OF OUR ANCESTORS.",0
string1:	 db "LISTEN CAREFULLY. DAL GURAK, THE ENEMY, WHOM YOUR ANCESTORS THOUGHT DEFEATED, HAS SURGED AGAIN FROM THE DARKNESS AND AGAIN IS GROWING STRONG. YOU MUST FOLLOW TURAKAM'S STEPS AND RECLAIM THE SWORD OF IANNA, WHICH WAS GIFTED TO HIM BY THE GODDESS. THIS IS THE ONLY WAY TO SEND THE ENEMY BACK TO THE HELL HE SHOULD HAD NEVER LEFT. GO TO THE TOMBS OF EPHYRA, WHERE THE WAY TO YOUR FATE WILL BE REVEALED TO YOU.",0


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
; Flag descriptions, will be used as parameters to functions
FLAG_PATROL_NONE:	EQU 0
FLAG_PATROL_NOFALL:	EQU 1	; do not jump blindly on platforms
FLAG_FIGHT_NONE:		EQU 0
FLAG_FIGHT_NOFALL:	EQU 1	; do not jump blindly when fighting
; script action definitions
ACTION_NONE:		EQU 0	; do nothing, no parameters
ACTION_JOYSTICK:	EQU 1	; control position/animation with joystick, no parameters
ACTION_PLAYER:		EQU 2	; player control
ACTION_PATROL:		EQU 3	; move left-right in the area, waiting until the player is in its view area
ACTION_FIGHT:		EQU 4	; Fight
ACTION_SECONDARY:	EQU 5	; script for secondary entities
ACTION_STRING:		EQU 6	; print a string in the notification area, useful for cutscenes. One parameter (db): string id
ACTION_WAIT:		EQU 7	; do nothing for a number of game frames. One parameter (db): number of frames
ACTION_MOVE:		EQU 8	; move for a number of game frames. Two parameter (db): direction, number of frames
ACTION_WAIT_SWITCH_ON:	EQU 9	; wait for a switch to be changed from 0 to 1 or 2. One parameter (db): object id
ACTION_WAIT_DEAD:	EQU 9	; wair for an enemy to be dead (its parameter is 1). One parameter (db): object id
ACTION_WAIT_DESTROYED:	EQU 9	; wair for an object to be destroyed (its parameter is 1). One parameter (db): object id
ACTION_WAIT_SWITCH_OFF:	EQU 10	; wait for a switch to be changed from 1/2 to 0. One parameter (db): object id
ACTION_TOGGLE_SWITCH_ON:	EQU 11	; toggle a switch. It will change the switch from 1 to 2, and also update the tiles. One parameter (db): object id
ACTION_TOGGLE_SWITCH_OFF: EQU 12	; toggle a switch. It will change the switch from 2 to 0, and also update the tiles. One parameter (db): object id
ACTION_OPEN_DOOR:	 EQU 13	; open a door. It will change the object value from 0 to 1, then to 2 when done, and update the tiles. One parameter (db): object id
ACTION_CLOSE_DOOR:	 EQU 14	; close a door. It will change the object value from 2 to 1, then to 0 when done, and update the tiles. One parameter (db): object id 
ACTION_REMOVE_BOXES:	 EQU 15	; remove a group of boxes. One parameter (db): object id
ACTION_RETURN_SUBSCRIPT: EQU 16  ; return from a subscript
ACTION_RESTART_SCRIPT:	EQU 17 	; restart the script
ACTION_TELEPORT:	EQU 18	; teleport. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)
ACTION_KILL_PLAYER:	EQU 19	; immediately kill the player
ACTION_ENERGY:		EQU 20	; add/reduce energy on entity touching it. 1 param (db): amount of energy to add/reduce
ACTION_SET_TIMER:	EQU 21	; set global timer, which will be decremented on every frame. 1 param(db): value to set
ACTION_WAIT_TIMER_SET:	EQU 22	; wait until global timer is != 0
ACTION_WAIT_TIMER_GONE:	EQU 23	; wait until global timer is == 0
ACTION_WAIT_CONTACT:	EQU 24	; wait until the player touches the entity
ACTION_MOVE_STILE:	EQU 25	; move stile. 5 params(db): x,y for stile, deltax, deltay per frame, number of frames.
ACTION_CHANGE_OBJECT:	EQU 26  ; switch to other object. 1 param(db): id of new object
ACTION_WAIT_PICKUP:	EQU 27	; used for objects, wait until picked up
ACTION_IDLE:		EQU 28	; set the state to idle
ACTION_ADD_INVENTORY:	EQU 29	; add object to inventory. 1 param(db): id of object to add to inventory
ACTION_REMOVE_JAR:	EQU 30	; remove a jar. One parameter (db): object id
ACTION_REMOVE_DOOR:	EQU 31	; remove a door. One parameter (db): object id
ACTION_ADD_ENERGY:  EQU 32  ; add energy. One parameter (db): amount of energy to add
ACTION_CHECK_OBJECT_IN_INVENTORY: EQU 33  ; wait until an object is in the inventory. One parameter (db): object id
ACTION_REMOVE_OBJECT_FROM_INVENTORY: EQU 34  ; remove object from inventory. One parameter (db): object id
ACTION_CHECKPOINT: EQU 35	; set checkpoint. No parameters
ACTION_FINISH_LEVEL: EQU 36 ; end level. One parameter (db): 0 -> get back to main menu. 1 -> Go to next level.
ACTION_ADD_WEAPON: EQU 37   ; add weapon to inventory. One parameter (db): 1-> eclipse, 2-> axe, 3-> blade
ACTION_WAIT_CROSS_DOOR: EQU 38   ; wait until player is crossing our door
ACTION_CHANGE_STILE: EQU 39  ; change stile. 3 parameters (db): x, y in stile coords, and stile number (0-255)
ACTION_CHANGE_HARDNESS: EQU 40   ; change hardness for stile. 3 parameters (db): x, y in stile coords, hardness value (0-3)
ACTION_SET_OBJECT_STATE: EQU 41  ; set object state. 2 parameters (db): object id, state value (0: normal, 1: transitioning, 2: dead/changed, 3-255: other)
ACTION_WAIT_OBJECT_STATE: EQU 42  ; wait until the object state has a specific value. 2 parameters (db): object id, state value
ACTION_NOP: EQU 43  ; no-op action
ACTION_WAIT_CONTACT_EXT: EQU 44  ; wait for contact with area. 4 parameters (db): upper-left X in chars, upper-left Y in chars, width, height in chars
ACTION_TELEPORT_EXT:	EQU 45	; teleport without waiting for contact. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)
ACTION_TELEPORT_ENEMY: EQU 46  ; teleport enemy to a different location in this screen. 2 params (db): x, y (in pixels)
ACTION_MOVE_OBJECT: EQU 47     ; move object in screen. 4 params (db): objid, deltax, deltay per frame, number of frames
ACTION_WAIT_PICKUP_INVENTORY:	EQU 48	; used for objects, wait until picked up and make sure there is space in the inventory
ACTION_FX:	EQU 49	; play an FX. 1 param (db): effect
current_script_pointer: dw script0, script1, script2, script3, script4, script5, script6, script7, script8, script9, script10
		dw script11, script12, script13, script14, script15, script16, script17, script18, script19, script20, script21
		dw script22, script23, script24, script25, script26, script27, script28, script29, script30, script31, script32
		dw script33, script34, script35, script36, script37, script38, script39, script40, script41, script42, script43
		dw script44, script45, script46, script47, script48, script49, script50, script51, script52, script53, script54
		dw script55, script56, script57, script58, script59, script60, script61, script62, script63, script64, script65
		dw script66, script67, script68, script69, script70, script71, script72, script73, script74, script75, script76
		dw script77, script78, script79, script80, script81, script82, script83

; SCRIPTS

script0:	 db ACTION_NONE
script1:	 db ACTION_PLAYER
script2:	 db ACTION_SECONDARY
script3:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_YELLOW,ACTION_NONE
script4:	 db ACTION_WAIT_PICKUP,ACTION_REMOVE_JAR,255,ACTION_ADD_ENERGY, 50, ACTION_NONE
script5:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_BLUE,ACTION_NONE
script6:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_HEALTH,ACTION_NONE
script7:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_WHITE,ACTION_NONE
script8:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_GREEN,ACTION_NONE
script9:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_RED,ACTION_NONE
script10:	 db ACTION_WAIT_PICKUP,ACTION_REMOVE_JAR,255,ACTION_ADD_ENERGY, 20, ACTION_NONE
script11:	 db ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_PURPLE,ACTION_NONE
script12:	 db ACTION_MOVE, 80, 1, ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 3, ACTION_MOVE, 17, 1, ACTION_WAIT, 20, ACTION_RETURN_SUBSCRIPT
script13:	 db ACTION_MOVE, 80, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT
script14:	 db ACTION_MOVE, 18, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT
script15:	 db ACTION_MOVE, 64, 12, ACTION_MOVE, 17, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT
script16:	 db ACTION_MOVE, 144, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT
script17:	 db ACTION_MOVE, 80, 1, ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT
script18:	 db ACTION_MOVE, 17, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT
script19:	 db ACTION_MOVE, 64, 8, ACTION_MOVE, 17, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT
script20:	 db ACTION_MOVE, 80, 1,  ACTION_RETURN_SUBSCRIPT
script21:	 db ACTION_MOVE, 64, 8,  ACTION_MOVE, 17, 1, ACTION_WAIT, 4, ACTION_MOVE, 128, 6,  ACTION_RETURN_SUBSCRIPT
script22:	 db ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 5,  ACTION_RETURN_SUBSCRIPT
script23:	 db ACTION_MOVE, 18, 1,  ACTION_WAIT, 2, ACTION_RETURN_SUBSCRIPT
script24:	 db ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 12,  ACTION_RETURN_SUBSCRIPT
script25:	 db ACTION_MOVE, 80, 1,  ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT
script26:	 db ACTION_MOVE, 17, 1,  ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT
script27:	 db ACTION_MOVE, 64, 8, ACTION_MOVE, 17, 1, ACTION_WAIT, 2, ACTION_MOVE, 128, 5, ACTION_RETURN_SUBSCRIPT
script28:	 db ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_RETURN_SUBSCRIPT
script29:	 db ACTION_TELEPORT_ENEMY, 16, 112, ACTION_WAIT, 8, ACTION_MOVE, 8, 2, ACTION_WAIT, 2, ACTION_MOVE, 32, 1, ACTION_WAIT, 2, ACTION_MOVE, 17, 1, ACTION_MOVE_OBJECT, 105, 0, 5, 1, ACTION_MOVE_OBJECT, 105, 1, 0, 8,  ACTION_MOVE_OBJECT, 105, -1, 0, 8, ACTION_MOVE_OBJECT, 105, 0, -5, 1, ACTION_RETURN_SUBSCRIPT
script30:	 db ACTION_TELEPORT_ENEMY, 112, 64, ACTION_WAIT, 8, ACTION_MOVE, 8, 2, ACTION_WAIT, 2, ACTION_MOVE, 32, 1, ACTION_WAIT, 2, ACTION_MOVE, 17, 1, ACTION_MOVE_OBJECT, 105, 5, 0, 1, ACTION_MOVE_OBJECT, 105, 1, 1, 6, ACTION_MOVE_OBJECT, 105, -1, 0, 12, ACTION_MOVE_OBJECT, 105, 1, -1, 6, ACTION_MOVE_OBJECT, 105, -5, 0, 1, ACTION_CHANGE_STILE, 8, 2, 92, ACTION_TELEPORT_ENEMY, 16, 112, ACTION_WAIT, 8, ACTION_MOVE, 8, 2, ACTION_WAIT, 2, ACTION_MOVE, 32, 1, ACTION_RETURN_SUBSCRIPT
script31:	 db ACTION_CHECKPOINT, ACTION_PLAYER
script32:	 db ACTION_IDLE,ACTION_MOVE, 8,28,ACTION_IDLE,ACTION_MOVE,4,1,ACTION_STRING, 1, ACTION_FINISH_LEVEL, 1, ACTION_PLAYER
script33:	 db ACTION_PATROL, FLAG_PATROL_NONE, ACTION_FIGHT, FLAG_FIGHT_NONE
script34:	 db ACTION_WAIT_SWITCH_ON, 255, ACTION_TOGGLE_SWITCH_ON, 255, ACTION_NONE
script35:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_BOXES, 255, ACTION_CHANGE_OBJECT,OBJECT_BREAD , ACTION_NONE
script36:	 db ACTION_KILL_PLAYER, ACTION_NONE
script37:	 db ACTION_WAIT_SWITCH_ON, 35, ACTION_OPEN_DOOR, 255, ACTION_NONE
script38:	 db ACTION_WAIT_DESTROYED,255, ACTION_REMOVE_BOXES, 255, ACTION_NONE
script39:	 db ACTION_WAIT_SWITCH_ON, 36, ACTION_OPEN_DOOR, 255, ACTION_NONE
script40:	 db ACTION_TELEPORT, 0, 3, 16, 112
script41:	 db ACTION_TELEPORT, 4, 1, 216, 96
script42:	 db ACTION_WAIT_CONTACT, ACTION_STRING,0,ACTION_SET_OBJECT_STATE, 110, 1, ACTION_CHECKPOINT, ACTION_NONE
script43:	 db ACTION_WAIT_DEAD, 31, ACTION_OPEN_DOOR, 255, ACTION_NONE
script44:	 db ACTION_WAIT_DESTROYED,255, ACTION_REMOVE_BOXES, 255, ACTION_CHANGE_OBJECT,OBJECT_BREAD , ACTION_NONE
script45:	 db ACTION_TELEPORT, 4, 0, 16, 96
script46:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_JAR, 255, ACTION_CHANGE_OBJECT,OBJECT_MEAT, ACTION_NONE
script47:	 db ACTION_PATROL, FLAG_PATROL_NOFALL, ACTION_FIGHT, FLAG_FIGHT_NOFALL
script48:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_DOOR, 255, ACTION_NONE
script49:	 db ACTION_WAIT_SWITCH_ON, 12, ACTION_OPEN_DOOR, 255, ACTION_NONE
script50:	 db ACTION_TELEPORT, 0, 6, 16, 112
script51:	 db ACTION_TELEPORT, 4, 0, 216, 112
script52:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_BOXES, 255, ACTION_NONE
script53:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_BOXES, 255, ACTION_CHANGE_OBJECT,OBJECT_MEAT , ACTION_NONE
script54:	 db ACTION_WAIT_SWITCH_ON, 13, ACTION_OPEN_DOOR, 255, ACTION_NONE
script55:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_JAR, 255, ACTION_CHANGE_OBJECT,OBJECT_HEALTH , ACTION_NONE
script56:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_JAR, 255, ACTION_CHANGE_OBJECT,OBJECT_BREAD , ACTION_NONE
script57:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_JAR, 255, ACTION_NONE
script58:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_BOXES, 255, ACTION_CHANGE_OBJECT, OBJECT_HEALTH, ACTION_NONE
script59:	 db ACTION_WAIT_SWITCH_ON, 11, ACTION_OPEN_DOOR, 255, ACTION_NONE
script60:	 db ACTION_TELEPORT, 4, 2, 216, 112
script61:	 db ACTION_WAIT_DESTROYED, 255, ACTION_REMOVE_JAR, 255, ACTION_CHECKPOINT,ACTION_NONE
script62:	 db ACTION_WAIT_DESTROYED, 108, ACTION_FX, 14, ACTION_MOVE_STILE, 3, 4, 1, 0, 10,  ACTION_MOVE_STILE, 13, 4, 0, 1, 1, ACTION_FX, 14, ACTION_MOVE_STILE, 3, 5, 1, 0, 7,   ACTION_MOVE_STILE, 10, 5, 0, 1, 1, ACTION_FX, 14, ACTION_MOVE_STILE, 3, 6, 1, 0, 4,  ACTION_MOVE_STILE, 7, 6, 0, 1, 1, ACTION_FX, 14,  ACTION_MOVE_STILE, 3, 7, 1, 0, 1,  ACTION_MOVE_STILE, 4, 7, 0, 1, 1, ACTION_FX, 8, ACTION_NONE
script63:	 db ACTION_ENERGY, -10, ACTION_NONE
script64:	 db ACTION_WAIT_SWITCH_ON, 62, ACTION_OPEN_DOOR, 255, ACTION_NONE
script65:	 db ACTION_TELEPORT, 0, 7, 16, 112
script66:	 db ACTION_WAIT_DEAD, 74, ACTION_OPEN_DOOR, 255,ACTION_NONE
script67:	 db ACTION_TELEPORT, 0, 8, 16, 112
script68:	 db ACTION_TELEPORT, 3, 6, 216, 112
script69:	 db ACTION_WAIT_DESTROYED, 67, ACTION_OPEN_DOOR, 255, ACTION_NONE
script70:	 db ACTION_WAIT_DESTROYED, 68, ACTION_OPEN_DOOR, 255, ACTION_NONE
script71:	 db ACTION_WAIT_DESTROYED, 73, ACTION_OPEN_DOOR, 255, ACTION_NONE
script72:	 db ACTION_WAIT_SWITCH_ON, 77, ACTION_OPEN_DOOR, 255, ACTION_WAIT_SWITCH_OFF, 77, ACTION_CLOSE_DOOR, 255,ACTION_RESTART_SCRIPT
script73:	 db ACTION_WAIT_SWITCH_ON, 255, ACTION_TOGGLE_SWITCH_ON, 255,ACTION_WAIT_SWITCH_OFF, 255, ACTION_TOGGLE_SWITCH_OFF, 255, ACTION_RESTART_SCRIPT
script74:	 db ACTION_WAIT_SWITCH_OFF, 77, ACTION_OPEN_DOOR, 255, ACTION_WAIT_SWITCH_ON, 77, ACTION_CLOSE_DOOR, 255,ACTION_RESTART_SCRIPT
script75:	 db ACTION_ENERGY,-10, ACTION_NONE
script76:	 db ACTION_TELEPORT,4, 6,216, 112
script77:	 db ACTION_WAIT_CONTACT,ACTION_SET_TIMER, 2, ACTION_FX, 5,ACTION_NONE
script78:	 db ACTION_WAIT_TIMER_SET,ACTION_WAIT_TIMER_GONE,ACTION_MOVE,8,50,ACTION_NONE
script79:	 db ACTION_WAIT_CONTACT, ACTION_SET_TIMER, 2, ACTION_FX, 5, ACTION_NONE
script80:	 db ACTION_WAIT_TIMER_SET,ACTION_WAIT_TIMER_GONE,ACTION_MOVE,4,50,ACTION_NONE
script81:	 db ACTION_WAIT_CONTACT, ACTION_SET_TIMER, 2, ACTION_FX, 5,  ACTION_NONE
script82:	 db ACTION_WAIT_TIMER_SET,ACTION_WAIT_TIMER_GONE,ACTION_WAIT_TIMER_SET,ACTION_WAIT_TIMER_GONE,ACTION_MOVE,8,50,ACTION_NONE
script83:	 db ACTION_WAIT_TIMER_SET,ACTION_WAIT_TIMER_GONE,ACTION_WAIT_TIMER_SET,ACTION_WAIT_TIMER_GONE,ACTION_MOVE,4,50,ACTION_NONE
