LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- 000 f=a b=0 ----> NOP
-- ------------------------
-- 001 f=a+b --> ADD
-- 111 f=a+1 cin=1 b =1--> INC
-- -------------------------
-- 010 f= a-b cin = 1 -> SUB
-- 011 f=a-b cin = 1, b=1 --> DEC
-- --------------------------
-- 100 f=a or b --> OR
-- 101 f = a and b --> AND
-- 110 f = not a ---> NOT
-- ---------------------------

ENTITY alu IS
    PORT (
        firstOperand, secondOperand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        selector : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        aluOutput : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        carryOutFlag, zeroFlag, negativeFlag : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE aluArch OF alu IS

    SIGNAL secondOperandSelected, resultSum, currentOutput : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL cin, cout : STD_LOGIC;
BEGIN

    nadder : ENTITY work.nadder GENERIC MAP(16) PORT MAP(firstOperand, secondOperandSelected, cin, resultSum, cout);

    secondOperandSelected <= x"0000" WHEN selector = "000" ELSE
        x"0001" WHEN selector = "111" ELSE
        x"FFFE" WHEN selector = "011" ELSE
        not secondOperand WHEN selector = "010" ELSE
        secondOperand;

    cin <= '1' WHEN selector = "010" OR selector = "011" ELSE
        '0';

    currentOutput <= firstOperand AND secondOperand WHEN selector = "101" ELSE
        firstOperand OR secondOperand WHEN selector = "100" ELSE
        NOT firstOperand WHEN selector = "110" ELSE
        resultSum;

    aluOutput <= currentOutput;
    carryOutFlag <= '0' WHEN selector = "101" OR selector = "100" OR selector = "110" ELSE
        cout;

    negativeFlag <= currentOutput(15);
    
    zeroFlag <= '1' WHEN currentOutput = x"0000" ELSE
        '0';

END aluArch;