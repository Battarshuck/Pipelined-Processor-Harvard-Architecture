LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RegisterFile IS
    PORT (
        clk, rst, writeEnable : IN STD_LOGIC;

        registerAddress1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        registerAddress2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        writeData : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        writeRegisterAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        readData1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        readData2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY RegisterFile;

ARCHITECTURE RegisterFile_arch OF RegisterFile IS
    TYPE ram_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ram : ram_type;
BEGIN

    PROCESS (clk, rst, registerAddress1, registerAddress2) IS
        --variable ram : ram_type;
    BEGIN
        IF (rst = '1') THEN
            FOR index IN 0 TO 7 LOOP
                ram(index) <= (OTHERS => '0');
            END LOOP;
        ELSIF rising_edge(clk) THEN
            IF writeEnable = '1' THEN
                ram(to_integer(unsigned((writeRegisterAddress)))) <= writeData;
            END IF;
        END IF;

        readData1 <= ram(to_integer(unsigned((registerAddress1))));
        readData2 <= ram(to_integer(unsigned((registerAddress2))));
 
    END PROCESS;

END RegisterFile_arch;