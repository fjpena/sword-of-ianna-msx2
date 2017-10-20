all: ianna.rom

clean:
	rm -f *~
	rm -f *.rom
	rm -f *.bin

ianna.rom: ianna.asm vars.asm vdp.asm sprites.asm interrupt.asm music.asm depack.asm tiles.asm entities.asm drawsprite.asm objects.asm input.asm font.asm score.asm scripts.asm menu.asm intro.asm ianna_2.rom ianna_3.rom ianna_4.rom ianna_5.rom ianna_6.rom ianna_7.rom ianna_8.rom ianna_9.rom ianna_10.rom ianna_11.rom ianna_12.rom ianna_13.rom ianna_14.rom ianna_15.rom ianna_16.rom ianna_17.rom ianna_18.rom ianna_19.rom ianna_20.rom ianna_21.rom ianna_22.rom ianna_23.rom ianna_24.rom ianna_25.rom ianna_26.rom ianna_27.rom ianna_28.rom ianna_29.rom ianna_30.rom ianna_31.rom ianna_32.rom ianna_33.rom ianna_34.rom ianna_35.rom ianna_36.rom ianna_37.rom ianna_38.rom ianna_39.rom ianna_40.rom ianna_41.rom ianna_42.rom ianna_43.rom font.SR5.plet1 arkos.bin music_sfx.sym 
	pasmo ianna.asm ianna.bin ianna.sym
	dd if=ianna.bin of=ianna-0_1.rom bs=1k count=32
	cat ianna-0_1.rom ianna_2.rom ianna_3.rom ianna_4.rom ianna_5.rom ianna_6.rom ianna_7.rom ianna_8.rom ianna_9.rom ianna_10.rom ianna_11.rom ianna_12.rom ianna_13.rom ianna_14.rom ianna_15.rom ianna_16.rom ianna_17.rom ianna_18.rom ianna_19.rom ianna_20.rom ianna_21.rom ianna_22.rom ianna_23.rom ianna_24.rom ianna_25.rom ianna_26.rom ianna_27.rom ianna_28.rom ianna_29.rom ianna_30.rom ianna_31.rom ianna_32.rom ianna_33.rom ianna_34.rom ianna_35.rom ianna_36.rom ianna_37.rom ianna_38.rom ianna_39.rom ianna_40.rom ianna_41.rom ianna_42.rom ianna_43.rom > ianna.rom


ianna_2.rom: sprite_barbaro_1.asm
	pasmo sprite_barbaro_1.asm ianna_2.bin
	fill16k ianna_2.bin ianna_2.rom

ianna_3.rom: sprite_barbaro_2.asm
	pasmo sprite_barbaro_2.asm ianna_3.bin
	fill16k ianna_3.bin ianna_3.rom

ianna_4.rom: sprite_barbaro_3.asm
	pasmo sprite_barbaro_3.asm ianna_4.bin
	fill16k ianna_4.bin ianna_4.rom

ianna_5.rom: sprite_barbaro_4.asm
	pasmo sprite_barbaro_4.asm ianna_5.bin
	fill16k ianna_5.bin ianna_5.rom

ianna_6.rom: sprite_barbaro_5.asm
	pasmo sprite_barbaro_5.asm ianna_6.bin
	fill16k ianna_6.bin ianna_6.rom

ianna_7.rom: sprite_esqueleto.asm
	pasmo sprite_esqueleto.asm ianna_7.bin
	fill16k ianna_7.bin ianna_7.rom

ianna_8.rom: sprite_orc.asm
	pasmo sprite_orc.asm ianna_8.bin
	fill16k ianna_8.bin ianna_8.rom

ianna_9.rom: sprite_mummy.asm
	pasmo sprite_mummy.asm ianna_9.bin
	fill16k ianna_9.bin ianna_9.rom

ianna_10.rom: sprite_troll.asm
	pasmo sprite_troll.asm ianna_10.bin
	fill16k ianna_10.bin ianna_10.rom

ianna_11.rom: sprite_dalgurak.asm
	pasmo sprite_dalgurak.asm ianna_11.bin
	fill16k ianna_11.bin ianna_11.rom

ianna_12.rom: sprite_rollingstone.asm
	pasmo sprite_rollingstone.asm ianna_12.bin
	fill16k ianna_12.bin ianna_12.rom

ianna_13.rom: sprite_caballerorenegado.asm
	pasmo sprite_caballerorenegado.asm ianna_13.bin
	fill16k ianna_13.bin ianna_13.rom

ianna_14.rom: sprite_golem_inf.asm
	pasmo sprite_golem_inf.asm ianna_14.bin
	fill16k ianna_14.bin ianna_14.rom

ianna_15.rom: sprite_golem_sup.asm
	pasmo sprite_golem_sup.asm ianna_15.bin
	fill16k ianna_15.bin ianna_15.rom

ianna_16.rom: sprite_ogro_inf.asm
	pasmo sprite_ogro_inf.asm ianna_16.bin
	fill16k ianna_16.bin ianna_16.rom

ianna_17.rom: sprite_ogro_sup.asm
	pasmo sprite_ogro_sup.asm ianna_17.bin
	fill16k ianna_17.bin ianna_17.rom

ianna_18.rom: sprite_minotauro_inf.asm
	pasmo sprite_minotauro_inf.asm ianna_18.bin
	fill16k ianna_18.bin ianna_18.rom

