#	All numbers in hex format
#	We always start by reset signal
# 	This is a commented line
#	You should ignore empty lines

# ---------- Don't forget to Reset before you start anything ---------- #
INSTRUCTION
[15:11]OPCODE
[10:8]Rdst
[7:5]Rs1
[4:2]Rs2
[1]Inturrupt
[0]Immediate

.org 0
IN R5			#R5= FFFE --> add FFFE on the in port, flags no change	01100-101-000-000-0-0
NOP
NOP
NOP
NOP
INC R5,R5 		#R5 = FFFF, C--> no change, N --> 1, Z --> no change 00100-101-101-000-0-0
INC R5,R5 		#R5 = 0000, C--> 1, N --> 0, Z --> 1 00100-101-101-000-0-0
IN R1			#R1= 0001 --> add 0001 on the in port, flags no change	01100-001-000-000-0-0
IN R2			#R2= 000F -> add 000F on the in port, flags no change	 01100-010-000-000-0-0
IN R3			#R3= 00C8 -> add 00C8 on the in port, flags no change	 01100-011-000-000-0-0
NOP				#Flags no change 00000-000-000-000-0-0
STD R1,00FF  	#M[1] = 00FF 
STD R3,001F  	#R3 --> has value 00C8 which is 200 in decimal, hence M[200] = 001F
STD R2,00FC  	#M[15] = 00FC	
INC R2,R1 		#R2 = 0002, C--> 0, N --> 0, Z --> 0 00100-010-001-000-0-0
LDD R0, R2  	#R0 = M[1] = 00FF 10011-000-010-000-0-0
LDD R0, R3  	#R0 = M[200] = 001F 10011-000-011-000-0-0
AND R1,R2,R5	#R1 = 0, C--> 0, N --> 0, Z --> 1 01010-001-010-101-0-0
INC R1,R1 		#R1 = 0001, C--> 0, N --> 0, Z --> 0 00100-001-001-000-0-0
NOP				#Flags no change 00000-000-000-000-0-0
AND R3,R1,R2	#R5 = 0, C--> 0, N --> 0, Z --> 1 01010-011-001-010-0-0
NOP				#Flags no change, C--> 0, N --> 0, Z --> 1 00000-000-000-000-0-0
NOP       00000-000-000-000-0-0
