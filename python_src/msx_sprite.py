import pygame
import struct
import constants

"""
Sprite class
 
Simple sprite, loaded from a bmp file
 
package: ianna
"""

class MSXSprite():
	""" MSX bitmap Sprite """

	sprite_data = [['idle',    	     		0, 1],
				   ['gira',    	     		1, 1],
				   ['camina',  	     		2, 6],
				   ['cae',     	     		8, 2],
				   ['agacha',        		10, 3],
				   ['saca_espada',   		13, 1],
				   ['idle_espada',   		14, 1],
				   ['camina_espada', 		15, 3],
				   ['espada_golpealto', 		18, 4],
				   ['espada_golpeadelante',  22, 4],
				   ['espada_comboadelante',  26, 2],
				   ['espada_golpebajo', 		28, 4],
				   ['espada_golpeatras', 	32, 4],
				   ['espada_bloquea',       31, 1],
				   ['espada_ouch', 			36, 1],
				   ['muere', 				37, 4]]

	sprite_data_barbaro = [['ouch', 			41, 1],
						   ['salta', 		42, 8],
						   ['salto_corto', 	50, 5],
						   ['salto_largo',	55, 5],
						   ['corre',			60, 4],
						   ['frena',			64, 1],
						   ['frena_gira',	65, 2],
						   ['palanca',		67, 2],
						   ['cuelga',		69, 1]]

	sprite_data_barbaro_weapon_eclipse = [
			  		      	  ['idle_espada_eclipse',   		   0, 1],
						      ['camina_espada_eclipse', 		   1, 3],
			   				  ['espada_golpealto_eclipse',	   4, 4],
				  		      ['espada_golpeadelante_eclipse',  8, 4],
						      ['espada_comboadelante_eclipse', 12, 2],
						      ['espada_golpebajo_eclipse', 	  14, 4],
						      ['espada_golpeatras_eclipse', 	  18, 4],
						      ['espada_bloquea_eclipse',       17, 1],
						      ['espada_ouch_eclipse', 		  22, 1]]

	sprite_data_barbaro_weapon_axe = [
			  		      	  ['idle_espada_axe',   		   	  23, 1],
						      ['camina_espada_axe', 		      24, 3],
			   				  ['espada_golpealto_axe',	      27, 4],
				  		      ['espada_golpeadelante_axe',     31, 4],
						      ['espada_comboadelante_axe',     35, 2],
						      ['espada_golpebajo_axe', 	      37, 4],
						      ['espada_golpeatras_axe', 	      41, 4],
		   				      ['espada_bloquea_axe',       40, 1],
						      ['espada_ouch_axe', 		      45, 1]]

	sprite_data_barbaro_weapon_blade =[
			  		      	   ['idle_espada_blade',   		  46, 1],
						       ['camina_espada_blade', 		  47, 3],
			   				   ['espada_golpealto_blade',      50, 4],
				  		       ['espada_golpeadelante_blade',  54, 4],
						       ['espada_comboadelante_blade',  58, 2],
						       ['espada_golpebajo_blade', 	  60, 4],
						       ['espada_golpeatras_blade', 	  64, 4],
							   ['espada_bloquea_blade',       63, 1],
						       ['espada_ouch_blade',		      68, 1]]

	def __init__ (self, filename, animation, doublesize=False, secondary=False):
		# Initialize sprite parameters
		self.frames=[]
		self.nframes=0
		self.sizex=24
		self.sizey=32

		if doublesize:
			self.fullsizey=64
			if secondary:
				self.skipy = 0
			else:
				self.skipy = 32	
		else:
			self.fullsizey=32
			self.skipy=0

		self.name = animation

		# Find sprite parameters
		sprite_info = None
		for sprite in self.sprite_data:
			if sprite[0] == animation:	# animation found
				sprite_info = sprite
				break
		if sprite_info == None:
			for sprite in self.sprite_data_barbaro:
				if sprite[0] == animation:	# animation found
					sprite_info = sprite
					break
		if sprite_info == None:
			for sprite in self.sprite_data_barbaro_weapon_eclipse:
				if sprite[0] == animation:	# animation found
					sprite_info = sprite
					break
		if sprite_info == None:
			for sprite in self.sprite_data_barbaro_weapon_axe:
				if sprite[0] == animation:	# animation found
					sprite_info = sprite
					break
		if sprite_info == None:
			for sprite in self.sprite_data_barbaro_weapon_blade:
				if sprite[0] == animation:	# animation found
					sprite_info = sprite
					break

		imgfile = pygame.image.load(filename).convert()
		pixels = pygame.PixelArray(imgfile)

		# We have the frame in bitmap format. Lets create a useable image
		start = sprite_info[1]
		nframes = sprite_info[2]
		self.nframes = nframes

		for frame in range(start, start+nframes):
			goodframe=pygame.Surface((self.sizex, self.sizey),depth=32)
			ar=pygame.PixelArray(goodframe)

			startx = (frame % 10) * self.sizex
			starty = (frame / 10) * self.fullsizey + self.skipy
	
			for y in range(0, self.sizey):
				for x in range(0, self.sizex):
					ar[x, y] = pixels[x+startx, y+starty]

			goodframe.set_colorkey((144,103,179))
			self.frames.append(goodframe)


	def flip(self):
		"""
		Flip all frames of a sprite
		Attach frames at the end
		"""
		for frame in range (0, self.nframes):
			newframe=pygame.transform.flip(self.frames[frame],True,False)
			newframe.set_colorkey((144,103,179))
			self.frames.append(newframe)

	def closest_color(self, px, paleta):
		color = 0
		diff = abs(px[0]-paleta[0][0]) + abs(px[1]-paleta[0][1]) + abs(px[2]-paleta[0][2])
		for i in range(1, 16):
		    newdiff	= abs(px[0]-paleta[i][0]) + abs(px[1]-paleta[i][1]) + abs(px[2]-paleta[i][2])
		    if newdiff < diff:
		        diff = newdiff
		        color = i
		return color

	def export(self, filename):
		fp = file("tileset.pl5", "rb")
		paleta_file = fp.read()
		fp.close()			# Close file
		paleta=[]
		for i in range(0, 16):
			color1 = struct.unpack("B", paleta_file[2*i])[0]
			color2 = struct.unpack("B", paleta_file[2*i+1])[0]
			r = (color1 << 1) & 0xf0
			b = (color1 << 5) & 0xf0
			g = color2 << 5
			paleta.append([r,g,b])	# Convert file read into an array of RGB values

		with open(filename, 'a') as fp:
			fp.write("%s:\n" % self.name)
			for k in range(0, self.nframes):
				frame = self.frames[k]
				pixels = pygame.PixelArray(frame)
				image=[]

				for y in range(0, self.sizey):
					for x in range(0, self.sizex / 2):
						px = [(pixels[2*x, y] >> 16) & 255, (pixels[2*x, y] >> 8) & 255,  pixels[2*x, y] & 255]
						px1 = self.closest_color(px, paleta)
						px = [(pixels[2*x + 1, y] >> 16) & 255, (pixels[2*x + 1, y] >> 8) & 255,  pixels[2*x + 1, y] & 255]
						px2 = self.closest_color(px, paleta)
						image.append(px2 * 16 + px1)

				for y in range(0, self.sizey):
					fp.write("    DB ")
					for x in range(0,(self.sizex / 2) - 1):
						fp.write("%3d, " % image[x + (y*self.sizex/2)])
					fp.write("%3d\n" % image[((self.sizex / 2) - 1)+(y*(self.sizex / 2))])
				fp.write("\n")

