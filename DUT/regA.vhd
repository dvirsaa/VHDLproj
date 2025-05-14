library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
entity reg_A is
generic( Dwidth: integer:=16
		);
port(	clk,Ain  :in std_logic;	
		data     :in std_logic_vector(Dwidth-1 downto 0);
		A				 :out std_logic_vector(Dwidth-1 downto 0)
);
end reg_A;
architecture behav of reg_A is 
signal A_o: std_logic_vector(Dwidth-1 downto 0);
begin
process(clk)
begin
if (clk'event and clk='1') then
	if Ain='1' then 
	   A<=data;
	   else
	   A<=unaffected;
	end if;
end if;
end process;
--A<=A_o;
end behav;
