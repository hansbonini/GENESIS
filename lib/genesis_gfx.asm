macro waitVBlank() {
-
    move.w 	VDP_CTRL,d0 		                    // ; copy VDP status to d0
    btst   	#3,d0     			                    // ; vblank state in bit 3
    beq  	- 	                                    // ; wait for vblank to complete
}

macro setVDPRegisters(SRC) {
    move.l      #{SRC},a0   		  	            // ; Load address of register table into a0
    move.l      #(VDP_NUM_REGISTER-1),d0 	        // ; 24 registers to write (-1 for loop counter)
    move.l      #VDP_REGS,d1    	                // ; 'Set register 0' command
-
    move.b      (a0)+,d1          			        // ; Move register value to lower byte of d1
    move.w      d1,VDP_CTRL     			        // ; Write command and value to VDP control port
    add.w       #$0100,d1          			        // ; Increment register #
    dbra        d0,-
}

macro clearCRAM() {
    move.l      #VDP_WRITE_PALETTES,VDP_CTRL        // ; Write to palette memory
    move.l      #$3F,d1                             // ; CRAM size (in words)
-	
    move.w      #0,VDP_DATA                         // ; Write 0 (autoincrement is 2)
    dbra        d1,-
}

macro clearVRAM(DEST, LENGTH) {
    dmaFillVRAM({DEST}, {LENGTH})
}

macro clearVSRAM() {

    // ; Set bytes to DMA fill (lo) (reg 19)
    move.w      #(VDP_REG_DMALEN_LO+$0050),(VDP_CTRL).l
    // ; Set bytes to fill (hi) (reg 20)
    move.w      #VDP_REG_DMALEN_HI,(VDP_CTRL).l
    // ; Set DMA to Fill (reg 23,bits 0-1)
    move.w      #(VDP_REG_DMASRC_HI+$0080),(VDP_CTRL).l

    move.l      #$40000090,VDP_CTRL 			    // ; Set destination address
    move.w      #$0,VDP_DATA           		        // ; Value to write
-                    
    move.w 	    VDP_CTRL,d1          		        // ; Read VDP status reg
    btst   	    #1,d1                 		        // ; Check if DMA finished
    bne  	    -

    // ; Set autoincrement to 1 byte
    move.w      #(VDP_REG_AUTOINCREMENT+$0002),(VDP_CTRL).l
    // ; Set H interrupt timing
    move.w      #(VDP_REG_HINT_FREQ+$00DF),(VDP_CTRL).l  			
}


macro loadVRAM(SRC, LENGTH, DEST) {
    SaveAllRegistersToSP()

    move.l      #($VDP_CTRL_VRAM_WRITE+(({DEST}&$3FFF)<<16)+(({DEST}&$C000)>>14)),(VDP_CTRL).l
    movea.l     #({SRC}),a0
    clr.l       d0
    move.l      #(({LENGTH}/32)-3),d0
-;
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #1
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #2
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #3
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #4
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #5
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #6
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #7
    move.l      (a0)+,(VDP_DATA).l                  //; TILE LINE #8
    dbf         d0,-

    LoadAllRegistersFromSP()
}


macro loadPal(SRC, LENGTH, INDEX) {
    SaveAllRegistersToSP()

    clr.l       d0
    move.b      #({INDEX}*$1E),d0
    lea         ({SRC}).l,a0
                                                    // ;  Colour index to CRAM destination address
	swap        d0                                  // ;  Move address to upper word
	ori.l       #VDP_CTRL_CRAM_WRITE,d0              // ;  OR CRAM write command
	move.l      d0,(VDP_CTRL).l                     // ;  Send dest address to VDP

    clr.l       d0
	move.b      #({LENGTH}-1),d0                    // ;  Size of palette
-
	move.w      (a0)+,(VDP_DATA).l                  // ;  Move word to CRAM
	dbra        d0,-

    LoadAllRegistersFromSP()
}

macro dmaLoadVRAM(SRC, LENGTH, DEST) {
    SaveAllRegistersToSP()

    move.w      #(VDP_REG_HINT+$0074),(VDP_CTRL).l
    move.w      #(VDP_REG_AUTOINCREMENT+$0002),(VDP_CTRL).l
    move.w      #(VDP_REG_DMALEN_LO+((({LENGTH})>>1)&$FF)),(VDP_CTRL).l
    move.w      #(VDP_REG_DMALEN_HI+(((({LENGTH})>>1)&$FF00)>>8)),(VDP_CTRL).l
    move.w      #(VDP_REG_DMASRC_LO+(({SRC}>>1)&$FF)),(VDP_CTRL).l
    move.w      #(VDP_REG_DMASRC_MI+((({SRC}>>1)&$FF00)>>8)),(VDP_CTRL).l
    move.w      #(VDP_REG_DMASRC_HI+((({SRC}>>1)&$7F0000)>>16)),(VDP_CTRL).l
    move.l      #$40000080+(({DEST}&$3FFF)<<16)+(({DEST}&$C000)>>14),(VDP_CTRL).l
-                    
    move.w 	    VDP_CTRL,d1          		        // ; Read VDP status reg
    btst   	    #1,d1                 		        // ; Check if DMA finished
    bne  	    -
    move.w      #(VDP_REG_HINT+$0064),(VDP_CTRL).l

    LoadAllRegistersFromSP()
}


macro dmaFillVRAM(DEST, LENGTH) {
    SaveAllRegistersToSP()

    move.w      #(VDP_REG_HINT+$0074),(VDP_CTRL).l
    move.w      #(VDP_REG_AUTOINCREMENT+$0001),(VDP_CTRL).l
    move.w      #(VDP_REG_DMALEN_LO+(({LENGTH}>>1)&$FF)),($c00004).l
    move.w      #(VDP_REG_DMALEN_HI+((({LENGTH}>>1)&$FF00)>>8)),($c00004).l
    move.w      #(VDP_REG_DMASRC_HI+$0080),(VDP_DATA).l
    move.l      #$40000080+(({DEST}&$3FFF)<<16)+(({DEST}&$C000)>>14),(VDP_DATA).l
    move.w      #(VDP_REG_HINT+$0064),(VDP_CTRL).l

    LoadAllRegistersFromSP()
}

macro setReadVRAM(OFFSET) {
    move.l      #VDP_CTRL_VRAM_READ+(({OFFSET}&$3FFF)<<16)+(({OFFSET}&$C000)>>14),(VDP_CTRL).l
}
macro setWriteVRAM(OFFSET) {
    move.l      #VDP_CTRL_VRAM_WRITE+(({OFFSET}&$3FFF)<<16)+(({OFFSET}&$C000)>>14),(VDP_CTRL).l
}
macro setReadCRAM(OFFSET) {
    move.l      #VDP_CTRL_CRAM_READ+({OFFSET}<<16),(VDP_CTRL).l
}
macro setWriteCRAM(OFFSET) {
    move.l      #VDP_CTRL_CRAM_WRITE+({OFFSET}<<16),(VDP_CTRL).l
}
macro setReadVSRAM(OFFSET) {
    move.l      #VDP_CTRL_VSRAM_READ+({OFFSET}<<16),(VDP_CTRL).l
}
macro setWriteVSRAM(OFFSET) {
    move.l      #VDP_CTRL_VSRAM_WRITE+({OFFSET}<<16),(VDP_CTRL).l
}