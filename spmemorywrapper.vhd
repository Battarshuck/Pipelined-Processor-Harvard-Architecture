
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY spmemorywrapper IS
	PORT ( clk, reset, MemWriteControl, MemReadControl, InterruptSignal, RTISignal : IN std_logic;
        data_in : IN std_logic_vector(15 downto 0);
        flag : IN std_logic_vector(2 downto 0);
        operation : IN std_logic_vector(2 downto 0);
        data_out : OUT std_logic_vector(15 downto 0);
        flagout : OUT std_logic_vector(15 downto 0));
END ENTITY spmemorywrapper;

ARCHITECTURE archspmemorywrapper OF spmemorywrapper IS 
signal outBuffer, temp :  std_logic_vector(22 downto 0);
signal sp, memoryOut, flagOutsig :  std_logic_vector(15 downto 0);
BEGIN
    FDbuffer : ENTITY work.buff GENERIC MAP(23) PORT MAP(temp, clk, reset, '1', outBuffer);
    dataMemory : entity work.memory PORT MAP(clk, reset,  outBuffer(20), outBuffer(19), outBuffer(22), outBuffer(21), outBuffer(15 downto 0), sp, flag, memoryOut, flagOutsig);

    stackRegister: entity work.stackregister PORT MAP(clk, reset, outBuffer(18 downto 16),sp);

    temp <= InterruptSignal & RTISignal &MemWriteControl & MemReadControl & operation & data_in;
    data_out <= memoryOut;
    flagout <= flagOutsig;

END archspmemorywrapper;