----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    16:16:07 10/06/2010 
-- Design Name: 	 BlazeRouter
-- Module Name:    BlazeRouter - RTL 
-- Project Name: 	 BlazeRouter
-- Target Devices: xc4vsx35-10ff668
-- Tool versions:  Using ISE 10.1.03
-- Description: 
--						 BlazeRouter is a hierarchical router that contains instances of
--						 various VHDL modules responsible for the entire makeup of the 
--						 design. The idea is to connect the available ports (N,S,E,W) to
--						 adjacent modules (i.e Processors) to realize an NoC.
-- Dependencies: 
--						 (See individual files for more details)
--						 Arbiter.vhd				- Contains the Routing and Arbitration Unit
--						 Buffer.vhd					- Contains a single 8 bit width buffer
--						 LinkController.vhd		- Contains the Link Controller
--						 SwitchUnit.vhd			- Contains the Switch mechanism
--						 SimplePackages.vhd		- All packages for BlazeRouter
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

entity BlazeRouter is
	 
    port ( north_in 	: in  std_logic_vector (WIDTH downto 0);
           east_in 	: in  std_logic_vector (WIDTH downto 0);
           south_in 	: in  std_logic_vector (WIDTH downto 0);
           west_in 	: in  std_logic_vector (WIDTH downto 0);
			  injection	: in	std_logic_vector (WIDTH downto 0);
			  
			  north_out	: out std_logic_vector (WIDTH downto 0);
			  east_out	: out std_logic_vector (WIDTH downto 0);
			  south_out : out std_logic_vector (WIDTH downto 0);
			  west_out	: out std_logic_vector (WIDTH downto 0);
			  ejection	: out std_logic_vector (WIDTH downto 0));
end BlazeRouter;

architecture rtl of BlazeRouter is
	--Define Components here that will make up the design
	--Refer to each .vhd module for definitions on ports
	component Buffers
		port(buffer_in 		: in  std_logic_vector (WIDTH downto 0);
           buffer_out 		: out std_logic_vector (WIDTH downto 0);
			  buffer_en			: in  std_logic;		  
			  status				: out std_logic_vector (WIDTH downto 0);
			  request_status	: in  std_logic);
	end component;
	
	component Arbiter
		port (north_in 			: in std_logic_vector (WIDTH downto 0);
				east_in 				: in std_logic_vector (WIDTH downto 0);
				south_in 			: in std_logic_vector (WIDTH downto 0);
				west_in				: in std_logic_vector (WIDTH downto 0);
				injection			: in std_logic_vector (WIDTH downto 0);
			
				north_status		: in std_logic_vector (WIDTH downto 0);
				east_status			: in std_logic_vector (WIDTH downto 0);
				south_status		: in std_logic_vector (WIDTH downto 0);
				west_status			: in std_logic_vector (WIDTH downto 0);
				injection_status	: in std_logic_vector (WIDTH downto 0);	
			
				rna_result			: out std_logic_vector (WIDTH downto 0));
	end component;
	
	component LinkController
		port (transmit_req 	: in  std_logic;
				receive_req 	: out std_logic;										
				buffer_en		: out std_logic;									
				status			: in  std_logic_vector(WIDTH downto 0));		
	end component;
	
	component SwitchUnit
		port (north_in 	: in std_logic_vector (WIDTH downto 0);
				east_in 		: in std_logic_vector (WIDTH downto 0);
				south_in 	: in std_logic_vector (WIDTH downto 0);
				west_in		: in std_logic_vector (WIDTH downto 0);
				injection	: in std_logic_vector (WIDTH downto 0);
				rna_result	: in std_logic_vector (WIDTH downto 0);
				
				north_out	: out std_logic_vector (WIDTH downto 0);
				east_out		: out std_logic_vector (WIDTH downto 0);	
				south_out	: out std_logic_vector (WIDTH downto 0);
				west_out 	: out std_logic_vector (WIDTH downto 0);
				ejection		: out std_logic_vector (WIDTH downto 0));
	end component;
	
	--Define signals here that will be used to connect the components
begin
	--Instantiate components here to create the overall functionality
	--n_in: Buffers port map(north_in, 
end rtl;

