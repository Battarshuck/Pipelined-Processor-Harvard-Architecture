LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY writebackStage IS
    PORT (
        memToRegControl: IN STD_LOGIC;
        flagIn: in STD_LOGIC_VECTOR(2 DOWNTO 0);
        dataFromMemory, dataFromALU : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        dataOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        flagOut: out STD_LOGIC_VECTOR(2 DOWNTO 0)
        ); 
END ENTITY writebackStage;


ARCHITECTURE writebackStageArch OF writebackStage IS  
SIGNAL flagTemp: STD_LOGIC_VECTOR(2 DOWNTO 0); 
BEGIN
    
WITH memToRegControl SELECT
    dataOut <= dataFromALU WHEN '0',
            dataFromMemory WHEN OTHERS;


flagTemp <= flagIn;
flagOut <= flagTemp;
    
END writebackStageArch;
