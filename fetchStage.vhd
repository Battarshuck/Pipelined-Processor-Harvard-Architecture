LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetchStage IS
    PORT (
        clk, rst, bubblingSignal, branchTrueSig : IN STD_LOGIC;
        interruptSigFD, interruptSigDE, interruptSigInput, RTISigM1M2 : IN STD_LOGIC;
        pcSourceDE, pcSrcM1M2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        Rs1DE, RMemoryOutput : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        jmpAddress, callAddress, returnAddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pcAfterAddition : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        instructions : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    ); --main instruction + immediate value 
END ENTITY fetchStage;

ARCHITECTURE fetchStageArch OF fetchStage IS
    SIGNAL pcInOutFromAdder, pcOut, M0, M1, chosenPcIn, pcFromMux, muxBranchTrue : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL pcSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL currentInstructions : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL currentInstructionsEnteringBuffer : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    pcHandler : ENTITY work.pcHandler PORT MAP(pcSourceDE, pcSrcM1M2, interruptSigFD, interruptSigDE, RTISigM1M2, pcSrc);

    muxBranchTrue <= pcInOutFromAdder WHEN (branchTrueSig = '0') ELSE
        Rs1DE; -- make sure from r source 1 if jmp!!!!!!
    pcFromMux <= pcInOutFromAdder WHEN (pcSrc = "00") ELSE
        muxBranchTrue WHEN (pcSrc = "01") ELSE
        Rs1DE WHEN (pcSrc = "10") ELSE
        RMemoryOutput;

    chosenPcIn <= M1 WHEN (interruptSigFD = '1') ELSE
        pcFromMux;

    pcRegister : ENTITY work.pcReg PORT MAP(chosenPcIn, M0, bubblingSignal, clk, rst, pcOut);
    instructionCache : ENTITY work.instructionCache PORT MAP(pcOut, M0, M1, currentInstructions);
    pcAdder : ENTITY work.pcAdder PORT MAP(pcOut, currentInstructionsEnteringBuffer(0), pcInOutFromAdder);

    currentInstructionsEnteringBuffer <= currentInstructions WHEN (interruptSigInput = '0') ELSE
        x"00000002";
    pcAfterAddition <= pcInOutFromAdder;
    instructions <= currentInstructionsEnteringBuffer;

END fetchStageArch;