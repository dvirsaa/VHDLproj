library IEEE;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------ssss
entity tb is
generic(
	Dwidth : integer :=16;
	Reg_size: integer:=4
		);
end tb;
---------------------------------------------------------ss
architecture rtb of tb is
	signal clk,rst,ena:std_logic;
	signal done:std_logic;	
	signal IRin,RFin,RFout,Imm1_in,Imm2_in,Ain,PCin,Mem_wr:  std_logic;
	signal RFaddr,WRfaddr:  std_logic_vector(1 downto 0);
	signal PCsel:  std_logic_vector(2 downto 0);
	signal opc: std_logic_vector(3 downto 0);
	signal st,ld,mov,done_in,add,sub,jmp,jc,jnc,or_o,xor_o,and_o,Cflag,Zflag,Nflag: std_logic;
	signal DTCM_addr_in,DTCM_addr_out: std_logic;
	signal DTCM_wr,DTCM_addr_sel,DTCM_out:std_logic;
	
begin
L0 : Control  generic map( 
		Dwidth,Reg_size) 
port map(clk,ena,rst,Nflag,Cflag,Zflag,st,ld,mov,done_in,add,sub,jmp,jc,jnc,and_o,or_o,xor_o,
DTCM_addr_in,DTCM_wr,DTCM_addr_out,DTCM_out,Ain,RFin,RFout,IRin,PCin,Imm1_in,Imm2_in,Mem_wr,done,DTCM_addr_sel,opc,PCsel,RFaddr,WRfaddr);

gen_rst : process
        begin
		  rst <= '1';
		  wait for 50 ns;
		  rst <= not rst;
		  ena<='1';
		  wait;
        end process;
		
        gen_clk : process
        begin
		  clk <= '0';
		  wait for 50 ns;
		  clk <= not clk;
		  wait for 50 ns;
        end process;
		
	status_proc : process
		begin
			st<='1';
			ld<='0';
			mov<='0';
			done_in<='0';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='1';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='1';
			mov<='0';
			done_in<='0';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='1';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='0';
			mov<='1';
			done_in<='0';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='1';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='0';
			mov<='0';
			done_in<='1';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='0';
			Zflag<='1';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='0';
			mov<='0';
			done_in<='0';
			add<='1';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='0';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='0';
			mov<='0';
			done_in<='0';
			add<='0';
			sub<='1';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='0';
			Zflag<='0';
			Nflag<='1';
			wait for 50 ns;
			st<='1';
			ld<='0';
			mov<='0';
			done_in<='1';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='0';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='0';
			mov<='0';
			done_in<='0';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='1';
			jnc<='0';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='1';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			st<='0';
			ld<='0';
			mov<='0';
			done_in<='0';
			add<='0';
			sub<='0';
			jmp<='0';
			jc<='0';
			jnc<='1';
			or_o<='0';
			xor_o<='0';
			and_o<='0';
			Cflag<='1';
			Zflag<='0';
			Nflag<='0';
			wait for 50 ns;
			end process;
			
			end architecture rtb;