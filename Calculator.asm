; Dominic and Alex: Final_Project_Hamilton
; Assembly Language Calculator


;  Source Citing:
;  For Circuit Board & IR Remote:
;  https://lastminuteengineers.com/arduino-1602-character-lcd-tutorial
;  https://www.electronicwings.com/pic/interfacing-lcd-16x2-in-4-bit-mode-with-pic18f4550-
;  https://download.elegoo.com/?t=UNO_R3_Project_Super_Starter_Kit
;  https://www.instructables.com/Arduino-IR-Sensor-and-Remote-With-LCD/
; 
;  For Code / Logic
;  Scott Griffith
;  https://whitgit.whitworth.edu/2024/fall/CS-278-1/In_Class/class_material/-/tree/main/Examples/IR_16x2_Display?ref_type=heads
;  https://www.vishay.com/docs/37484/lcd016n002bcfhet.pdf
;  https://www.sparkfun.com/datasheets/LCD/ADM1602K-NSW-FBS-3.3v.pdf
; 
;

;
;   Wiring for 16x2:
;       PORTD:
;           2 : R/S
;           3 : Enable
;           4-7 : D4-D7
;
;   Wiring for IR reciever:
;       PORTB: 0 - Y
;       5V       - R
;       GND      - G
;
;
; compile with:
; gavrasm.exe -b main.asm
; 
; upload with:
; avrdude -c arduino -p atmega328p -P COM4 -U main.hex
;
; Ref for IR Reciever: Page 95 of ELEGOO Starter Kit document: https://www.elegoo.com/pages/download (STEM Kit, Super Starter Kit)
;
; Ref for 16x2: https://www.electronicwings.com/pic/interfacing-lcd-16x2-in-4-bit-mode-with-pic18f4550-
;
; Interesting PDFs:
; https://www.vishay.com/docs/37484/lcd016n002bcfhet.pdf
; https://www.sparkfun.com/datasheets/LCD/ADM1602K-NSW-FBS-3.3v.pdf 

;
; Pulses are measured around ~1-2ms
; If you aim to keep 16 bit counts at 10 microseconds you can measure ~650ms widths
;
; We are probably going to want Clear Timer on Compare Match (CTC) Mode (i.e. set up an interrupt that will happen exactly every 10uS)
; 
; TCCR0A: Should not need to interact with OC0A / OC0B, so keep those 0
;           We want mode 2, WGM02: 0, WGM01: 1, WGM00: 9 
; TCCR0B: WGM02: 0,
;       Clock scaling: Aim: 10uS
;       System clock: 16MHz: 62.5 ns
;              8 bits @ prescale 0: 0 to 15.937us (this should work!)
;       CS02-CS00: 001 
; OCR0A: should be set to 160
;         160 * 62.5ns = 10uS
; TIMSK0: We do want OCMA to trigger
;        
; ------------------------------
; decoding
; ------------------------------
; 0  = 100000000111111110110100010010111111111111111111111011111110101011111111011
; 1  = 100000000111111110011000011001111110011111111111111011111110101011111111
; 2  = 100000000111111110001100011100111110101111111111111011111110101011111111
; 3  = 100000000111111110111101010000101111101111111111111011111110101011111111011
; 4  = 100000000111111110011000011101111110101111111111111011111110101011111111
; 5  = 100000000111111110011100011000111110101111111111111011111110101011111111
; 6  = 100000000111111110101101010100101110101111111111111011111110101011111111
; 7  = 100000000111111110100001010111101110101111111111111011111110101011111111
; 8  = 100000000111111110100101010110101110101111111111111011111110101011111111
; 9  = 100000000111111110101001010101101110101111111111111011111110101011111111
; P  = 100000000111111111010001001011101110101111110111111011111110101011111111
; V+ = 100000000111111110110001010011101111101111110111111011111110101011111111010
; F  = 100000000111111111110001000011101110101111110111111011111110101011111111
; >> = 1000000001111111111000010001111011111111111101111110111111101010111111110101111
; >| = 1000000001111111100000010111111011111110111101111110111111101010111111110101111
; << = 100000000111111110010001011011101110111011110111111011111110101011111111
; D  = 100000000111111111110000000111111111111011110111111011111110101011111111010
; V- = 100000000111111111010100001010111110101011110111111011111110101011111111
; U  = 100000000111111111001000001101111111101011110111111011111110101011111111010
; EQ = 10000000011111111100110000110011111111111111011111101111111010101111111101011111110
; ST = 100000000111111111011000001001111111111111110111111011111110111011111111010
; First 16 = Check = 0000000011111111 = 00FF
; Next 32 = Distinct Pattern
; 0  = 01101000100101111111111111111111 = 0  = 6897FFFF  
; 1  = 00110000110011111100111111111111 = 1  = 30CFCFFF 
; 2  = 00011000111001111101011111111111 = 2  = 18E7D7FF 
; 3  = 01111010100001011111011111111111 = 3  = 7A85F7FF 
; 4  = 00010000111011111101011111111111 = 4  = 10EFD7FF 
; 5  = 00111000110001111101011111111111 = 5  = 38C7D7FF 
; 6  = 01011010101001011101011111111111 = 6  = 5AA5D7FF 
; 7  = 01000010101111011101011111111111 = 7  = 42BDD7FF 
; 8  = 01001010101101011101011111111111 = 8  = 4AB5D7FF 
; 9  = 01010010101011011101011111111111 = 9  = 52ADD7FF 
; P  = 10100010010111011101011111101111 = P  = A25DD7EF 
; V+ = 01100010100111011111011111101111 = V+ = 629DF7EF 
; F  = 11100010000111011101011111101111 = F  = E21DD7EF 
; >> = 11000010001111011111111111101111 = >> = C23DFFEF 
; >| = 00000010111111011111110111101111 = >| = 02FDFDEF 
; << = 00100010110111011101110111101111 = << = 22DDDDEF 
; D  = 11100000001111111111110111101111 = D  = E03FFDEF 
; V- = 10101000010101111101010111101111 = V- = A857D5EF 
; U  = 10010000011011111111010111101111 = U  = 906FF5EF 
; EQ = 10011000011001111111111111101111 = EQ = 9867FFEF 
; ST = 10110000010011111111111111101111 = ST = B04FFFEF 

; we can actually use just first 8 digits
;  0  = 68
;  1  = 30
;  2  = 18
;  3  = 7A
;  4  = 10
;  5  = 38
;  6  = 5A
;  7  = 42
;  8  = 4A
;  9  = 52
;  P  = A2
;  V+ = 62
;  F  = E2
;  >> = C2
;  >| = 02
;  << = 22
;  D  = E0
;  V- = A8
;  U  = 90
;  EQ = 98
;  ST = B0
 
; address to hold input from IR
.EQU IR_BUFF =  $0100

; address to hold decoded values
.EQU INPUT_HOLD = $0400

; address to hold flag for determining which entry program is on
.EQU ENTRY_FLAG = $0600

; address to hold multiply product
.EQU MULT_HOLD = $0700

