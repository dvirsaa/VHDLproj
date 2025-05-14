library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity Control is
generic(Dwidth: integer:= 16;
		Reg_size: integer:=4);
port(	clk,ena,rst: in std_logic;
		Nflag,Cflag,Zflag :in std_logic;	
		st,ld,mov,done_in,add,sub,jmp,jc,jnc,and_o,or_o,xor_o :in std_logic;
		DTCM_addr_in,DTCM_wr,DTCM_addr_out,DTCM_out,Ain,RFin,RFout,
		IRin,PCin,Imm1_in,Imm2_in,Mem_wr,done,DTCM_addr_sel : out std_logic;
		ALUFN:out std_logic_vector(Reg_size-1 downto 0);---
		PCsel: out std_logic_vector(2 downto 0);
		RFaddr,WRFaddr: out std_logic_vector(1 downto 0)
 
		);
end Control;--
architecture control_beha of Control is 
type state is (Reset,Fetch,Decode,Excute,Branch,MemAdir,I_type,done_state,MovState,waitLD);
signal old_state,new_state:state ;
begin
FSM:process (clk,rst)----process for inputs when i got the status from decoder  ss
begin
		if (rst='1') then 
		old_state<=Reset;	
		elsif (clk'event and clk='1' and ena='1') then 
		old_state<=new_state;
		end if;
	end process;
LP_FSM: process(st,ld,mov,done_in,add,sub,jmp,jc,jnc,Cflag,Zflag,Nflag,old_state)
begin 
	case old_state is ---- start the fsm at every state turn on;
		when reset=> --the diffult setting 
			---- PCin='1',
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
			done<='0';
			new_state<=Fetch;
			---next state----(fetch)
			when Fetch=>
			DTCM_addr_in<='0';
			DTCM_addr_out<='0';
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
			done<='0';
			---- IRin="1",PCin='0',Mem_wr = '0', others => dont care---
			new_state<=Decode;
		when Decode =>
			if( add='1' or sub='1' or and_o='1' or or_o='1' or xor_o='1') then -- nop ,add ,sub,xor,or,and 
			DTCM_wr<='0';
			DTCM_addr_out<='0';
			DTCM_out<='0';
			Ain<='1';
			RFin<='0';
			RFout<='1';
			IRin<='0';
			PCin<='0';
			Imm1_in<='0';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<="01";---rb
			PCsel<=(others=>'0');
			done<='0';
			ALUFN<="1111";---maybe need to change 		   
			new_state<=Excute;
			elsif(jmp='1' or jc='1' or jnc='1') then
				Ain<='0';
				RFin<='0';
				RFout<='0';
				IRin<='0';
				PCin<='1';
				Imm1_in<='1';
				Imm2_in<='0';
				Mem_wr<='0';
				RFaddr<=(others=>'0');
				done<='0';			
			-- PCsel logic
			if jmp = '1' then
				PCsel <= "111";
				new_state<=Fetch;
			elsif jc = '1' and Cflag = '1' then
				PCsel <= "000";
				new_state<=Fetch;
			elsif jnc = '1' and Cflag = '0' then
				PCsel <= "001";
				new_state<=Fetch;
			else
				PCsel <= ("100");
				new_state<=Fetch;	-- or safe default like "010"
			end if;	    
			elsif(ld='1' or st='1') then -- ld,st,mov,done 
			Imm2_in<='1';
			Ain<='1';
			ALUFN<="1111";
			IRin<='0';
			new_state<=I_type;
			elsif (mov='1') then 
			RFin<='1';
			WRFaddr<="00";
			PCin<='0';
			PCsel<="100";
			new_state<=MovState;
			elsif(done_in='1') then  ------means done_in is on
			done<='1';
			new_state<=done_state;
			end if;
				-----RFaddr ="01" ,RFout = '1',OPC="1111'
			when Excute=> -- nop ,add ,sub,or,xor,and
			if(add='1' or xor_o='1' or or_o='1' or and_o='1' or sub='1' ) then --R-type actions	
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
			done<='0';
			if add = '1' then
				ALUFN <= "0000";
			elsif sub = '1' then
				ALUFN <= "0001";
			elsif and_o = '1' then
				ALUFN <= "0010";
			elsif or_o = '1' then
				ALUFN <= "0011";
			elsif xor_o = '1' then
				ALUFN <= "0100";
			else
				ALUFN <= ("1111"); -- or some default like "1111"z
			end if;
				   --"0101" when sub='1' else;
		           --"0110" when xor_o='1' else;
				-----RFaddr ="01" ,RFout = '1',OPC="1111'
			end if;
			new_state <= Fetch	; 
		when I_type=>
			if (ld='1') then 
			IRin<='0';
			PCin<='1';
			PCsel<="100";
			RFout<='1';
			RFaddr<="01";--RR
			Ain<='0';
			ALUFN<="0000";--IMM+R[rb]=c
			DTCM_addr_sel<='0';--BUS_A
			DTCM_addr_out<='1';--enable DFF sss
			DTCM_wr<='0';
			Imm2_in<='0';
			new_state<=waitLD;
			--new_state<=MemAdir;
			elsif(st='1') then
			PCin<='1';
			IRin<='0';
			Imm2_in<='0';
			PCsel<="100";
			DTCM_wr<='0';
			RFout<='1';
			RFaddr<="01";
			ALUFN<="0000";
			Ain<='0';
			DTCM_addr_sel<='0';
			DTCM_addr_in<='1';
			new_state<=waitLD;
			--new_state<=MemAdir;
			end if;
		when waitLD=>
		RFout<='0';
		IRin<='0';
		Imm1_in<='0';
		Imm2_in<='0';
		DTCM_out<='0';
		Ain<='0';
		PCin<='0';
		Imm2_in<='0';
		Imm1_in<='0';
		DTCM_addr_in<='0';
		DTCM_addr_out<='0';
		ALUFN<="0000";
		DTCM_addr_out<='0';
		done<='0';
		new_state<=MemAdir;
		
		when Branch=>  --jmp,jc,jnc 
			Ain<='0';
			RFin<='0';
			RFout<='0';
			IRin<='0';
			PCin<='1';
			Imm1_in<='1';
			Imm2_in<='0';
			Mem_wr<='0';
			RFaddr<=(others=>'0');
			done<='0';			
			-- PCsel logic
			if jmp = '1' then
				PCsel <= "111";
				new_state<=Fetch;
			elsif jc = '1' and Cflag = '1' then
				PCsel <= "000";
				new_state<=Fetch;
			elsif jnc = '1' and Cflag = '0' then
				PCsel <= "001";
				new_state<=Fetch;
			else
				PCsel <= ("100");
				new_state<=Fetch;	-- or safe default like "010"
			end if;	   
				   ---add here the actions of the lab3
		when MemAdir=> -- st,ld,mov sss
		if(ld='1') then
		DTCM_out<='1';
		RFout<='0';
		ALUFN<="1111";
		RFin<='1';
		WRFaddr<="00";
		PCin<='0';
		Ain<='0';
		DTCM_addr_in<='0';
		DTCM_addr_out<='0';
		elsif(St='1') then
		DTCM_wr<='1';
		DTCM_out<='0';
		DTCM_addr_in<='0';
		DTCM_addr_out<='0';
		RFout<='1';
		RFaddr<="00";
		PCin<='0';
		PCsel<="100";
		end if;
		new_state<=Fetch;
		
		when MovState=>
		IRin<='0';
		RFin<='1';
		ALUFN<="1111";
		Imm1_in<='1';
		RFout<='0';
		WRFaddr<="00";
		Ain<='0';
		PCin<='1';
		PCsel<="100";
		new_state<=Fetch;
		when done_state=>
		done<='1';
END CASE;
end process;
end control_beha;