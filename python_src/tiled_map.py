import pygame
import struct
import tmxlib

objmatch = {	'switch' :'OBJECT_SWITCH',
		'door'           :'OBJECT_DOOR',
		'box_door'       :'OBJECT_DOOR_DESTROY',
		'box_floor'      :'OBJECT_DOOR_DESTROY',
		'box_jar'        : 'OBJECT_JAR',
		'wall'           :'OBJECT_FLOOR_DESTROY',
		'box_left'       :'OBJECT_BOX_LEFT',
		'box_right'      :'OBJECT_BOX_RIGHT',
		'teleport'       : 'OBJECT_TELEPORTER',
		'enemy_squeleton':'OBJECT_ENEMY_SKELETON',
		'enemy_orc'      :'OBJECT_ENEMY_ORC',
		'enemy_mummy'    :'OBJECT_ENEMY_MUMMY',
		'enemy_troll'    :'OBJECT_ENEMY_TROLL',
		'enemy_rock'     :'OBJECT_ENEMY_ROCK',
		'enemy_knight'   :'OBJECT_ENEMY_KNIGHT',
		'enemy_golem'    :'OBJECT_ENEMY_GOLEM',
		'enemy_ogre'     :'OBJECT_ENEMY_OGRE',
		'enemy_minotaur' :'OBJECT_ENEMY_MINOTAUR',
		'enemy_demon'	 :'OBJECT_ENEMY_DEMON',
		'enemy_dalgurak' :'OBJECT_ENEMY_DALGURAK',
	}


"""
IannaTileset class
 
This is a simple tileset class, derived from the Tiled map
 
package: ianna
"""
class IannaTileset():
	""" Tileset for game """
	tilelist=[]			# Tiles
	tilelist_unique=[]		# List of unique tiles, to be exported later
	stilelist=[]			# List of supertiles
	tilecolors=[]			# Colors for each tile
	stilecolors=[]			# Colors per supertile (4 per stile)

	def __init__ (self, tile_file, height, width):
		tiles_image = pygame.image.load(tile_file).convert()
		fp = file("tileset.pl5", "rb")
		paleta_file = fp.read()
		fp.close()			# Close file
		paleta = []
		for i in range(0, 16):
		    color1 = struct.unpack("B", paleta_file[2*i])[0]
		    color2 = struct.unpack("B", paleta_file[2*i+1])[0]
		    r = (color1 << 1) & 0xf0
		    b = (color1 << 5) & 0xf0
		    g = color2 << 5
		    paleta.append([r, g, b])  # Convert file read into an array of RGB values

		pixels = pygame.PixelArray(tiles_image)
		self.image = []

		for y in range(0, 256):
		    for x in range(0, 128):
				px = [(pixels[2*x, y] >> 16) & 255, (pixels[2*x, y] >> 8) & 255,  pixels[2*x, y] & 255]
				px1 = self.closest_color(px, paleta)
				px = [(pixels[2*x + 1, y] >> 16) & 255, (pixels[2*x + 1, y] >> 8) & 255,  pixels[2*x + 1, y] & 255]
				px2 = self.closest_color(px, paleta)
				self.image.append(px1 * 16 + px2)

	def closest_color(self, px, paleta):
		color = 0
		diff = abs(px[0]-paleta[0][0]) + abs(px[1]-paleta[0][1]) + abs(px[2]-paleta[0][2])
		for i in range(1, 16):
		    newdiff	= abs(px[0]-paleta[i][0]) + abs(px[1]-paleta[i][1]) + abs(px[2]-paleta[i][2])
		    if newdiff < diff:
		        diff = newdiff
		        color = i
		return color

	def print_stiles(self, f):
		for pix in self.image:
			f.write(struct.pack("B", pix))

class IannaScreen():
	""" Single screen in a game level """
	objlist=[]
	dureza=[]
	screenmap=[]
	screen_x=0
	screen_y=0
	minimum_hard_tile=0


	def __init__ (self, tmx_tilemap, tmx_foreground, objset, hardmap, map_width,map_height, posx, posy, properties=None):
		self.objlist=[]
		self.dureza=[]
		self.screenmap=[]
                self.foreground=[]
		self.screen_x=posx
		self.screen_y=posy
		self.properties=properties
		# Get the screen tile map
		for y1 in range(0,10):
			line=[]
			for x1 in range(0,16):
				thistile = tmx_tilemap[x1+16*posx,y1+10*posy].gid
				if thistile > 256:
                                        print("WARNING: wrong tile %s in level, at %s, %s. You should fix this" % (thistile, str(x1), str(y1)))
                                        thistile=2
				line.append(thistile-1)
			self.screenmap.append(line)
                # Get the foreground map
                for y1 in range(0,10):
                        line=[]
                        for x1 in range(0,16):
                                thistile = tmx_foreground[x1+16*posx,y1+10*posy].gid
                                if thistile > 256:
                                    print("WARNING: wrong foreground tile %s in level, at %s, %s. You should fix this" % (thistile, str(x1), str(y1)))
                                    thistile=1
                                line.append(thistile-1)
                        self.foreground.append(line)
		# Get the screen object map
		for obj in objset.objectset:	
			if int(obj.y) >= posy*10 and int(obj.y) < (posy+1)*10:
				if int(obj.x) >= posx*16 and int(obj.x) < (posx+1)*16:
					objeto=[]		
					objeto=[obj.properties['objid'],objmatch[obj.properties['objtype']],str(int(obj.x-posx*16)),str(int(obj.y-posy*10)-1),obj.properties['energy'],obj.properties['script']]
					self.objlist.append(objeto)
		# Get the hardness map
		# First, find the minimum hardness tile value
		minimum_hard_tile=16384
		for y in range(0,map_height):
			for x in range(0,map_width):
				if hardmap[x,y].value < minimum_hard_tile:
					minimum_hard_tile = hardmap[x,y].value
	
