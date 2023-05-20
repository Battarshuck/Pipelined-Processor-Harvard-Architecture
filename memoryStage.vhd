LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memoryStage IS
    PORT (
        clk, rst, MemWriteControl, MemReadControl, CallSignalControl, SPSignalControl : IN std_logic;
        PCAfterAddition, dataFromALU: in std_logic_vector(15 downto 0);--data in
        Rsrc2Address, SPAddress: in std_logic_vector(15 downto 0);
        ReadData: out std_logic_vector(15 downto 0);--data out
        --interrupt signal and return from interrupt signals, normal Return signal, and a bit that tells if the current instruction is valid or not (aka. flushed)
        InterruptSignal, RTISignal, RETSignal, validInstructionSignal : in std_logic; 
        flagIn: in std_logic_vector(2 downto 0); --flag values
        ReadFlag: out std_logic_vector(15 downto 0) --flag values output from the memory
        ); 
END ENTITY memoryStage;


ARCHITECTURE memoryStageArch OF memoryStage IS   
    SIGNAL writeData, Address, memoryOut, flagOut, validPCbuffInput, validPCbuffOutput : std_logic_vector(15 downto 0);
BEGIN
    
    dataMemory : entity work.memory PORT MAP(clk, rst, MemWriteControl, MemReadControl, InterruptSignal, writeData, Address, flagIn, memoryOut, flagOut);
    ValidPCBuffer : ENTITY work.buff GENERIC MAP(16) PORT MAP(validPCbuffInput, clk, rst, validInstructionSignal, validPCbuffOutput);


    --if call signal is 1, that means we want to push the PC to the stack
    writeData <= dataFromALU WHEN CallSignalControl = '0' ELSE
                PCAfterAddition;

    --if SPsignal is 1, that means we want to use the stack pointer as the address, so we assign the memory address to be the stack pointer
    Address <= Rsrc2Address WHEN SPSignalControl = '0' ELSE
                SPAddress;


    --assigning the output values
    ReadData <= memoryOut; 
    ReadFlag <= flagOut;

    --=================================VALID PC BUFFER===================================

    --if the the instruction is normal RET, then the flag value is written on the memoryOut signal
    --if the RTI signal is '1', then the flag value in the memory is written on the flagOut signal 
    --else the last valid PC value is on the PCAfterAddition signal
    validPCbuffInput <= memoryOut when RETSignal = '1' else
                        flagOut when RTISignal = '1' else
                        PCAfterAddition;

END memoryStageArch;

