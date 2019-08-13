.ORIG	x3000
        LDI 	R0, 	A
        LDI 	R1, 	B

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
        HALT

A       .FILL	x3100
B       .FILL	x3101
Y       .FILL	x3102 ; Location to store quotient
Z       .FILL	x3103 ; Location to store remainder
.END