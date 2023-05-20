LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY processor IS
    PORT (
        clk, rst : IN STD_LOGIC;
        inputPort : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        interrupt : IN STD_LOGIC;
        isOutputDataValid : OUT STD_LOGIC;
        outputPort : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY processor;
ARCHITECTURE processorArch OF processor IS
    --Fetch Stage signals
    SIGNAL branchTrueSig : STD_LOGIC := '0';
    SIGNAL interruptSigFD, interruptSigDE, interruptSigInput, RTISigM1M2 : STD_LOGIC := '0';
    SIGNAL pcSourceDE, pcSrcM1M2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL Rs1DE, RMemoryOutput : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pcAfterAddition, readData1Decode, readData2Decode, writeBackData : STD_LOGIC_VECTOR(15 DOWNTO 0);
    ------------------FD buffer----------------
    SIGNAL RETSignalMM, RTISignalMM, callSignalDE : STD_LOGIC := '0';
    ---------------------------------------------
    SIGNAL bubblingSignal, writeBackEnable, FDbufferEnable, DEbufferEnable, EM1bufferEnable, MMbufferEnable, MWBbufferEnable, FDrst, DErst, EM1rst, MMrst, MWBrst, flagEnable, outputPortValidTemp : STD_LOGIC := '0';
    SIGNAL pcSource : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL instructions : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aluOut : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL carryOutFlag, zeroFlag, negativeFlag : STD_LOGIC;
    SIGNAL OutMemory : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL outWriteBack : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, isImmediate, doutPortEnable, dSPSignal, dcallSignal, dRETsignal, dRTIsignal : STD_LOGIC;

    SIGNAL dpcSrc, djumpType, dcarrySig : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL dstackOP : STD_LOGIC_VECTOR (2 DOWNTO 0);

    SIGNAL inFDbuffer, outFDbuffer : STD_LOGIC_VECTOR (48 DOWNTO 0);
    SIGNAL inDEbuffer, outDEbuffer : STD_LOGIC_VECTOR (89 DOWNTO 0);
    SIGNAL inEM1buffer, outEM1buffer : STD_LOGIC_VECTOR (59 DOWNTO 0);
    SIGNAL inMWBbuffer, outMWBbuffer : STD_LOGIC_VECTOR (36 DOWNTO 0);
    SIGNAL outMMbuffer : STD_LOGIC_VECTOR (59 DOWNTO 0);
    SIGNAL doperation, writeRegisterAddress : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EM_OP, MM_OP, MWB_OP, immediateOP : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL S1_FU, S2_FU : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL inPortEnable : STD_LOGIC := '0';
    SIGNAL flagInput, flagOut : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL flagRst : STD_LOGIC := '0';
    SIGNAL SPSignalControl : STD_LOGIC := '0';
    SIGNAL SPAddress : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL outputPortDataTemp : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN
    --bubblingSignal<= outHazardDetedction();
    --branchTrueSig <= outExecuteStage();    
    --interruptSigFD <= outFDBuffer();
    --interruptSigDE <= outDEBuffer();
    interruptSigInput <= interrupt;
    --RTISigM1M2 <= outMMbuffer();
    --pcSourceDE <= outDEbuffer();
    --pcSrcM1M2 <= outMMbuffer();
    --Rs1DE <= outExecutionStage();
    --RMemoryOutput <= outMemoryStage();

    --pcAfterAddition out to FD buffer (16)
    --instructions out to FD buffer (32)

    fetchStage : ENTITY work.fetchStage PORT MAP(clk, rst, bubblingSignal, branchTrueSig, interruptSigFD, interruptSigDE
        , interruptSigInput, RTISigM1M2, pcSourceDE, pcSrcM1M2
        , Rs1DE, RMemoryOutput, pcAfterAddition, instructions);

    --#################################################################################################--

    inFDbuffer <= instructions(1) & pcAfterAddition & instructions;
    FDbufferEnable <= NOT bubblingSignal;
    FDrst <= rst OR branchTrueSig OR RETSignalMM OR RTISignalMM OR callSignalDE; -- or el 7agat el tanya
    FDbuffer : ENTITY work.buff GENERIC MAP(49) PORT MAP(inFDbuffer, clk, FDrst, FDbufferEnable, outFDbuffer);
    --outFDbuffer[48] is interrupt signal
    --outFDbuffer[47:32] is the pc
    --outFDbuffer[31:0] is the instruction Instruction + immediate
    --outFDbuffer[31:16] is the immediate
    --outFDbuffer[15:0] is instruction 1 where [15:11] is the opcode and [10:8] is dest address and [7:5] is source 1 address and [4:2] is source 2 address and [1:0] is the function code

    --########################################################################################################--
    --writeBackEnable <= outMWBbuffer(of 7aga);
    --writeRegisterAddress <= outMWBbuffer(of 7aga);
    --writeBackData <= outMWBbuffer(of 7aga);
    decodeStage : ENTITY work.decodeStage PORT MAP(clk, rst, writeBackEnable, writeRegisterAddress, writeBackData
        , outFDbuffer(31 DOWNTO 0), outFDbuffer(0), outFDbuffer(48), dwriteEnable, dmemWrite, dmemRead, dmemToReg, doutPortEnable, dinPortEnable
        , dSPSignal, djumpType, dpcSrc, dstackOP, dcarrySig, dcallSignal, dRETsignal, dRTIsignal, doperation, readData1Decode, readData2Decode);

    --#########################################################################################################--
    -- in DE BUFFER interrupt, all CTRL signals (22 bits), 
    --Read Data 1 (16 bits), Read Data 2 (16 bits), Immediate (16 bits), 
    --Rdest (3 bits)
    --PC after addition (16 bits)

    inDEbuffer <= outFDbuffer(48) & dwriteEnable & dmemWrite & dmemRead & dmemToReg & doutPortEnable & dinPortEnable
        & dSPSignal & djumpType & dpcSrc & dstackOP & dcarrySig & dcallSignal & dRETsignal & dRTIsignal & doperation
        & readData1Decode & readData2Decode & outFDbuffer(31 DOWNTO 16) & outFDbuffer(10 DOWNTO 8) & outFDbuffer(47 DOWNTO 32);

    DEbufferEnable <= NOT bubblingSignal;
    DErst <= rst OR RETSignalMM OR RTISignalMM; -- or el 7agat el tanya
    DEbuffer : ENTITY work.buff GENERIC MAP(90) PORT MAP(inDEbuffer, clk, DErst, DEbufferEnable, outDEbuffer);

    --outDEbuffer[89] is interrupt signal
    --outDEbuffer[88:67] is the control signals
    --outDEbuffer[66:51] is the read data 1
    --outDEbuffer[50:35] is the read data 2
    --outDEbuffer[34:19] is the immediate
    --outDEbuffer[18:16] is the destination register
    --outDEbuffer[15:0] is the pc after addition

    --====================Control Signal Details===========================-

    --outDEbuffer[88] is write enable
    --outDEbuffer[87] is memory write
    --outDEbuffer[86] is memory read
    --outDEbuffer[85] is memory to register
    --outDEbuffer[84] is output port enable
    --outDEbuffer[83] is input port enable
    --outDEbuffer[82] is SP signal
    --outDEbuffer[81:80] is jump type
    --outDEbuffer[79:78] is pc source
    --outDEbuffer[77:75] is stack operation
    --outDEbuffer[74:73] is carry signal
    --outDEbuffer[72] is call signal
    --outDEbuffer[71] is RET signal
    --outDEbuffer[70] is RTI signal
    --outDEbuffer[69:67] is operation

    --=====================================================================-
    --#########################################################################################################--

    -- executionStage : ENTITY work.executionStage PORT MAP(outDEbuffer(31 DOWNTO 16), outDEbuffer(15 DOWNTO 0),
    --     inputPort, EM_OP, MM_OP, MWB_OP, immediateOP, S1_FU, S2_FU, outDEbuffer(72), outDEbuffer(73),
    --     outDEbuffer(69 DOWNTO 67), aluOut,
    --     carryOutFlag, zeroFlag, negativeFlag);

    -- flagEnable <= '1' WHEN outDEbuffer(69 DOWNTO 67) = "111" OR outDEbuffer(69 DOWNTO 67) = "101" ELSE
    --     '0';

    -- flagRst <= rst;
    -- flagInput <= carryOutFlag & zeroFlag & negativeFlag;
    -- flagRegister : ENTITY work.buff GENERIC MAP(3) PORT MAP(flagInput, clk, flagRst, flagEnable, flagOut);
    -- inEM1buffer <= outDEbuffer(77) & outDEbuffer(76) & outDEbuffer(75) & outDEbuffer(74) & outDEbuffer(71 DOWNTO 70) & outDEbuffer(66 DOWNTO 51) & outDEbuffer(50 DOWNTO 48) & flagOut & outDEbuffer(15 DOWNTO 0) & aluOut;
    -- --inEM1Buffer[0:15] is aluOut
    -- --inEM1Buffer[16:31] is Rsource2
    -- --inEM1Buffer[32:34] is flagOut
    -- --inEM1Buffer[35:37] is Rdest
    -- --inEM1Buffer[38:53] is pc+1
    -- --inEM1Buffer[54:55] is PcSrc --for branching
    -- --inEM1Buffer[56] is memToReg SIGNAL
    -- --inEM1Buffer[57] is memRead SIGNAL
    -- --inEM1Buffer[58] is memWrite SIGNAL
    -- --inEM1Buffer[59] is writeEnable SIGNAL
    -- EM1bufferEnable <= NOT bubblingSignal;
    -- EM1rst <= rst; -- or el 7agat el tanya
    -- EM1buffer : ENTITY work.buff GENERIC MAP(60) PORT MAP(inEM1buffer, clk, EM1rst, EM1bufferEnable, outEM1buffer);

    -- MMbufferEnable <= '1';
    -- MMrst <= rst; -- or el 7agat el tanya
    -- MMBuffer : ENTITY work.buff GENERIC MAP(60) PORT MAP(outEM1buffer, clk, MMrst, MMbufferEnable, outMMbuffer);
    -- --NOTE: outBuffer(18 downto 16) is just a **PLACEHOLDER**, we need to put the stack operation instead
    -- stackRegister : ENTITY work.stackregister PORT MAP(clk, rst, outBuffer(18 DOWNTO 16), SPAddress);
    -- memoryStage : ENTITY work.memoryStage PORT MAP(clk, rst, outMMbuffer(58), outMMbuffer(57), CallSignalControl, SPSignalControl, outMMbuffer(53 DOWNTO 38), outMMbuffer(15 DOWNTO 0), outMMbuffer(31 DOWNTO 16), SPAddress, OutMemory);

    -- inMWBbuffer <= outMMbuffer(59) & outMMbuffer(56) & outMemory & outMMbuffer(15 DOWNTO 0) & outMMbuffer(37 DOWNTO 35);
    -- --inMWBuffer[0:2] is Rdest
    -- --inMWBuffer[3:18] is aluOut
    -- --inMWBuffer[19:34] is outMemory
    -- --inMWBuffer[35] is memToReg SIGNAL
    -- --inMWBuffer[36] is writeEnable SIGNAL

    -- MWBbufferEnable <= '1';
    -- MWBrst <= rst; -- or el 7agat el tanya
    -- MWBBuffer : ENTITY work.buff GENERIC MAP(37) PORT MAP(inMWBbuffer, clk, MWBrst, MWBbufferEnable, outMWBbuffer);

    -- writeBackStage : ENTITY work.writebackStage PORT MAP(outMWBbuffer(35), outMWBbuffer(34 DOWNTO 19), outMWBbuffer(18 DOWNTO 3), outWriteBack);
    -- --NOTE outputPortEnable is just a **PLACEHOLDER**, we need to put the outputPortEnable signal instead
    -- OutPort : ENTITY work.outputPort PORT MAP(outputPortEnable, outWriteBack, outputPortValidTemp, outputPortDataTemp);
    -- outputPort <= outputPortDataTemp; --output data
    -- outputPortValid <= outputPortValidTemp; --output valid signal

    -- -- pcRegister : entity work.pcReg PORT MAP(pcIn, bubblingSignal, clk, rst, pcOut);
    -- -- pcAdder : entity work.pcAdder PORT MAP(pcOut, currentInstructions(0), pcIn);
    -- -- instructionCache : entity work.instructionCache PORT MAP(pcOut, currentInstructions);

    -- -- pcAfterAddition <= pcIn;
    -- -- instructions <= currentInstructions;

END processorArch;