arch        md.cpu
endian      msb

output      "demo.md",create
define      CONFIG_TITLE("RESILIENCIA - CAPITULO 1 - O MAL PRESSAGIO      ")
define      CONFIG_REGION("JUE")
define      CONFIG_RELEASEDATE("(C)BASS 2021.JAN")
define      CONFIG_SERIAL("GM XXXXXXXX-00")
define      CONFIG_ROMSTART(header)
define      CONFIG_ROMEND(end)

constant    CONFIG_ENTRYPOINT(start)
constant    CONFIG_EXCEPTION(exception)
constant    CONFIG_NULLINTERRUPT(null)
constant    CONFIG_HBLANKINTERRUPT(hblank)
constant    CONFIG_VBLANKINTERRUPT(vblank)

include     "../../lib/genesis.asm"
include     "../../lib/genesis_gfx.asm"


macro loadTextToPlaneA(SRC, LENGTH, LINE, COL) {
    SaveAllRegistersToSP()

    setWriteVRAM(($C000+({LINE}*$80)+({COL}*2)))

    clr.l       d0
    move.w      #{LENGTH},d0
    lea         ({SRC}).l,a0
    
-
    cmp.w       #0,d0
    beq         +
    clr.l       d1
    move.w      #$8000,d1
    add.b       (a0)+,d1
    sub.w       #$1F,d1
    move.w      d1,(VDP_DATA).l
    dbf         d0,-
+
    LoadAllRegistersFromSP()
}

macro drawTilemapSequenceToPlaneA(SRC, LINE, COL, WIDTH, HEIGHT) {
    SaveAllRegistersToSP()

    clr.l       d0
    clr.l       d1
    clr.l       d2
    clr.l       d3
    clr.l       d4
    clr.l       d5
    clr.l       d6

    move.w      #({SRC}/32),d0
    add.l       #$A000,d0
    move.w      #({WIDTH}-1),d1
    move.w      #({HEIGHT}-1),d2
    move.w      #($C000+({LINE}*$80)+({COL}*2)),d3
    move.l      #VDP_CTRL_VRAM_WRITE,d4
    move.l      d3,d5
    move.l      d3,d6
    andi.w      #$3FFF,d5
    andi.w      #$C000,d6
    asl.l       #8,d5
    asl.l       #8,d5
    asr.l       #7,d6
    asr.l       #7,d6
    add.l       d5,d6
    add.l       d6,d4
    move.l      d4,d5

-
    move.l      d4,(VDP_CTRL).l
    move.w      d0,(VDP_DATA).l
    add.w       #1,d0
    add.l       #$00020000,d4
    dbf         d1,-

    move.w      #({WIDTH}-1),d1
    add.l       #$00800000,d5
    move.l      d5,d4
    dbf         d2,-

    LoadAllRegistersFromSP()
}

macro drawTilemapSequenceToPlaneB(SRC, LINE, COL, WIDTH, HEIGHT) {
    SaveAllRegistersToSP()

    clr.l       d0
    clr.l       d1
    clr.l       d2
    clr.l       d3
    clr.l       d4
    clr.l       d5
    clr.l       d6

    move.w      #({SRC}/32),d0
    add.l       #$E000,d0
    move.w      #({WIDTH}-1),d1
    move.w      #({HEIGHT}-1),d2
    move.w      #($E000+({LINE}*$80)+({COL}*2)),d3
    move.l      #VDP_CTRL_VRAM_WRITE,d4
    move.l      d3,d5
    move.l      d3,d6
    andi.w      #$3FFF,d5
    andi.w      #$C000,d6
    asl.l       #8,d5
    asl.l       #8,d5
    asr.l       #7,d6
    asr.l       #7,d6
    add.l       d5,d6
    add.l       d6,d4
    move.l      d4,d5

-
    move.l      d4,(VDP_CTRL).l
    move.w      d0,(VDP_DATA).l
    add.w       #1,d0
    add.l       #$00020000,d4
    dbf         d1,-

    move.w      #({WIDTH}-1),d1
    add.l       #$00800000,d5
    move.l      d5,d4
    dbf         d2,-

    LoadAllRegistersFromSP()
}

