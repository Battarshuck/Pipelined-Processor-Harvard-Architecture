LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
--this file is the forwarding unit

-- -- not done phase 2

ENTITY pcHandler IS
    PORT (

        pcSrcDEBuff, pcSrcM1M2Buff : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        interruptSigFD, interruptSigDE, RTISigM1M2 : IN STD_LOGIC;
        pcSrcOut : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY pcHandler;

ARCHITECTURE pcHandlerArch OF pcHandler IS
BEGIN

    pcSrcOut <= "00" WHEN ((interruptSigFD = '1') OR (interruptSigDE = '1')) ELSE
        pcSrcM1M2Buff WHEN (RTISigM1M2 = '1') ELSE
        pcSrcDEBuff;

END pcHandlerArch;