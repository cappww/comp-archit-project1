; Capp Wiedenhoefer
; This program utilizes the Doomsday Alogrithm, created by John Conway
.ORIG	x3000
; STEP 1: Find the century code

        LDI	R2,	YEAR   ; Contains the input year
        LD	R3,	Y2K    ; Contains -2000
        LD	R4,	Y19C   ; Contains -1900
        AND	R0,	R0,	#0 
        ADD	R5,	R2,	R3  ; Subtracts the input year by 2000 to determine the century code
        BRzp	CEN2
        ADD	R0,	R0,	#3  ; Negative makes the century code 3
        ADD	R1,	R2,	R4  ; Isolates the years within the 1900s
        BRnzp	STORE
CEN2    ADD	R0,	R0,	#2  ; Zero or positive makes the century code 2
        ADD	R1,	R2,	R3  ; Isolates the years within the 21st century
STORE   STI	R0,	C
        STI     R1,     YY

; R1 contains YY
; STEP 2: Determine if its a leap year

        AND	R2,	R2,	#0
        ADD	R2,	R2,	#4
        STI	R1,	A
        STI	R2,	B
        JSR	DIV
        LDI     R6,     Z       ; Get the remainder
        ADD	R6,	R6,	#0
        BRz	LEAP            ; If the remainder is zero, then it is a leap year
        BRp	NLEAP
LEAP    LEA	R5,	MONTHS
        AND	R4,	R4,	#0
        ADD	R4,	R4,	#4
        STR	R4,	R5,	#0
        ADD	R4,	R4,	#-3
        STR	R4,	R5,	#1
        BRnzp	CONT
NLEAP   LEA	R5,	MONTHS
        AND	R4,	R4,	#0
        ADD	R4,	R4,	#3
        STR	R4,	R5,	#0
        ADD	R4,	R4,	#-3
        STR	R4,	R5,	#1

; STEP 3 : Get the doomsday value for associated input month

CONT    LDI     R1,     MONTH
        AND	R2,	R2,	#0
        ADD	R2,	R2,	#-1
        LEA	R3,	MONTHS     ; Start by placing the Address of Jan's doomsday in R3
LOOP    ADD	R4,	R1,	R2 
        BRz	END
        ADD	R2,	R2,	#-1
        ADD	R3,	R3,	#1
        BRnzp	LOOP
END     LDR	R5,	R3,	#0

; R5 contains the doomsday value of the associated month
; STEP 4: Calculate 'D'

NEXT    LDI	R6,	DAY
        NOT	R5,	R5
        ADD	R5,	R5,	#1 ; Make the doomsday value negative
        ADD	R6,	R6,	R5 ; This is the value of D
        BRzp	POS
        ADD	R6,	R6,	#7 ; If D is negative, add 7 to it
POS     STI	R6,	D      ; Store the value of D

; STEP 5: Calculate 'Q1' and 'R'

        LDI	R1,	YY
        STI	R1,	A
        AND     R1,     R1,     #0  ; Sets R1 to 12
        ADD	R1,	R1,	#12
        STI	R1,	B       ; Inserts the second parameter for the Div function
        JSR	DIV             ; YY / 12
        LDI	R0,	Y   
        STI	R0,	Q1      ; Stores the resulting quotient, Q1
        LDI     R1,     Z
        STI	R1,	R       ; Stores the resulting remainder, R

; R1 contains the remainder 
; STEP 6: Calculate 'Q2'

        STI     R1,     A
        AND     R0,     R0,     #0
        ADD	R0,	R0,	#4 
        STI     R0,     B
        JSR     DIV             ; Divide the remainder by 4: R / 4
        LDI	R4,	Y
        STI	R4,	Q2      ; Stores the resulting quotient, Q2

; STEP 7: Calculate 'T'

        LDI     R0,     C
        LDI     R1,     D
        LDI     R2,     Q1
        LDI     R3,     R
        ADD	R5,	R0,	R1 ; Add all of the variables together
        ADD	R5,	R5,	R2
        ADD	R5,	R5,	R3
        ADD	R5,	R5,	R4
        STI	R5,	T          ; Store as total

