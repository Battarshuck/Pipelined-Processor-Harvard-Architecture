LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY buff IS
    GENERIC (n : INTEGER := 16);
    PORT (
        dataIn : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        clk, rst, enable : IN STD_LOGIC;
        dataOut : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
        );
END ENTITY buff;

ARCHITECTURE bufferArch OF buff IS
BEGIN
    PROCESS (clk, rst)
        VARIABLE innerData : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    BEGIN
        IF rst = '1'  THEN
            innerData := (OTHERS => '0');
        --To ensure writng in rising edge
        ELSIF rising_edge(clk) AND enable = '1' THEN
            innerData := dataIn;
        END IF;
        --To ensure reading in falling edge
        IF(falling_edge(clk))THEN
            dataOut<=innerData;
        END IF;
    END PROCESS;
END bufferArch;