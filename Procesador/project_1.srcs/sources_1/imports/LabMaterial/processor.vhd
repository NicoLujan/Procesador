library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 

 
    signal pc: std_logic_vector(31 downto 0);
    signal PC_in: std_logic_vector(31 downto 0);
    signal PCSrc: std_logic;
    signal add_PC: std_logic_vector(31 downto 0);
    signal IF_ID_PC_4: std_logic_vector(31 downto 0);
    signal IF_ID_inst: std_logic_vector(31 downto 0);
    signal inst: std_logic_vector(5 downto 0);
    
    -- Control
    signal RegDst: std_logic;
    signal ALUSrc: std_logic;
    signal MemtoReg: std_logic;
    signal RegWrite: std_logic;
    signal MemRead: std_logic;
    signal MemWrite: std_logic;
    signal Branch: std_logic;
    signal ALUOp2: std_logic;
    signal ALUOp1: std_logic;
    signal ALUOp0: std_logic;
    
    signal ID_EX_Ctrl_RegDst: std_logic;
    signal ID_EX_Ctrl_ALUSrc: std_logic;
    signal ID_EX_Ctrl_MemtoReg: std_logic;
    signal ID_EX_Ctrl_RegWrite: std_logic;
    signal ID_EX_Ctrl_MemRead: std_logic;
    signal ID_EX_Ctrl_MemWrite: std_logic;
    signal ID_EX_Ctrl_Branch: std_logic;
    signal ID_EX_Ctrl_ALUOp2: std_logic;
    signal ID_EX_Ctrl_ALUOp1: std_logic;
    signal ID_EX_Ctrl_ALUOp0: std_logic;
    
    signal ID_EX_PC_4: std_logic_vector(31 downto 0);
    signal ID_EX_RegA: std_logic_vector(31 downto 0);
    signal ID_EX_RegB: std_logic_vector(31 downto 0);
    signal ID_EX_DataInm: std_logic_vector(31 downto 0);
    signal ID_EX_RegD_lw: std_logic_vector(4 downto 0);
    signal ID_EX_RegD_TR: std_logic_vector(4 downto 0);
    
    -- BANCO DE REGISTROS
    signal ReadRegister1:  STD_LOGIC_VECTOR (4 downto 0);
    signal ReadRegister2:  STD_LOGIC_VECTOR (4 downto 0);
    signal WriteRegister:  STD_LOGIC_VECTOR (4 downto 0);
    signal WriteData :  STD_LOGIC_VECTOR (31 downto 0);
    signal ReadData1 :  STD_LOGIC_VECTOR (31 downto 0);
    signal ReadData2 :  STD_LOGIC_VECTOR (31 downto 0);
    
    component registers
	port(
           reg1_rd, reg2_rd, reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           wr, clk, reset : in STD_LOGIC;
           data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           data2_rd : out STD_LOGIC_VECTOR (31 downto 0)
         );
	end component;
    
    signal SignExtend_in: std_logic_vector(15 downto 0);
    signal SignExtend: std_logic_vector(31 downto 0);
    
    -- 3er etapa
    signal ShiftLeft: std_logic_vector(31 downto 0);
    signal AddShift: std_logic_vector(31 downto 0);
    
    signal CodigoR: std_logic_vector(5 downto 0);
    
    component Alu
	Port ( a : in  std_logic_vector (31 downto 0);
           b : in  std_logic_vector (31 downto 0);
           control : in  std_logic_vector (2 downto 0);
           result : out std_logic_vector (31 downto 0);
           zero : out std_logic);
	end component;
	
	signal AluResult: std_logic_vector(31 downto 0);
	signal Zero: std_logic;
	signal AluControl: std_logic_vector (2 downto 0);
	signal Mux_EX_MEM: std_logic_vector(31 downto 0);
	signal Mux_EX_MEM_2: std_logic_vector(4 downto 0);
    
    --3ra pipeline 
    signal EX_MEM_ADD: std_logic_vector(31 downto 0);
    signal EX_MEM_AluResult: std_logic_vector(31 downto 0);
    signal EX_MEM_RegB: std_logic_vector(31 downto 0);
    signal EX_MEM_MUX2: std_logic_vector(4 downto 0);
    signal EX_MEM_Ctrl_MemtoReg: std_logic;
    signal EX_MEM_Ctrl_RegWrite: std_logic;
    signal EX_MEM_Ctrl_MemRead: std_logic;
    signal EX_MEM_Ctrl_MemWrite: std_logic;
    signal EX_MEM_Ctrl_Branch: std_logic;
    signal EX_MEM_Zero: std_logic;
  
    --4ta pipeline 
    signal MEM_WB_ReadData: std_logic_vector(31 downto 0);
    signal MEM_WB_AluResult: std_logic_vector(31 downto 0);
    signal MEM_WB_MUX: std_logic_vector(4 downto 0);
    signal MEM_WB_Ctrl_MemtoReg: std_logic;
    signal MEM_WB_Ctrl_RegWrite: std_logic;
    
    --5ta etapa 
    signal Mux_MEM_WB: std_logic_vector(31 downto 0);
   
