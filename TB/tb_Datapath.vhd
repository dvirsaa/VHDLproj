library IEEE;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;

entity tb is 
generic(Dwidth : integer:=16;
		Awidth : integer:=6;
		opc_len : integer:=4;
		Reg_size : integer:=4;
		dept:   integer:=64;
		IMM8:   integer:=8;
		IMM4:   integer:=4
		);
		end tb;
architecture Dattb of tb is 
signal clk,rst,DTCM_tb_wr,tbactive,IRin,RFin,RFout,Imm1_in,Imm2_in,Ain,PCin,DTCM_wr,Mem_wr,DTCM_out   --inputs
,DTCM_addr_sel,DTCM_addr_out,DTCM_addr_in,ITCM_tb_wr : std_logic;                --inputs
signal PCsel : std_logic_vector(2 downto 0);                                                             --inputs
signal DTCM_tb_addr_in,DTCM_tb_addr_out,ITCM_tb_addr_in: std_logic_vector(Awidth-1 downto 0);          --inputs
signal DTCM_tb_in,ITCM_tb_in :std_logic_vector(Dwidth-1 downto 0);
signal st,ld,mov,add,sub,jmp,jc,jnc,done_in,and_o,or_o,xor_o,Cflag,Zflag,Nflag:std_logic;---outputs
signal DTCM_tb_out: std_logic_vector(Dwidth-1 downto 0); ---outputs
signal 		RFaddr,WRFaddr :std_logic_vector(1 downto 0);
signal ALUFN:std_logic_vector(3 downto 0);





----
		

begin 
LOP: Datapath port map(clk	,
		rst,ALUFN,
		DTCM_tb_wr,TBactive,
		DTCM_tb_addr_in,DTCM_tb_addr_out,ITCM_tb_addr_in,DTCM_tb_in,
		IRin,RFin,RFout,Imm1_in,Imm2_in,Ain,PCin,DTCM_wr,Mem_wr,DTCM_out,
		RFaddr,WRFaddr,
		PCsel,
		DTCM_addr_sel,DTCM_addr_out,DTCM_addr_in,
		ITCM_tb_wr,
		ITCM_tb_in
		,st,ld,mov,add,sub,jmp,jc,jnc,done_in,and_o,or_o,xor_o,Cflag,Zflag,Nflag,
		DTCM_tb_out);

-------------
rst_gen: process
begin
	rst<='1';
	wait for 300 ns;
	rst <='0'  ;
	wait;
	end process;
	clk_gen: process
