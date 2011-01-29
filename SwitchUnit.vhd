----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    13:25:16 12/20/2010  
-- Design Name: 	 BlazeRouter
-- Module Name:    SwitchUnit - RTL 
-- Project Name: 	 BlazeRouter
-- Target Devices: xc4vsx35-10ff668
-- Tool versions:  Using ISE 10.1.03
-- Description: 
--						 Part of the BlazeRouter design, the SwitchUnit is responsible
--						 for establishing the connections from input to output and 
--						 transfering data from input buffers to their respective output
--						 buffer as determined by the Routing and Arbitration unit, which
--						 will post a result for the switch unit to follow through the 
--						 RNA_RESULT port.
--
-- Dependencies: 
--						 None
-- Revision: 
-- 					 Revision 0.01 - File Created
--						 Revision 0.02 - Added additional modules (KVH)
--					Revision 0.03 - Added functional code (KM) (not synthed yet)
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.router_library.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SwitchUnit is
	port ( 	north_in 	: in std_logic_vector (WIDTH downto 0);		-- Incoming traffic
				east_in 		: in std_logic_vector (WIDTH downto 0);
				south_in 	: in std_logic_vector (WIDTH downto 0);
				west_in		: in std_logic_vector (WIDTH downto 0);
				injection	: in std_logic_vector (WIDTH downto 0);		-- From Processor Logic Bus
				rna_result	: in std_logic_vector (9 downto 0);		-- Routing and Arbritration Results
				switch_en	: in std_logic;
				
				north_out	: out std_logic_vector (WIDTH downto 0);		-- Outgoing traffic
				east_out		: out std_logic_vector (WIDTH downto 0);	
				south_out	: out std_logic_vector (WIDTH downto 0);
				west_out 	: out std_logic_vector (WIDTH downto 0);
				ejection		: out std_logic_vector (WIDTH downto 0));		-- To Processor Logic Bus
end SwitchUnit;

architecture rtl of SwitchUnit is
	
	signal northsw	: std_logic_vector(2 downto 0);
	signal eastsw	: std_logic_vector(2 downto 0);
	signal southsw	: std_logic_vector(2 downto 0);
	signal westsw	: std_logic_vector(2 downto 0);
	signal procsw	: std_logic_vector(2 downto 0);
	
begin

	-- North out uses bits 0 and 1
	-- East out uses bits 2 and 3
	-- South out uses bits 4 and 5
	-- West out uses bits 6 and 7
	-- ejection uses bits 8 and 9	

	northsw <= switch_en & rna_result(1) & rna_result(0);
	eastsw <= switch_en & rna_result(3) & rna_result(2);
	southsw <= switch_en & rna_result(5) & rna_result(4);
	westsw <= switch_en & rna_result(7) & rna_result(6);
	procsw <= switch_en & rna_result(9) & rna_result(8);


	-- north switch
	north_out <= east_in when(northsw = "100") else
			 south_in when(northsw = "101") else
			 west_in when(northsw = "110") else
			 injection when(northsw = "111");
	
	-- east switch
	east_out <=  south_in when(eastsw = "100") else
			 west_in when(eastsw = "101") else
			 north_in when(eastsw = "110") else
			 injection when(eastsw = "111");
	
	-- south switch
	south_out <= west_in when(southsw = "100") else
			 north_in when(southsw = "101") else
			 east_in when(southsw = "110") else
			 injection when(southsw = "111");
	
	-- west switch
	west_out <=  north_in when(westsw = "100") else
			 east_in when(westsw = "101") else
			 south_in when(westsw = "110") else
			 injection when(westsw = "111");
			
	-- ejection switch
	ejection <=  north_in when(procsw = "100") else
			 east_in when(procsw = "101") else
			 south_in when(procsw = "110") else
			 west_in when(procsw = "111");

end rtl;

