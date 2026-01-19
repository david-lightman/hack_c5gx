// Simple IO Test
// 1. Read Switches -> Write to LEDs
// 2. If Key[0] is pressed, turn on all LEDs

/*
(LOOP)
    // Check Switches
    @SW
    D=M
    @LEDG
    M=D     // LEDs = Switches
    
    // Check Key 0
    @KEY
    D=M
    @1
    D=D&A   // Mask bit 0
    @LOOP
    D;JEQ   // If Key0 is not pressed, skip
    
    // Key Pressed: Override LEDs to ALL ON
    @255    // 0xFF
    D=A
    @LEDG
    M=D
    
(SKIP_OVERRIDE)
    @SKIP_OVERRIDE
    0;JMP

*/

(LOOP)
    // 1. Check Key 0
    @24578  // KEY Address
    D=M
    @1
    D=D&A   // Mask bit 0. D=1 if Pressed, D=0 if Released.
    
    @key_pressed
    D;JNE   // If D != 0 (Pressed), Jump to override

    // 2. State: Key Released (Copy SW to LED)
    @24577  // SW Address
    D=M
    @write_leds
    0;JMP

(key_pressed)
    // 3. State: Key Pressed (All LEDs ON)
    @255    // 0xFF
    D=A

(write_leds)
    // 4. Update Hardware
    @24579  // LED Address
    M=D
    
    // 5. Repeat forever
    @LOOP
    0;JMP
