
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity registers is
    Port ( 
           reg1_rd, reg2_rd, reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           wr, clk, reset : in STD_LOGIC;
           data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           data2_rd : out STD_LOGIC_VECTOR (31 downto 0)
          );
end registers;

architecture PRACTICA of registers is
	type mem is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    signal regs: mem;
begin


-- process de escritura
process (clk, reset) 
begin
    if (reset = '1') then 
        regs <= (others => (others => '0'));  
    elsif (falling_edge(clk)) then 
        if (wr = '1') then
            if (reg_wr /= "00000") then 
                regs (CONV_INTEGER(reg_wr)) <= data_wr; 
            end if;    
        end if;
    end if;
    
end process;


-- process de lectura
process (reg1_rd)
begin
    if (reg1_rd /= "00000") then 
        data1_rd <= regs (CONV_INTEGER(reg1_rd));
    else 
        data1_rd <= x"00000000";
    end if;
end process;



-- process de lectura
process (reg2_rd)
begin
    if (reg2_rd /= "00000") then 
        data2_rd <= regs (CONV_INTEGER(reg2_rd));
    else 
        data2_rd <= x"00000000";
    end if;
end process;


end PRACTICA;