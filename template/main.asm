arch        md.cpu
endian      msb

output      "demo.md",create
define      CONFIG_TITLE("GAME NAME                                       ")
define      CONFIG_REGION("JUE")
define      CONFIG_RELEASEDATE("(C)BASS 2021.JAN")
define      CONFIG_SERIAL("GM XXXXXXXX-00")
define      CONFIG_ROMSTART(header)
define      CONFIG_ROMEND(end)

constant    CONFIG_PLANEA($C000)
constant    CONFIG_PLANEB($E000)

constant    CONFIG_ENTRYPOINT(start)
constant    CONFIG_EXCEPTION(exception)
constant    CONFIG_NULLINTERRUPT(null)
constant    CONFIG_HBLANKINTERRUPT(hblank)
constant    CONFIG_VBLANKINTERRUPT(vblank)

include     "../../lib/genesis.asm"
include     "../../lib/genesis_gfx.asm"

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
    // MAIN GAME CODE HERE
origin $07FFFF
end:

