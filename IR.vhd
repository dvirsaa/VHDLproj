library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity IR is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 Reg_size:   integer:=4;
		 IMM8: integer:=8);
port(data_in: in std_logic_vector(Dwidth-1 downto 0);
	 RFaddr,W_RFaddr  :in std_logic_vector(1 downto 0);
	 IRin    :in std_logic;---- add the in and outs of the IR such as register and opc and const (j/i) ext....
	 Opc     :out std_logic_vector(Reg_size-1 downto 0); 
	 IMM8_o  :out std_logic_vector(IMM8-1 downto 0);
	 IMM4_o  :out std_logic_vector(4-1 downto 0);
	 Reg_out,WReg_out :out std_logic_vector(Reg_size-1 downto 0)
);
end IR;
architecture behavIR of IR is
 
signal IR_Val:		 std_logic_vector(Dwidth-1 downto 0);
alias ra is IR_Val	(Reg_size*3-1 downto 2*Reg_size);-- define the requsted register 
alias rb is IR_Val	(Reg_size*2-1 downto Reg_size);--define the requsted register 
alias rc is IR_Val	(Reg_size-1 downto 0);---define the requsted register 
alias IMM8_in is IR_Val	(IMM8-1 downto 0);-- define for off_set/imm constants
alias IMM4 is	IR_Val  (4-1 downto 0);-- define for I-type 
begin 
IR_Val<= data_in when IRin='1' else unaffected;-- only when the control line is active
IMM4_o<=IMM4;
IMM8_o<=IMM8_in;
Opc<= IR_Val(Dwidth-1 downto Dwidth-Reg_size);-- the last 4 bits 
with RFaddr select
	Reg_out<=	ra when "00",
				rb when "01",
				rc when "10",
			    unaffected when others;
with W_RFaddr select
	WReg_out<=	ra when "00",
				rb when "01",
				rc when "10",
			    unaffected when others;
end behavIR;		
