library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
port(
--input is the OP code only
opCode: in std_logic_vector(4 downto 0);
isInterrupt: in std_logic;

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
--NOT   00011  not, enables writeEnable and operation is 110
--DEC   00101  enables writeEnable and operation is 011
--MOV   00111  enables writeEnable and operation is 000
--ADD   01000  enables writeEnable and operation is 001
--SUB   01001  enables writeEnable and operation is 010
--OR    01011  enables writeEnable and operation is 100
--LDD   10011  enables writeEnable andmemRead and  memToReg
--IADD  11000  enables writeEnable and operation is 001
--LDM   11001  enables writeEnable and operation is 000
--pop   01111  enables stackOP and writeEnable, SPsignal, memRead, memtoreg and operation is 000

--SETC  00001  setcarry flag
--CLRC  00010  clear carry flag
--STD   10100  enables memWrite
--OUT   01101  enables outPortEnable
--push  01110  enables stackOP and MemWrite, SPsignal and operation is 000
--CALL  10000  enables memWrite SPsignal, PCsrc, StackOP, call signal and operation is 000
--RET   10001  enables MemRead,SPsignal, PCsrc, StackOP, return signal and operation is 000
--RTI   10010  enables MemRead,SPsignal, PCsrc, StackOP, rti signal and operation is 000
--JZ    10101  enables PCsrc, jumpType and operation is 000
--JC    10110  enables PCsrc, jumpType and operation is 000
--JMP   10111  enables PCsrc, jumpType and operation is 000
operation<="000" when opCode="00000" else
"111" when opCode="00100" else --increament
"101" when opCode="01010" else --and
"110" when opCode="00011" else --not
"011" when opCode="00101" else --dec
"001" when opCode="01000" or opCode="11000" else --add
"010" when opCode="01001" else --sub
"100" when opCode="01011" else --or
"000";



--NOP or Branching or Stalling w keda lesa phase 2
writeEnable<='0' when opCode="00000" or  opCode="10100" or  opCode="00001" or opCode="00010" or  opCode="01101" or  opCode="01110" or  opCode="10000" or  opCode="10001" or  opCode="10010" or  opCode="10101" or  opCode="10110" or  opCode="10111" else
'1';

memRead<='1' when opCode="10011" or  opCode="10001" or  opCode="10010"  or opCode="01111" else

'0';

memToReg<='1' when opCode="10011" or opCode="01111" else
'0';

memWrite<='1' when opCode="10100" or opCode="01110" or opCode="10000" or isInterrupt='1' else
'0';

outPortEnable<='1' when opCode="01101" else
'0';

inPortEnable<='1' when opCode="01100" else
'0';

SPSignal<='1' when opCode="01111" or opCode="01110" or opCode="10000" or opCode="10001" or opCode="10010" or isInterrupt='1' else
'0';

jumpType<="01" when opCode="10111" else
"10" when opCode="10101" else
"11" when opCode="10110" else
"00";

--1 conditional jmp
--2 unconditional jmp
--3 ret rti

--JZ    10101  enables PCsrc, jumpType and operation is 000
--JC    10110  enables PCsrc, jumpType and operation is 000
--JMP   10111  enables PCsrc, jumpType and operation is 000
--CALL  10000  enables SPsignal, PCsrc, StackOP, call signal and operation is 000
--RET   10001  enables SPsignal, PCsrc, StackOP, return signal and operation is 000
--RTI   10010  enables SPsignal, PCsrc, StackOP, rti signal and operation is 000

pcSrc<="01" when opCode="10110" or opCode="10101" else
"10" when opCode="10111" or opCode="10000" else
"11" when opCode="10001" or opCode="10010" else
"00";

stackOP<="011" when isInterrupt='1' else
"001" when opCode="01110" else
"010" when opCode="10000" else
"100" when opCode="01111" else
"101" when opCode="10001" else
"111" when opCode="10010" else
"000";

carrySig<="01" when opCode="00001" else
"10" when opCode="00010" else
"00";

callSignal<='1' when opCode="10000" else
'0';


RETsignal<='1' when opCode="10001" else
'0';

RTIsignal<='1' when opCode="10010" else
'0';




end myctrl;
