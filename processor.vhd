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
    SIGNAL bubblingSignal, writeBackEnable, FDbufferEnable, DEbufferEnable, EM1bufferEnable,MMbufferEnable,MWBbufferEnable, FDrst, DErst, EM1rst,MMrst,MWBrst, flagEnable, outputPortValidTemp : STD_LOGIC := '0';
    SIGNAL pcSource : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL instructions : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aluOut : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL carryOutFlag, zeroFlag, negativeFlag : STD_LOGIC;
    SIGNAL OutMemory : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL outWriteBack : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, isImmediate : STD_LOGIC;
    SIGNAL dpcSrc : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL inFDbuffer, outFDbuffer : STD_LOGIC_VECTOR (47 DOWNTO 0);
    SIGNAL inDEbuffer, outDEbuffer : STD_LOGIC_VECTOR (77 DOWNTO 0);
    SIGNAL inEM1buffer, outEM1buffer : STD_LOGIC_VECTOR (59 DOWNTO 0);
    SIGNAL inMWBbuffer, outMWBbuffer : STD_LOGIC_VECTOR (36 DOWNTO 0);
    SIGNAL outMMbuffer : STD_LOGIC_VECTOR (59 DOWNTO 0);
    SIGNAL doperation, writeRegisterAddress : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EM_OP, MM_OP, MWB_OP, immediateOP : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL S1_FU, S2_FU : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL inPortEnable : STD_LOGIC := '0';
    SIGNAL flagInput, flagOut : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL flagRst : STD_LOGIC := '0';
    SIGNAL CallSignalControl : STD_LOGIC := '0';
    SIGNAL SPSignalControl : STD_LOGIC := '0';
    SIGNAL SPAddress : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL outputPortDataTemp : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    
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
        clk, rst, outMWBbuffer(36),
        outMWBbuffer(2 downto 0),
        outWriteBack,
        outFDbuffer(31 DOWNTO 0),
        dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, isImmediate,
        dpcSrc,
        doperation,
        readData1Decode, readData2Decode);

    inDEbuffer <= dwriteEnable & dmemWrite & dmemRead & dmemToReg & dinPortEnable & isImmediate & dpcSrc & doperation & outFDbuffer(47 DOWNTO 32) & outFDbuffer(10 DOWNTO 8) & outFDbuffer(31 DOWNTO 16) & readData1Decode & readData2Decode;
    DEbufferEnable <= NOT bubblingSignal;
    DErst <= rst; -- or el 7agat el tanya
    DEbuffer : ENTITY work.buff GENERIC MAP(78) PORT MAP(inDEbuffer, clk, DErst, DEbufferEnable, outDEbuffer);
    --outDEbuffer[0:15] is Readdata2 (Rsource 2)
    --outDEbuffer[16:31] is Readdata1 (Rsource 1)
    --outDEbuffer[32:47] is immediate
    --outDEbuffer[48:50] is Rdest
    --outDEbuffer[51:66] is pc+1
    --outDEbuffer[67:69] is ALU operation
    --outDEbuffer[70:71] is pcSrc SIGNAL
    --outDEbuffer[72] is isImmediate SIGNAL
    --outDEbuffer[73] is inPortEnable SIGNAL
    --outDEbuffer[74] is memToReg SIGNAL
    --outDEbuffer[75] is memRead SIGNAL
    --outDEbuffer[76] is memWrite SIGNAL
    --outDEbuffer[77] is writeEnable SIGNAL

    executionStage : ENTITY work.executionStage PORT MAP(outDEbuffer(31 DOWNTO 16), outDEbuffer(15 DOWNTO 0),
        inputPort, EM_OP, MM_OP, MWB_OP, immediateOP, S1_FU, S2_FU, outDEbuffer(72), outDEbuffer(73),
        outDEbuffer(69 DOWNTO 67), aluOut,
        carryOutFlag, zeroFlag, negativeFlag);

    flagEnable <= '1' when outDEbuffer(69 downto 67) = "111" or outDEbuffer(69 downto 67) = "101" else
                    '0';

    flagRst <= rst;
    flagInput <= carryOutFlag & zeroFlag & negativeFlag;
    flagRegister : ENTITY work.buff GENERIC MAP(3) PORT MAP(flagInput, clk, flagRst, flagEnable, flagOut);
    inEM1buffer <= outDEbuffer(77)& outDEbuffer(76)& outDEbuffer(75)& outDEbuffer(74) & outDEbuffer(71 downto 70) & outDEbuffer(66 downto 51) & outDEbuffer(50 downto 48)  & flagOut & outDEbuffer(15 downto 0) & aluOut;
    --inEM1Buffer[0:15] is aluOut
    --inEM1Buffer[16:31] is Rsource2
    --inEM1Buffer[32:34] is flagOut
    --inEM1Buffer[35:37] is Rdest
    --inEM1Buffer[38:53] is pc+1
    --inEM1Buffer[54:55] is PcSrc --for branching
    --inEM1Buffer[56] is memToReg SIGNAL
    --inEM1Buffer[57] is memRead SIGNAL
    --inEM1Buffer[58] is memWrite SIGNAL
    --inEM1Buffer[59] is writeEnable SIGNAL
    EM1bufferEnable <= NOT bubblingSignal;
    EM1rst <= rst; -- or el 7agat el tanya

    
    EM1buffer : ENTITY work.buff GENERIC MAP(60) PORT MAP(inEM1buffer, clk, EM1rst, EM1bufferEnable, outEM1buffer);
    
    MMbufferEnable <= '1';
    MMrst <= rst; -- or el 7agat el tanya
    MMBuffer : entity work.buff GENERIC MAP(60) PORT MAP(outEM1buffer, clk, MMrst, MMbufferEnable, outMMbuffer); 


    --NOTE: outBuffer(18 downto 16) is just a **PLACEHOLDER**, we need to put the stack operation instead
    stackRegister: entity work.stackregister PORT MAP(clk, rst, outBuffer(18 downto 16), SPAddress);
    memoryStage : entity work.memoryStage PORT MAP(clk,rst,outMMbuffer(58),outMMbuffer(57),CallSignalControl,SPSignalControl,outMMbuffer(53 downto 38),outMMbuffer(15 downto 0),outMMbuffer(31 downto 16),SPAddress,OutMemory);
    
    inMWBbuffer <= outMMbuffer(59) & outMMbuffer(56) & outMemory & outMMbuffer(15 downto 0) & outMMbuffer(37 downto 35);
    --inMWBuffer[0:2] is Rdest
    --inMWBuffer[3:18] is aluOut
    --inMWBuffer[19:34] is outMemory
    --inMWBuffer[35] is memToReg SIGNAL
    --inMWBuffer[36] is writeEnable SIGNAL

    MWBbufferEnable <= '1';
    MWBrst <= rst; -- or el 7agat el tanya
    MWBBuffer : entity work.buff GENERIC MAP(37) PORT MAP(inMWBbuffer, clk, MWBrst, MWBbufferEnable, outMWBbuffer);



    writeBackStage: ENTITY work.writebackStage PORT MAP(outMWBbuffer(35),outMWBbuffer(34 downto 19),outMWBbuffer(18 downto 3),outWriteBack);
    --NOTE outputPortEnable is just a **PLACEHOLDER**, we need to put the outputPortEnable signal instead
    OutPort: ENTITY work.outputPort PORT MAP(outputPortEnable, outWriteBack, outputPortValidTemp, outputPortDataTemp);
    outputPort <= outputPortDataTemp; --output data
    outputPortValid <= outputPortValidTemp; --output valid signal

    -- pcRegister : entity work.pcReg PORT MAP(pcIn, bubblingSignal, clk, rst, pcOut);
    -- pcAdder : entity work.pcAdder PORT MAP(pcOut, currentInstructions(0), pcIn);
    -- instructionCache : entity work.instructionCache PORT MAP(pcOut, currentInstructions);

    -- pcAfterAddition <= pcIn;
    -- instructions <= currentInstructions;

END processorArch;