ianna_19.rom: sprite_minotauro_sup.asm
	pasmo sprite_minotauro_sup.asm ianna_19.bin
	fill16k ianna_19.bin ianna_19.rom

ianna_20.rom: sprite_demonio_inf.asm
	pasmo sprite_demonio_inf.asm ianna_20.bin
	fill16k ianna_20.bin ianna_20.rom

ianna_21.rom: sprite_demonio_sup.asm
	pasmo sprite_demonio_sup.asm ianna_21.bin
	fill16k ianna_21.bin ianna_21.rom

ianna_22.rom: level1.map
	fill16k level1.map ianna_22.rom

ianna_23.rom: tiles01.asm tiles_nivel01.SR5.plet1
	pasmo tiles01.asm ianna_23.bin
	fill16k ianna_23.bin ianna_23.rom

ianna_24.rom: level2.map
	fill16k level2.map ianna_24.rom

ianna_25.rom: tiles02.asm tiles_nivel02.SR5.plet1
	pasmo tiles02.asm ianna_25.bin
	fill16k ianna_25.bin ianna_25.rom

ianna_26.rom: level3.map
	fill16k level3.map ianna_26.rom

ianna_27.rom: tiles03.asm tiles_nivel03.SR5.plet1
	pasmo tiles03.asm ianna_27.bin
	fill16k ianna_27.bin ianna_27.rom

ianna_28.rom: level4.map
	fill16k level4.map ianna_28.rom

ianna_29.rom: tiles04.asm tiles_nivel04.SR5.plet1
	pasmo tiles04.asm ianna_29.bin
	fill16k ianna_29.bin ianna_29.rom

ianna_30.rom: level5.map
	fill16k level5.map ianna_30.rom

ianna_31.rom: tiles05.asm tiles_nivel05.SR5.plet1
	pasmo tiles05.asm ianna_31.bin
	fill16k ianna_31.bin ianna_31.rom

ianna_32.rom: level6.map
	fill16k level6.map ianna_32.rom

ianna_33.rom: tiles06.asm tiles_nivel06.SR5.plet1
	pasmo tiles06.asm ianna_33.bin
	fill16k ianna_33.bin ianna_33.rom

ianna_34.rom: level7.map
	fill16k level7.map ianna_34.rom

ianna_35.rom: tiles07.asm tiles_nivel07.SR5.plet1
	pasmo tiles07.asm ianna_35.bin
	fill16k ianna_35.bin ianna_35.rom

ianna_36.rom: level8.map
	fill16k level8.map ianna_36.rom

ianna_37.rom: tiles08.asm tiles_nivel08.SR5.plet1
	pasmo tiles08.asm ianna_37.bin
	fill16k ianna_37.bin ianna_37.rom

ianna_38.rom: level9.map
	fill16k level9.map ianna_38.rom

ianna_39.rom: tiles09.asm tiles_nivel09.SR5.plet1
	pasmo tiles09.asm ianna_39.bin
	fill16k ianna_39.bin ianna_39.rom

ianna_40.rom: music_sfx.bin
	fill16k music_sfx.bin ianna_40.rom

ianna_41.rom: introscr.asm
	pasmo introscr.asm introscr.bin introscr.sym
	fill16k introscr.bin ianna_41.rom

ianna_42.rom: endingscr.asm
	pasmo endingscr.asm endingscr.bin endingscr.sym
	fill16k endingscr.bin ianna_42.rom

ianna_43.rom: level0.map menu_screen.SR5.plet1
	cat level0.map menu_screen.SR5.plet1 > ianna_43.bin
	fill16k ianna_43.bin ianna_43.rom

arkos.bin: ArkosTrackerPlayer_CPC_MSX.asm
	pasmo ArkosTrackerPlayer_CPC_MSX.asm arkos.bin arkos.sym

music_sfx.sym: music_sfx.bin
music_sfx.bin: music_sfx.asm iannafx.pck music-nomusic.pck music-level1.pck music-level3.pck music-level4.pck music-level5.pck music-level6.pck music-level7.pck music-level8.pck music-gameover.pck music-intro.pck music-menu.pck music-end.pck music-credits.pck
	pasmo music_sfx.asm music_sfx.bin music_sfx.sym

iannafx.pck: iannafx.mus
	apack iannafx.mus iannafx.pck

music-nomusic.pck: music-nomusic.mus
	apack music-nomusic.mus music-nomusic.pck

music-level1.pck: music-level1.mus
	apack music-level1.mus music-level1.pck

music-level3.pck: music-level3.mus
	apack music-level3.mus music-level3.pck

music-level4.pck: music-level4.mus
	apack music-level4.mus music-level4.pck

music-level5.pck: music-level5.mus
	apack music-level5.mus music-level5.pck

music-level6.pck: music-level6.mus
	apack music-level6.mus music-level6.pck

music-level7.pck: music-level7.mus
	apack music-level7.mus music-level7.pck

music-level8.pck: music-level8.mus
	apack music-level8.mus music-level8.pck

music-gameover.pck: music-gameover.mus
	apack music-gameover.mus music-gameover.pck

music-intro.pck: music-intro.mus
	apack music-intro.mus music-intro.pck

music-menu.pck: music-menu.mus
	apack music-menu.mus music-menu.pck

music-end.pck: music-end.mus
	apack music-end.mus music-end.pck

music-credits.pck: music-credits.mus
	apack music-credits.mus music-credits.pck
