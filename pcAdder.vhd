LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pcAdder IS
    PORT (
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        addingChoice : IN STD_LOGIC;
        newAddress : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END pcAdder;

ARCHITECTURE pcAdderArch OF pcAdder IS

    SIGNAL temp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL resultSum1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL resultSum2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL one : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL cin : STD_LOGIC;
    SIGNAL two : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    f0 : entity work.nadder GENERIC MAP(16) PORT MAP(address, one, cin, resultSum1, temp(0));
    f1 : entity work.nadder GENERIC MAP(16) PORT MAP(address, two, cin, resultSum2, temp(1));
   

    one <= "0000000000000001";
    two <= "0000000000000010";
    cin <= '0';

    newAddress <= resultSum1 WHEN addingChoice = '0' ELSE
        resultSum2;
END pcAdderArch;