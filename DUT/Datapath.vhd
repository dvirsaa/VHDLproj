library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
USE work.aux_package.all;
--------------------------------------------------------------

entity Datapath is
generic( Dwidth : integer:=16;
		Awidth : integer:=6;
		opc_len : integer:=4;
		Reg_size : integer:=4;
		dept:   integer:=64;
		IMM8:   integer:=8;
		IMM4:   integer:=4
		);
port(	clk: in std_logic;	
		rst:in std_logic;
		ALUFN:in std_logic_vector(opc_len-1 downto 0);
		DTCM_tb_wr,TBactive: in std_logic;---inputs of the tb  ssss
		DTCM_tb_addr_in,DTCM_tb_addr_out,ITCM_tb_addr_in:in std_logic_vector(Awidth-1 downto 0);---addr input of tb
		DTCM_tb_in:in std_logic_vector(Dwidth-1 downto 0);---input of tb 
		
		IRin,RFin,RFout,Imm1_in,Imm2_in,Ain,PCin,DTCM_wr,Mem_wr,DTCM_out: in std_logic;
		RFaddr,WRFaddr: in std_logic_vector(1 downto 0);--- selector by register chooser 
		PCsel: in std_logic_vector(2 downto 0);
		DTCM_addr_sel,DTCM_addr_out,DTCM_addr_in: in std_logic;
		ITCM_tb_wr:in std_logic; ----tb_inputssssss
		ITCM_tb_in:in std_logic_vector(Dwidth-1 downto 0);
		st,ld,mov,add,sub,jmp,jc,jnc,done,and_o,or_o,xor_o,Cflag,Zflag,Nflag:out std_logic;
		DTCM_tb_out:out std_logic_vector(Dwidth-1 downto 0)
		);
end Datapath;

architecture Datapath_behav of Datapath is 
signal Bus_A,Bus_B :std_logic_vector(Dwidth-1 downto 0);----sentral buses
signal Data_in :std_logic_vector(Dwidth-1 downto 0);---in Program mem output IR 
signal RF_data: std_logic_vector(Dwidth-1 downto 0);---data from RF into the Bdir
signal IMM8_in :std_logic_vector(IMM8-1 downto 0);
signal IMM4_in :std_logic_vector(IMM4-1 downto 0);
signal Reg_addr,Wreg_addr: std_logic_vector(Reg_size-1 downto 0);---the Wreg is for store only actions
signal Sxt_IMM1,Sxt_IMM2 :std_logic_vector(Dwidth-1 downto 0):=(others=>'0');
signal A_out: 			  std_logic_vector(Dwidth-1 downto 0);
signal DataOut: std_logic_vector(Dwidth-1 downto 0); -- the output of the dataMem
signal P_Counter:std_logic_vector(Awidth-1 downto 0);---the output of the pc unit and input of program mem
signal opc: std_logic_vector(opc_len-1 downto 0);
signal C_flag,temp_flag:std_logic:='0';
signal w_dataout_Mem,DataInDatamem: std_logic_vector(Dwidth-1 downto 0);
signal readAddrTemp,writeAddrTemp,readaddrmux,writeaddrmux:std_logic_vector(Awidth-1 downto 0) := (0 => '1', others => '0');----signal for mux and DFF of data 
signal readAddrDataMem,writeAddrDataMem:std_logic_vector(Awidth-1 downto 0);----data in mem
signal WRen_DataMem:std_logic;
begin
---OPCODER------st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o
Opcoder_PM:opcoder port map (opc,st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o);
-------IR-----
IR_PM:IR generic map(Dwidth,Awidth,Reg_size,IMM8) port map (Data_in,RFaddr,WRFaddr,IRin,opc,IMM8_in,IMM4_in,Reg_addr,Wreg_addr);

------RF Port map----
RF_PM: RF generic map (Dwidth,Reg_size) port map(clk,rst,RFin,Bus_A,Wreg_addr,Reg_addr,RF_data);
Bdir_PM:BidirPin generic map (Dwidth) port map(RF_data,RFout,Bus_B,open);---need add the inout val 
---sign ext portmap------
Sxt_IMM1<=("00000000"&IMM8_in);
Sxt_IMM2<=("000000000000"&IMM4_in);
Bdir_PM_IMM1:BidirPin generic map (Dwidth) port map(Sxt_IMM1,Imm1_in,Bus_B,open);--- 
Bdir_PM_IMM2:BidirPin generic map (Dwidth) port map(Sxt_IMM2,Imm2_in,Bus_B,open);--- 
----Reg A port MAP-----------
RegA_PM: reg_A generic mAP(Dwidth) port map(clk,Ain,Bus_A,A_out);
---------------ALU PORT MAP-----------
ALU_PM:ALU generic map (Dwidth,opc_len) port map(ALUFN,A_out,Bus_B,Bus_A,C_flag,Nflag,Zflag);
----------PC UNIT---------------
PCPM:PC_cnt generic map (IMM8,opc_len,Awidth) port map(clk,rst,PCin,C_flag,PCsel,IMM8_in,P_Counter);

-----PROGMEM portmapppp------
MEMPM:progMem generic map(Dwidth,Awidth,dept) port map(clk,ITCM_tb_wr,ITCM_tb_in,ITCM_tb_addr_in,P_Counter,Data_in);

carryDFF:process(ALUFN)
begin
		if ALUFN="0000" or ALUFN="0001" then
			Cflag<=C_flag;
		else 
		Cflag<=unaffected;
		end if;
	end process;			

readAddrTemp<=Bus_B(Awidth-1 downto 0) when DTCM_addr_sel='1' else Bus_A(Awidth-1 downto 0);---mux 
writeAddrTemp<=Bus_B(Awidth-1 downto 0) when DTCM_addr_sel='1' else Bus_A(Awidth-1 downto 0);---mux ss
----DFF----
dff_maker1:process(clk)
begin
	if rising_edge(clk) then
		if DTCM_addr_in='1' then
			writeaddrmux<=writeAddrTemp;
		end if;
	end if;
	end process;		

dff_maker2: process(clk)
begin
	if rising_edge(clk) then
		if DTCM_addr_out='1' then
			readaddrmux<=readAddrTemp;
		end if;
	end if;
	end process;
		
----the muxes---
WRen_DataMem<= DTCM_tb_wr 			when 	TBactive='1'	 else DTCM_wr;
readAddrDataMem<= DTCM_tb_addr_out 	when 	TBactive='1' 	 	else readaddrmux;
writeAddrDataMem<=DTCM_tb_addr_in 	when 	TBactive='1' 	 	else writeaddrmux;
DataInDatamem<=	DTCM_tb_in 			when 	TBactive='1'	else Bus_B;
----Data mem-----
DATA_PM: dataMem generic map(Dwidth,Awidth,dept) port map(clk,WRen_DataMem,DataInDatamem,writeAddrDataMem,readAddrDataMem,DataOut);
----DATA BIDRPIN-----
dataBdir1: BidirPin generic map(Dwidth) port map(DataOut,DTCM_out,Bus_B,open);---
process (clk)
begin
			if rising_edge(clk) then
				if WRen_DataMem = '0' then
					DTCM_tb_out <= DataOut;
				-- else do nothing, retain previous value
				end if;
			end if;
end process;---1 for reading ld  s
end Datapath_behav;
	