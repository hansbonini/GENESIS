constant MEGACD($400000)
constant MEGA32X($800000)
constant MEGA32X_FB($840000)
constant MEGA32X_FB_OW($860000)
constant MEGA32X_ROM($880000)
constant MEGA32X_ROM_BS($900000)
constant Z80_RAM($A00000)
constant VERSION($A10001)
constant JOYSTICK1_DATA($A10002)
constant JOYSTICK2_DATA($A10004)
constant EXPANSION_DATA($A10006)
constant JOYSTICK1_CTRL($A10008)
constant JOYSTICK2_CTRL($A1000A)
constant EXPANSION_CTRL($A1000C)
constant Z80_BUS($A111101)
constant Z80_RESET($A11201)
constant TMSS($A14000)
constant VDP_DATA($C00000)
constant VDP_DATA2($C00002)
constant VDP_CTRL($C00004)
constant VDP_CTRL2($C00006)
constant HV_COUNTER($C00008)
constant HV_COUNTER2($C0000A)
constant HV_COUNTER3($C0000C)
constant HV_COUNTER4($C0000E)
constant PSG($C00011)
constant PSG2($C00013)
constant PSG3($C00015)
constant PSG4($C00017)
constant DEBUG($C0001C)
constant DEBUG2($C0001E)
constant RAM($FF0000)
constant HBLANK_COUNTER($FF0000)
constant VBLANK_COUNTER(HBLANK_COUNTER+4)

constant VDP_CTRL_VRAM_READ($00000000)
constant VDP_CTRL_VRAM_WRITE($40000000)
constant VDP_CTRL_CRAM_READ($00000020)
constant VDP_CTRL_CRAM_WRITE($C0000000)
constant VDP_CTRL_VSRAM_READ($00000010)
constant VDP_CTRL_VSRAM_WRITE($40000010)

constant VDP_NUM_REGISTER($18)
constant VDP_REGS($8000)
constant VDP_REG_HINT($8100)
constant VDP_REG_VINT($8200)
constant VDP_REG_SCROLL_A($8300)
constant VDP_REG_WINDOW($8400)
constant VDP_REG_SCROLL_B($8500)
constant VDP_REG_SPRITES($8600)
constant VDP_REG_BGCOLOR($8800)
constant VDP_REG_HINT_FREQ($8A00)
constant VDP_REG_EXTINTERRUPTS_HVFULLSCREEN($8B00)
constant VDP_REG_SHADOWS_INTERLACE_H40($8C00)
constant VDP_REG_HSCROLL($8D00)
constant VDP_REG_AUTOINCREMENT($8F00)
constant VDP_REG_HVSCROLL($9000)
constant VDP_REG_WINDOW_X($9100)
constant VDP_REG_WINDOW_Y($9200)
constant VDP_REG_DMALEN_LO($9300)
constant VDP_REG_DMALEN_HI($9400)
constant VDP_REG_DMASRC_LO($9500)
constant VDP_REG_DMASRC_MI($9600)
constant VDP_REG_DMASRC_HI($9700)
constant VDP_WRITE_PALETTES($C0000000)

constant JOYSTICK_LATCH($40)

constant STACK_TOP($00FFE000)
constant RAM_SIZE_B($0000FFFF)
constant RAM_SIZE_W(RAM_SIZE_B/2)
constant RAM_SIZE_L(RAM_SIZE_B/4)

macro clearRegisters() {
    move.l  #RAM,a0      		                    //; Move address of first byte of ram (contains zero,RAM has been cleared) to a0
    movem.l (a0),#($FFFD)      	                    //; Multiple move zero to all registers (except sp)
    move.l  #$00000000,a0      	                    //; Clear a0
}
macro SaveAllRegistersToSP() {
    movem.l #$FFFF,-(a7)                            //; Save all registers a0-a7/d0-d7 into stack (sp) 
}
macro LoadAllRegistersFromSP() {
    movem.l (a7)+,#$FFFF                            //; Load all registers a0-a7/d0-d7 into stack (sp)
}

macro init(MAIN) {
    bra         +
-
    jmp         {MAIN}
+
    tst.w       (JOYSTICK1_CTRL).l                  //; Test Joystick 1
    bne -                                           //; Branch if Not Equal (to zero) - to Main
    tst.w       (EXPANSION_CTRL).l                  //; Test Expansion Port
    bne -                                           //; Branch if Not Equal (to zero) - to Main
}

macro initTMSS() {
    bra +
-
    db          "SEGA"
+
    move.b      (VERSION).l,d0                      //; Move Megadrive hardware version to d0
    andi.b      #$0F,d0                             //; The version is stored in last four bits, so mask it with 0F
    beq         +                                   //; If version is equal to 0, skip TMSS signature
    move.l      (-).l,(TMSS).l                      //; Move the string "SEGA" to $A14000 (TMSS)
    +
}

macro clearRAM(START, LENGTH) {
    move.l      #{START},a0                         //; Set start address
    move.l      #({LENGTH})/4,d1                    //; Set length
-
    move.l      #$00000000,(a0)+                    //; Move 4 bytes to address then increment
    dbra        d1,-                                //; Loop until equal length
}

macro loadRAM(SRC, LENGTH, DEST) {
    SaveAllRegistersToSP()

    movea.l #RAM,a1
    movea.l #({SRC}),a0
    clr.l   d0
    move.l  #(({LENGTH}/32)-3),d0
-;
    move.l  (a0)+,(a1)+                             //; TILE LINE #1
    move.l  (a0)+,(a1)+                             //; TILE LINE #2
    move.l  (a0)+,(a1)+                             //; TILE LINE #3
    move.l  (a0)+,(a1)+                             //; TILE LINE #4
    move.l  (a0)+,(a1)+                             //; TILE LINE #5
    move.l  (a0)+,(a1)+                             //; TILE LINE #6
    move.l  (a0)+,(a1)+                             //; TILE LINE #7
    move.l  (a0)+,(a1)+                             //; TILE LINE #8
    dbf     d0,-

    LoadAllRegistersFromSP()
}

macro disableInterrupts() {
    move        #$2700,sr                           //; Disable all Interrupts
}

macro enableInterrupts() {
    move.w      #$2000,sr                           //; Enable all Interrupts
}

macro setInterruptLevel(LEVEL) {
    move.w      sr,d0
    if ({LEVEL} == 3) {
        andi.w #$F8FF,d0	                        // ; INT level 3 (all interrupts)
    }
    move.w      d0,sr
    clr.l       d0			                        // ; Clear d0
}