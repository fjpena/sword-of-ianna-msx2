#!/usr/bin/env python

from __future__ import print_function

import pygame
import pygame.locals
import struct
import sys


def closest_color(px, paleta):
    color = 0
    diff = abs(px[0]-paleta[0][0]) + abs(px[1]-paleta[0][1]) + abs(px[2]-paleta[0][2])
    for i in range(1, 16):
        newdiff	= abs(px[0]-paleta[i][0]) + abs(px[1]-paleta[i][1]) + abs(px[2]-paleta[i][2])
        if newdiff < diff:
            diff = newdiff
            color = i
    return color


def export_tileset(image, filename):
    with open(filename, 'wb') as fp:
        for pix in image:
            fp.write(struct.pack("B", pix))


pygame.init()
screen = pygame.display.set_mode((256*3, 192*3))
pygame.display.set_caption('Ianna - Press F12 to set fullscreen')
screen.fill((0, 0, 0))
buffer = pygame.Surface((256, 192))
tiles_image = pygame.image.load('tiles_nivel01.bmp').convert()

buffer.blit(tiles_image, (0, 0))
pygame.transform.scale(buffer, (256*3, 192*3), screen)
pygame.display.flip()

fp = file("level1.pl5", "rb")
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

imagen = []

for y in range(0, 256):
    for x in range(0, 128):
        px = [(pixels[2*x, y] >> 16) & 255, (pixels[2*x, y] >> 8) & 255,  pixels[2*x, y] & 255]
        px1 = closest_color(px, paleta)
        px = [(pixels[2*x + 1, y] >> 16) & 255, (pixels[2*x + 1, y] >> 8) & 255,  pixels[2*x + 1, y] & 255]
        px2 = closest_color(px, paleta)
        imagen.append(px1 * 16 + px2)

export_tileset(imagen, 'tiles_nivel01.SR5')


while True:
    events = pygame.event.get()
    for event in events:
        if event.type == pygame.locals.QUIT:
            sys.exit(0)






