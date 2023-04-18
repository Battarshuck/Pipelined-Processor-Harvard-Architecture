LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


--Pass value of pc and if there is a bubble then current val
ENTITY pcReg IS
    PORT (
        pcIn : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        bubblingSignal : IN STD_LOGIC;
        clk, rst : IN STD_LOGIC;
        pcOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY pcReg;

ARCHITECTURE pcArch OF pcReg IS
BEGIN

    PROCESS (clk, rst)
        VARIABLE currentVal : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        IF (rst = '1') THEN
            currentVal := (OTHERS => '0');
        ELSIF rising_edge(clk) AND bubblingSignal = '0' THEN
            currentVal := pcIn;
        END IF;
        pcOut <= currentVal;
    END PROCESS;
END pcArch;