
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;




entity ALU is
    Port ( a : in  std_logic_vector (31 downto 0);
           b : in  std_logic_vector (31 downto 0);
           control : in  std_logic_vector (2 downto 0);
           result : out std_logic_vector (31 downto 0);
           zero : out std_logic);           
end ALU;

architecture PRACTICA of ALU is
	
	signal r: std_logic_vector(31 downto 0);
	
begin

process (a, b, control)
begin
    case control is 
    
        when "000" => -- A and B 
            
            r <= (a And b);
            
        when "001" => -- A or B 
        
            r <= (a Or b);
        
        when "010" => -- A + B
        
            r <= (a + b); 
        
        when "110" => -- A – B 
         
            r <= (a - b);
         
        when "111" => -- A < B
        
            if (a < b) then
                r <= x"00000001"; 
            else 
                r <= x"00000000"; 
            end if;
        
        when "100" => -- B << 16 (logico) 
        
            r <= b(15 downto 0) & "0000000000000000";
        
        when others => -- 0
        
            r <= x"00000000";
          
    end case;
  
end process;

result <= r;

zero <= '1' when r = x"00000000";
zero <= '0' when r /= x"00000000";

end PRACTICA;