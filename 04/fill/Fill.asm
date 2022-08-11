// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.
@R0
M=0
(LOOP)
    @KBD
    D=M
    @R0
    M=D

    @i
    M=0
    @k
    M=0

    @ROW_LOOP
    0;JMP
@LOOP
0;JMP

(COL_LOOP)
    @32
    D=A
    @j
    D=D-M

    @ROW_LOOP_END
    D;JEQ

    @j
    D=M
    @k
    D=D+M

    @SCREEN
    D=A+D
    @PIXEL
    M=D

    @R0
    D=M

    @PRESSED
    D;JNE

    @PIXEL
    A=M
    M=0

    @END_PRESSED
    0;JMP

(PRESSED)
    @PIXEL
    A=M
    M=-1
    @END_PRESSED
    0;JMP

(END_PRESSED)
    @j
    M=M+1

    @COL_LOOP
    0;JMP

(ROW_LOOP)
    @j
    M=0

    @256
    D=A
    @i
    D=D-M

    @LOOP
    D;JEQ

    @COL_LOOP
    0;JMP

(ROW_LOOP_END)
    @i
    M=M+1
    @32
    D=A
    @k
    M=M+D

    @ROW_LOOP
    0;JMP