begin 
	clk<='0';
	wait for 50 ns;
	clk <='1';
	wait for 50 ns ;
	end process;
	
	
	programdata: process
	begin 
			ITCM_tb_in<="0000100000000000"; -- data out ssss 
			ITCM_tb_addr_in<=(others=>'0');--addr of data 
			ITCM_tb_wr<='1';
			wait for 150 ns;
			ITCM_tb_in<=(10 =>'1',others=>'0'); -- data out 
			ITCM_tb_addr_in<=(others=>'0');--addr of data 
			ITCM_tb_wr<='1';
			wait for 150 ns;
			ITCM_tb_in<=(11=>'1',9=>'1',5=>'1',0=>'1',others=>'0'); -- data out 
			ITCM_tb_addr_in<=(0=>'1',1=>'1',others=>'0');--addr of data 
			ITCM_tb_wr<='1';
			wait for 150 ns;
			ITCM_tb_in<="10000" & "00000" & "1" & "00000"; -- data out 
			ITCM_tb_addr_in<=(5=>'1',others=>'0');--addr of data 
			ITCM_tb_wr<='1';
			wait for 150 ns;
			ITCM_tb_in<="11001" & "00000" & "1" & "00000"; -- data out 
			ITCM_tb_addr_in<=(others=>'1');--addr of data 
			ITCM_tb_wr<='1';
			wait for 150 ns;
			ITCM_tb_in<=(12=>'1',others=>'0'); -- data out 
			ITCM_tb_addr_in<=(2=>'1',1=>'1',others=>'0');--addr of data 
			ITCM_tb_wr<='1';
			wait for 150 ns;
			ITCM_tb_in<=(others=>'0'); -- data out 
			ITCM_tb_addr_in<=(others=>'0');--addr of data 
			ITCM_tb_wr<='0';
			wait;
			end process;
			
		data_mem: process
		begin
		tbactive<='1';
		DTCM_addr_in<='1' ;  -----length 16 
		DTCM_tb_addr_in<=(1=>'1' ,others=>'0');
		DTCM_tb_addr_out<=(2=>'1', others=>'0');
		DTCM_tb_wr<='1';
		wait for 300 ns;
		DTCM_addr_in<='0';   -----length 16 
		DTCM_tb_addr_in<= (1=>'1',2=>'1', others=>'0');
		DTCM_tb_addr_out<=(3=>'1',others=>'0');
		DTCM_tb_wr<='0';
		wait for 300 ns;
		DTCM_addr_out<='1';   -----length 16 
		DTCM_tb_addr_in<=(4=>'1', others=>'0');
		DTCM_tb_addr_out<=(5=>'1', others=>'0');
		DTCM_tb_wr<='1';
		wait for 300 ns;
		DTCM_tb_wr<='0';
		tbactive<='0';
		wait for 300 ns;
		DTCM_addr_out<='0';   -----length 16 
		DTCM_tb_addr_in<=(4=>'1', others=>'0');
		DTCM_tb_addr_out<=(5=>'1', others=>'0');
		DTCM_tb_wr<='1';
		wait;
		end process;
		
		control_proc : process
		begin
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			ALUFN<="0000";
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			PCsel<=(others=>'0');
			done_in<='0';
			wait for 200 ns;
			--------fetch------
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			ALUFN<="0000";
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='1';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			PCsel<=(others=>'0');
			done_in<='0';
			wait for 200 ns;
			----decode------
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			Ain<='0';
			RFin<='0';
			RFout<='1';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="01";
			PCsel<=(others=>'0');
			done_in<='0';
			ALUFN<="1111";---maybe need to change 
			wait for 200 ns;
			-----secFetch----
			ALUFN<="1111";---this code does B=C
			Ain<='1';
			RFin<='0';
			RFout<='1';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="01";------bring rb into the fetch
			WRFaddr<="11";---not relevant cuz RFin='0'
			PCsel<=(others=>'0');
			done_in<='0';
			wait for 200 ns;
			-----excute-----sub-----
			
			Ain<='0';
			RFin<='1';
			RFout<='1';
			IRin<='0';
			PCin<='1';---inc the pc 
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="10";------bring rc into the ALU
			WRFaddr<="00";---ra is the write reg
			PCsel<="100" ;---INC THE PC 
			done_in<='0';
			ALUFN <= "0001";
			wait for 200 ns;
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			ALUFN<="0000";
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			PCsel<=(others=>'0');
			done_in<='0';
			wait for 200 ns; 
			--------fetch------
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			ALUFN<="0000";
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='1';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			PCsel<=(others=>'0');
			wait for 100 ns;
			----decode------
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			Ain<='0';
			RFin<='0';
			RFout<='1';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="01";
			PCsel<=(others=>'0');
			done_in<='0';
			ALUFN<="1111";---maybe need to change 
			wait for 100 ns;
			-----secFetch----
			ALUFN<="1111";---this code does B=C
			Ain<='1';
			RFin<='0';
			RFout<='1';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="01";------bring rb into the fetch
			WRFaddr<="11";---not relevant cuz RFin='0'
			PCsel<=(others=>'0');
			done_in<='0';
			wait for 100 ns;
			-----excute-----and-----
			
						Ain<='0';
			RFin<='1';
			RFout<='1';
			IRin<='0';
			PCin<='1';---inc the pc 
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="10";------bring rc into the ALU
			WRFaddr<="00";---ra is the write reg
			PCsel<="100" ;---INC THE PC 
			ALUFN <= "0010";
			wait for 50 ns;
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			ALUFN<="0000";
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			PCsel<=(others=>'0');
			done_in<='0';
			
			--------fetch------
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			ALUFN<="0000";
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='1';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			PCsel<=(others=>'0');
			wait for 50 ns;
			----decode------
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			Ain<='0';
			RFin<='0';
			RFout<='1';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="01";
			PCsel<=(others=>'0');
			ALUFN<="1111";---maybe need to change 
			wait for 50 ns;
			----I-type-- ld action---
			RFout<='1';
			RFaddr<="01";
			Ain<='0';
			ALUFN<="0000";--IMM+R[rb]=c
			DTCM_addr_sel<='0';
			DTCM_addr_out<='1';--enable DFF
			DTCM_wr<='1';
			Imm2_in<='0';
			wait for 50 ns;
			-----MEDadir----ld
			DTCM_out<='1';
			RFout<='0';
			ALUFN<="1111";
			RFin<='1';
			WRFaddr<="00";
			PCin<='1';
			Ain<='0';
			PCsel<="100";
			end process; 
		
		
		
		
end architecture Dattb;
			
			
	
			

		
		
			
	