macro LoadVRAMDistortionMask(SRC, LENGTH, DEST, MASK) {
    SaveAllRegistersToSP()

    move.l      #(VDP_CTRL_VRAM_WRITE+(({DEST}&$3FFF)<<16)+(({DEST}&$C000)>>14)),(VDP_CTRL).l
    movea.l     #({SRC}),a0
    clr.l       d1
    clr.l       d0
    move.l      #(({LENGTH}/32)-3),d0
-;
    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    move.l      (a0)+,d1
    andi.l      #{MASK},d1
    move.l      d1,(VDP_DATA).l 

    dbf         d0,-

    LoadAllRegistersFromSP()
}

origin $0000000
header:
include     "../../header/header.asm"

exception:
   stop         #$2700                  // ;  Halt CPU
   jmp          exception

null:
    rte

hblank:
   addi.l       #1, HBLANK_COUNTER    // ;  Increment hinterrupt counter
   rte

vblank:
   addi.l       #1, VBLANK_COUNTER    // ;  Increment vinterrupt counter
   rte

vdpRegisters:
   db $14 // ; 0: H interrupt on, palettes on
   db $74 // ; 1: V interrupt on, display on, DMA on, Genesis mode on
   db $34 // ; 2: Pattern table for Scroll Plane A at VRAM $C000 (bits 3-5 = bits 13-15)
   db $00 // ; 3: Pattern table for Window Plane at VRAM $0000 (disabled) (bits 1-5 = bits 11-15)
   db $07 // ; 4: Pattern table for Scroll Plane B at VRAM $E000 (bits 0-2 = bits 11-15)
   db $FF // ; 5: Sprite table at VRAM $F000 (bits 0-6 = bits 9-15)
   db $00 // ; 6: Unused
   db $00 // ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
   db $00 // ; 8: Unused
   db $00 // ; 9: Unused
   db $01 // ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
   db $00 // ; 11: External interrupts off, V scroll fullscreen, H scroll fullscreen
   db $81 // ; 12: Shadows and highlights off, interlace off, H40 mode (320 x 240 screen res)
   db $3F // ; 13: Horiz. scroll table at VRAM $FC00 (bits 0-5)
   db $00 // ; 14: Unused
   db $02 // ; 15: Autoincrement 2 bytes
   db $01 // ; 16: Vert. scroll 32, Horiz. scroll 64
   db $00 // ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
   db $00 // ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
   db $FF // ; 19: DMA length lo byte
   db $FF // ; 20: DMA length hi byte
   db $00 // ; 21: DMA source address lo byte
   db $00 // ; 22: DMA source address mid byte
   db $80 // ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)

initVDP:
    setVDPRegisters(vdpRegisters)
    clearCRAM()
    clearVRAM($0000, $FFFF)
    clearVSRAM()
    rts

wait:
    waitVBlank()
    waitVBlank()
    waitVBlank()
    waitVBlank()
    rts

start:
    disableInterrupts()
    init(main)
    initTMSS()
    jsr initVDP
    clearRAM(RAM, $FFFF)
    clearRegisters()
    enableInterrupts()
    setInterruptLevel(3)

main:
    dmaLoadVRAM(gfx_font, (gfx_font_end-gfx_font), $0020)
    //dmaLoadVRAM(gfx_logo, (gfx_logo_end-gfx_logo), $0800)
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $00000000)
    dmaLoadVRAM(gfx_intro_elements, (gfx_intro_elements_end-gfx_intro_elements), $2600)
    dmaLoadVRAM(gfx_castle, (gfx_castle_end-gfx_castle), $2c00)
    drawTilemapSequenceToPlaneB($2C00,2,0,28,14)
    loadPal(palette_text,16,0)
    loadPal(palette_logo,16,1)
    loadPal(pallette_intro_elements,32,2)
    loadTextToPlaneA(text_pressstart, (text_pressstart_end-text_pressstart), 13, 22)
    drawTilemapSequenceToPlaneA($800,4,14,28,8)
    jsr     animationIntroLogo


loop: 
    jsr     intro

    jmp     loop

intro:
    loadPal(pallette_intro_elements,32,2)

    clr.l   d0
    move.l  #5,d0
-
    jsr     animationIntroBG
    dbf     d0,-

    loadPal(pallette_intro_elements_blink,32,2)

    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-

    loadPal(pallette_intro_elements,32,2)

    clr.l   d0
    move.l  #8,d0
-
    jsr     animationIntroBG
    dbf     d0,-

    loadPal(pallette_intro_elements_blink,32,2)

    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-

    loadPal(pallette_intro_elements,32,2)

    jsr     animationIntroBG

    loadPal(pallette_intro_elements_blink,32,2)

    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    rts

