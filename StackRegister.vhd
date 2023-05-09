LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY StackRegister IS
	PORT (clk,rst : IN  std_logic;
          operation : IN std_logic_vector(2 downto 0);
		  address : out std_logic_vector(15 downto 0));
END ENTITY StackRegister;

ARCHITECTURE archStackRegister OF StackRegister IS 
BEGIN
--we are using operation[2] bit to change the value of stack pointer immediately without forcing the stack pointer to wait for the next clock cycle
--mn el a5r keda ya ebn 3amy b el balady keda 3ashan el stack pointer yet8ayar 3alatol badal ma yestana cycle zeyada
--katebhalak aho franco w 2efrangy 3ashan tefham ya abo 3amo
--a7la mesa 3ala el beyen2el el code ;)
PROCESS (clk, rst, operation(2)) IS
        variable value : std_logic_vector(15 downto 0);
    BEGIN
        IF (rst = '1') THEN
            value := x"03FE";
        ELSIF rising_edge(clk) THEN
            
            IF (operation = "001" or operation = "010") THEN -- PUSH & CALL both of them decrease the stack pointer by 1
                value := std_logic_vector(to_unsigned(to_integer(signed(value))-1,16));
            ELSIF (operation = "100" or operation = "101") THEN -- POP & RET both of them increase the stack pointer by 1
                value := std_logic_vector(to_unsigned(to_integer(signed(value))+1,16));
            ELSIF (operation = "011") THEN -- INTERRUPT
                value := std_logic_vector(to_unsigned(to_integer(signed(value))-2,16));
            ELSIF(operation = "111") THEN -- RTI
                value := std_logic_vector(to_unsigned(to_integer(signed(value))+2,16));
            ELSE
                value := value;
            END IF;

        END IF;

        address <= value;
END PROCESS; 

END archStackRegister;