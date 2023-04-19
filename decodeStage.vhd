LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY decodeStage IS
    PORT (

        clk, rst, writeBackEnable : IN STD_LOGIC;
        writeRegisterAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        writeBackData : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        instructions : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        writeEnable, memWrite, memRead, memToReg, inPortEnable, isImmediate : OUT STD_LOGIC;
        pcSrc : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        operation : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        readData1, readData2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

        --outPortEnable, SPSignal, isImmediate, BranchTrue: out std_logic;
        --jumpType: out std_logic_vector (1 downto 0);
        --stackOP:  out std_logic_vector (2 downto 0);
    );
END ENTITY decodeStage;
ARCHITECTURE decodeStageArch OF decodeStage IS
    Signal data1, data2: STD_LOGIC_VECTOR(15 DOWNTO 0);
    Signal dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable : STD_LOGIC;
    Signal dpcSrc : STD_LOGIC_VECTOR (1 DOWNTO 0);
    Signal doperation : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

    controller : ENTITY work.controller PORT MAP(instructions(15 DOWNTO 11), dwriteEnable, dmemWrite
        , dmemRead, dmemToReg, dinPortEnable, dpcSrc, doperation);

    RegisterFile : ENTITY work.RegisterFile PORT MAP(clk, rst, writeBackEnable, instructions(7 DOWNTO 5),
        instructions(4 DOWNTO 2), writeBackData, writeRegisterAddress, data1, data2);

    isImmediate <= instructions(0);
    readData1<=data1;
    readData2<=data2;
    writeEnable<=dwriteEnable;
    memWrite<=dmemWrite;
    memRead<=dmemRead;
    memToReg<=dmemToReg;
    inPortEnable<=dinPortEnable;
    pcSrc<=dpcSrc;
    operation<=doperation;
END decodeStageArch;