animationIntroLogo:
    dmaLoadVRAM(tilemap_intro_bg, (tilemap_intro_bg_end-tilemap_intro_bg), $E800)
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $0484480)
    clr.l   d0
    move.l  #60,d0
-
    jsr     wait
    dbf     d0,-  
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $48A448A4)
    dmaLoadVRAM(tilemap_intro_bg_water_f2, (tilemap_intro_bg_water_f2_end-tilemap_intro_bg_water_f2), $E800)
    clr.l   d0
    move.l  #60,d0
-
    jsr     wait
    dbf     d0,-  
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $8AC88AC8)
    clr.l   d0
    move.l  #60,d0
-
    jsr     wait
    dbf     d0,-
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $ACFAACFA)
    dmaLoadVRAM(tilemap_intro_bg_water_f3, (tilemap_intro_bg_water_f3_end-tilemap_intro_bg_water_f3), $E800)
    clr.l   d0
    move.l  #60,d0
-
    jsr     wait
    dbf     d0,-
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $CFFCCFFC)
    clr.l   d0
    move.l  #60,d0
-
    jsr     wait
    dbf     d0,-
    LoadVRAMDistortionMask(gfx_logo, (gfx_logo_end-gfx_logo), $0800, $FFFFFFFF)
    dmaLoadVRAM(tilemap_intro_bg_water_f4, (tilemap_intro_bg_water_f4_end-tilemap_intro_bg_water_f4), $E800)
    rts


animationIntroBG:
    SaveAllRegistersToSP()

    loadTextToPlaneA(text_pressstart, (text_pressstart_end-text_pressstart), 13, 22)

    dmaLoadVRAM(tilemap_intro_bg, (tilemap_intro_bg_end-tilemap_intro_bg), $E800)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_water_f2, (tilemap_intro_bg_water_f2_end-tilemap_intro_bg_water_f2), $E800)
    dmaLoadVRAM(tilemap_intro_bg_sky_l1_f2, (tilemap_intro_bg_sky_l1_f2_end-tilemap_intro_bg_sky_l1_f2), $E900)
    dmaLoadVRAM(tilemap_intro_bg_sky_l2_f2, (tilemap_intro_bg_sky_l2_f2_end-tilemap_intro_bg_sky_l2_f2), $EA00)
    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_sky_l3_f2, (tilemap_intro_bg_sky_l3_f2_end-tilemap_intro_bg_sky_l3_f2), $EC00)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-

    dmaLoadVRAM(tilemap_intro_bg_water_f3, (tilemap_intro_bg_water_f3_end-tilemap_intro_bg_water_f3), $E800)
    dmaLoadVRAM(tilemap_intro_bg_sky_l1_f3, (tilemap_intro_bg_sky_l1_f3_end-tilemap_intro_bg_sky_l1_f3), $E900)
    dmaLoadVRAM(tilemap_intro_bg_sky_l2_f3, (tilemap_intro_bg_sky_l2_f3_end-tilemap_intro_bg_sky_l2_f3), $EA00)
    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_sky_l3_f3, (tilemap_intro_bg_sky_l3_f3_end-tilemap_intro_bg_sky_l3_f3), $EC00)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-

    dmaLoadVRAM(tilemap_intro_bg_water_f4, (tilemap_intro_bg_water_f4_end-tilemap_intro_bg_water_f4), $E800)
    dmaLoadVRAM(tilemap_intro_bg_sky_l1_f4, (tilemap_intro_bg_sky_l1_f4_end-tilemap_intro_bg_sky_l1_f4), $E900)
    dmaLoadVRAM(tilemap_intro_bg_sky_l2_f4, (tilemap_intro_bg_sky_l2_f4_end-tilemap_intro_bg_sky_l2_f4), $EA00)
    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_sky_l3_f4, (tilemap_intro_bg_sky_l3_f4_end-tilemap_intro_bg_sky_l3_f4), $EC00)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-
    loadTextToPlaneA(text_pressstart_clear, (text_pressstart_clear_end-text_pressstart_clear), 13, 22)

    dmaLoadVRAM(tilemap_intro_bg, (tilemap_intro_bg_end-tilemap_intro_bg), $E800)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_water_f2, (tilemap_intro_bg_water_f2_end-tilemap_intro_bg_water_f2), $E800)
    dmaLoadVRAM(tilemap_intro_bg_sky_l1_f2, (tilemap_intro_bg_sky_l1_f2_end-tilemap_intro_bg_sky_l1_f2), $E900)
    dmaLoadVRAM(tilemap_intro_bg_sky_l2_f2, (tilemap_intro_bg_sky_l2_f2_end-tilemap_intro_bg_sky_l2_f2), $EA00)
    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_sky_l3_f2, (tilemap_intro_bg_sky_l3_f2_end-tilemap_intro_bg_sky_l3_f2), $EC00)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-

    dmaLoadVRAM(tilemap_intro_bg_water_f3, (tilemap_intro_bg_water_f3_end-tilemap_intro_bg_water_f3), $E800)
    dmaLoadVRAM(tilemap_intro_bg_sky_l1_f3, (tilemap_intro_bg_sky_l1_f3_end-tilemap_intro_bg_sky_l1_f3), $E900)
    dmaLoadVRAM(tilemap_intro_bg_sky_l2_f3, (tilemap_intro_bg_sky_l2_f3_end-tilemap_intro_bg_sky_l2_f3), $EA00)
    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_sky_l3_f3, (tilemap_intro_bg_sky_l3_f3_end-tilemap_intro_bg_sky_l3_f3), $EC00)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-

    dmaLoadVRAM(tilemap_intro_bg_water_f4, (tilemap_intro_bg_water_f4_end-tilemap_intro_bg_water_f4), $E800)
    dmaLoadVRAM(tilemap_intro_bg_sky_l1_f4, (tilemap_intro_bg_sky_l1_f4_end-tilemap_intro_bg_sky_l1_f4), $E900)
    dmaLoadVRAM(tilemap_intro_bg_sky_l2_f4, (tilemap_intro_bg_sky_l2_f4_end-tilemap_intro_bg_sky_l2_f4), $EA00)
    clr.l   d0
    move.l  #20,d0
