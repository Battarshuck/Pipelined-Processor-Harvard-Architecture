LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memoryStage IS
    PORT (
        clk, reset, MemWriteControl, MemReadControl, CallSignalControl, SPSignalControl : IN std_logic;
        PCAfterAddition, dataFromALU: in std_logic_vector(15 downto 0);--data in
        Rsrc2Address, SPAddress: in std_logic_vector(15 downto 0);
        ReadData: out std_logic_vector(15 downto 0)--data out       
        ); 
END ENTITY memoryStage;


ARCHITECTURE memoryStageArch OF memoryStage IS   
    SIGNAL writeData, Address, memoryOut : std_logic_vector(15 downto 0);
BEGIN
    
    dataMemory : entity work.memory PORT MAP(clk, reset, MemWriteControl, MemReadControl, writeData, Address, memoryOut);

    writeData <= dataFromALU WHEN CallSignalControl = '0' ELSE
                PCAfterAddition;

    Address <= Rsrc2Address WHEN SPSignalControl = '0' ELSE
                SPAddress;

    ReadData <= memoryOut; 

END memoryStageArch;

