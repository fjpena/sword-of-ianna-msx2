The Sword of Ianna (MSX2)
.........................

This is the full source code, including artwork, for MSX2 version of our
game, The Sword of Ianna.

Compiling
.........

The makefile has been created for Linux. It will probably work on Mac OS X
without many changes. I will happily accept PRs for a Windows makefile.

You can just run "make" to get the ianna.rom file. You will need some tools to
build:

- The pasmo assembler (http://pasmo.speccy.org/)
- The apack compressor. I use the version from http://www.smspower.org/maxim/uploads/SMSSoftware/aplib12.zip?sid=23bcb2a72f8a461be5cad0f46f7c3681,
  renamed to "apack" and run via Wine.
- The fill16k utility, from the tools/ directory.
- There are some files (with .plet1 extension) that have been created using
  pletter ("pletter 1 file").

There are not many hardcoded values in this version (it is cleaner than the
Spectrum one, to be honest). If you have any trouble compiling, just let me
know and I will try to help.

License
.......

Please refer to the LICENSE file included in this repository.
