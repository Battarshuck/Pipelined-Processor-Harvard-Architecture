library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
port(
opCode: in std_logic_vector(4 downto 0);
writeEnable: out std_logic;
memWrite: out std_logic;
memRead: out std_logic;
memToReg: out std_logic;
--outPortEnable: out std_logic;
--SPSignal: out std_logic;
inPortEnable: out std_logic;
--jumpType: out std_logic_vector (1 downto 0);
pcSrc: out std_logic_vector (1 downto 0);
--stackOP:  out std_logic_vector (2 downto 0);
--BranchTrue: out std_logic;
--return signal: out std_logic;
operation: out std_logic_vector(2 downto 0)

);
end entity;

architecture myctrl of controller is
begin
--Now we will write the control signals for the ALU
--We will use the opCode to determine the control signals
--The opCode is 5 bits long
--we will implement the following instructions
--nop, INC, AND, IN, LDD, STD
--The opCode for each instruction is as follows
--NOP   00000 enables nothing and operation is 0000.
--INC	00100 enables writeEnable and operation.
--AND	01010 enables writeEnable and operation.
--IN	01100 enables inPortEnable and writeEnable.
--LDD	10011  Load enables memRead and memToReg to 1.
--STD   10100  Store enables memWrite.

operation<="000" when opCode="00000" else
"111" when opCode="00100" else --increament
"101" when opCode="01010" else --and
"000";

--NOP or Branching or Stalling w keda lesa phase 2
writeEnable<='0' when opCode="00000" or  opCode="10100"  else
'1';

memRead<='1' when opCode="10011" else
'0';

memToReg<='1' when opCode="10011" else
'0';

memWrite<='1' when opCode="10100" else
'0';

inPortEnable<='1' when opCode="01100" else
'0';

pcSrc<="00";

end myctrl;