; address for storing previous answer
; CITE SCOTT
; _myString: .db "r16",0 ; does this run an error

.DEVICE ATmega328p ;Define the correct device
; Interrupt Vectors
.cseg
.org 000000 ; Start at memory location 0
	rjmp Begin ; Reset vector
	nop
	reti ; INT0
	nop
	reti ; INT1
	nop
	reti ; PCI0
	nop
	reti ; PCI1
	nop
	reti ; PCI2
	nop
	reti ; WDT
	nop
	reti ; OC2A
	nop
	reti ; OC2B
	nop
	reti ; OVF2
	nop
	reti ; ICP1
	nop
	reti ; OC1A
	nop
	reti ; OC1B
	nop
	reti ; OVF1
	nop
	rjmp OC0A_int ; OC0A
	nop
	reti ; OC0B
	nop
	reti ; OVF0
	nop
	reti ; SPI
	nop
	reti ; URXC
	nop
	reti ; UDRE
	nop
	reti ; UTXC
	nop
	reti ; ADCC
	nop
	reti ; ERDY
	nop
	reti ; ACI
	nop
	reti ; TWI
	nop
	reti ; SPMR
	nop 

; Goal of the subroutine: Keep track of the pulse widths on the IR receiver
; Uses the following for state:
; X - Current timer count
; Y - indirect SRAM location of the buffer
; r24 - counts entries from remote
; r25 - current state:
;       00 - Idle -> waiting for a 0 on the pin
;       01 - Mark -> Currently reading a 'down' / Low
;       02 - Space -> Currently reading a 'up' / High
;       03 - Done -> don't need to do anything else
; r23 - high nibble holds first entry number of digits, low nibble holds second entry number of digits

OC0A_int:
    push r16

    in r16, PINB
    andi r16, $01 ; mask out everything but the IR signal

    cpi r25, 3 ; Check for done condition; If done, don't need to do anything
    breq OC0A_int_return

    cpi XH, $70
    brge OC0A_int_LONGPULSE ; If X high is ever this long, then we are done and should transition to stop    

    cpi r25, 0 ; Check for Idle, if Idle, we are waiting for a low signal to start
    breq OC0A_int_IDLE

    cpi r25, 1 ; Check for MARK, if Mark we are waiting for a space
    breq OC0A_int_MARK

    cpi r25, 2 ; Check for SPACE, if Space we are waiting for a mark
    breq OC0A_int_SPACE

    ; We should never get here, so output an error and halt
    ldi r16, 'E'
    call LCD_Char
int_trap:
    nop
    rjmp int_trap

OC0A_int_IDLE:
    cpi r16, 0 ; Low signal, time to do some measuring (i.e. first signal)
    brne OC0A_int_return ; If it is not equal (i.e. high), then we want to keep waiting

    ;; What we know at this point: We have just recieved a low signal, which is the start of a transmission
    ;; What we need to do next: Set state to MARK
    ;;                          Set counter to 0
    clr XH
    clr XL  
    ldi r25, 1
    rjmp OC0A_int_return

OC0A_int_MARK:

    cpi r16, 1 ; If High, we need have transitioned and need to move to SPACE
    breq OC0A_int_MARK_TO_SPACE

    ;;What we know: we are in a mark, and it is ongoing
    adiw X,1 ; Add one to X count
    ; Keep going
    rjmp OC0A_int_return

OC0A_int_MARK_TO_SPACE:
    ;; This is the transition from mark to space, so low to high
    ;;Record count
    st Y+, XH ; Store count in SRAM location
    st Y+, XL
    ldi r25, 2; Set state to Space
    clr XH ; Reset count
    clr XL
    rjmp OC0A_int_return

OC0A_int_SPACE:

    cpi r16, 0 ; If low, we need to transition to MARK
    breq OC0A_int_SPACE_TO_MARK

    ;;What we know: we are in a space, and it is ongoing
    adiw X,1
    ;Keep going
    rjmp OC0A_int_return

OC0A_int_SPACE_TO_MARK:
    ;; This is the transition from mark to space, so low to high
    ;;Record count
    st Y+, XH ; Store count in SRAM location
    st Y+, XL
    ldi r25, 1; Set state to Space
    clr XH ; Reset count
    clr XL
    rjmp OC0A_int_return

OC0A_int_LONGPULSE:
    ;;What we know, the pulse is too long!
    st Y+, XH ; Store count in SRAM location
    st Y+, XL
    ldi r25, 3; Set state to Space
    clr XH ; Reset count
    clr XL

OC0A_int_return:
    pop r16
    reti


Begin:
    ; Set up the stack pointer (for calling subroutines)
    ldi r31, $08 ; Set high part of stack pointer
    out SPH, r31
    ldi r31, $ff ; set low part of stack pointer
    out SPL, r31
    
    sbi PORTB, 5 ; Turn off
    ldi r16, $20 ; Test LED signal
    out DDRB, r16
   
    ; EEPROM Set Up
    ldi r20, (0<<EEPM1) | (0<<EEPM0) ; Set EEPROM operations to erase and write
    sts EECR, r20 ; Because both are set to zero, this doesn't really do anything


    call IR_Timer_Init

    ; USART set up
    call USART_Init

    ; LED Set Up
    call LCD_Init
    ;ldi r16, 'T'
    ;call LCD_Char

    ; X - Current timer count
    ; Y - indirect SRAM location of the buffer
    ; r24 - buffer count
    ; r25 - current state:
    clr XH
    clr XL
    ldi YH, HIGH(IR_BUFF)
    ldi YL, LOW(IR_BUFF)

    ; setting entry flag to 0, indicating we are on first entry
    call ClearEntryFlag

    clr r24 ; set buffer to 0
    clr r23 ; reset number of digits
    ldi r25, 0 ; Set state to Idle
    
    sei ; Turn interrupts on

testLoop:
    cpi r25, 3; Compare with 3 (done)
    breq tLoopDone
    nop
    nop
    nop
    rjmp testLoop

; when done taking input, decode the value
tLoopDone:
    ; wait a little
    push r16
    ldi r16, $80
    call wait_xms
    pop r16
    ; decode
    call Decode

end:
    nop
    ld r17, Z
    cpi r17, $10 ; if equals sign has been pushed, go to PrintAnswer
    breq PrintAnswer
    cpi r17, $0D ; if power button has been pushed, reset screen
    breq Restart

    ; cpi r17, $0E ; if func button has been pressed, grab last answer from EEPROM
    ; breq LD_FROM_EEPROM

    ; otherwise reset all necessary registers and get next input
    clr XH
    clr XL
    ldi YH, HIGH(IR_BUFF)
    ldi YL, LOW(IR_BUFF)
    ldi r25, 0 ; Set state to Idle
    rjmp testLoop

restartLoop:
    ld r17, Z
    cpi r17, $10    ; if eq button pressed, go to print anser
    breq PrintAnswer
    clr XH          ; otherwise reset and go back to get next input
    clr XL
    ldi YH, HIGH(IR_BUFF)
    ldi YL, LOW(IR_BUFF)
    clr r24 ; set buffer to 0
    ldi r25, 0 ; Set state to Idle
    rjmp testLoop

