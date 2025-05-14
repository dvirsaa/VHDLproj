library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;
 
 
-------------------------------------
entity ALU is
generic( Dwidth: integer:=16;
		 opc_len : integer:=4
		);
port(
		ALUFN	 :in std_logic_vector(opc_len-1 downto 0);
		A,B	     :in std_logic_vector(Dwidth-1 downto 0);
		C_o				 :out std_logic_vector(Dwidth-1 downto 0);
		Cflag,Nflag,Zflag: out std_logic
);
end ALU;
architecture ALUbehav of ALU is 
signal	A_in,B_in   :std_logic_vector(Dwidth-1 downto 0);
signal Carry_in 		:std_logic;
signal temp_reg    :std_logic_vector(Dwidth-1 downto 0):=(others=>'0');
signal S_out       :std_logic_vector(Dwidth-1 downto 0):=(others=>'0');
signal C_out       :std_logic_vector(Dwidth-1 downto 0):=(others=>'0');
signal zeroes  	:std_logic_vector(Dwidth-1 downto 0):=(others=>'0');
signal carry_out    :std_logic; 
--signal
constant z_vec 	:std_logic_vector(Dwidth-1 downto 0):=(others=>'0');
begin -------------- add 
	Carry_in <= '1' WHEN (ALUFN = "0001") ELSE '0';--for the subtraction
	A_in <=A;--- when the control line is off we send zero to the line  
	B_maker  : for i in Dwidth-1 downto 0 generate
		B_in(i) <= (B(i) xor '1')		WHEN (ALUFN = "0001") ELSE  ----sub is add with xor and +1
					  B(i);
	end generate;
	-- First FA operation to ALU
	first: FA port map(A_in(0), B_in(0), Carry_in, S_out(0), temp_reg(0));
	-- Make the rest of the FA operations
	rest : for i in 1 to Dwidth-1 generate
		chain : FA port map(A_in(i), B_in(i), temp_reg(i-1), S_out(i), temp_reg(i));
	end generate;
C_out<=S_out when (ALUFN="0000" OR ALUFN="0001") ELSE 
		(A_in and B_in) WHEN (ALUFN="0010") ELSE 
		(A_in or B_in) when (ALUFN="0011") else
		(A_in xor B_in) when (ALUFN="0100") else
		B_in when ALUFN="1111" else 
		(others=>'0');
	C_o<=C_out;
	carry_out<=temp_reg(Dwidth-1);
	with ALUFN select
	Cflag<=carry_out when ("0000"),
			carry_out when ("0001"),
		 unaffected when others;
	Nflag<=C_out(Dwidth-1);
	Zflag <= '1' when C_out = zeroes else '0';
end ALUbehav;
