LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;


--not done phase 2
ENTITY FU IS
    PORT (
        dataIn : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        clk, rst, enable : IN STD_LOGIC;
        dataOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY FU;

ARCHITECTURE fuArch OF FU IS
BEGIN

END fuArch;

