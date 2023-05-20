LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY decodeStage IS
    PORT (

        clk, rst, writeBackEnable : IN STD_LOGIC;
        writeRegisterAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        writeBackData : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        instructions : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        isImmediate, isInterrupt : OUT STD_LOGIC;
        
        writeEnable: out std_logic;
        memWrite: out std_logic;
        memRead: out std_logic;
        memToReg: out std_logic;

        outPortEnable: out std_logic;
        inPortEnable: out std_logic;

        SPSignal: out std_logic;
        jumpType: out std_logic_vector (1 downto 0);
        pcSrc: out std_logic_vector (1 downto 0);
        stackOP:  out std_logic_vector (2 downto 0);

        carrySig: out std_logic_vector(1 downto 0);

        callSignal: out std_logic;
        RETsignal: out std_logic;
        RTIsignal: out std_logic;

        operation: out std_logic_vector(2 downto 0);
        readData1, readData2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)


    );
END ENTITY decodeStage;
ARCHITECTURE decodeStageArch OF decodeStage IS
    Signal data1, data2: STD_LOGIC_VECTOR(15 DOWNTO 0);
    Signal dwriteEnable, dmemWrite, dmemRead, dmemToReg, dinPortEnable, doutPortEnable, dSPSignal,dcallSignal,dRETsignal,dRTIsignal  : STD_LOGIC;
    Signal dpcSrc,djumpType,dcarrySig : STD_LOGIC_VECTOR (1 DOWNTO 0);
    Signal dstackOP : STD_LOGIC_VECTOR (2 DOWNTO 0);
    Signal doperation : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN


    

    controller : ENTITY work.controller PORT MAP(instructions(15 DOWNTO 11), dwriteEnable, dmemWrite
        , dmemRead, dmemToReg, doutPortEnable, dinPortEnable, dSPSignal, djumpType, dpcSrc, dstackOP
        , dcarrySig, dcallSignal, dRETsignal, dRTIsignal, doperation);

    RegisterFile : ENTITY work.RegisterFile PORT MAP(clk, rst, writeBackEnable, instructions(7 DOWNTO 5),
        instructions(4 DOWNTO 2), writeBackData, writeRegisterAddress, data1, data2);

    isImmediate <= instructions(0);
    isInterrupt <= instructions(1);
    readData1<=data1;
    readData2<=data2;
    writeEnable<=dwriteEnable;
    memWrite<=dmemWrite;
    memRead<=dmemRead;
    memToReg<=dmemToReg;
    inPortEnable<=dinPortEnable;
    outPortEnable<=doutPortEnable;
    SPSignal<=dSPSignal;
    jumpType<=djumpType;
    stackOP<=dstackOP;
    pcSrc<=dpcSrc;
    carrySig<=dcarrySig;
    callSignal<=dcallSignal;
    RETsignal<=dRETsignal;
    RTIsignal<=dRTIsignal;
    operation<=doperation;
END decodeStageArch;