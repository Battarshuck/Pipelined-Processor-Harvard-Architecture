LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetchStage IS
    PORT (
        clk, rst, bubblingSignal: IN STD_LOGIC;
        pcSource : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        jmpAddress,callAddress, returnAddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pcAfterAddition : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        instructions : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); --main instruction + immediate value 
END ENTITY fetchStage;


ARCHITECTURE fetchStageArch OF fetchStage IS
    Signal pcIn, pcOut : STD_LOGIC_VECTOR(15 DOWNTO 0);
    Signal currentInstructions : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    pcRegister : entity work.pcReg PORT MAP(pcIn, bubblingSignal, clk, rst, pcOut);
    pcAdder : entity work.pcAdder PORT MAP(pcOut, currentInstructions(0), pcIn);
    instructionCache : entity work.instructionCache PORT MAP(pcOut, currentInstructions);

    pcAfterAddition <= pcIn;
    instructions <= currentInstructions;
    
END fetchStageArch;
