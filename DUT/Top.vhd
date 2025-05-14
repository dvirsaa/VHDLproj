library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
USE work.aux_package.all;
--------------------------------------------------------------

entity Top is
generic( Dwidth : integer:=16;
		Awidth : integer:=6;
		opc_len : integer:=4;
		Reg_size : integer:=4;
		dept:   integer:=64;
		IMM8:   integer:=8;
		IMM4:   integer:=4;
		n :integer:=16;
		m :integer :=16
		);
port(rst,ena,clk:in std_logic;
		dataInProg :in std_logic_vector(m-1 downto 0);
		DataInMem:in std_logic_vector(n-1 downto 0);
		ITCM_tb_wr:in std_logic;
		ITCM_tb_addr_in:in std_logic_vector(Awidth-1 downto 0);
		TBactive,DTCM_tb_wr: in std_logic;
		DTCM_TB_addr_in,DTCM_TB_addr_out: in std_logic_vector(Awidth-1 downto 0);
		dataout:out std_logic_vector(n-1 downto 0);
		done:out std_logic
		);	

end Top;

architecture Top_behav of Top is
signal IRin,RFin,RFout,Imm1_in,Imm2_in,Ain,PCin,Cout,Cin,MemOut,MemIn,Mem_wr: std_logic; 
signal RFaddr,WRfaddr: std_logic_vector(1 downto 0);
signal PCsel: std_logic_vector(2 downto 0);
signal opc:std_logic_vector(3 downto 0);
signal st,ld,mov,done_in,add,sub,jmp,jc,jnc,Cflag,Zflag,Nflag,xor_o,or_o,and_o,DTCM_wr: std_logic;
signal DTCM_addr_in,DTCM_addr_out :std_logic;
signal DTCM_addr_sel,DTCM_out:std_logic;

begin


Control_PM:Control generic map(Dwidth,Reg_size) port map(clk,ena,rst,Nflag,Cflag,Zflag,st,ld,mov,done_in,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,
DTCM_addr_in,DTCM_wr,DTCM_addr_out,DTCM_out,Ain,RFin,RFout,IRin,PCin,Imm1_in,Imm2_in,Mem_wr,done,DTCM_addr_sel,opc,PCsel,RFaddr,WRfaddr);

DATAPATH_PM:Datapath generic map(Dwidth,Awidth,opc_len,Reg_size,dept,IMM8,IMM4) port map(clk	,
		rst,opc,
		DTCM_tb_wr,TBactive,
		DTCM_tb_addr_in,DTCM_tb_addr_out,ITCM_tb_addr_in,DataInMem,
		IRin,RFin,RFout,Imm1_in,Imm2_in,Ain,PCin,DTCM_wr,Mem_wr,DTCM_out,
		RFaddr,WRFaddr,
		PCsel,
		DTCM_addr_sel,DTCM_addr_out,DTCM_addr_in,
		ITCM_tb_wr,
		dataInProg
		,st,ld,mov,add,sub,jmp,jc,jnc,done_in,and_o,or_o,xor_o,Cflag,Zflag,Nflag,
		dataout);
end Top_behav;