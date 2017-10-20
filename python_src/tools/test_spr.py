#!/usr/bin/env python

from __future__ import print_function

import pygame
import pygame.locals
import struct
import sys

sprite_data = [['%s_idle',    	     		0, 1],
			   ['%s_gira',    	     		1, 1],
			   ['%s_camina',  	     		2, 6],
			   ['%s_cae',     	     		8, 2],
			   ['%s_agacha',        		10, 3],
			   ['%s_saca_espada',   		13, 1],
			   ['%s_idle_espada',   		14, 1],
			   ['%s_camina_espada', 		15, 3],
			   ['%s_espada_golpealto', 		18, 4],
			   ['%s_espada_golpeadelante',  22, 4],
			   ['%s_espada_comboadelante',  26, 2],
			   ['%s_espada_golpebajo', 		28, 4],
			   ['%s_espada_golpeatras', 	32, 4],
			   ['%s_espada_ouch', 			36, 1],
			   ['%s_muere', 				37, 4]]

sprite_data_barbaro = [['%s_ouch', 			41, 1],
					   ['%s_salta', 		42, 8],
					   ['%s_salto_corto', 	50, 5],
					   ['%s_salto_largo',	55, 5],
					   ['%s_corre',			60, 4],
					   ['%s_frena',			64, 1],
					   ['%s_frena_gira',	65, 2],
					   ['%s_palanca',		67, 2],
					   ['%s_cuelga',		69, 1]]

sprite_data_barbaro_weapon_eclipse = [
			  		      	  ['%s_idle_espada_eclipse',   		   0, 1],
						      ['%s_camina_espada_eclipse', 		   1, 3],
			   				  ['%s_espada_golpealto_eclipse',	   4, 4],
				  		      ['%s_espada_golpeadelante_eclipse',  8, 4],
						      ['%s_espada_comboadelante_eclipse', 12, 2],
						      ['%s_espada_golpebajo_eclipse', 	  14, 4],
						      ['%s_espada_golpeatras_eclipse', 	  18, 4],
						      ['%s_espada_ouch_eclipse', 		  22, 1]]

sprite_data_barbaro_weapon_axe = [
			  		      	  ['%s_idle_espada_axe',   		   	  23, 1],
						      ['%s_camina_espada_axe', 		      24, 3],
			   				  ['%s_espada_golpealto_axe',	      27, 4],
				  		      ['%s_espada_golpeadelante_axe',     31, 4],
						      ['%s_espada_comboadelante_axe',     35, 2],
						      ['%s_espada_golpebajo_axe', 	      37, 4],
						      ['%s_espada_golpeatras_axe', 	      41, 4],
						      ['%s_espada_ouch_axe', 		      45, 1]]

sprite_data_barbaro_weapon_blade =[
			  		      	   ['%s_idle_espada_blade',   		  46, 1],
						       ['%s_camina_espada_blade', 		  47, 3],
			   				   ['%s_espada_golpealto_blade',      50, 4],
				  		       ['%s_espada_golpeadelante_blade',  54, 4],
						       ['%s_espada_comboadelante_blade',  58, 2],
						       ['%s_espada_golpebajo_blade', 	  60, 4],
						       ['%s_espada_golpeatras_blade', 	  64, 4],
						       ['%s_espada_ouch_blade',		      68, 1]]


def closest_color(px, paleta):
	color = 0
	diff = abs(px[0]-paleta[0][0]) + abs(px[1]-paleta[0][1]) + abs(px[2]-paleta[0][2])
	for i in range(1,16):
		newdiff	= abs(px[0]-paleta[i][0]) + abs(px[1]-paleta[i][1]) + abs(px[2]-paleta[i][2])
		if newdiff < diff:
			diff = newdiff
			color = i
	return color


def export_spritesheet(image, name, filename, barbarian=False):
	if barbarian:
		filename1 = filename + "_1.asm"
		filename2 = filename + "_2.asm"
	else:
		filename1 = filename + ".asm"

	with open(filename1, 'w') as fp:
		for sprite in sprite_data:
			sp_name = sprite[0] % name
			start = sprite[1]
			nframes = sprite[2]
			fp.write("%s:\n" % sp_name)
			for frame in range(start, start+nframes):
				startx = (frame % 10) * 12
				starty = (frame / 10) * 32
	
				for y in range(0,32):
					fp.write("    DB ")
					for x in range(0,11):
						fp.write("%3d, " % imagen[(x+startx)+(y+starty)*128])
					fp.write("%3d\n" % imagen[(11+startx)+(y+starty)*128])
			fp.write("\n")

	if barbarian:
		with open(filename2, 'w') as fp:
			for sprite in sprite_data_barbaro:
				sp_name = sprite[0] % name
				start = sprite[1]
				nframes = sprite[2]
				fp.write("%s:\n" % sp_name)
				for frame in range(start, start+nframes):
					startx = (frame % 10) * 12
					starty = (frame / 10) * 32

					for y in range(0,32):
						fp.write("    DB ")
						for x in range(0,11):
							fp.write("%3d, " % imagen[(x+startx)+(y+starty)*128])
						fp.write("%3d\n" % imagen[(11+startx)+(y+starty)*128])
				fp.write("\n")