begin 	


I_RdStb <= '1';  
I_WrStb <= '0';

-- PARTE 1
--MUX 
PC_in <= add_PC when (PCSrc = '0') else
    EX_MEM_ADD;

--ADD a PC
add_PC <= PC + x"00000004";

I_Addr <= PC;

-- PARTE 2

inst <= IF_ID_inst(31 downto 26);

--Unidad de Control 
process (inst)
begin
    case inst is 
    
        when "000000" => -- R format
            RegDst <= '1';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '0';
            ALUOp2 <= '0';
            ALUOp1 <= '1';
            ALUOp0 <= '0';
  
        when "100011" => -- lw
            RegDst <= '0';
            ALUSrc <= '1';
            MemtoReg <= '1';
            RegWrite <= '1';
            MemRead <= '1';
            MemWrite <= '0';
            Branch <= '0';
            ALUOp2 <= '0';
            ALUOp1 <= '0';
            ALUOp0 <= '0';

        when "101011" => -- sw
            ALUSrc <= '1';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '1';
            Branch <= '0';
            ALUOp2 <= '0';
            ALUOp1 <= '0';
            ALUOp0 <= '0';

        when "000100" => -- beq
            ALUSrc <= '0';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '1';
            ALUOp2 <= '0';
            ALUOp1 <= '0';
            ALUOp0 <= '1';
        
        when "001111" => -- LUI
            RegDst <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '0';
            
            ALUOp2 <= '1';            
            ALUOp1 <= '0';
            ALUOp0 <= '0';
            
        when "001000" => -- ADDI
            RegDst <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '0';
            
            ALUOp2 <= '1';            
            ALUOp1 <= '0';
            ALUOp0 <= '1';
            
        when "001100" => -- ANDI
            RegDst <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '0';
            
            ALUOp2 <= '1';            
            ALUOp1 <= '1';
            ALUOp0 <= '0';
            
        --when "001101" => -- ORI
        when others =>
            RegDst <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '0';
            
            ALUOp2 <= '1';            
            ALUOp1 <= '1';
            ALUOp0 <= '1';
     
    end case;
end process;

-- Banco de Registros 
Registers1: registers port map (
             reg1_rd => ReadRegister1,
             reg2_rd => ReadRegister2,
             reg_wr => WriteRegister,
             data_wr => WriteData,
             wr => MEM_WB_Ctrl_RegWrite,
             clk => clk,
             reset => reset,
             data1_rd => ReadData1,
             data2_rd => ReadData2
           );

ReadRegister1 <= IF_ID_inst(25 downto 21);
ReadRegister2 <= IF_ID_inst(20 downto 16);
WriteRegister <= MEM_WB_MUX;
WriteData <= Mux_MEM_WB;   

-- SignExtend
SignExtend_in <= IF_ID_inst(15 downto 0);
SignExtend <= ("1111111111111111"&SignExtend_in) when SignExtend_in(15)='1' else ("0000000000000000"&SignExtend_in);