#		print minimum_hard_tile

		for y1 in range(0,10):
			line=[]
			for x1 in range(0,16):
				line.append(hardmap[x1+16*posx,y1+10*posy].value - minimum_hard_tile)
			self.dureza.append(line)


	def print_screen(self,f, scriptlist):
		f.write("org $0000\n")
		# Print definitions. FIXME anytime the main code changes, this must change!
		f.write("; Object types\n")
		f.write("OBJECT_NONE		EQU 0\n")
		f.write("OBJECT_SWITCH		EQU 1\n")
		f.write("OBJECT_DOOR		EQU 2\n")
		f.write("OBJECT_DOOR_DESTROY	EQU 3\n")
		f.write("OBJECT_FLOOR_DESTROY	EQU 4\n")
		f.write("OBJECT_WALL_DESTROY	EQU 5\n")
		f.write("OBJECT_BOX_LEFT	EQU 6\n")
		f.write("OBJECT_BOX_RIGHT	EQU 7\n")
		f.write("OBJECT_JAR		EQU 8\n")
		f.write("OBJECT_TELEPORTER	EQU 9\n")

		f.write("; Pickable object types\n")

		f.write("OBJECT_KEY_GREEN	EQU 11\n")
		f.write("OBJECT_KEY_BLUE    EQU 12\n")
		f.write("OBJECT_KEY_YELLOW	EQU 13\n")
		f.write("OBJECT_BREAD		EQU 14\n")
		f.write("OBJECT_MEAT	    EQU 15\n")
		f.write("OBJECT_HEALTH		EQU 16\n")
		f.write("OBJECT_KEY_RED		EQU 17\n")
		f.write("OBJECT_KEY_WHITE   EQU 18\n")
		f.write("OBJECT_KEY_PURPLE	EQU 19\n")

		f.write("; Object types for enemies\n")

		f.write("OBJECT_ENEMY_SKELETON	EQU 20\n")
		f.write("OBJECT_ENEMY_ORC	EQU 21\n")
		f.write("OBJECT_ENEMY_MUMMY	EQU 22\n")
		f.write("OBJECT_ENEMY_TROLL	EQU 23\n")
		f.write("OBJECT_ENEMY_ROCK	EQU 24\n")
		f.write("OBJECT_ENEMY_KNIGHT EQU 25\n")
		f.write("OBJECT_ENEMY_DALGURAK EQU 26\n")
		f.write("OBJECT_ENEMY_GOLEM  EQU 27\n")
		f.write("OBJECT_ENEMY_OGRE   EQU 28\n")
		f.write("OBJECT_ENEMY_MINOTAUR EQU 29\n")
		f.write("OBJECT_ENEMY_DEMON    EQU 30\n")
		f.write("OBJECT_ENEMY_SECONDARY EQU 31\n")

		# Print tile map for screen
		f.write("Screen_"+str(self.screen_y)+"_"+str(self.screen_x)+":\n")
		for y in range(0,10):
			f.write("DB ")
			for x in range(0,15):
				f.write(str(self.screenmap[y][x])+", ")
			f.write(str(self.screenmap[y][15])+"\n")

		# Print foreground map for screen
		f.write("Screen_%s_%s_foreground:\n" % (self.screen_y, self.screen_x))
		for y in range(0,10):
			f.write("DB ")
			for x in range(0,15):
				foreg = self.foreground[y][x]
				if foreg == -1:
					foreg = 0
				f.write(str(foreg)+", ")
			foreg = self.foreground[y][15]
			if foreg == -1:
				foreg = 0
			f.write(str(foreg)+"\n")

		# Print hardness map for screen
		f.write("HardScreen_"+str(self.screen_y)+"_"+str(self.screen_x)+":\n")
		for y in range(0,10):
			f.write("DB ")
			values = [0,0,0,0]
			for x in range(0,4):
				values[x] = (self.dureza[y][x*4] << 6) + (self.dureza[y][x*4+1] << 4) + (self.dureza[y][x*4+2] << 2) + (self.dureza[y][x*4+3])
			f.write(str(values[0])+", "+str(values[1])+", "+str(values[2])+", "+str(values[3])+"\n")

		# Print object map for screen
		f.write("Obj_"+str(self.screen_y)+"_"+str(self.screen_x)+":\n")
		script = None
		try:
			scriptid = "script-"+str(self.screen_x)+"_"+str(self.screen_y)
			script = self.properties[scriptid]
		except KeyError:
			pass
		if script:
			scriptid = scriptlist.index(script)
		else:
			scriptid = 1

		f.write("DB "+str(scriptid)+"			; PLAYER\n")
		# First print enemies (max 2)
		enemies_found=0
		for obj in self.objlist:
			if obj[1].find("ENEMY") != -1:	# This is an enemy
				f.write("DB "+obj[0]+", "+obj[1]+", "+obj[2]+", "+str(int(obj[3])+1)+", "+obj[4]+", "+str(scriptlist.index(obj[5]))+"\n")
				enemies_found = enemies_found + 1
		if enemies_found < 2:
			for i in range(enemies_found,2):
				f.write("DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY ENEMY\n")
		# Then print objects (max 5)
		objects_found=0
		for obj in self.objlist:
			if obj[1].find("ENEMY") == -1:	# This is an object
				f.write("DB "+obj[0]+", "+obj[1]+", "+obj[2]+", "+str(int(obj[3])+1)+", "+obj[4]+", "+str(scriptlist.index(obj[5]))+"\n")
				objects_found = objects_found + 1
		if objects_found < 5:
			for i in range(objects_found,5):
				f.write("DB 0, OBJECT_NONE, 0, 0, 0, 0 	; EMPTY OBJECT\n")

	def get_scripts_from_screen(self):
		scriptlist = ["ACTION_NONE","ACTION_NONE","ACTION_NONE","ACTION_NONE","ACTION_NONE","ACTION_NONE"]
		counter = 0
		for obj in self.objlist:
			scriptlist[counter] = obj[5]
			counter = counter + 1
		return scriptlist

