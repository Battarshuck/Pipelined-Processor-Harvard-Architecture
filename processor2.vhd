LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY processor2 IS
    PORT (
        clk, rst : IN STD_LOGIC;
        inputPort : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        interrupt : IN STD_LOGIC;
        isOutputDataValid : OUT STD_LOGIC;
        outputPort : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY processor2;

ARCHITECTURE processorArch OF processor2 IS
    --Fetch stage signals:
    SIGNAL bubblingSignal, interruptSigFD, RTISigM1M2 : STD_LOGIC := '0';
    SIGNAL pcSourceDE, pcSrcM1M2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL Rs1DE, RMemoryOutput : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pcAfterAdditionFetch : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instructionsFetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --FD buffer signals:
    SIGNAL inFDbuffer : STD_LOGIC_VECTOR(48 DOWNTO 0);
    SIGNAL rstFDbuffer : STD_LOGIC;
    SIGNAL RETSignalMM, RTISignalMM, callSignalDE : STD_LOGIC := '0';
    SIGNAL enableFDbuffer : STD_LOGIC;
    SIGNAL outFDbuffer : STD_LOGIC_VECTOR(48 DOWNTO 0);
    --Decode stage signals:
    SIGNAL disImmediate, disInterrupt, dWriteEnable, dMemWrite, dMemRead, dMemToReg, dOutPortEnable, dInPortEnable, dSPSignal : STD_LOGIC;
    SIGNAL dJumpType : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dPcSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dStackOP : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL dCarrySig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dCallSignal, dRETsignal, dRTIsignal : STD_LOGIC;
    SIGNAL dOperation : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL dReadData1, dReadData2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    --should be taked from write back stage
    SIGNAL writeBackEnable : STD_LOGIC := '0';
    SIGNAL writeRegisterAddress : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL writeBackData : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    --DE buffer signals:
    SIGNAL inDEbuffer : STD_LOGIC_VECTOR(96 DOWNTO 0);
    SIGNAL DEbufferEnable : STD_LOGIC;
    SIGNAL DErst : STD_LOGIC;
    SIGNAL outDEbuffer : STD_LOGIC_VECTOR(96 DOWNTO 0);
    --excution stage
    SIGNAL EM_OP, MM_OP, MWB_OP : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL S1_FU, S2_FU, S3_FU : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL flagFromWB : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RET_EM_buffer, RET_M1M2_buffer : STD_LOGIC := '0';
    SIGNAL aluOut : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL carryOutFlag, zeroFlag, negativeFlag : STD_LOGIC := '0';
    SIGNAL PCoutput : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL branchTrueFlagOutput : STD_LOGIC := '0';
    SIGNAL RSCR2Address, RSCR1Output : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN
    --Fetch stage:
    fetchStage : ENTITY work.fetchStage PORT MAP(clk, rst, bubblingSignal, branchTrueFlagOutput, outFDbuffer(48), outDEbuffer(96)
        , interrupt, RTISigM1M2, outDEbuffer(85 downto 84), pcSrcM1M2
        , RSCR1Output, RMemoryOutput, pcAfterAdditionFetch, instructionsFetch);
    ----------------------------------------------------------------------------------------------------------------------------
    --FD buffer:
    --bubbling signal is an output of the hazard detection unit
    inFDbuffer <= interrupt & pcAfterAdditionFetch & instructionsFetch;
    rstFDbuffer <= ((branchTrueFlagOutput OR RETSignalMM OR RTISignalMM OR callSignalDE) AND NOT outFDbuffer(48)) OR rst OR outDEbuffer(96);
    enableFDbuffer <= NOT bubblingSignal;
    FDbuffer : ENTITY work.buff GENERIC MAP(49) PORT MAP(inFDbuffer, clk, rstFDbuffer, enableFDbuffer, outFDbuffer);
    --outFDbuffer(48) = interrupt Sig FD;
    --outFDbuffer(47 downto 32) = pcAfterAdditionFetch;
    --outFDbuffer(31 downto 0) = instructions Fetch output;
    --outFDbuffer(31 downto 16) is the immediate
    --outFDbuffer(15 downto 0) is instruction 1 where [15:11] is the opcode and [10:8] is dest address and [7:5] is source 1 address and [4:2] is source 2 address and [1:0] is the function code
    ----------------------------------------------------------------------------------------------------------------------------
    --Decode stage:

    --inputs of decode stage 
    --instructions : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -> outFDbuffer(31 downto 0)
    --isImmediate, isInterrupt : OUT STD_LOGIC;-> outFDbuffer(0) and outFDbuffer(1)

    decodeStage : ENTITY work.decodeStage PORT MAP(clk, rst, writeBackEnable, writeRegisterAddress, writeBackData, outFDbuffer(31 DOWNTO 0)
        , disImmediate, disInterrupt, dWriteEnable, dMemWrite, dMemRead, dMemToReg, dOutPortEnable, dInPortEnable, dSPSignal
        , dJumpType, dPcSrc, dStackOP, dCarrySig, dCallSignal, dRETsignal, dRTIsignal, dOperation, dReadData1, dReadData2);

    --DE buffer:
    --bubbling signal is an output of the hazard detection unit
    -- in DE BUFFER: interrupt , all CTRL signals (22 bits), 
    --Read Data 1 (16 bits), Read Data 2 (16 bits), Immediate (16 bits), 
    --Rdest (3 bits) , Rsrc1 (3 bits), Rsrc2 (3 bits)
    --PC after addition (16 bits)

    inDEbuffer <= outFDbuffer(48) & disImmediate & dwriteEnable & dmemWrite & dmemRead & dmemToReg & doutPortEnable & dinPortEnable
        & dSPSignal & djumpType & dpcSrc & dstackOP & dcarrySig & dcallSignal & dRETsignal & dRTIsignal & doperation
        & dReadData1 & dReadData2 & outFDbuffer(31 DOWNTO 16) & outFDbuffer(10 DOWNTO 2) & outFDbuffer(47 DOWNTO 32);

    DEbufferEnable <= NOT bubblingSignal;
    DErst <= ((RETSignalMM OR RTISignalMM) AND NOT outDEbuffer(89)) OR rst;
    DEbuffer : ENTITY work.buff GENERIC MAP(97) PORT MAP(inDEbuffer, clk, DErst, DEbufferEnable, outDEbuffer);

    --outDEbuffer[96] is interrupt signal
    --outDEbuffer[95] is immediate signal
    --outDEbuffer[94:73] is the control signals
    --outDEbuffer[72:57] is the read data 1
    --outDEbuffer[56:41] is the read data 2
    --outDEbuffer[40:25] is the immediate
    --outDEbuffer[24:22] is the destination register
    --outDEbuffer[21:19] is the source 1 register
    --outDEbuffer[18:16] is the source 2 register
    --outDEbuffer[15:0] is the pc after addition

    --====================Control Signal Details===========================-

    --outDEbuffer[94] is write enable
    --outDEbuffer[93] is memory write
    --outDEbuffer[92] is memory read
    --outDEbuffer[91] is memory to register
    --outDEbuffer[90] is out port enable
    --outDEbuffer[89] is in port enable
    --outDEbuffer[88] is stack pointer signal
    --outDEbuffer[87:86] is jump type
    --outDEbuffer[85:84] is pc source
    --outDEbuffer[83:81] is stack operation
    --outDEbuffer[80:79] is carry signal
    --outDEbuffer[78] is call signal
    --outDEbuffer[77] is return signal
    --outDEbuffer[76] is RTI signal
    --outDEbuffer[75:73] is operation
    --=====================================================================-

    excutionStage : ENTITY work.executionStage PORT MAP(clk, rst, outDEbuffer(72 DOWNTO 57), outDEbuffer(56 DOWNTO 41),
        inputPort, EM_OP, MM_OP, MWB_OP, outDEbuffer(40 DOWNTO 25), S1_FU, S2_FU, S3_FU, outDEbuffer(95),
        outDEbuffer(89), outDEbuffer(75 DOWNTO 73), outDEbuffer(87 DOWNTO 86), outDEbuffer(15 DOWNTO 0),
        outDEbuffer(76), flagFromWB, outDEbuffer(80 DOWNTO 79), RET_EM_buffer, RET_M1M2_buffer, aluOut,
        carryOutFlag, zeroFlag, negativeFlag, PCoutput, branchTrueFlagOutput, RSCR2Address, RSCR1Output

        );

END processorArch;