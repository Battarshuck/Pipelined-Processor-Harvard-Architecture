LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY select_adder IS
    generic (n: integer := 8);
	PORT (a,b : IN  std_logic_vector(n-1 downto 0);
          cin : in std_logic;
		  s : out std_logic_vector(n-1 downto 0);
           cout : OUT std_logic );
END select_adder;

ARCHITECTURE a_my_adder OF select_adder IS
component  my_nadder IS
generic (n: integer := 8);
PORT (a,b : IN  std_logic_vector(n-1 downto 0);
      cin : in std_logic;
      s : out std_logic_vector(n-1 downto 0);
       cout : OUT std_logic );
END component;

    signal S0,S1 : std_logic_vector( n-1 downto 0);
    signal cout0,cout1:std_logic;
	BEGIN
		
	
        f0:my_nadder generic map(n) port map(a,b,'0',s0,cout0);
        f1:my_nadder generic map(n) port map(a,b,'1',s1,cout1);

        s <= s0 when cin ='0' else s1;
        cout <= cout0 when cin = '0' else cout1;

END a_my_adder;