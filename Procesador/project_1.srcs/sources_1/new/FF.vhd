
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity FF is
    Port ( clk, reset: in  std_logic;
           d : in  std_logic;
           q : out std_logic);
end FF;

architecture Behavioral of FF is

	
begin

 process (clk, reset)
    begin
		if (reset = '1') then 
		    q <= '0';
		else
			if (rising_edge(clk)) then 
				q <= d;
			end if;	
		end if;
	end process;
	
end Behavioral;