-
    jsr     wait
    dbf     d0,-
    dmaLoadVRAM(tilemap_intro_bg_sky_l3_f4, (tilemap_intro_bg_sky_l3_f4_end-tilemap_intro_bg_sky_l3_f4), $EC00)
    clr.l   d0
    move.l  #80,d0
-
    jsr     wait
    dbf     d0,-
    loadTextToPlaneA(text_pressstart_clear, (text_pressstart_clear_end-text_pressstart_clear), 13, 22)

    LoadAllRegistersFromSP()

    rts

palette_text:
	dw	$0111,$0111,$0222,$0333,$0444,$0555,$0666,$0777
	dw	$0888,$0999,$0AAA,$0BBB,$0CCC,$0DDD,$0EEE,$0FFF
palette_text_end:

palette_logo:
	dw	$0000,$00AE,$0044,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
palette_logo_end:

pallette_intro_elements:
	dw	$0383,$0FFF,$0EA8,$0E86,$0E64,$0E42,$0EEC,$0FFF
    dw	$0000,$0FFF,$0FA8,$0F86,$0F64,$0F42,$0FEC,$0FFF
	dw	$0000,$0211,$0322,$0220,$0222,$0622,$0442,$0642
	dw	$0664,$0A66,$0004,$0AAA,$0640,$0862,$0626,$0EA8
	dw	$0000,$0CA6,$0CC6,$0EE8,$0AAE,$0ACE,$066A,$086A
	dw	$0CAE,$0CEE,$0662,$0826,$0822,$0202,$0000,$0000
pallette_intro_elements_end:

pallette_intro_elements_blink:
	dw	$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
	dw	$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
	dw	$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
	dw	$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
	dw	$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
	dw	$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
pallette_intro_elements_blink_end:

tilemap_intro_bg:
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150

    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153

    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133
    dw  $C130,$C131,$C132,$C133,$C130,$C131,$C132,$C133

    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137
    dw  $C134,$C135,$C136,$C137,$C134,$C135,$C136,$C137

    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B
    dw  $C138,$C139,$C13A,$C13B,$C138,$C139,$C13A,$C13B

    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F
    dw  $C13C,$C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F

    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143

    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147

    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B

    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F
    dw  $C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F

    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143
    dw  $C140,$C141,$C142,$C143,$C140,$C141,$C142,$C143

    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147
    dw  $C144,$C145,$C146,$C147,$C144,$C145,$C146,$C147

    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
    dw  $C148,$C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B
tilemap_intro_bg_end:

