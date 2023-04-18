LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY cache_memory IS
    PORT (
        address : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        dataOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY cache_memory;

ARCHITECTURE cacheMemoryArch OF cache_memory IS
    TYPE ram_type IS ARRAY(0 TO 63) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ram : ram_type;
BEGIN
    dataout <= ram(to_integer(unsigned((address))));
END cacheMemoryArch;
