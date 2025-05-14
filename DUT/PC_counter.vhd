library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PC_cnt is 
generic(IMM8:integer:=8;
		opc_jmp:integer:=4;
		Awidth :integer:=6
		);
port (clk,rst,PCin,Cflag        :in std_logic;
		PCsel 		 :in std_logic_vector(2 downto 0);--- for the mux chooser
		off_Set_addr :in std_logic_vector(IMM8-1 downto 0);
		ReadAddr :out std_logic_vector(Awidth-1 downto 0)
		);
end PC_cnt;

architecture behavPC of PC_cnt is 
signal pc_count:	std_logic_vector(Awidth-1 downto 0);
signal off_Set : std_logic_vector(Awidth-1 downto 0);
begin 
off_Set<=off_Set_addr(5 downto 0);
process(clk,rst)
	begin 
	if rst= '1' then
		pc_count<=(others=>'0');-- choosing to rest the pc counter  s
		elsif (clk'event and clk='1' and PCin='1') then
		case PCsel is
		when "111"|"000"|"001" =>
		pc_count<= 		pc_count + off_Set+1;
		when others =>
                    pc_count <= pc_count + 1;
			   --pc_count + off_Set_addr + one when "010"
			   --pc_count + off_Set_addr + one when "011"s
			end case;
	end if;
	end process;
ReadAddr<=pc_count;
end behavPC;
				
	
	
	