class IannaMap():
	""" Map for a game level """
	tilemap=[]			# Tile map
	height=0
	width=0
	
	def __init__ (self, tmx_tilemap, tmx_foreground, map_width, map_height):
		self.tilemap=tmx_tilemap
                self.tilemap_foreground=tmx_foreground
		self.height=map_height / 10
		self.width=map_width / 16

	def print_mapinfo(self,f, nscripts, nstrings, initialx, initialy, screenx, screeny):
		f.write("org $8000\n")
		f.write("level_mark:  DB \"LEVELXXX\"\n")
		f.write("offset_scripts: DW level_strings_en\n")		# FIXME: this will be the future offset for english strings
		f.write("offset_strings: DW level_strings\n")		
		f.write("level_nscreens: DB "+str(self.width*self.height)+"\n")
		f.write("level_width: DB "+str(self.width)+"\n")
		f.write("level_height: DB "+str(self.height)+"\n")
		f.write("level_nscripts: DB "+str(nscripts)+"\n")
		f.write("level_nstrings: DB "+str(nstrings)+"\n")
		f.write("level_screenx: DB "+str(screenx)+"\n")
		f.write("level_screeny: DB "+str(screeny)+"\n")
		f.write("level_initialx: DB "+str(initialx)+"\n")
		f.write("level_initialy: DB "+str(initialy)+"\n")
		f.write("dummy: db 0\n")	# To pad the header up to 28 bytes :)

	def print_tilemap(self):
		print "pantalla: "
		for y in range(0,self.height):
			for x in range(0,self.width):
				# This is a single screen
				for y1 in range(0,10):
					print "DB ",
					for x1 in range(0,15):
						print str(self.tilemap[x1+16*x,y1+10*y].value-1)+",",
					print str(self.tilemap[15+16*x,y1+10*y].value-1)
				print "" # Newline between screens
		print ""

class IannaObjectSet():
	""" Set of objects for a game level """
	objectset=[]			# Tile map
	height=0
	width=0
	

	def __init__ (self, tmx_objectset,map_width,map_height):
		self.objectset=tmx_objectset
		self.height=map_height / 10
		self.width=map_width / 16

	# Go through object list, and add them to the tile map
	# For now, only tile objects are supported, FIXME skip sprite objects
	def addObjectsToMap(self,tilemap):
		for obj in self.objectset:
			posx=int(obj.x)
			posy=int(obj.y)
			tilenumber=obj.value
			tilemap.tilemap[posx,posy-1]=tilenumber

	# Print objects... Not much info for now, but we need to do it per screen
	def printObjects(self):
		currentscreen=0
		for y in range(0,self.height):
			for x in range(0,self.width):
				print "Screen "+str(currentscreen)
				for obj in self.objectset:	
					if int(obj.y) >= y*10 and int(obj.y) < (y+1)*10:
						if int(obj.x) >= x*16 and int(obj.x) < (x+1)*16:
							print "DB "+obj.properties['objid']+","+objmatch[obj.properties['objtype']]+", "+str(int(obj.x-x*16))+", "+str(int(obj.y-y*10))+", "+obj.properties['energy']+", "+obj.properties['scriptid']
				currentscreen=currentscreen+1
