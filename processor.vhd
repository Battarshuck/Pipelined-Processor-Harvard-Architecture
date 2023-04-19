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
    FDrst <= rst; -- or el 7agat el tanya

    FDbuffer : ENTITY work.buff GENERIC MAP(48) PORT MAP(inFDbuffer, clk, FDrst, FDbufferEnable, outFDbuffer);
    --outFDbuffer[0:31] is the instruction Instruction + immediate
    --outFDbuffer[31:16] is the immediate
    --outFDbuffer[0:15] is instruction 1 where [15:11] is the opcode and [10:8] is dest address and [7:5] is source 1 address and [4:2] is source 2 address and [1:0] is the function code
    --outFDbuffer[32:47] is the pc
    decodeStage : ENTITY work.decodeStage PORT MAP(
        clk, rst, writeBackEnable,
        writeRegisterAddress,
        writeBackData,
        outFDbuffer(31 DOWNTO 0),
        dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, isImmediate,
        dpcSrc,
        doperation,
        readData1Decode, readData2Decode);

    inDEbuffer <=  dwriteEnable & dmemWrite & dmemRead & dmemToReg & dinPortEnable & isImmediate & dpcSrc & doperation & outFDbuffer(47 downto 32)  & outFDbuffer(10 downto 8) & outFDbuffer(31 downto 16) & readData1Decode & readData2Decode;
    DEbufferEnable<= not bubblingSignal;
    DErst <= rst; -- or el 7agat el tanya
    DEbuffer : ENTITY work.buff GENERIC MAP(78) PORT MAP(inDEbuffer, clk, DErst, DEbufferEnable, outDEbuffer);
    --outDEbuffer[0:15] is Readdata2 (Rsource 2)
    --outDEbuffer[16:31] is Readdata1 (Rsource 1)
    --outDEbuffer[32:47] is immediate
    --outDEbuffer[48:51] is Rdest
    --outDEbuffer[52:67] is pc+1
    --outDEbuffer[68:70] is ALU operation
    --outDEbuffer[71:72] is pcSrc SIGNAL
    --outDEbuffer[73] is isImmediate SIGNAL
    --outDEbuffer[74] is inPortEnable SIGNAL
    --outDEbuffer[75] is memToReg SIGNAL
    --outDEbuffer[76] is memRead SIGNAL
    --outDEbuffer[77] is memWrite SIGNAL
    --outDEbuffer[78] is writeEnable SIGNAL



    
    
    
    
    -- pcRegister : entity work.pcReg PORT MAP(pcIn, bubblingSignal, clk, rst, pcOut);
    -- pcAdder : entity work.pcAdder PORT MAP(pcOut, currentInstructions(0), pcIn);
    -- instructionCache : entity work.instructionCache PORT MAP(pcOut, currentInstructions);

    -- pcAfterAddition <= pcIn;
    -- instructions <= currentInstructions;

END processorArch;