-- 3er etapa
ShiftLeft <= (ID_EX_DataInm (29 downto 0) & "00");
AddShift <= ShiftLeft + ID_EX_PC_4;

Mux_EX_MEM <= ID_EX_RegB when (ID_EX_Ctrl_ALUSrc = '0') else
    ID_EX_DataInm;

EX_ALU: Alu port map (a=> ID_EX_RegA, b=> Mux_EX_MEM, control=> AluControl , result=> AluResult , zero=> zero);

CodigoR <= ID_EX_DataInm(5 downto 0);

process (ID_EX_Ctrl_ALUOp0, ID_EX_Ctrl_ALUOp1, ID_EX_Ctrl_ALUOp2, CodigoR) 
begin
    
    if (ID_EX_Ctrl_ALUOp2 = '0') then -- si no es de tipo I
        if (ID_EX_Ctrl_ALUOp1 = '1') then --  y es de tipo R
             case CodigoR is
                 when "100000" => AluControl <= "010"; --add  
                 when "100010" => AluControl <= "110"; --sub
                 when "100100" => AluControl <= "000"; --and
                 when "100101" => AluControl <= "001"; --or
                 when "101010" => AluControl <= "111"; --slt 
                 when others => AluControl <= "111"; --slt
             end case; 
        else -- si no es de tipo I ni de tipo R
            if (ID_EX_Ctrl_ALUOp0 = '1') then
                AluControl <= "110"; --sub
            else -- lw o sw (en ambos es un add)
                AluControl <= "010"; -- add
            end if;
        end if;
    else -- si es de tipo I
        if (ID_EX_Ctrl_ALUOp1 = '0' and ID_EX_Ctrl_ALUOp0 = '0')then -- si ALUop = 100 => LUI
            AluControl <= "100";
        else
            if (ID_EX_Ctrl_ALUOp1 = '0' and ID_EX_Ctrl_ALUOp0 = '1') then -- si ALUop = 101 => ADDI
                AluControl <= "010";
            else 
                if (ID_EX_Ctrl_ALUOp1 = '1' and ID_EX_Ctrl_ALUOp0 = '0') then -- si ALUop = 110 => ANDI
                    AluControl <= "000"; 
                else 
                    if (ID_EX_Ctrl_ALUOp1 = '1' and ID_EX_Ctrl_ALUOp0 = '1') then -- si ALUop = 111 => ORI
                        AluControl <= "001"; 
                    end if;
                end if;
            end if;
        end if;
    end if;        

  end process;

Mux_EX_MEM_2 <= ID_EX_RegD_lw when (ID_EX_Ctrl_RegDst = '0') else
    ID_EX_RegD_TR;

-- 4ta etapa 
PCSrc <= (EX_MEM_Ctrl_Branch and EX_MEM_Zero);

D_Addr <= EX_MEM_AluResult;                             
D_DataOut <= EX_MEM_RegB;
D_RdStb <= EX_MEM_Ctrl_MemRead;
D_WrStb <= EX_MEM_Ctrl_MemWrite;


--5ta etapa 
Mux_MEM_WB <= MEM_WB_ReadData when (MEM_WB_Ctrl_MemtoReg = '1') else
    MEM_WB_AluResult;

