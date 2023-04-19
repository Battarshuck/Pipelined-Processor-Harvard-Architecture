LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY processor IS
    PORT (
        clk, rst : IN STD_LOGIC;
        inputPort : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        isOutputDataValid : OUT STD_LOGIC;
        outputPort : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY processor;
ARCHITECTURE processorArch OF processor IS
    SIGNAL jmpAddress, callAddress, returnAddress, pcAfterAddition : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL bubblingSignal : STD_LOGIC := '0';
    SIGNAL pcSource : STD_LOGIC_VECTOR(1 DOWNTO 0)  := "00";
    SIGNAL instructions : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    fetchStage : ENTITY work.fetchStage PORT MAP(clk, rst, bubblingSignal, pcSource, jmpAddress, callAddress
        , returnAddress, pcAfterAddition, instructions);
    -- pcRegister : entity work.pcReg PORT MAP(pcIn, bubblingSignal, clk, rst, pcOut);
    -- pcAdder : entity work.pcAdder PORT MAP(pcOut, currentInstructions(0), pcIn);
    -- instructionCache : entity work.instructionCache PORT MAP(pcOut, currentInstructions);

    -- pcAfterAddition <= pcIn;
    -- instructions <= currentInstructions;

END processorArch;