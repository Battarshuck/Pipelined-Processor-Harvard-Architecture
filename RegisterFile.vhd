LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RegisterFile IS
    PORT ( 
        clk, rst, writeEnable : IN STD_LOGIC;

        registerAddress1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        registerAddress2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        writeData : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        writeRegisterAddress:IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        readData1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        readData2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END ENTITY RegisterFile;

architecture RegisterFile_arch of RegisterFile is
    TYPE ram_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

    PROCESS (clk, rst) IS
    variable ram : ram_type;
    BEGIN
        IF (rst = '1') THEN
            FOR index IN 0 TO 7 LOOP
                ram(index) := (OTHERS => '0');
            END LOOP;
        ELSIF rising_edge(clk) THEN
            IF writeEnable = '1' THEN
                ram(to_integer(unsigned((writeRegisterAddress)))) := writeData;
            END IF;
        ELSIF falling_edge(clk) THEN
            readData1 <= ram(to_integer(unsigned((registerAddress1))));
            readData2 <= ram(to_integer(unsigned((registerAddress2))));
        END IF;
    END PROCESS;

END RegisterFile_arch;