PrintAnswer:
    ; wait a little bit
    push r16
    ldi r16, $80
    call wait_xms
    pop r16
    ; set pointer to beginning of input vector
    ldi ZH, high(INPUT_HOLD)
    ldi ZL, low(INPUT_HOLD)
    ldi r19, 0
PrintAnswerLoop:
    ; r24 hold how many entries were pressed, if we go past that then error occured and jump back
    cpi r24, 0
    breq restartLoop
    dec r24
    ; load the entries in, 0A means addition and 0B means subtraction so jump appropriately
    ld r18, Z+
    cpi r18, $0A
    breq addition
    cpi r18, $0B
    breq subtractionInt
    cpi r18, $0C
    breq multiplicationInt
    rjmp PrintAnswerLoop
; --------------------------------------------
; ; This is where we ld into EEPROM after printing the answer from calculation
; was not able to fully get this working
; LD_INTO_EEPROM:
;     push ZH
;     push ZL
;     push r18
;     ;_myString: .db "_",0
;     ldi ZH, HIGH(_myString*2)
;     ldi ZL, LOW(_myString*2)
;     lpm r18, Z+ 

;     cpi r18, 0 ; Compare read char to 0
;     breq LD_INTO_EEPROM_END ; If we find 0, then we need to end

;     rjmp LD_INTO_EEPROM

; LD_INTO_EEPROM_END:
;     pop r18
;     pop ZL
;     pop ZH

; ; Ld from EEPROM into screen
; LD_FROM_EEPROM:
;     push ZH
;     push ZL
;     ldi ZH, HIGH(_myString*2)
;     ldi ZL, LOW(_myString*2)

;     rjmp LD_FROM_EEPROM

;     pop ZL
;     pop ZH

; intermediate jump because relative out of jump for breq
subtractionInt:
    jmp subtraction
multiplicationInt:
    jmp OneDigitMultiplication

Restart:
    push r16
    ldi r16, $FF
    call wait_xms
    ;call wait_xms
    ;call wait_xms
    pop r16
    rjmp Begin
; --------------------------------------------
; This is where we jump when we need to execute and print sum
addition:
    push r16 ; will be used to print to LCD
    push r17 ; will be used to hold total number of entriesr
    push r18 ; will be used to hold # of digit one entries
    push r19 ; will be used to hold # of digit two entries
    push r20 ; temp hold for loaded values from Z pointer (dig1)
    push r21 ; temp hold for loaded values from Z pointer (dig2)
    push r22 ; will hold value for how many digits to print to LCD
    push r26 ; will hold carry bit if over 9

    ldi r17, $0
    ldi r22, $0
    ldi r26, $0

    mov r18, r23
    swap r18
    andi r18, $0f
    dec r18

    mov r19, r23
    andi r19, $0f

    add r17, r19
    add r17, r18
    inc r17  ; need to inc to take into account operation symbol

addLoop:
    call setZandYforAns
    ; add offset to ZL and YL, then load values into r20 and r21
    add ZL, r18 
    ld r20, Z
    add YL, r17
    ld r21, Y

    ; add registers holding values
    add r20, r21

    ; add carry bit
    add r20, r26

    ; addCarry will set carry and get accurate value of 0-9 to print to LCD
    call addCarry
    ; push that value to the stack to print in reverse later, increment and decrement appropriate registers
    push r20


    inc r22
    dec r17
    dec r18
    brmi addDigitCheck
    dec r19
    brmi addDigitCheck
    
    ; loop back
    rjmp addLoop

; checks if leading digit had an overflow and need to print a leading 1 and increment number of prints to execute
addDigitCheck:
    cpi r26, $00    ; if carry is 0, jump to printing portion
    breq printAdd
    push r26
    ldi r26, $00
    inc r22
    rjmp printAdd

printAdd:
    ; go to end wehn r22 has run out of digits to print
    cpi r22, $0
    breq endAdd
    dec r22
    ; wait a little bit
    ldi r16, $FF
    call wait_xms
    call wait_xms

    ; pop from top of stack and print
    pop r16
    call converToASCII
    call LCD_Char
    rjmp printAdd

endAdd:
    pop r25
    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
    rjmp restartLoop
; --------------------------------------------
; this is where we jump when we need to execute and print difference
subtraction:
    push r16 ; will be used to print to LCD
    push r17 ; will be used to hold total number of entries
    push r18 ; will be used to hold # of digit one entries
    push r19 ; will be used to hold # of digit two entries
    push r20 ; temp hold for loaded values from Z pointer (dig1)
    push r21 ; temp hold for loaded values from Z pointer (dig2)
    push r22 ; will hold value for how many digits to print to LCD
    push r26 ; will be flag to whether we need to print a negtive sign

    ; initialize number of entries, answer entries, and negative flag to 0
    ldi r17, $0
    ldi r22, $0
    ldi r26, $0

    mov r18, r23
    swap r18
    andi r18, $0f
    dec r18


    mov r19, r23
    andi r19, $0f

    add r17, r19
    add r17, r18
    inc r17  ; need to inc to take into account operation symbol

    ; call check negative function to see if second number greater than first
    call checkNegative
    ; short wait
    ldi r16, $0a
    call wait_xms
    ; since we use r17 and r18 to index through stored entries and do calculations, swapping them would swap the direction of subtraction
    call swap17and18
subLoop:
    ; reset the Z and Y registers to beginning of entries
    call setZandYforAns
    ; add offset to ZL and YL, then load values into r20 and r21
    ; we are decrementing r18 and r17 each time to parse from lsb to msb in order, like a pseudo decrement counter
    add ZL, r18 
    ld r20, Z
    add YL, r17
    ld r21, Y

    ; add registers holding values
    sub r20, r21

    ; subCarry will alter stored values if need carry down from higher decimal digit
    call subCarry

    ; push that value to the stack to print in reverse later, increment and decrement appropriate registers
    push r20
    inc r22 ; increment total number of digits to print
    dec r19
    brmi negtiveSymbol ; if r19 is negative, we have gone through all digits, jump to see if we print a negative symbol
    dec r17 ; decrement appropriately
    dec r18
    ; loop back
    rjmp subLoop

negtiveSymbol:
    ; screen kept printing a lower case y at the start, so just popped it off the stack and decremented the overall print counter
    pop r16
    dec r22
    ; if negative flag is 0, branch to print
    cpi r26, $00
    breq printSub
    ; wait
    ldi r16, $FF
    call wait_xms
    ; otherwise print a minus symbol to LCD
    ldi r16, '-'
    call LCD_Char
printSub:
    ldi r16, $FF
    call wait_xms
    ; go to end wehn r22 has run out of digits to print
    cpi r22, $0
    breq endSub
    dec r22

    ; pop from top of stack and print to LCD
    pop r16
    call converToASCII
    call LCD_Char


    rjmp printSub

