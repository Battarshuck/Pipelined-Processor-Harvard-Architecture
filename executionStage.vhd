LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY executionStage IS
    PORT (
        Op1,Op2,inPort : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EM_OP,MM_OP,MWB_OP,immediateOP: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        S1_FU,S2_FU : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        isImmediate : IN STD_LOGIC;
        inPortEnable : IN STD_LOGIC;
        aluOp : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        aluOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        carryOutFlag,zeroFlag,negativeFlag : OUT STD_LOGIC        
    );
END ENTITY executionStage;


ARCHITECTURE executionStageArch OF executionStage IS
    signal firstOperand,secondOperand,Op2Temp,aluOutTemp : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

    ALU : entity work.alu port map(firstOperand,secondOperand,aluOp,aluOutTemp,carryOutFlag,zeroFlag,negativeFlag);
    --Selecting the first operand
    firstOperand <= Op1 when S1_FU = "00" else
                    EM_OP when S1_FU = "01" else
                    MM_OP when S1_FU = "10" else
                    MWB_OP when S1_FU = "11" else (OTHERS => '0');
    --Selecting if the second operand is immediate or not
    Op2Temp <= Op2 when isImmediate = '0' else
                immediateOP;
    --Selecting the second operand
    secondOperand <= Op2Temp when S2_FU = "00" else
                    EM_OP when S2_FU = "01" else
                    MM_OP when S2_FU = "10" else
                    MWB_OP when S2_FU = "11" else (OTHERS => '0');
    --Outputing the alu output
    aluOut <= aluOutTemp when inPortEnable = '0' else
                    inPort;

END executionStageArch;
