library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


ENTITY ALU_TB_vhd IS
END ALU_TB_vhd;

ARCHITECTURE PRACTICA OF ALU_TB_vhd IS 

-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ALU
	PORT( a : in  std_logic_vector (31 downto 0);
           b : in  std_logic_vector (31 downto 0);
           control : in  std_logic_vector (2 downto 0);
           result : out std_logic_vector (31 downto 0);
           zero : out std_logic);
	END COMPONENT;
	
	--Inputs
	SIGNAL a :  std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL b :  std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL control :  std_logic_vector(2 downto 0) := (others=>'0');
	
	--Outputs
	SIGNAL result :  std_logic_vector(31 downto 0);
	SIGNAL zero :  std_logic;
	
	BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: ALU PORT MAP(
		a => a,
		b => b,
		control => control,
		result => result,
		zero => zero
	);


-- Testbench propiamente dicho
	process begin
		a <= x"00000001";
		b <= x"00000000";	
		control <= "010";
		

		wait; 
	end process;
	

END PRACTICA;
