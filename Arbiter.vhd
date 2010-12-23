----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    13:55:59 12/20/2010
-- Design Name: 	 BlazeRouter
-- Module Name:    Arbiter - RTL
-- Project Name: 	 BlazeRouter
-- Target Devices: xc4vsx35-10ff668
-- Tool versions:  Using ISE 10.1.03
-- Description: 
--						 Part of the BlazeRouter design, the Arbiter monitors the status
--						 of each buffer within the router to see if any new data has arrived
--						 in a Round Robin with Priority scheme. When data arives, a copy
--						 of the packet within the buffer is taken, analyzed by one of the
--						 routing algorithms and a result is forwarded to the RNA_RESULT
--						 port instructing the switch on configuration.
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

entity Arbiter is	
	port ( 	north_in 			: in std_logic_vector (WIDTH downto 0);		-- Incoming traffic
				east_in 				: in std_logic_vector (WIDTH downto 0);
				south_in 			: in std_logic_vector (WIDTH downto 0);
				west_in				: in std_logic_vector (WIDTH downto 0);
				injection			: in std_logic_vector (WIDTH downto 0);		-- From Processor Logic Bus/FSL
				
				north_status		: in std_logic_vector (WIDTH downto 0);		-- Can be setup as stimulus
				east_status			: in std_logic_vector (WIDTH downto 0);
				south_status		: in std_logic_vector (WIDTH downto 0);
				west_status			: in std_logic_vector (WIDTH downto 0);
				injection_status	: in std_logic_vector (WIDTH downto 0);	
				
				rna_result			: out std_logic_vector (WIDTH downto 0));		-- Routing and Arbritration Results
end Arbiter;

architecture rtl of Arbiter is

begin


end rtl;

