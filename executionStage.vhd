LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY executionStage IS
    PORT (
        clk,rst : IN STD_LOGIC;
        Op1,Op2,inPort : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EM_OP,MM_OP,MWB_OP,immediateOP: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        S1_FU,S2_FU,S3_FU : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        isImmediate : IN STD_LOGIC;
        inPortEnable : IN STD_LOGIC;
        aluOp : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        jumpTypeSignal : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        PCincremented : IN STD_LOGIC_vector(15 DOWNTO 0);
        RTISignal : IN STD_LOGIC;
        flagFromWB : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        setOrClearFlag : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        RET_EM_buffer, RET_M1M2_buffer : IN STD_LOGIC;        
        aluOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        carryOutFlag,zeroFlag,negativeFlag : OUT STD_LOGIC;
        PCoutput : OUT STD_LOGIC_vector(15 DOWNTO 0);
        branchTrueFlagOutput : OUT STD_LOGIC;
        RSCR2Address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RSCR1Output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY executionStage;


ARCHITECTURE executionStageArch OF executionStage IS
    signal branchTrueFlag, flagEnable,tempCarryOutFlag, tempZeroOutFlag, tempNegativeOutFlag, isRET : STD_LOGIC;
    signal firstOperand,secondOperand,Op2Temp,aluOutTemp, RSCR2AddressTemp: STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal flagIn, flagOutput, tempFlagIn : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

    ALU : entity work.alu port map(firstOperand, secondOperand, aluOp, aluOutTemp, tempCarryOutFlag, tempZeroOutFlag, tempNegativeOutFlag);
    flagRegister : ENTITY work.flagRegister PORT MAP(clk, rst, flagEnable, setOrClearFlag, flagIn, flagOutput);

    --=====================FLAG REGISTER=====================
    --if the RTI signal is 1, then the flag is set to the flag from the write back stage because it pops the flag from the stack
    --if the RTI signal is 0, then the flag is set to the flag from the ALU unit
    tempFlagIn <= tempCarryOutFlag & tempZeroOutFlag & tempNegativeOutFlag;
    flagIn <= tempFlagIn when RTISignal = '0' else
             flagFromWB;

    --flagEnable is '1' if and only if either the RTI signal is 1 or an instruction uses the ALU unit
    --alu operation here are ADD, INC, SUB, DEC, OR, AND, and NOT respectively, and SETC, CLRC
    flagEnable <= '1' when RTISignal = '1' or (isRET ='0' and (aluOp ="001" or aluOp="111" or aluOp="010" or aluOp="011" or aluOp="100" or aluOp="101" or aluOp="110" or  setOrClearFlag /= "00"))  else
                  '0';

    --isRET check if there is RET instruction in memory1 and memory2 stages
    --if so, then the flag cannot be changed by next ALU instruction
    isRET <= '1' WHEN RET_EM_buffer = '1' or RET_M1M2_buffer = '1' else
              '0';

    --=====================ASSIGNING FLAG OUTPUT=====================
    carryOutFlag <= flagOutput(2);  --third bit is the carry flag
    zeroFlag <= flagOutput(1);      --second bit is the zero flag
    negativeFlag <= flagOutput(0);  --first bit is the negative flag


    --=====================ALU INPUT=====================
    --Selecting the first operand
    firstOperand <= Op1 when S1_FU = "00" else
                    EM_OP when S1_FU = "01" else
                    MM_OP when S1_FU = "10" else
                    MWB_OP when S1_FU = "11" else 
                    (OTHERS => '0');
    --Selecting if the second operand is immediate or not
    Op2Temp <= Op2 when isImmediate = '0' else
                immediateOP;
    --Selecting the second operand
    secondOperand <= Op2Temp when S2_FU = "00" else
                    EM_OP when S2_FU = "01" else
                    MM_OP when S2_FU = "10" else
                    MWB_OP when S2_FU = "11" else 
                    (OTHERS => '0');
    --Outputing the alu output
    aluOut <= aluOutTemp when inPortEnable = '0' else
                    inPort;

    --=====================IF RSRC2 IS AN ADDRESS===========================
    RSCR2Address <= RSCR2AddressTemp;
    RSCR2AddressTemp <= Op2 when S3_FU = "00" else
                        EM_OP when S3_FU = "01" else
                        MM_OP when S3_FU = "10" else
                        MWB_OP when S3_FU = "11" else 
                        (OTHERS => '0');

    --=====================PC OUTPUT TO THE NEXT BUFFER===================== 
    --Outputing the incremented PC
    PCoutput <= PCincremented when branchTrueFlag = '0' else --decding which PC should be outputed to the next buffer
                firstOperand;


    --=====================BRANCHING=====================
    branchTrueFlagOutput <= branchTrueFlag; --this is the output signal going to the fetch stage, where is the PC changed

    branchTrueFlag <= '0' WHEN jumpTypeSignal = "00" else -- this is the ouput from the branching unit
                      '1' WHEN jumpTypeSignal = "01" else
                      flagOutput(1) when jumpTypeSignal = "10" else --jmpzero
                      flagOutput(2); --jmpcarry

    --this is used back at the fetch stage for the PC
    RSCR1Output <= firstOperand;

END executionStageArch;
