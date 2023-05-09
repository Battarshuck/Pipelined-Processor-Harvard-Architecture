LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY outputPort IS
	PORT (enable : IN  std_logic;
          dataIn : IN std_logic_vector(15 downto 0);

          validData  : OUT std_logic;
		  dataOut : out std_logic_vector(15 downto 0));
END ENTITY outputPort;

ARCHITECTURE archOutputPort OF outputPort IS 
BEGIN

--we used a latch here because we want to keep the dataOut value when enable = '0', even though we don't need it
--we could have used a flip-flop, but we would have to use a clock, and we don't need it
--to remove the latch, we can simply add else dataOut <= x"0000"; in the when statement
--*could be changed later*
dataOut <= dataIn when enable = '1';

validData <= enable;

END archOutputPort;