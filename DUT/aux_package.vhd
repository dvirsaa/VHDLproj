LIBRARY ieee;
USE ieee.std_logic_1164.all;
----------------Package-------------------------------------
package aux_package is
-------------------------- ALU ----------------------------	
	component ALU IS
	  GENERIC (Dwidth   : INTEGER := 16;
				opc_len : INTEGER:=4
				);---
	  PORT (	
		ALUFN	 :in std_logic_vector(opc_len-1 downto 0);
		A,B	     :in std_logic_vector(Dwidth-1 downto 0);
		C_o				 :out std_logic_vector(Dwidth-1 downto 0);
		Cflag,Nflag,Zflag: out std_logic
);
	END component;
---------------------- Bi-Dir Bus Line -----------------------
	component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
	end component;
---------------------- Bi Direction Pin Basic -----------------------
	component BidirPinBasic is
	port(   writePin: in 	std_logic;
			readPin:  out 	std_logic;
			bidirPin: inout std_logic
	);
	end component;	
---------------------- Control Unit -----------------------
	component Control IS
	generic( 
		Dwidth: integer:= 16;
		Reg_size: integer:=4);
		PORT(
			clk,ena,rst: in std_logic;
		Nflag,Cflag,Zflag :in std_logic;	
		st,ld,mov,done_in,add,sub,jmp,jc,jnc,and_o,or_o,xor_o :in std_logic;
		DTCM_addr_in,DTCM_wr,DTCM_addr_out,DTCM_out,Ain,RFin,RFout,
		IRin,PCin,Imm1_in,Imm2_in,Mem_wr,done,DTCM_addr_sel : out std_logic;
		ALUFN:out std_logic_vector(Reg_size-1 downto 0);---
		PCsel: out std_logic_vector(2 downto 0);
		RFaddr,WRFaddr: out std_logic_vector(1 downto 0)

		);
	END component;	
---------------------- Data Memory -----------------------
	component dataMem is
	generic( Dwidth: integer:=16;
			 Awidth: integer:=6;
			 dept:   integer:=64);
	port(	clk,memEn: in std_logic;	
			WmemData:	in std_logic_vector(Dwidth-1 downto 0);
			WmemAddr,RmemAddr:	
						in std_logic_vector(Awidth-1 downto 0);
			RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
	);
	end component;
---------------------- Data Path -------------------------
	component Datapath is
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
		ALUFN :in std_logic_vector(3 downto 0);
		DTCM_tb_wr,TBactive: in std_logic;---inputs of the tb 
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
end component;
---------------------- Full Adder -----------------------	
	component FA IS
	PORT (xi, yi, cin: IN std_logic;
			  s, cout: OUT std_logic);
	END component;
---------------------- Instruction Register --------------	
	component IR is 
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
end component;
-------------------------- OPC Decoder ----------------------------	
	component opcoder is
		port(	opcode:in std_logic_vector(3 downto 0);
		st,ld,mov,done,add,sub,jmp,jc,jnc,and_o,or_o,xor_o :out std_logic
	);
	end component;
---------------------- Program Counter -----------------------	
	component Pc_cnt IS
		generic(IMM8:integer:=8;
		opc_jmp:integer:=4;
		Awidth :integer:=6
		);
		port (clk,rst,PCin,Cflag        :in std_logic;
		PCsel 		 :in std_logic_vector(2 downto 0);--- for the mux chooser
		off_Set_addr :in std_logic_vector(IMM8-1 downto 0);
		ReadAddr :out std_logic_vector(Awidth-1 downto 0)
		);
	END component;
---------------------- Program Memory -----------------------
	component ProgMem is
	generic( Dwidth: integer:=16;
			 Awidth: integer:=6;
			 dept:   integer:=64);
	port(	clk,memEn: in std_logic;	
			WmemData:	in std_logic_vector(Dwidth-1 downto 0);
			WmemAddr,RmemAddr:	
						in std_logic_vector(Awidth-1 downto 0);
			RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
	);
	end component;	
---------------------- Register File -----------------------
	component RF is
	generic( Dwidth: integer:=16;
			 Reg_Size: integer:=4);
	port(	clk,rst,RFin: in std_logic;	
			WregData:	in std_logic_vector(Dwidth-1 downto 0);
			WregAddr,RregAddr:	
						in std_logic_vector(Reg_size-1 downto 0);
			RregData: 	out std_logic_vector(Dwidth-1 downto 0)
	);
	end component;
---------------------- top -----------------------
	component Top IS
		generic( Dwidth: integer:=16;	-- Data Memory In Data Size
			 Awidth:  integer:=6;
			 opc_len,Reg_size : INTEGER:=4;
			 dept :INTEGER :=64;
			 IMM8 : INTEGER :=8;
			 IMM4 :INTEGER :=4;
			 n,m :INTEGER:=16
			 	  
			 );  	-- Address Size
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

	END component;
	component reg_A is 
	generic( Dwidth: integer:=16
		);
	port(	clk,Ain  :in std_logic;	
		data     :in std_logic_vector(Dwidth-1 downto 0);
		A				 :out std_logic_vector(Dwidth-1 downto 0)
		);
	end component;
end aux_package;
