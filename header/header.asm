  
      // ; ******************************************************************
      // ; Sega Megadrive ROM header
      // ; ******************************************************************
      dl   STACK_TOP                                                         // ; Initial stack pointer value
      dl   CONFIG_ENTRYPOINT                                                 // ; Start of program
      dl   CONFIG_EXCEPTION                                                  // ; Bus error
      dl   CONFIG_EXCEPTION                                                  // ; Address error
      dl   CONFIG_EXCEPTION                                                  // ; Illegal instruction
      dl   CONFIG_EXCEPTION                                                  // ; Division by zero
      dl   CONFIG_EXCEPTION 
      dl   CONFIG_EXCEPTION
      dl   CONFIG_EXCEPTION                                                 // ; CHK CONFIG_EXCEPTIONdl   CONFIG_EXCEPTION                                                  // ; TRAPV CONFIG_EXCEPTIONdl   CONFIG_EXCEPTION                                                  // ; Privilege violation
      dl   CONFIG_NULLINTERRUPT                                              // ; TRACE CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; Line-A emulator
      dl   CONFIG_NULLINTERRUPT                                              // ; Line-F emulator
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Spurious CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; IRQ level 1
      dl   CONFIG_NULLINTERRUPT                                              // ; IRQ level 2
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT                                                    // ; IRQ level 3
      dl   CONFIG_HBLANKINTERRUPT                                            // ; IRQ level 4 (horizontal retrace interrupt)
      dl   CONFIG_NULLINTERRUPT                                              // ; IRQ level 5
      dl   CONFIG_VBLANKINTERRUPT                                            // ; IRQ level 6 (vertical retrace interrupt)
      dl   CONFIG_NULLINTERRUPT                                              // ; IRQ level 7
      dl   CONFIG_NULLINTERRUPT                                              // ; TRAP #00 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #01 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #02 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #03 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #04 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #05 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #06 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #07 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #08 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #09 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #10 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #11 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #12 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #13 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #14 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; TRAP #15 CONFIG_EXCEPTIONdl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT                                              // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT                                            // ; Unused (reserved)
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      dl   CONFIG_NULLINTERRUPT
      // ;*******************************************************************
      // ; Genesis
      // ;*******************************************************************
      db "SEGA MEGA DRIVE "                                                  // ; Console name
      db {CONFIG_RELEASEDATE}                                                // ; Copyrght holder and release date
      db {CONFIG_TITLE}                                                      // ; Domestic name
      db {CONFIG_TITLE}                                                      // ; International name
      db {CONFIG_SERIAL}                                                     // ; Version number
      dw $0000                                                               // ; Checksum
      db "J               "                                                  // ; I/O support
      dl {CONFIG_ROMSTART}                                                   // ; Start address of ROM
      dl {CONFIG_ROMEND}                                                     // ; End address of ROM
      dl RAM                                                                 // ; Start address of RAM
      dl (RAM+$FFFF)                                                           // ; End address of RAM
      dl $00000000                                                           // ; SRAM enabled
      dl $00000000                                                           // ; Unused
      dl $00000000                                                           // ; Start address of SRAM
      dl $00000000                                                           // ; End address of SRAM
      dl $00000000                                                           // ; Unused
      dl $00000000                                                           // ; Unused
      db "                                        "                          // ; Notes (unused)
      db {CONFIG_REGION},"             "                                     // ; Country codes