endSub:
    pop r26
    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
    rjmp restartLoop
; --------------------------------------------
; multiplication portion of program, basically use first entry a counter and then second digit is added onto itself until counter is out
; was not able to fully get this working, so use OneDigitMultiplication loop instead
multiplication:
    push r16 ; will be used to print to LCD
    push r17 ; will be used to hold total number of entries
    push r18 ; will be used to hold # of digit one entries
    push r19 ; will be used to hold # of digit two entries
    push r20 ; will hold running sum
    push r21 ; temp hold for loaded values from Z pointer (dig2)
    push r22 ; will hol value for how many digits to print to LCD
    push r25 ; will hold counter for repeated addition
    push r26 ; loop will hold carry bit if over 9


    ldi r17, $0
    ldi r26, $0
    ldi r25, $0

    mov r16, r26
    call printr

    mov r18, r23
    swap r18
    andi r18, $0f
    dec r18

    mov r19, r23
    andi r19, $0f

    ; print how many digits were entered
    ;mov r16, r19
    ;call printr

    mov r22, r19

    add r17, r19
    add r17, r18
    inc r17  ; need to inc to take into account operation symbol

    ldi ZH, high(MULT_HOLD)
    ldi ZL, low(MULT_HOLD)
    ldi r16, $06
    call clearZ
multOuterOuterLoop:
    mov r16, r26
    call printr
    call setMultCounter
    mov r16, r26
    call printr
    ; print the count after running through the count setter
    ;mov r16, r25
    ;call printr

multOuterLoop:
    mov r16, r26
    call printr
    ldi ZH, high(MULT_HOLD)
    ldi ZL, low(MULT_HOLD)
    push r20
    ld r20, Z
    mov r16, r26
    call printr
    ; print whatever value is stored at MUL_HOLD
    ;mov r16, r20
    ;call printr
    ; print count again
    ;mov r16, r25
    ;call printr

    pop r20
    ;cpi r26, $00
    ;breq multOuterOuterLoop
    cpi r25, $00
    breq multPrint
multInnerLoop:
    ldi YH, high(INPUT_HOLD)
    ldi YL, low(INPUT_HOLD)


    add YL, r17

    ld r21, Y
    ld r20, Z

    ;mov r16, r21
    ;call printr
    ;mov r16, r20
    ;call printr
    mov r16, r26
    call printr

    add r20, r21
    ;add r20, r26
    ;clr r26
    call addCarry

    st Z+, r20

    ;mov r16, r20
    ;call printr
    mov r16, r26
    call printr

    dec r25
    dec r17
    dec r19
    breq multDigitCheck
    rjmp multInnerLoop

; checks if leading digit had an overflow and need to print a leading 1 and increment number of prints to execute
multDigitCheck:
    cpi r26, 0
    breq multOuterLoop
multDigitCheckInnerLoop:
    ld r20, Z+
    add r20, r26
    st Z+, r20
    call addCarry
    cpi r26, 0
    breq multOuterLoop
    inc r22
    rjmp multDigitCheckInnerLoop

multPrint:
    ; go to end wehn r22 has run out of digits to print
    cpi r22, $0
    breq endMult
    dec r22
    ; wait a little bit
    ldi r16, $FF
    call wait_xms
    ; pop from top of stack and print
    add ZL, r22
    ld r16, Z
    call converToASCII
    call LCD_Char
    rjmp multPrint

endMult:
    pop r26
    pop r25
    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
    rjmp restartLoop

; in case we can't get multiplication working, we at least can do one digit multiplication as a demo
OneDigitMultiplication:
    push r16    ; save r16, going to be using to print
    ; set Z register to where our user input is stored
    call setZandYforAns
    ld r19, Z+  ; load in first entry, step forward
    adiw Z, 1   ; jump forward past operator to load in second entry
    ld r18, Z

    mul r19, r18    ; multiply both entries
    ldi r16, 'x'
    call LCD_Char
    ; with one digit multiplication, maximum value it 81 so only need bottom byte of mult answer
    mov r16, r00    ; load in low bit of product from r00, print to LCD
    ; print answer in two digit hex
    call multConvertPrint

    pop r16 ; restore r16
    rjmp restartLoop

; See notes above as to why we are setting these this way
IR_Timer_Init:
    push r16
    ; TCCR0A: Should not need to interact with OC0A / OC0B, so keep those 0
    ;           We want mode 2, WGM02: 0, WGM01: 1, WGM00: 0 
    ldi r16, (1<<WGM01)
    out TCCR0A, r16

    ; TCCR0B: WGM02: 0,
    ;       Clock scaling: Aim: 10uS
    ;       System clock: 16MHz: 62.5 ns
    ;              8 bits @ prescale 0: 0 to 15.937us (this should work!)
    ;       CS02-CS00: 001 
    ldi r16, (1<<CS00)
    out TCCR0B, r16

    ; OCR0A: should be set to 160
    ;         160 * 62.5ns = 10uS
    ldi r16, 160
    out OCR0A, r16

    ; TIMSK0: We do want OCIE0A to trigger
    ldi r16, (1<<OCIE0A)
    sts TIMSK0, r16

    pop r16
    ret

