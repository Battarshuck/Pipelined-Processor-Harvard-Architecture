LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY instructionCache IS
    PORT (
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        M0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        M1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        dataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END ENTITY instructionCache;

ARCHITECTURE instructionCacheArch OF instructionCache IS
    TYPE ram_type IS ARRAY(0 TO 1023) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ram : ram_type;
BEGIN
    M0 <= ram(0);
    M1 <= ram(1);
    dataout <= ram(to_integer(unsigned((address)))+1) & ram(to_integer(unsigned((address))));
END instructionCacheArch;
