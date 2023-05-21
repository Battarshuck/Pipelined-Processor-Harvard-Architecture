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
    SIGNAL ealuOut : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ecarryOutFlag, ezeroFlag, enegativeFlag : STD_LOGIC := '0';
    SIGNAL ePCoutput : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ebranchTrueFlagOutput : STD_LOGIC := '0';
    SIGNAL eRSCR2Address, eRSCR1Output : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    --EM buffer signals:
    SIGNAL inEMbuffer : STD_LOGIC_VECTOR(76 DOWNTO 0);
    SIGNAL EMbufferEnable : STD_LOGIC;
    SIGNAL EMrst : STD_LOGIC;
    SIGNAL outEMbuffer : STD_LOGIC_VECTOR(76 DOWNTO 0);
    --Stack register signals:
    SIGNAL stackPointerOutput : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"03FE";
    --M1M2 buffer signals:
    SIGNAL inM1M2buffer : STD_LOGIC_VECTOR(76 DOWNTO 0);
    SIGNAL M1M2bufferEnable : STD_LOGIC;
    SIGNAL M1M2rst : STD_LOGIC := '1';
    SIGNAL outM1M2buffer : STD_LOGIC_VECTOR(76 DOWNTO 0);
    SIGNAL validInstructionSignal : STD_LOGIC := '0';
    SIGNAL RMemoryFlag : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');


BEGIN
    --Fetch stage:
    fetchStage : ENTITY work.fetchStage PORT MAP(clk, rst, bubblingSignal, ebranchTrueFlagOutput, outFDbuffer(48), outDEbuffer(96)
        , interrupt, RTISigM1M2, outDEbuffer(85 DOWNTO 84), pcSrcM1M2
        , eRSCR1Output, RMemoryOutput, pcAfterAdditionFetch, instructionsFetch);
    ----------------------------------------------------------------------------------------------------------------------------
    --FD buffer:
    --bubbling signal is an output of the hazard detection unit
    inFDbuffer <= interrupt & pcAfterAdditionFetch & instructionsFetch;
    rstFDbuffer <= ((ebranchTrueFlagOutput OR RETSignalMM OR RTISignalMM OR callSignalDE) AND NOT outFDbuffer(48)) OR rst;
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
    -- Execution stage:
    executionStage : ENTITY work.executionStage PORT MAP(clk, rst, outDEbuffer(72 DOWNTO 57), outDEbuffer(56 DOWNTO 41),
        inputPort, EM_OP, MM_OP, MWB_OP, outDEbuffer(40 DOWNTO 25), S1_FU, S2_FU, S3_FU, outDEbuffer(95),
        outDEbuffer(89), outDEbuffer(75 DOWNTO 73), outDEbuffer(87 DOWNTO 86), outDEbuffer(15 DOWNTO 0),
        outDEbuffer(76), flagFromWB, outDEbuffer(80 DOWNTO 79), RET_EM_buffer, RET_M1M2_buffer, ealuOut,
        ecarryOutFlag, ezeroFlag, enegativeFlag, ePCoutput, ebranchTrueFlagOutput, eRSCR2Address, eRSCR1Output
        );
    --eRSCR2Address is used for store operation
    --EM buffer:
    inEMBuffer <= outDEbuffer(96) & ealuOut & ecarryOutFlag & ezeroFlag & enegativeFlag & ePCoutput & eRSCR2Address
        & outDEbuffer(24 DOWNTO 22) & outDEbuffer(94 DOWNTO 73);

    EMbufferEnable <= NOT bubblingSignal;
    EMrst <= RETSignalMM OR RTISignalMM or bubblingSignal or rst;

    EMbuffer : ENTITY work.buff GENERIC MAP(77) PORT MAP(inEMBuffer, clk, EMrst, EMbufferEnable, outEMbuffer);

    --outEMbuffer(76) is interrupt signal
    --outEMbuffer(75 downto 60) is the ALU output
    --outEMbuffer(59) is the carry flag
    --outEMbuffer(58) is the zero flag
    --outEMbuffer(57) is the negative flag
    --outEMbuffer(56 downto 41) is the PC after addition or PC jump/call output
    --outEMbuffer(40 downto 25) is the RSCR2 address (as address of memory to be written to)
    --outEMbuffer(24 downto 22) is the destination register
    --outEMbuffer(21 downto 0) is all the control signals

    --====================Control Signal Details===========================-
    --outEMbuffer(21) is write enable
    --outEMbuffer(20) is memory write
    --outEMbuffer(19) is memory read
    --outEMbuffer(18) is memory to register
    --outEMbuffer(17) is out port enable
    --outEMbuffer(16) is in port enable
    --outEMbuffer(15) is stack pointer signal
    --outEMbuffer(14 downto 13) is jump type
    --outEMbuffer(12 downto 11) is pc source
    --outEMbuffer(10 downto 8) is stack operation
    --outEMbuffer(7 downto 6) is carry signal
    --outEMbuffer(5) is call signal
    --outEMbuffer(4) is return signal
    --outEMbuffer(3) is RTI signal
    --outEMbuffer(2 downto 0) is operation

    --=====================================================================-
    -- M1 Stage
    -- Rdst will go to Forward Unit (outEMbuffer(24 downto 22)
    inM1M2buffer <= outEMbuffer;
    M1M2bufferEnable <= '1';
    M1M2rst <= rst ; -- check
    M1M2buffer : entity work.buff GENERIC MAP(77) PORT MAP(inM1M2buffer, clk, M1M2rst, M1M2bufferEnable, outM1M2buffer);
    -- Same as EM buffer

    --=====================================================================-
    -- Stack Pointer Register
    stackRegister : entity work.StackRegister port map (clk,rst,outM1M2bufer(10 downto 8),stackPointerOutput);
    --=====================================================================-
--     ENTITY memoryStage IS
--     PORT (
--         clk, rst, MemWriteControl, MemReadControl, CallSignalControl, SPSignalControl : IN std_logic;
--         PCAfterAddition, dataFromALU: in std_logic_vector(15 downto 0);--data in
--         Rsrc2Address, SPAddress: in std_logic_vector(15 downto 0);
--         InterruptSignal, RTISignal, RETSignal, validInstructionSignal : in std_logic;  -- valid instruction signal is checked from pc added coming out from the buffer (0's)
--         flagIn: in std_logic_vector(2 downto 0); --flag values
--         ReadData: out std_logic_vector(15 downto 0);--data out
--         --interrupt signal and return from interrupt signals, normal Return signal, and a bit that tells if the current instruction is valid or not (aka. flushed)
--         ReadFlag: out std_logic_vector(15 downto 0) --flag values output from the memory
--         ); 
-- END ENTITY memoryStage;
-- Memory Stage 2
validInstructionSignal <= '0' when (outM1M2buffer(56 downto 41) = x"0000") else '1';
memoryStage : entiy work.memoryStage port map (clk,rst,outM1M2buffer(20),outM1M2buffer(19),outM1M2buffer(5),outM1M2buffer(15),outM1M2buffer(56 downto 41),outM1M2buffer(75 downto 60),outM1M2buffer(40 downto 25),stackPointerOutput,outM1M2buffer(76),outM1M2buffer(3),outM1M2buffer(4),validInstructionSignal,outM1M2buffer(59 downto 57),RMemoryOutput,RMemoryFlag);

END processorArch;
