# User Manual for Final_Project_hamilton
Dominic Gusman and Alex Leonida


## Table of Contents
**[Troubleshooting](#troubleshooting)**
1. [Materials Needed](#section-1-materials-needed)
2. [Setting up the board](#section-2-setting-up-the-board)
3. [Running the Program](#section-3-running-the-program)
4. [Reset](#reset)
5. [Assumptions](#assumptions)
6. [Citations](#citations)


## Troubleshooting
If you follow the manual and at any point you feel that you are at the wrong step
1. Unplug the USB. Replug the USB. 
2. If the LCD is stuck on  the famous "[blocks](/Documentation/Pictures/LCD_Blocks.jpg)", refer to the [Reset](#reset) portion of the manual


## Section 1: Materials Needed
*All items were found [here](https://us.elegoo.com/products/elegoo-uno-r3-super-starter-kit?_pos=1&_psq=ELEGOO+Starter+Kit&_ss=e&_v=1.0?utm_source=officialhome&utm_medium=referral&utm_id=usstore)*


Our project consisted of the following items:
- 9 x Jumper Wires
- 1x Circuit Board
- 1 x ELEGOO/Arduino UNO R3 Controller Board (both have a ATmega328P chip)
- 1 x USB Cable for Controller Board
- 1 x Lcd1602 (LCD)
- 1 x 10k Potentiometer
- 1 x IR Receiver (Specific to link above)
- 1 x IR Remote (Specific to link above)


## Section 2: Setting up the board
Refer [here](/Documentation/pictures/circuit.png) for diagram of circuit set up


## Section 3: Running the Program
### Overview
This calculator has many restrictions, and all are **required** for the use of this program.


If a problem occurs, refer [here](#troubleshooting)


1. [Addition](#add-stuff)
2. [Subtraction](#subtract-stuff)
3. [Multiplication](#multiply-stuff)


### Add Stuff
**NOTE**, when you use this calculator, you MUST use **TWO** digits of the **SAME** digit size.


1. [Reset](#reset) the LCD
   - The cursor should now be on the first line of the LCD (*not-visible*)
2. Enter the first number
   - Point the IR remote at the IR sensor and hold it there
   - Use the IR remote's number pad to enter a number that is 4 digits or less.
       - Working Ex. 1234, 0123, 123, 0001, 001, 1
       - Non-Working Ex. 11233
3. Enter an Arithmetic
   - Use the up button (∧) to output an addition symbol (+) to the display
4. Enter the second number
   - Use the IR remote's number pad to enter a number that is 4 digits or less.
       - **IMPORTANT**: this digit **MUST** be the same digit size as the first inputted number!
       - Working Ex.
           - num1:1234 -> num2:4321
           - num1:0123 -> num2:0321
           - num1:123 -> num2:321
           - num1:001 -> num2: 001
       - Non-Working Ex.
           - num1:1234 -> num2:123
           - num1:1234 -> num2:12345
           - num1:01234 -> num2:12345
5. Complete calculation
   - Use the enter button (EQ) to output an equals sign (=) to the display
   - You will know that the calculation has completed when the equals sign appears, and the outputted answer appears on the same line.
6. Explanation
   - The LCD has 16 visible slots for the user to occupy on the first line
   - In a maximum use case where num1 = 9999 and num2 = 9999, the output will be 19998 which is five digits.
   - Because the the digit size of num1 and num2 are 4 and their output's digit size is 5, then we know that 4 + 4 + 5 = 13
   - We also know that on that same line, an arithmetic operator will exist (+) along with the equality operator (=) which are two more digits. 13 + 2 = 15.
   - Therefore, the line will hold a maximum of 15 digits at a time if used correctly, and because 15 < 16, the calculations output should always be visible




### Subtract Stuff
1. [Reset](#reset) the LCD
   - The cursor should now be on the first line of the LCD (*not-visible*)
2. Enter the first number
   - Point the IR remote at the IR sensor and hold it there
   - Use the IR remote's number pad to enter a number that is 4 digits or less.
       - Working Ex. 1234, 0123, 123, 0001, 001, 1 
       - Non-Working Ex. 11233
3. Enter an Arithmetic
   - Use the down button (∨) to output an addition symbol (-) to the display
4. Enter the second number
   - Use the IR remote's number pad to enter a number that is 4 digits or less.
       - **IMPORTANT**: this digit **MUST** be the same digit size as the first inputted number!
       - Working Ex.
           - num1:1234 -> num2:4321
           - num1:0123 -> num2:0321
           - num1:123 -> num2:321
           - num1:001 -> num2: 001
       - Non-Working Ex.
           - num1:1234 -> num2:123
           - num1:1234 -> num2:12345
           - num1:01234 -> num2:12345
5. Complete calculation
   - Use the enter button (EQ) to output an equals sign (=) to the display
   - You will know that the calculation has completed when the equals sign appears, and the outputted answer appears on the same line.
6. Explanation
   - The LCD has 16 visible slots for the user to occupy on the first line
   - In a maximum use case where num1 = 9999 and num2 = 9999, the output will be 0000 which is four digits. *Note*: The output will always have the same digit count as it's respective input in subtraction.
   - Because the the digit size of num1 and num2 are 4 and their output's digit size is 4, then we know that 4 + 4 + 4 = 12
   - We also know that on that same line, an arithmetic operator will exist (-) along with the equality operator (=) which are two more digits. 12 + 2 = 14.
   - Therefore, the line will hold a maximum of 15 digits at a time if used correctly, and because 14 < 16, the calculations output should always be visible


### Multiply Stuff
1. [Reset](#reset) the LCD
   - The cursor should now be on the first line of the LCD (*not-visible*)
2. Enter the first number
   - Point the IR remote at the IR sensor and hold it there
   - Use the IR remote's number pad to enter a number that is 3 digits or less.
       - Working Ex. 123, 123, 001, 01, 1 
       - Non-Working Ex. 11233
3. Enter an Arithmetic
   - Use the Volume Down button (VOL-) to output a multiplication symbol (x) to the display
4. Enter the second number
   - Use the IR remote's number pad to enter a number that is 3 digits or less.
       - **IMPORTANT**: this digit **MUST** be the same digit size as the first inputted number!
       - Working Ex.
           - num1:123 -> num2:432
           - num1:012 -> num2:032
           - num1:12 -> num2:32
           - num1:01 -> num2: 01
       - Non-Working Ex.
           - num1:1234 -> num2:123
           - num1:1234 -> num2:12345
           - num1:01234 -> num2:12345
5. Complete calculation
   - Use the enter button (EQ) to output an equals sign (=) to the display
   - You will know that the calculation has completed when the equals sign appears, and the outputted answer appears on the same line.
6. Explanation
   - The LCD has 16 visible slots for the user to occupy on the first line
   - In a maximum use case where num1 = 999 and num2 = 999, the output will be 998001 which is six digits.
   - Because the the digit size of num1 and num2 are 3 and their output's digit size is 6, then we know that 3 + 3 + 6 = 12
   - We also know that on that same line, an arithmetic operator will exist (x) along with the equality operator (=) which are two more digits. 12 + 2 = 14.
   - Therefore, the line will hold a maximum of 14 digits at a time if used correctly, and because 14 < 16, the calculations output should always be visible


## Reset
You are here to reset your board which means either
- A calculation has just been performed and you would like to perform a new calculation <br>
or
- You are staring at [the blocks](/Documentation/Pictures/LCD_Blocks.jpg)
or
- You just want to stare at a blank screen


Either way, there is something cluttering the screen right now and this is the place that you need to be in order to clear it off.


There will be two portions to this section.
1. [Use our way](#our-way-to-reset) to reset the screen
2. [Use the logical way](#logical-way-to-reset) to reset the screen


### Our way to reset


Use the power button (I/O) on the IR remote to clear the display


This will work during or after any calculation on the calculator. (Even if there's an error)
It might work when the 'blocks' are on the screen.


### Logical way to reset


1. Locate the UNO R3 Controller Board
2. Position the board so that the words "ELEGOO UNO R3" are facing towards you as if you were reading a boook.
3. On the top left corner of the board, there is a red button. This is the board's reset button. Press it.


If the LCD has not reset to its original (blank) state, try one or both of the following


1. Disconnect the USB cable from the UNO R3 Controller Board
2. Disconnect the USB cable from your laptop


If the LCD has STILL not reset to its original state, retry everything mentioned above until it works. That's not a joke, it should eventually work.

Because we don't know why these blocks appear, this is our tentative, skeptical, method of resetting the LCD and it has worked every time for us.


## Assumptions
1. The user uses the proper hardware for this project (All hardware works)
2. User does not run the program or plug in the board if any wires are disonected
3. User knows what they are doing with the board before they do it (so the smoke does not escape)
4. User inputs two of the same digit length into the calculator
5. User inputs two digits of the appropriate digit length
6. User points the IR Remote at it's reciever before presisng a button
7. User is within a max distance of 4~5 meters of the board with the IR Remote when using this calculator for most accurate signals read in where the closer the better
8. Petentiometer is set so that the values on the LCD are visible
9. User knows how to attach board to PC
10. If signals are not catching for some reason,
11. User uses exact IR Remote and IR Reciever as the ones that we used
   - There could be different signals being read in
12. User knows how to set up and utilize a tasks.json file in order to run their code
   - References MACOS vs Windows, PUTTY
13. User does not convert ATMega238P code into standard Arduino language
   - References the interrupt that will happen exactly every 10uS & prescalar
14. User does not change clock time from 16Mz, this will change the signals being read in


## Citations
-  Source Citing:
-  For Circuit Board & IR Remote:
-  https://lastminuteengineers.com/arduino-1602-character-lcd-tutorial
-  https://www.electronicwings.com/pic/interfacing-lcd-16x2-in-4-bit-mode-with-pic18f4550-
-  https://download.elegoo.com/?t=UNO_R3_Project_Super_Starter_Kit
-  https://www.instructables.com/Arduino-IR-Sensor-and-Remote-With-LCD/
- 
-  For Code / Logic
-  Scott Griffith
-  https://whitgit.whitworth.edu/2024/fall/CS-278-1/In_Class/class_material/-/tree/main/Examples/IR_16x2_Display?ref_type=heads
-  https://www.vishay.com/docs/37484/lcd016n002bcfhet.pdf
-  https://www.sparkfun.com/datasheets/LCD/ADM1602K-NSW-FBS-3.3v.pdf