; 16x2 Initilization
; Set up things in 4 bit mode
;
LCD_Init:
    push r16
    ; Configure 

    ; PortD set up
    ; Assuming RS: D2, E: D3, D4-7: D4-7 
	; set up port D:7-2 as output
	ldi r16, $fC ; DDRD - data direction (Upper 6 output)
    out DDRD, r16
    ldi r16, $00 ; Clear all PORTD values
	out PORTD, r16 ; Send configuration


    ; Configure LCD chip
    ldi r16, 15
    call wait_xms ; wait 15ms for chip to turn on

    ldi r16, $02
    call LCD_Command ; Should initialize 4bit mode

    ldi r16, $28
    call LCD_Command ; Function Set (4bit mode, 2-line display, Format 5x8 (maybe)

    ldi r16, $01
    call LCD_Command ; Clear display

    ldi r16, $0C
    ;ldi r16, $0E
    call LCD_Command ; Display ON/OFF, D Turns Display on, C cursor off, B blink off

    ldi r16, $06
    call LCD_Command ; Entry Mode (incrament cursor, shift display off)

    ;;https://www.electronicwings.com/pic/interfacing-lcd-16x2-in-4-bit-mode-with-pic18f4550-

    pop r16
    ret

; Subroutines
;---------------------------------------------------------------------------------
; Send LCD Command
; whatever is in r16 gets sent to LCD
LCD_Command:
    push r17

    ; Process upper nibble first
    mov r17, r16
    andi r17, $f0 ; clear out all other data (remember display d4-7 are in the upper bits already

    ; This will functionally set RS and EN to 0 in the same step (D:2 / D3: also set to 0
    out PORTD, r17 ; send info out the port
    ; Data set, RS: 0 (command register select), Enable: low

    sbi PORTD, 3 ; Sets enable high
    nop ; wait to latch (Tpw = 140ns, might need to be 2, one op is 62ns)
    nop
    nop
    cbi PORTD, 3 ; Set enable low

    ;need to wait ~1 ms (1.2 microsecond for enable time cycle)
    push r16
    ldi r16, 1
    call wait_xms
    pop r16

    ; process lower nibble second, largely copied from the above
    mov r17, r16
    swap r17 ; move lower bit into higher nibble
    andi r17, $f0 ; 

    out PORTD, r17
    sbi PORTD, 3 ; set enable high
    nop
    nop
    cbi PORTD, 3 ; set enable low

    ;wait ~3ms
    push r16
    ldi r16, 3
    call wait_xms
    pop r16

    pop r17
    ret

;---------------------------------------------------------------------------------

;---------------------------------------------------------------------------------

; Send LCD Char
; whatever is in r16 gets sent to LCD current position
LCD_Char:
    push r17

    ; Process upper nibble first
    mov r17, r16
    andi r17, $f0 ; clear out all other data (remember display d4-7 are in the upper bits already

    ; This will functionally set RS and EN to 0 in the same step (D:2 / D3: also set to 0
    out PORTD, r17 ; send info out the port
    ; Data set, RS: 0 (command register select), Enable: low
    sbi PORTD, 2; Setting RS high (for writing data, not instructions)

    sbi PORTD, 3 ; Sets enable high
    nop ; wait to latch (Tpw = 140ns, might need to be 2, one op is 62ns)
    nop
    nop
    cbi PORTD, 3 ; Set enable low

    ;need to wait ~1 ms (1.2 microsecond for enable time cycle)
    push r16
    ldi r16, 2
    call wait_xms
    pop r16

    ; process lower nibble second, largely copied from the above
    mov r17, r16
    swap r17 ; move lower bit into higher nibble
    andi r17, $f0 ; 

    out PORTD, r17
    sbi PORTD, 2; Setting RS high (for writing data, not instructions)
    sbi PORTD, 3 ; set enable high
    nop
    nop
    cbi PORTD, 3 ; set enable low

    ;wait ~3ms
    push r16
    ldi r16, 6
    call wait_xms
    pop r16

    pop r17
    ret

;---------------------------------------------------------------------------------

; Utility to set which display line we are about to write
LCD_set_line0:
    push r16
    ldi r16, $80
    call LCD_Command
    pop r16
    ret

LCD_set_line1:
    push r16
    ldi r16, $C0
    call LCD_Command
    pop r16
    ret


;---------------------------------------------------------------------------------


; USART Initilization
; Pulled from pg. 149 of ATmega328P data sheet
; Baud rate: this is how fast the serial connection 'talks' 
;            both sides need to know ahead of time this number
;            a higher baud rate results in 'faster' communication
; UBRR0H/L : USART Baurd Rate Register 19.10.5 (see table 19-12, for 16MHz baud calc)
; UCSR0B   : USART Control and Status Register 0 B 19.10.3
;            this enables / disables RX/TX (kind of like setting DDRn)
; UCSR0C   : USART Control and Status Register 0 C 19.10.3
;            sets the 'shape' of the signal (how many bits / stop bits / parity)
; Need to use sts / lds because USART registers are in 'extended' I/O range (in / out is too restrictive)
USART_Init:
    push r16 ; Save r16 / r17 just in case
    push r17

    ; Set baud rate
    ldi r17, $00 ; High baud (aiming for 9600bps)
    ldi r16, $67 ; Low baud
    sts UBRR0H, r17
    sts UBRR0L, r16

    ; Enable receiver and transmitter
    ldi r16, (1<<RXEN0)|(1<<TXEN0)
    sts UCSR0B,r16

    ; Set frame format: 8data, 2stop bit
    ldi r16, (1<<USBS0)|(3<<UCSZ00)
    sts UCSR0C,r16

    pop r17 ; Restore r17 and r16
    pop r16
    ret     ; go back to where this was called

; USART Transmit
; Pulled from 19.6.1 from Data Sheet
; UCSR0A: USART Control and Status Register 0 A
;         Bit we care about is the USART data register empty bit (UDRE0)
;         When this is clear, it means that we can put new data in the data transmit register
; UDR0  : When you write data into this register, the hardware manages sending this 
;         over the USART connection (USB)
serial_send:
    push r17
    ;push r18
    ;push r19
    ;push r20
serial_send_loop:
    ; Wait for empty transmit buffer
    lds r17, UCSR0A ; Load status
    sbrs r17,UDRE0  ; Jump back (without messing with the stack) if not set (i.e. not empty)
    rjmp serial_send_loop
    ;ldi r19, $0
    ; At this point we know the data buffer is empty, and thus can write to it
    ;cpi r16, $C8
    ;in r18, SREG
    ;sbrs r18, 2
    ;call Print200
    ;sbrc r19, 1
    ;rjmp USART_Done
    ;cpi r16, $64
    ;in r18, SREG
    ;sbrs r18, 2
   ; call Print100
    ; Put data (r16) into buffer, automatically sends the data
    ;sbrc r19, 0
    ;rjmp USART_Done
    sts UDR0, r16
USART_Done:
    ;pop r20
    ;pop r19
    ;pop r18
    pop r17
    ret

;---------------------------------------------------------------------------------
; Check USART for new data
; If there is data it will be in r16
; If there is not data, r16 will be clear

serial_poll_input:
    ; check to see if there is data
    lds r16, UCSR0A ; Load status 
    sbrs r16, RXC0 ; See if recieve flag is set
    rjmp spi_zero

    ; Recieve flag is set, read in value
    lds r16, UDR0 
    call serial_send
    rjmp spi_done ; we can jmp to the end

spi_zero:
    clr r16 ; Clear the value of r16 (nothing to read in)

spi_done:
    ret ; Done, we can go back now
;---------------------------------------------------------------------------------

;---------------------------------------------------------------------------------
; nop delay for approx 1ms
;
; target:     0.001
; one cycle  ~0.0000000625
; 0.001 / x = 0.0000000625
; x = 16,000
; 16,000 / 256 = ~62
; If we loop through 256 nop loops 62 times, we should be good
wait_1ms:
    push r16
    push r17

    clr r16
    clr r17

wait_1ms_outerLoop:
wait_1ms_inner: ; This should run 256 times taking aprox 1 + 1 cycles
    inc r16
    brne wait_1ms_inner

    inc r17
    cpi r17, 30 ; Only need to loop 30 times because inner loop is two cycles (thus twice as long as expected)
    brne wait_1ms_outerLoop


    pop r17
    pop r16
    ret
;---------------------------------------------------------------------------------

; Wait x ms, where r16 is holding x
wait_xms:
    push r16 ;Save state of r16

wait_xms_loop:
    call wait_1ms ; should wait 1 ms per call
    dec r16 ; Loop r16 times
    brne wait_xms_loop

    pop r16 ; restore
    ret

;---------------------------------------------------------------------------------

; R17 has the data
; we want to send '$xx' to LCD
; where xx is the hex of r16
REG_to_LCD:
    push r16
    push r17

    ldi r16, '$'
    call LCD_Char

    ; Isolate value / nibble
    mov r16, r17
    andi r16, $f0 ; mask out lower nibble

    ; Convert to ASCII
    swap r16; move to lower nibble

    call converToASCII
    call LCD_Char

    mov r16, r17
    andi r16, $0f

    call converToASCII
    call LCD_Char

    pop r17
    pop r16
    ret
;---------------------------------------------------------------------------------
; Converting some 0-15 value into '0'-'9','A'-'F'
; r16
converToASCII:
    cpi r16, 10
    brsh ASCII_letter
    subi r16, -'0'
    rjmp convertRet
ASCII_letter:
    subi r16, 10
    subi r16, -'A'
convertRet:
    ret
;---------------------------------------------------------------------------------
NewLine_CarriageReturn:
    cpi r21, $0
    breq EndNLCR
    ldi r16, $0A           ; Newline
    call serial_send
    ldi r16, $0D        ; carriage return
    call serial_send
    dec r21
    rjmp NewLine_CarriageReturn
EndNLCR:
    ret
;---------------------------------------------------------------------------------
 ;Put data register 16 to print register value to Terminal
Printr:
    push r17 ; save r17 and r18
    push r18
    push r21

    mov r17, r16 ; copy count into r17
    mov r18, r17 ; copy count into r18
    swap r18 ; swap nibbles to print high bits first
    andi r18, $0f ; mask out high bits
    mov r16, r18
    ; convert to ASCII then print
    call converToASCII
    call serial_send

    ; mask out high bits
    andi r17, $0f
    mov r16, r17
    ; convert to ASCII then print
    call converToASCII
    call serial_send

    push r16
    ldi r16, '_'
    call serial_send
    pop r16
    ;ldi r21, $03
    ;call NewLine_CarriageReturn

    pop r21
    pop r18
    pop r17
    ret
;---------------------------------------------------------------------------------
; registers 16, 17, 18, 19 will hold data
Decode:
    push r16 ; bottom byte of check, should be ff to check, then 
    push r17 ; top byte of  initial check, should be 00, then use for 3rd byte of input
    push r18 ; will be used for decoding, second byte
    push r19 ; will be used for decoding, top byte
    push r20 ; holds SREG values when needed
    push r21 ; miscellaneous counter
    push r22 ; flag to see if we just did intial check or decoding
    ; make sure clear before loading values
    ldi r16, 0
    ldi r17, 0
    ldi r18, 0
    ldi r19, 0
    ldi ZH, high(IR_BUFF)
    ldi ZL, low(IR_BUFF)
    adiw Z, 7
    ldi r21, $10 ; first only read 16 to
    ldi r22, $00 ; initially 0, set to 1 after initial check

Checkloop: 
    cpi r21, $00 ; see if r21 has hit 0 yet
    breq FlagCheck ; if equal then done printing
    dec r21
    ld r20, Z ; load bytes back to back in order to only get lower byte


    cpi r20, $50 ; compare to $50 and Print a 1 if greater than that
    brsh Input1
    rjmp Input0 ; otherwise print a 0

FlagCheck:
    cpi r22, $00
    breq CheckFirst16
    rjmp Decode_num

Input1:
    lsl r19
    lsl r18
    in r20, SREG
    sbrc r20, 0
    inc r19
    lsl r17 ; logical shift left upper byte first
    in r20, SREG
    sbrc r20, 0
    inc r18
    lsl r16 ; shift lower byte
    in r20, SREG ; read SREG
    sbrc r20, 0 ; if no carry, skip over incrementing top byte
    inc r17
    inc r16 ; increment bottom byte because we recieved a 1
    adiw Z, 4 ; skip forward 2 words
    ; test to see bits in USART
    sbrc r22, 0
    call Dig_to_USART1
    rjmp Checkloop ; loop back

Input0:
    lsl r19
    lsl r18
    in r20, SREG
    sbrc r20, 0
    inc r19
    lsl r17 ; logical shift left upper byte first
    in r20, SREG
    sbrc r20, 0
    inc r18
    lsl r16 ; shift lower byte
    in r20, SREG ; read SREG
    sbrc r20, 0 ; if no carry, skip over incrementing top byte
    inc r17
    adiw Z, 4
    ; test to see bits in USART
    sbrc r22, 0
    call Dig_to_USART0
    rjmp Checkloop

CheckFirst16:
    cpi r17, $00 ; if r17 not 00, then invalid entry and branch to return
    brne Decode_retInt
    cpi r16, $ff ; if r16 not ff, then invalid entry and branch to return
    brne Decode_retInt
    push r16
    ldi r16, $FF
    ;call wait_xms
    ;call wait_xms

    ;call wait_xms
    call wait_xms
    pop r16
    rjmp CheckNextInt ; jump to return
Decode_retInt:
    jmp Decode_ret
; intialize counter to read next 32 bits, go back to check loop 
CheckNextInt:
    ldi r21, $20 ; set counter to 32 to print next 32 digits for decoding
    ldi r22, $01 ; 
    clr r16
    clr r17
    rjmp Checkloop

; check the top value 
Decode_Num:
    ; first, check the entry flag and increment the appropriate digit that we just entered
    ; need to initialize Z for each decoding sequence but already using Z to take in signals from IR,
    ; so using pseudo offset by keeping track of how many entries and offsetting it by that many data locations each time
    ldi ZH, high(INPUT_HOLD)
    ldi ZL, low(INPUT_HOLD)
    add ZL, r24
    ; set address to keep track of entries
    push r16
    ldi r16, $80
    call wait_xms
    pop r16
    ; check if operation or entry has been pressed
    cpi r19, $90 ; +
    breq LCD_UPINT
    cpi r19, $E0 ; -
    breq LCD_DOWNINT
    cpi r19, $A8 ; x
    breq LCD_VOLDOWNINT
    cpi r19, $98 ; EQ
    breq LCD_EQINT
    ; we want to call check entry flag after checking if enter or operation has been pressed so that we don't count those entries as a digit
    call CheckEntryFlag
    ; check if number has been pressed
    cpi r19, $68 ; 0
    breq LCD_0INT
    cpi r19, $30 ; 1
    breq LCD_1INT
    cpi r19, $18 ; 2
    breq LCD_2INT
    cpi r19, $7A ; 3
    breq LCD_3INT
    cpi r19, $10 ; 4
    breq LCD_4INT
    cpi r19, $38 ; 5
    breq LCD_5INT
    cpi r19, $5A ; 6
    breq LCD_6INT
    cpi r19, $42 ; 7
    breq LCD_7INT
    cpi r19, $4A ; 8
    breq LCD_8INT
    cpi r19, $52 ; 9
    breq LCD_9INT

    cpi r19, $B0 
    breq LCD_STINT    
    cpi r19, $62
    breq LCD_VOLUPINT
    cpi r19, $E2
    breq LCD_FUNCINT
    cpi r19, $02
    breq LCD_PAUSEINT
    cpi r19, $A2
    breq LCD_POWERINT
    cpi r19, $C2
    breq LCD_FORWARDINT
    cpi r19, $22
    breq LCD_BACKWARDINT
    rjmp LCD_INVALIDINT

; Had to make intermediate jump steps because branches were out of range
LCD_EQINT:
    jmp LCD_EQ
LCD_UPINT:
    jmp LCD_UP
LCD_DOWNINT:
    jmp LCD_DOWN
LCD_VOLDOWNINT:
    jmp LCD_VOLDOWN
LCD_0INT:
    jmp LCD_0
LCD_1INT:
    jmp LCD_1
LCD_2INT:
    jmp LCD_2
LCD_3INT:
    jmp LCD_3
LCD_4INT:
    jmp LCD_4
LCD_5INT:
    jmp LCD_5
LCD_6INT:
    jmp LCD_6
LCD_7INT:
    jmp LCD_7
LCD_8INT:
    jmp LCD_8
LCD_9INT:
    jmp LCD_9
LCD_STINT:
    jmp LCD_ST
LCD_VOLUPINT:
    jmp LCD_VOLUP
LCD_FUNCINT:
    jmp LCD_FUNC
LCD_PAUSEINT:
    jmp LCD_PAUSE
LCD_POWERINT:
    jmp LCD_POWER
LCD_FORWARDINT:
    jmp LCD_FORWARD
LCD_BACKWARDINT:
    jmp LCD_BACKWARD
LCD_INVALIDINT:
    jmp LCD_INVALID

Decode_ret:
    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
    ret

Dig_to_USART0:
    push r16
    ldi r16, '0'
    ;call serial_send
    pop r16
    ret

Dig_to_USART1:
    push r16
    ldi r16, '1'
    ;call serial_send
    pop r16
    ret

; Section to print to LCD, all sections follow same method
; save r16
; load respective output in r16 then print to LCD
; restore r16 then jump to return from "Decode"
; r24 holds how many entriesso increment each time
; store appropriate digit in Z depending on entry, no need to use Z+ because we do an offset when initializing the Z vector every entry (line 1116)
LCD_0:
    inc r24
    push r16
    ldi r16, '0' ; print a 0 to LCD and then store a 0 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 0
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_1:
    inc r24
    push r16
    ldi r16, '1'    ; print a 1 to LCD and then store a 1 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 1
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_2:
    inc r24
    push r16
    ldi r16, '2'    ; print a 2 to LCD and then store a 2 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 2
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_3:
    inc r24
    push r16
    ldi r16, '3'    ; print a 3 to LCD and then store a 3 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 3
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_4:
    inc r24
    push r16
    ldi r16, '4'    ; print a 4 to LCD and then store a 4 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 4
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_5:
    inc r24
    push r16
    ldi r16, '5'    ; print a 5 to LCD and then store a 5 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 5
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_6:
    inc r24
    push r16
    ldi r16, '6'    ; print a 6 to LCD and then store a 6 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 6
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_7:
    inc r24
    push r16
    ldi r16, '7'    ; print a 7 to LCD and then store a 7 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 7
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_8:
    inc r24
    push r16
    ldi r16, '8'    ; print a 8 to LCD and then store a 8 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 8
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_9:
    inc r24
    push r16
    ldi r16, '9'    ; print a 9 to LCD and then store a 9 in memory to access later when calculating answer
    call LCD_Char
    ldi r16, 9
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_EQ:
    push r16
    ;call LCD_set_line1
    ldi r16, '=' ; do calculations for answer 
    call LCD_Char
    ; will use this value later to decide when we are done with entries
    ldi r16, $10
    st Z, r16
    pop r16
    rjmp Decode_ret
LCD_ST:
    inc r24
    push r16
    ldi r16, 'S'
    call LCD_Char
    pop r16
    rjmp Decode_ret

; up arrow is addition
LCD_UP:
    call SetEntryFlag
    inc r24
    push r16
    ldi r16, '+'
    call LCD_Char
    ; A will be the value for choosing addition later
    ldi r16, $0A
    st Z+, r16
    pop r16
    rjmp Decode_ret

; down arrow is subtraction
LCD_DOWN:
    call SetEntryFlag
    inc r24
    push r16
    ldi r16, '-'
    call LCD_Char
    ; B will be the value for choosing subtraction later
    ldi r16, $0B
    st Z+, r16
    pop r16
    rjmp Decode_ret
; volume down button is multiplication
LCD_VOLDOWN:
    call SetEntryFlag
    inc r24
    push r16
    ldi r16, 'x'
    call LCD_Char
    ; C will be the value for choosing multiplication when printing answer to LCD
    ldi r16, $0C
    st Z+, r16
    pop r16
    rjmp Decode_ret
; volume up button is divison (future)
LCD_VOLUP:
    inc r24
    push r16
    ldi r16, 'V'
    call LCD_Char
    pop r16
    rjmp Decode_ret
; func button will output last calculated answer
LCD_FUNC:
    push r16
    ldi r16, $0E ; will use this value in main loop later to see when to restart program
    st Z, r16
    pop r16
    rjmp Decode_ret

LCD_PAUSE:
    inc r24
    push r16
    ldi r16, 'P'
    call LCD_Char
    pop r16
    rjmp Decode_ret
; power button will be reset of whole calculator
LCD_POWER:
    inc r24
    push r16
    ldi r16, $0D ; will use this value in main loop later to see when to restart program
    st Z, r16
    pop r16
    rjmp Decode_ret

LCD_FORWARD:
    inc r24
    push r16
    ldi r16, 'F'
    call LCD_Char
    pop r16
    rjmp Decode_ret
LCD_BACKWARD:
    inc r24
    push r16
    ldi r16, 'B'
    call LCD_Char
    pop r16
    rjmp Decode_ret
; if invalid just return
LCD_INVALID:
    rjmp Decode_ret
;---------------------------------------------------------------------------------
; subroutine to increment top nibble by 1, indicating first entry digit was entered
FirstEntryDigits:
    push r16
    ldi r16, $10
    add r23, r16
    pop r16
    ret
;---------------------------------------------------------------------------------
; subroutine to increment bottom nibble by 1, indicating second entry digit was entered
SecondEntryDigits:
    inc r23
    ret
;---------------------------------------------------------------------------------
; subroutine to clear entry flag
ClearEntryFlag:
    push ZH
    push ZL
    push r16
    ldi ZH, high(ENTRY_FLAG)
    ldi ZL, low(ENTRY_FLAG)
    ldi r16, $00
    st Z, r16
    pop r16
    pop ZL
    pop ZH
    ret
;---------------------------------------------------------------------------------
; subroutine to set the entry flag
SetEntryFlag:
    push ZH
    push ZL
    push r16
    ldi ZH, high(ENTRY_FLAG)
    ldi ZL, low(ENTRY_FLAG)
    ldi r16, $01
    st Z, r16
    pop r16
    pop ZL
    pop ZH
    ret
;---------------------------------------------------------------------------------
CheckEntryFlag:
    ; push needed registers
    push ZH
    push ZL
    push r16
    push r17
    ; load in flag to r16
    ldi ZH, high(ENTRY_FLAG)
    ldi ZL, low(ENTRY_FLAG)
    ld r16, Z
    ; compare flag to 0 and then read in SREG to r17
    cpi r16, $00
    in r17, SREG
    sbrc r17, 1     ; if zero flag is not set, then we want to increment second digits
    call FirstEntryDigits
    sbrs r17, 1     ; if zero flag is set we want to skip over incrementing second digits
    call SecondEntryDigits    
    ; restore values
    pop r17
    pop r16
    pop ZL
    pop ZH
    ; return
    ret
;---------------------------------------------------------------------------------
; subroutine for printing correct values to LCD in Decimal, r20 being altered, r26 will hold carry bit
addCarry:

    ldi r26, $00
    cpi r20, $0A    ; compare to 10
    brlo noCarryAdd ; branch to end if no carry
    subi r20, $0A   ; subtract 10 from r20 and set r23 carry bit
    
    ldi r26, $01
    
    rjmp addCarryEnd
noCarryAdd:
    ldi r26, $00
addCarryEnd:

    ret
;---------------------------------------------------------------------------------
; subroutine to check whether first number is greater than second in subtraction, if no push a '-' to 
subCarry:
    push r16
    push r17
    push ZH
    push ZL

    ldi r16, $0A

    cpi r20, $0
    brge subCarryEnd
    add r20, r16
    dec ZL
    ld r17, Z
    dec r17
    st Z, r17

subCarryEnd:
    pop ZL
    pop ZH
    pop r17
    pop r16
    ret

;---------------------------------------------------------------------------------
; subroutine to set Z and Y pointers for printing answers
setZandYforAns:
    ldi ZH, high(INPUT_HOLD)    ; reset Z pointer
    ldi ZL, low(INPUT_HOLD)     

    ldi YH, high(INPUT_HOLD)    ; reset Y pointer
    ldi YL, low(INPUT_HOLD)     
    ret
;---------------------------------------------------------------------------------
;---------------------------------------------------------------------------------
; subroutine for checking whether going to be negative answer
; starts at msb of each entry and compares, if entry two digit is greater, we know that digit two is greater so we set the negative flag (r26)
; if they're equal then keep looping back until either all digits are checked or a difference is found
checkNegative:
    ; push needed registers, r17 and r18 hold the number of entries from digit 1 and total entries respectively
    push r16
    push r18
    push r17
    push r20
    push r21
    push r19
    ; want to save the pointer value and restore later, we will use these here
    push ZL
    push ZH
    push YL
    push YH

    ; set the addresses holding our entries
    mov r19, r18
    ldi r18, 0 ; this sets r18 to the msb of entry 1 when added to ZL
    sub r17, r19    ; this sets r17 to msb of entry 2 when added to YL

    ldi r26, $00 ; make sure negative flag clear before continuing

checkNegLoop:
    call setZandYforAns
    add ZL, r18
    add YL, r17 ; this should set Y to be msb for entry 2
    ; load msb into r20 (entry 1) and r21 (entry 2)
    ld r20, Z
    ld r21, Y

; compare second entry msb to 1st entry msb
    cp r21, r20
    brlt endCheckNeg    ; if r21 < r20, we know first digit is greater
    cp r20, r21
    brlt needNegative   ; if r20 < r21, we know second digit is greater
    inc r18             ; increment counting registers
    inc r17
    cp r19, r18         ; r19 still holds how many digits in entry 1, when r18 > r19 we have gone through all digits
    brlt endCheckNeg
    rjmp checkNegLoop

needNegative:
    ldi r26, $01    ; set negative flag register
    rjmp endCheckNeg

endCheckNeg:
    ; restore values and return
    pop YH
    pop YL
    pop ZH
    pop ZL
    pop r19
    pop r21
    pop r20
    pop r17
    pop r18
    pop r16

    ret
;---------------------------------------------------------------------------------
; swap r17, r18, will be used for the negative check subroutine
swap17and18:
    push r16

    cpi r26 , $00   ; r26 is negative flag, so if equal 0 do not swap register values
    breq endSwap

    mov r16, r17    ; store r17 value in r16
    mov r17, r18    ; store r18 value into r17
    mov r18, r16    ; move the previous r16 value into r18

endSwap:
    pop r16
    ret
;---------------------------------------------------------------------------------
; multiplication counter setter
; altering r25 as a counter
setMultCounter:
    ; push needed registers
    push r18
    push r19
    push r20
    push ZL
    push ZH
    push YL
    push YH

    ; r19 is our count to see when we've looked at all digits
    ldi r19, 0
    ; set Z pointer to 1st entry
    call setZandYforAns
    ld r20, Z

setCountLoop:
    inc r19         ; increment to next digit
    cpi r19, $01    ; if digit 1, jump to appropriate tag
    breq firstDigSet
    cpi r19, $02    ; if digit 1, jump to appropriate tag
    breq firstDigSet
    cpi r19, $03    ; if digit 1, jump to appropriate tag
    breq firstDigSet
    rjmp endMultL

; if looking at first digit, load value stright into r26 counter and clear
firstDigSet:
    cpi r20, $0
    breq countReset
    mov r25, r20
    clr r20
    st Z+, r20
    rjmp endSetCount
; if looking at the second digit, load 10 into counter and decrement stored digit
secondDigSet:
    cpi r20, $0
    breq countReset
    ldi r25, $0A
    dec r20
    st Z+, r20
    rjmp endSetCount
; if looking at the second digit, load 100 into counter and decrement stored digit
thirdDigSet:
    cpi r20, $0
    breq endMultL
    ldi r25, $64
    dec r20
    st Z, r20
    rjmp endSetCount

; if r19 = 03, we've looked at all digits and we're all 0, can end loop now
countReset:
    cpi r19, $03
    breq endMultL
    inc ZL
    rjmp setCountLoop

; if r26 is negative in main loop, we are done adding
endMultL:
    ldi r25, -1
endSetCount:
    pop YH
    pop YL
    pop ZH
    pop ZL
    pop r20
    pop r19
    pop r18

    ret
;---------------------------------------------------------------------------------
; subroutine to clear r16 digits of Z
clearZ:
    push ZL
    push ZH
    push r17
clearZLoop:
    cpi r16, 0
    breq clearZend
    ld r17, Z
    clr r17
    st Z+, r17
clearZend:
    pop r17
    pop ZH
    pop ZL
    ret
;---------------------------------------------------------------------------------
; subroutine to call when you want to display multiply answer
; prints r16 in two seperate bits as hex values
multConvertPrint:
    push r17
    push r16

    ; save value we want to print
    mov r17, r16

    ; mask out lower bits, then swap to print higher bits
    andi r16, $f0
    swap r16
    subi r16, -'0'
    call LCD_Char
    ; mask out higher bits, then send back to r16 to print
    andi r17, $0f
    mov r16, r17
    subi r16, -'0'
    call LCD_Char

    pop r16
    pop r17
    ret
