LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY flagRegister IS
    PORT (
        clk, rst, enable : IN STD_LOGIC;
        operation : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        dataIn : IN STD_LOGIC_VECTOR(2 DOWNTO 0);      
        dataOut : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
END ENTITY flagRegister;

ARCHITECTURE flagRegisterArch OF flagRegister IS
BEGIN
    PROCESS (clk, rst)
    variable value : std_logic_vector(2 downto 0);
    BEGIN
        IF rst = '1'  THEN
            value := "000";
        --To ensure writng in rising edge
        ELSIF rising_edge(clk) AND enable = '1' AND rst = '0' THEN
            if operation = "01" then --set carry
                value(2) := '1';
            elsif operation = "10" then --clear carry
                value(2) := '0';
            else
                value := dataIn;
            end if;
        END IF;
        --To ensure reading in falling edge
        IF(falling_edge(clk))THEN
            dataOut<=value;
        END IF;
    END PROCESS;
END flagRegisterArch;