--process que contiene a los registros y FF
process (clk, reset) 
    begin
		if (reset = '1') then 

		    PC <= (others => '0');
		    
		    --if/id PIPELINE 
		    IF_ID_PC_4 <= (others => '0');
		    IF_ID_inst <= (others => '0');
		    
		    --ID/EX PIPELINE
		    ID_EX_Ctrl_RegDst <= '0';
		    ID_EX_Ctrl_ALUSrc <= '0';
		    ID_EX_Ctrl_MemtoReg <= '0';
		    ID_EX_Ctrl_RegWrite <= '0';
		    ID_EX_Ctrl_MemRead <= '0';
		    ID_EX_Ctrl_MemWrite <= '0';
		    ID_EX_Ctrl_Branch <= '0';
		    ID_EX_Ctrl_ALUOp2 <= '0';
		    ID_EX_Ctrl_ALUOp1 <= '0';
		    ID_EX_Ctrl_ALUOp0 <= '0';
 
		    ID_EX_PC_4 <= (others => '0');
		    ID_EX_RegA <= (others => '0');
		    ID_EX_RegB <= (others => '0');
		    ID_EX_DataInm <= (others => '0');
		    ID_EX_RegD_lw <= (others => '0');
		    ID_EX_RegD_TR <= (others => '0');
		    
		    --EX/MEM PIPELINE
		    EX_MEM_Ctrl_MemtoReg <= '0';
		    EX_MEM_Ctrl_RegWrite <= '0';
		    EX_MEM_Ctrl_MemRead <= '0';
		    EX_MEM_Ctrl_MemWrite <= '0';
		    EX_MEM_Ctrl_Branch <= '0';
		    
		    EX_MEM_ADD <= (others => '0');
		    EX_MEM_AluResult <= (others => '0');
		    EX_MEM_RegB <= (others => '0');
		    EX_MEM_MUX2 <= (others => '0');
		    
		    --MEM/WB PIPELINE
		    MEM_WB_Ctrl_MemtoReg <= '0';
		    MEM_WB_Ctrl_RegWrite <= '0';
		    
		    MEM_WB_ReadData <= (others => '0');
		    MEM_WB_AluResult <= (others => '0');
		    MEM_WB_MUX <= (others => '0');
		    
		else
			if (rising_edge(clk)) then 
	
			PC <= PC_in;
		    
		    --if/id PIPELINE 
		    IF_ID_PC_4 <= add_pc;
		    IF_ID_inst <= I_DataIn;
		    
		    --ID/EX PIPELINE
		    ID_EX_Ctrl_RegDst <= RegDst;
		    ID_EX_Ctrl_ALUSrc <= ALUSrc;
		    ID_EX_Ctrl_MemtoReg <= MemtoReg;
		    ID_EX_Ctrl_RegWrite <= RegWrite;
		    ID_EX_Ctrl_MemRead <= MemRead;
		    ID_EX_Ctrl_MemWrite <= MemWrite;
		    ID_EX_Ctrl_Branch <= Branch;
		    ID_EX_Ctrl_ALUOp2 <= ALUOp2;
		    ID_EX_Ctrl_ALUOp1 <= ALUOp1;
		    ID_EX_Ctrl_ALUOp0 <= ALUOp0;
 
		    ID_EX_PC_4 <= IF_ID_PC_4;
		    ID_EX_RegA <= ReadData1;
		    ID_EX_RegB <= ReadData2;
		    ID_EX_DataInm <= SignExtend;
		    ID_EX_RegD_lw <= IF_ID_inst(20 downto 16);
		    ID_EX_RegD_TR <= IF_ID_inst(15 downto 11);
		    
		    --EX/MEM PIPELINE
		    EX_MEM_Ctrl_MemtoReg <= ID_EX_Ctrl_MemtoReg;
		    EX_MEM_Ctrl_RegWrite <= ID_EX_Ctrl_RegWrite;
		    EX_MEM_Ctrl_MemRead <= ID_EX_Ctrl_MemRead;
		    EX_MEM_Ctrl_MemWrite <= ID_EX_Ctrl_MemWrite;
		    EX_MEM_Ctrl_Branch <= ID_EX_Ctrl_Branch;
		    
		    EX_MEM_Zero <= Zero;
		    
		    EX_MEM_ADD <= AddShift;
		    EX_MEM_AluResult <= AluResult;
		    EX_MEM_RegB <= ID_EX_RegB;
		    EX_MEM_MUX2 <= Mux_EX_MEM_2;
		    
		    --MEM/WB PIPELINE
		    MEM_WB_Ctrl_MemtoReg <= EX_MEM_Ctrl_MemtoReg;
		    MEM_WB_Ctrl_RegWrite <= EX_MEM_Ctrl_RegWrite;
		    
		    MEM_WB_ReadData <= D_DataIn;
		    MEM_WB_AluResult <= EX_MEM_AluResult;
		    MEM_WB_MUX <= EX_MEM_MUX2;
			end if;	
		end if;
	end process;
    
end processor_arq;