def export_spritesheet_extraweapons(image, name, filename):
	filename3 = filename + "_3.asm"
	filename4 = filename + "_4.asm"
	filename5 = filename + "_5.asm"

	with open(filename3, 'w') as fp:
		fp.write("dummyspace: ds 5376\n")
		for sprite in sprite_data_barbaro_weapon_eclipse:
			sp_name = sprite[0] % name
			start = sprite[1]
			nframes = sprite[2]
			fp.write("%s:\n" % sp_name)
			for frame in range(start, start+nframes):
				startx = (frame % 10) * 12
				starty = (frame / 10) * 32
	
				for y in range(0,32):
					fp.write("    DB ")
					for x in range(0,11):
						fp.write("%3d, " % imagen[(x+startx)+(y+starty)*128])
					fp.write("%3d\n" % imagen[(11+startx)+(y+starty)*128])
			fp.write("\n")


	with open(filename4, 'w') as fp:
		fp.write("dummyspace: ds 5376\n")
		for sprite in sprite_data_barbaro_weapon_axe:
			sp_name = sprite[0] % name
			start = sprite[1]
			nframes = sprite[2]
			fp.write("%s:\n" % sp_name)
			for frame in range(start, start+nframes):
				startx = (frame % 10) * 12
				starty = (frame / 10) * 32
	
				for y in range(0,32):
					fp.write("    DB ")
					for x in range(0,11):
						fp.write("%3d, " % imagen[(x+startx)+(y+starty)*128])
					fp.write("%3d\n" % imagen[(11+startx)+(y+starty)*128])
			fp.write("\n")

	with open(filename5, 'w') as fp:
		fp.write("dummyspace: ds 5376\n")
		for sprite in sprite_data_barbaro_weapon_blade:
			sp_name = sprite[0] % name
			start = sprite[1]
			nframes = sprite[2]
			fp.write("%s:\n" % sp_name)
			for frame in range(start, start+nframes):
				startx = (frame % 10) * 12
				starty = (frame / 10) * 32
	
				for y in range(0,32):
					fp.write("    DB ")
					for x in range(0,11):
						fp.write("%3d, " % imagen[(x+startx)+(y+starty)*128])
					fp.write("%3d\n" % imagen[(11+startx)+(y+starty)*128])
			fp.write("\n")


def load_spritesheet(filename):
	fp = file("level1.pl5", "rb")
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


	imgfile = pygame.image.load(filename).convert()
	pixels = pygame.PixelArray(imgfile)

	image=[]

	for y in range(0, 256):
		for x in range(0, 128):
			px = [(pixels[2*x, y] >> 16) & 255, (pixels[2*x, y] >> 8) & 255,  pixels[2*x, y] & 255]
			px1 = closest_color(px, paleta)
			px = [(pixels[2*x + 1, y] >> 16) & 255, (pixels[2*x + 1, y] >> 8) & 255,  pixels[2*x + 1, y] & 255]
			px2 = closest_color(px, paleta)
			image.append(px2 * 16 + px1)

	return image



pygame.init()
screen = pygame.display.set_mode((256*3, 192*3))
pygame.display.set_caption('Ianna - Press F12 to set fullscreen')
screen.fill((0, 0, 0))
buffer = pygame.Surface((256,192))
barbaro_image = pygame.image.load('barbaro01.bmp').convert()

buffer.blit(barbaro_image,(0,0))
pygame.transform.scale(buffer,(256*3,192*3),screen)
pygame.display.flip()


imagen = load_spritesheet('barbaro01.bmp')
export_spritesheet(imagen, 'barbaro', 'sprite_barbaro', barbarian=True)

imagen = load_spritesheet('barbaro02.bmp')
export_spritesheet_extraweapons(imagen, 'barbaro', 'sprite_barbaro')

imagen = load_spritesheet('esqueleto.bmp')
export_spritesheet(imagen, 'esqueleto', 'sprite_esqueleto')

imagen = load_spritesheet('orc.bmp')
export_spritesheet(imagen, 'orc', 'sprite_orc')

imagen = load_spritesheet('dalgurak.bmp')
export_spritesheet(imagen, 'dalgurak', 'sprite_dalgurak')

imagen = load_spritesheet('mummy.bmp')
export_spritesheet(imagen, 'mummy', 'sprite_mummy')

imagen = load_spritesheet('troll.bmp')
export_spritesheet(imagen, 'troll', 'sprite_troll')

imagen = load_spritesheet('caballerorenegado.bmp')
export_spritesheet(imagen, 'caballerorenegado', 'sprite_caballerorenegado')

imagen = load_spritesheet('rollingstone.bmp')
export_spritesheet(imagen, 'rollingstone', 'sprite_rollingstone')



while True:
	events = pygame.event.get()
	for event in events:
		if event.type == pygame.locals.QUIT:
			sys.exit(0)






