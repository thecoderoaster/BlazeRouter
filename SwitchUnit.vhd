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
				rna_result	: in std_logic_vector (WIDTH downto 0);		-- Routing and Arbritration Results
				switch_en	: in std_logic;
				
				north_out	: out std_logic_vector (WIDTH downto 0);		-- Outgoing traffic
				east_out		: out std_logic_vector (WIDTH downto 0);	
				south_out	: out std_logic_vector (WIDTH downto 0);
				west_out 	: out std_logic_vector (WIDTH downto 0);
				ejection		: out std_logic_vector (WIDTH downto 0));		-- To Processor Logic Bus
end SwitchUnit;

architecture rtl of SwitchUnit is

begin

end rtl;