tilemap_intro_bg_water_f2:
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151

    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
    dw  $C151,$C152,$C153,$C150,$C151,$C152,$C153,$C150
tilemap_intro_bg_water_f2_end:

tilemap_intro_bg_water_f3:
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152

    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
    dw  $C152,$C153,$C150,$C151,$C152,$C153,$C150,$C151
tilemap_intro_bg_water_f3_end:


tilemap_intro_bg_water_f4:
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153
    dw  $C150,$C151,$C152,$C153,$C150,$C151,$C152,$C153

    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
    dw  $C153,$C150,$C151,$C152,$C153,$C150,$C151,$C152
tilemap_intro_bg_water_f4_end:

tilemap_intro_bg_sky_l1_f2:
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133
    dw  $C134,$C131,$C132,$C133,$C134,$C131,$C132,$C133

    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
    dw  $C137,$C134,$C135,$C136,$C137,$C134,$C135,$C136
tilemap_intro_bg_sky_l1_f2_end:

tilemap_intro_bg_sky_l1_f3:
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131
    dw  $C132,$C133,$C134,$C131,$C132,$C133,$C134,$C131

    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
    dw  $C136,$C137,$C134,$C135,$C136,$C137,$C134,$C135
tilemap_intro_bg_sky_l1_f3_end:

tilemap_intro_bg_sky_l1_f4:
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130
    dw  $C131,$C132,$C133,$C130,$C131,$C132,$C133,$C130

    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
    dw  $C135,$C136,$C137,$C134,$C135,$C136,$C137,$C134
tilemap_intro_bg_sky_l1_f4_end:

tilemap_intro_bg_sky_l2_f2:
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138
    dw  $C139,$C13a,$C13B,$C138,$C139,$C13A,$C13B,$C138

    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C
    dw  $C13D,$C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C

    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140

    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
tilemap_intro_bg_sky_l2_f2_end:


tilemap_intro_bg_sky_l2_f3:
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139

    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D

    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141

    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C146,$C145
tilemap_intro_bg_sky_l2_f3_end:


tilemap_intro_bg_sky_l2_f4:
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139
    dw  $C13A,$C13B,$C138,$C139,$C13A,$C13B,$C138,$C139

    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D
    dw  $C13E,$C13F,$C13C,$C13D,$C13E,$C13F,$C13C,$C13D

    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141
    dw  $C142,$C143,$C140,$C141,$C142,$C143,$C140,$C141

    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C144,$C145
tilemap_intro_bg_sky_l2_f4_end:

tilemap_intro_bg_sky_l3_f2:
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148
    dw  $C149,$C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148

    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C
    dw  $C14D,$C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C

    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140
    dw  $C141,$C142,$C143,$C140,$C141,$C142,$C143,$C140

    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
    dw  $C145,$C146,$C147,$C144,$C145,$C146,$C147,$C144
tilemap_intro_bg_sky_l3_f2_end:

tilemap_intro_bg_sky_l3_f3:
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149
    dw  $C14A,$C14B,$C148,$C149,$C14A,$C14B,$C148,$C149

    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D
    dw  $C14E,$C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D

    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142

    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
    dw  $C146,$C147,$C144,$C145,$C146,$C147,$C145,$C145
tilemap_intro_bg_sky_l3_f3_end:

tilemap_intro_bg_sky_l3_f4:
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A
    dw  $C14B,$C148,$C149,$C14A,$C14B,$C148,$C149,$C14A

    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E
    dw  $C14F,$C14C,$C14D,$C14E,$C14F,$C14C,$C14D,$C14E

    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142
    dw  $C143,$C140,$C141,$C142,$C143,$C140,$C141,$C142

    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
    dw  $C147,$C144,$C145,$C146,$C147,$C144,$C145,$C146
tilemap_intro_bg_sky_l3_f4_end:

text_pressstart:
    db "APERTE START"
text_pressstart_end:

text_pressstart_clear:
    db "            "
text_pressstart_clear_end:

gfx_font:
    insert "gfx/font_8x8_4bpp.bin"
gfx_font_end:

gfx_logo:
    insert "gfx/logo_28x8_4bpp.bin"
gfx_logo_end:

gfx_intro_elements:
    insert "gfx/intro_elements_16x16_4bpp.bin"
gfx_intro_elements_end:
    
gfx_castle:
    insert "gfx/castle_28x14_4bpp.bin"
gfx_castle_end:

origin $07FFFF
end:

