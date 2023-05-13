LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
ENTITY memory IS
PORT (
    clk, reset, MemWrite, MemRead, InterruptSignal, RTISignal: IN std_logic;
    WriteData: in std_logic_vector(15 downto 0);--data in 
    Address: in std_logic_vector(15 downto 0); --use the first 10 bits only
    FlagRegister: in std_logic_vector(2 downto 0); --use the first 3 bits only
    ReadData: out std_logic_vector(15 downto 0);--data out
    ReadFlags: out std_logic_vector(15 downto 0)--flags out 
);
END ENTITY memory;

ARCHITECTURE myRAM OF memory IS
    TYPE ram_type IS ARRAY(0 TO 1023) of std_logic_vector(15 DOWNTO 0);
    
BEGIN
PROCESS(clk, reset, MemWrite, MemRead, Address) IS
VARIABLE ram : ram_type ;
BEGIN
    IF reset = '1' THEN
    for u in ram' range loop                 
        ram(u) := (others=>'0');
    end loop;
    elsif rising_edge(clk) and MemWrite = '1' THEN	
        if InterruptSignal = '1' then
            ram(to_integer(unsigned((Address(9 downto 0))))-1) := "0000000000000" & FlagRegister;
        end if;
        ram(to_integer(unsigned((Address(9 downto 0))))) := WriteData;
    END IF;

    IF  MemRead = '1' then --falling_edge(clk) and
        if RTISignal = '1' then
            ReadFlags <= ram(to_integer(unsigned((Address(9 downto 0))))-1);
        end if;
        ReadData <= ram(to_integer(unsigned((Address(9 downto 0)))));
    END IF;

END PROCESS;
    --Q <= ram(to_integer(unsigned((readAddr))));
END myRAM;