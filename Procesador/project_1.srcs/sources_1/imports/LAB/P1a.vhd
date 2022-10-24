-- Realizado por Martín Vázquez. 1/4/2010

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity reg is
    Port ( clk, reset: in  std_logic;
           d : in  std_logic_vector (31 downto 0);
           q : out std_logic_vector (31 downto 0));
end reg;

architecture Behavioral of reg is

	
begin

 -- registro con reset asincrono 	
	process (clk, reset) 
    begin
		if (reset = '1') then 
		    q <= (others => '0');
		else
			if (rising_edge(clk)) then 
				q <= d;
			end if;	
		end if;
	end process;
	
end Behavioral;