; R5 contains the total
; STEP 8: Calculate the Day of the Week

        STI	R5,	A
        AND	R6,	R6,	#0 ; Set R6 to 7
        ADD	R6,	R6,	#7
        STI	R6,	B
        JSR     DIV             ; Total / 7
        LDI     R1,     Z       ; Load the remainder, which is also the solution, into R1
        STI	R1,	DOW     ; Store R1, the solution, into the correct address

; R1 contains the Day of the Week
; STEP 9: Print the sentence

        LEA	R0,	ASCII
        PUTS            ; Output the beginning of the sentence: "The day is "

        LEA	R5,	DAYS
        AND	R3,	R3,	#0
LOOP2   ADD	R4,	R1,	R3
        BRz	END2
        ADD	R5,	R5,	#10 ; Since every string is 9 chracters, the address moves 10 places
        ADD	R3,	R3,	#-1
        BRnzp	LOOP2
END2    ADD	R0,     R5,     #0	

        PUTS
        HALT ; End program

; ---------Divide Operation----------------------------------
A       .FILL	x3100 ; Dividend
B       .FILL	x3101 ; Divisor
Y       .FILL	x3102 ; Location to store quotient
Z       .FILL	x3103 ; Location to store remainder

DIV     LDI     R0,     A
        LDI     R1,     B

        NOT	R1,	R1
        ADD	R1,	R1,	#1 ; Make R1 negative to subtract from R0

        AND	R2,	R2,	#0 ; Clear R2, it will be the quotient
        ADD	R2,	R2,	#-1 ; Starts R2 as -1 

ITER    ADD	R2,	R2,	#1 ; First iteration would set R2 to 0
        ADD	R0,	R0,	R1 ; Subtract value B from value A
        BRp	ITER
        BRn	NEG
        BRz	ZERO
NEG     NOT	R1,	R1
        ADD	R1,	R1,	#1
        ADD	R0,	R0,	R1
        BRnzp	FIN
ZERO    ADD	R2,	R2,	#1 ; If the quotient is zero, add 1 to compensate for starting as -1
FIN     STI	R2,	Y
        STI	R0,	Z
        RET
; --------End of Divide Operation ----------------------------

; Variable locations
DAY     .FILL	x31F0
MONTH   .FILL	x31F1
YEAR    .FILL	x31F2
DOW     .FILL	x31F3

C       .FILL	x31F4 ; Stores the "century code" for the corresponding year
D       .FILL	x31F5 ; Stores the difference of the "Dooms Date" and the input date
Q1      .FILL	x31F6 ; Stores the first quotient
R       .FILL	x31F7 ; Stores the remainder of the first quotient
Q2      .FILL	x31F8 ; Stores the second quotient: R / 4
T       .FILL	x31F9 ; The total: C + D + Q1 + R + Q2
YY      .FILL	x31FA ; Stores the years within the century

Y2K     .FILL	xF830 ; The value of -2000 to determine the century code
Y19C    .FILL	xF894 ; The value of -1900 to isolate the years within the century

; "Doomsdays"
MONTHS  .FILL	x0003 ; 1/3
        .FILL	x0000 ; 2/0
        .FILL	x0000 ; 3/0
        .FILL	x0004 ; 4/4
        .FILL	x0002 ; 5/2
        .FILL	x0006 ; 6/6
        .FILL	x0004 ; 7/4
        .FILL	x0001 ; 8/1
        .FILL	x0005 ; 9/5
        .FILL	x0003 ; 10/3
        .FILL	x0000 ; 11/0
        .FILL	x0005 ; 12/5

; String outputs:
ASCII   .STRINGZ	"The day is "
DAYS    .STRINGZ	"Sunday   "
        .STRINGZ	"Monday   "
        .STRINGZ	"Tuesday  "
        .STRINGZ	"Wednesday"
        .STRINGZ	"Thursday "
        .STRINGZ	"Friday   "
        .STRINGZ	"Saturday "

.END