# XC-Edit
An IDE for XC=BASIC

## What is it?
XC=Edit is an IDE for XC=BASIC, a cross compiler to write C64 programs. It has a similar style to BASIC, but is much faster as it compiles directly to assembler. XC=BASIC code is ~20 times faster than standard BASIC V2 and still ~6 times than BASIC V2 compiled with a BASIC compiler like BASIC BOSS or AustroSpeed.

Features include:
* compile XC=BASIC code and run it directly in VICE (probably other emulators, too)
* basic syntax highlighting
* code folding

Currently it's very limited in its usage, as it's in early stage. But XC=Edit is in active development and should improve over time.

## Getting started
You need XC=BASIC of course. You can find more infos [here](https://xc-basic.net/).

After launching XC=Edit you need to select the XC=BASIC cross compiler. For this go to `Edit -> Options`. You can choose both the master and development branch (which usually provides more functionality, but probably is less stable) as different compilers. Please select xcb.bat.

In the options you also need to choose an emulator to run compiled XC=BASIC programs. XC=BASIC is only tested with VICE.

## Get the latest compiled version
Binary downloads will be provided at [itch.io](https://hamrath.itch.io/xcedit). Although XC=Edit should work fine on Linux and macOS, only Windows binaries are provided yet.

## How to use XC=Edit
After opening XC=Edit you are provided with an editor. You can write your XC=BASIC code and press `[F9]` to compile and run your code in the emulator. To just check if your code compiles you can press `[Ctrl+F9]`. To toggle between main and development compiler press `[Ctrl+F5]`.

## Future plans
This is a very early preview of XC=Edit. Future development includes:

* full project management
* parsing error and warning messages
* procedure List
* ~~find / Search & Replace (it's there, but not working yet)~~ (should work now)
* better syntax highlighting
* ~~open multiple files at once~~ (fixed)
* bug fixes
* much more

Any suggestions? Open an issue at the [Github repository](https://github.com/oliverhermanni/XC-Edit).

## Tips & Tricks
* To make code folding working properly, you should only write one command per line, especially commands like PROC ... ENDPROC, IF ... ELSE ... ENDIF, etc. 

## Compile the XC=Edit source code
To compile you'll need at least Lazarus 2.0.4. Also some additional packes are required: synfacilsyn, richmemopackage and JVCL. If they're not installed, Lazarus should ask you to do so.

