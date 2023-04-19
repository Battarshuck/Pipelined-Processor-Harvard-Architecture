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
    SIGNAL jmpAddress, callAddress, returnAddress, pcAfterAddition, readData1Decode, readData2Decode, writeBackData
    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL bubblingSignal, writeBackEnable, FDbufferEnable, DEbufferEnable, FDrst, DErst: STD_LOGIC := '0';
    SIGNAL pcSource : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL instructions : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, isImmediate : STD_LOGIC;
    SIGNAL dpcSrc : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL inFDbuffer, outFDbuffer : STD_LOGIC_VECTOR (47 DOWNTO 0);
    SIGNAL inDEbuffer, outDEbuffer : STD_LOGIC_VECTOR (77 DOWNTO 0);
    SIGNAL doperation, writeRegisterAddress : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
    fetchStage : ENTITY work.fetchStage PORT MAP(clk, rst, bubblingSignal, pcSource, jmpAddress, callAddress
        , returnAddress, pcAfterAddition, instructions);

    inFDbuffer <= pcAfterAddition & instructions;
    FDbufferEnable <= NOT bubblingSignal;

    FDbuffer : ENTITY work.buff GENERIC MAP(48) PORT MAP(inFDbuffer, clk, FDrst, FDbufferEnable, outFDbuffer);

    decodeStage : ENTITY work.decodeStage PORT MAP(
        clk, rst, writeBackEnable,
        writeRegisterAddress,
        writeBackData,
        outFDbuffer(31 DOWNTO 0),
        dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, isImmediate,
        dpcSrc,
        doperation,
        readData1Decode, readData2Decode);

    DEbuffer : ENTITY work.buff GENERIC MAP(78) PORT MAP(inDEbuffer, clk, DErst, DEbufferEnable, outDEbuffer);
    
    -- pcRegister : entity work.pcReg PORT MAP(pcIn, bubblingSignal, clk, rst, pcOut);
    -- pcAdder : entity work.pcAdder PORT MAP(pcOut, currentInstructions(0), pcIn);
    -- instructionCache : entity work.instructionCache PORT MAP(pcOut, currentInstructions);

    -- pcAfterAddition <= pcIn;
    -- instructions <= currentInstructions;

END processorArch;