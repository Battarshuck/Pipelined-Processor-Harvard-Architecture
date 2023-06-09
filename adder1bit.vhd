LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY adder1bit IS
	PORT (a,b,cin : IN  std_logic;
		  s, cout : OUT std_logic );
END adder1bit;

ARCHITECTURE adder1bitArch OF adder1bit IS
	BEGIN
		
				s <= a XOR b XOR cin;
				cout <= (a AND b) OR (cin AND (a XOR b));
		
END adder1bitArch;