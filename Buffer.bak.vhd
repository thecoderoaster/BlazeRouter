----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    13:54:48 12/20/2010 
-- Design Name: 	 BlazeRouter
-- Module Name:    Buffer - RTL
-- Project Name: 	 BlazeRouter
-- Target Devices: xc4vsx35-10ff668
-- Tool versions:  Using ISE 10.1.03
-- Description: 
--						 Part of the BlazeRouter design, the Buffer is a First In First Out 
--						 (FIFO) buffer that stores packets or flits of data from adajacent
--						 routers.
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

entity Buffers is 
    port ( buffer_in 			: in  std_logic_vector (WIDTH downto 0);				--Input to buffer
           buffer_out 			: out std_logic_vector (WIDTH downto 0);				--Output to switch
			  buffer_in_en			: in  std_logic;												--Enables Data Transfer into the buffer		  
			  buffer_out_en		: in  std_logic;												--Enables Data Transfer out of the buffer
			  status					: out std_logic_vector (WIDTH downto 0);				--Provides current Status Code
			  request_status		: in  std_logic);												--Asynchronous Status request on LOGIC '1'			
end Buffers;

architecture rtl of Buffers is

begin


end rtl;

