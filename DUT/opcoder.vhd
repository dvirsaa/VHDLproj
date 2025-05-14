library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity Opcoder is
port (opcode:in std_logic_vector(3 downto 0);
		st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o :out std_logic
		);
		end opcoder;
architecture opcbehave of Opcoder is
begin 
add  	<=	'1' when opcode = "0000" else '0';
sub  	<=	'1' when opcode = "0001" else '0';
and_o   <=  '1' when opcode = "0010" else '0';
or_o    <=  '1' when opcode = "0011" else '0';
xor_o	<=  '1' when opcode = "0100" else '0';
----    <=  '1' when opcode = "0101" else '0';
-----	<=	'1' when opcode = "0110" else '0';
jmp  	<=	'1' when opcode = "0111" else '0';
jc   	<=	'1' when opcode = "1000" else '0';
jnc  	<=	'1' when opcode = "1001" else '0';
----    <=  '1' when opcode = "1010" else '0';
----    <=  '1' when opcode = "1011" else '0';
mov  	<=	'1' when opcode = "1100" else '0';
ld   	<=  '1' when opcode = "1101" else '0';
st   	<=	'1' when opcode = "1110" else '0';
done	<=  '1' when opcode = "1111" else '0';

end opcbehave;


		
		