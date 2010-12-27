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
	port ( 	n_data_in 			: in std_logic_vector (WIDTH downto 0);		-- Incoming traffic
				e_data_in			: in std_logic_vector (WIDTH downto 0);
				s_data_in			: in std_logic_vector (WIDTH downto 0);
				w_data_in			: in std_logic_vector (WIDTH downto 0);
				injection_data_in	: in std_logic_vector (WIDTH downto 0);		
				status_0				: in std_logic_vector (WIDTH downto 0); -- Can be setup as stimulus
				status_1				: in std_logic_vector (WIDTH downto 0);
				status_2				: in std_logic_vector (WIDTH downto 0);
				status_3				: in std_logic_vector (WIDTH downto 0);
				status_4				: in std_logic_vector (WIDTH downto 0);
				status_5				: in std_logic_vector (WIDTH downto 0);
				status_6				: in std_logic_vector (WIDTH downto 0);
				status_7				: in std_logic_vector (WIDTH downto 0);
				status_8				: in std_logic_vector (WIDTH downto 0);
				status_9				: in std_logic_vector (WIDTH downto 0);
				clk					: in std_logic;
				
				request_0			: out std_logic;
				request_1			: out std_logic;
				request_2			: out std_logic;
				request_3			: out std_logic;
				request_4			: out std_logic;
				request_5			: out std_logic;
				request_6			: out std_logic;
				request_7			: out std_logic;
				request_8			: out std_logic;
				request_9			: out std_logic;
				
				buffer_en_0			: out std_logic;
				buffer_en_1			: out std_logic;
				buffer_en_2			: out std_logic;
				buffer_en_3			: out std_logic;
				buffer_en_4			: out std_logic;
				buffer_en_5			: out std_logic;
				buffer_en_6			: out std_logic;
				buffer_en_7			: out std_logic;
				buffer_en_8			: out std_logic;
				buffer_en_9			: out std_logic;
				
				switch_en			: out std_logic;
				
				rna_result			: out std_logic_vector (WIDTH downto 0));		-- Routing and Arbritration Results
end Arbiter;

architecture rtl of Arbiter is

begin


end rtl;

