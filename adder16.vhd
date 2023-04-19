LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY adder16 IS
	PORT (a,b : IN  std_logic_vector(15 downto 0);
          cin : in std_logic;
		  s : out std_logic_vector(15 downto 0);
           cout : OUT std_logic );
END adder16;

ARCHITECTURE archAdder16 OF adder16 IS
component  my_nadder IS
generic (n: integer := 8);
PORT (a,b : IN  std_logic_vector(n-1 downto 0);
      cin : in std_logic;
      s : out std_logic_vector(n-1 downto 0);
       cout : OUT std_logic );
END component;

component select_adder IS
    generic (n: integer := 8);
	PORT (a,b : IN  std_logic_vector(n-1 downto 0);
          cin : in std_logic;
		  s : out std_logic_vector(n-1 downto 0);
           cout : OUT std_logic );
END component;



    signal s0,s1,s2, s3 : std_logic_vector( 3 downto 0);
    signal cout0,cout1, cout2, cout3:std_logic;
	BEGIN
		
	
        f0:my_nadder generic map(4) port map(a(3 downto 0),b(3 downto 0),cin,s0,cout0);
	f1:select_adder generic map(4) port map(a(7 downto 4), b(7 downto 4), cout0, s1, cout1);
	f2:select_adder generic map(4) port map(a(11 downto 8), b(11 downto 8), cout1, s2, cout2);
	f3:select_adder generic map(4) port map(a(15 downto 12), b(15 downto 12), cout2, s3, cout3);
        
	cout <= cout3;
	s <= s3 & s2 & s1 & s0;

END archAdder16;