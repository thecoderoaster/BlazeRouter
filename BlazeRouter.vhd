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
	 
    port ( north_data_in 		: inout std_logic_vector (WIDTH downto 0);
			  north_data_out		: inout std_logic_vector (WIDTH downto 0);
           north_neighbor_txr : in	std_logic;
			  north_neighbor_rxr	: in  std_logic;
			  north_local_txr		: out std_logic;
			  north_local_rxr		: out std_logic;
			  
			  
			  east_data_in 		: inout std_logic_vector (WIDTH downto 0);
			  east_data_out		: inout std_logic_vector (WIDTH downto 0);
			  east_neighbor_txr 	: in	std_logic;
			  east_neighbor_rxr	: in  std_logic;
			  east_local_txr		: out std_logic;
			  east_local_rxr		: out std_logic;
			  
           south_data_in 		: inout std_logic_vector (WIDTH downto 0);
			  south_data_out 		: inout std_logic_vector (WIDTH downto 0);
			  south_neighbor_txr : in	std_logic;
			  south_neighbor_rxr	: in  std_logic;
			  south_local_txr		: out std_logic;
			  south_local_rxr		: out std_logic;
			  
           west_data_in 		: inout std_logic_vector (WIDTH downto 0);
			  west_data_out		: inout std_logic_vector (WIDTH downto 0);
			  west_neighbor_txr 	: in	std_logic;
			  west_neighbor_rxr	: in  std_logic;
			  west_local_txr		: out std_logic;
			  west_local_rxr		: out std_logic;
			  
			  injection_data		: inout std_logic_vector (WIDTH downto 0);
			  ejection_data		: inout std_logic_vector (WIDTH downto 0);
			  processor_txr		: in  std_logic;
			  processor_rxr		: in  std_logic;
			  local_txr				: out std_logic;
			  local_rxr				: out std_logic;
			  in_buffer_in_en		: in  std_logic;
			  ej_buffer_out_en	: in	std_logic;
			  
			  clk						: in std_logic);
end BlazeRouter;

architecture rtl of BlazeRouter is
	--Define Components here that will make up the design
	--Refer to each .vhd module for definitions on ports
	component Buffers
		port ( buffer_in 			: in  std_logic_vector (WIDTH downto 0);				
           buffer_out 			: out std_logic_vector (WIDTH downto 0);				
			  buffer_in_en			: in  std_logic;														  
			  buffer_out_en		: in  std_logic;												
			  status					: out std_logic_vector (WIDTH downto 0);				
			  request_status		: in  std_logic);												
	end component;
	
	component Arbiter
		port (n_data_in 			: in std_logic_vector (WIDTH downto 0);
				e_data_in			: in std_logic_vector (WIDTH downto 0);
				s_data_in			: in std_logic_vector (WIDTH downto 0);
				w_data_in			: in std_logic_vector (WIDTH downto 0);
				injection_data_in	: in std_logic_vector (WIDTH downto 0);		
				status_0				: in std_logic_vector (WIDTH downto 0);
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
				
				rna_result			: out std_logic_vector (WIDTH downto 0));
	end component;
	
	component LinkController
		port (rxr 				: in  std_logic;										
			   txr 				: out  std_logic;									   
			   data				: inout std_logic_vector(WIDTH downto 0);			
			   data_local		: inout std_logic_vector(WIDTH downto 0);		
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
				switch_en	: in std_logic;
				
				north_out	: out std_logic_vector (WIDTH downto 0);
				east_out		: out std_logic_vector (WIDTH downto 0);	
				south_out	: out std_logic_vector (WIDTH downto 0);
				west_out 	: out std_logic_vector (WIDTH downto 0);
				ejection		: out std_logic_vector (WIDTH downto 0));
	end component;
	
	--Define signals here that will be used to connect the components
	signal	n_data_in, n_data_out, n_data_out_to_sw, n_data_in_from_sw, e_data_in, e_data_out, e_data_out_to_sw,
				e_data_in_from_sw, s_data_in, s_data_out, s_data_out_to_sw, s_data_in_from_sw, 
				w_data_in, w_data_out, w_data_out_to_sw, w_data_in_from_sw, nB1_status, nB5_status, 
				eB2_status, eB6_status, sB3_status, sB7_status, wB4_status, wB8_status, inB9_status,
				ejB10_status, injection_data_to_sw, ejection_data_from_sw, rna_results: bit8;
	
	signal 	nB1_buffer_in_en, nB5_buffer_in_en, eB2_buffer_in_en, eB6_buffer_in_en, 
				sB3_buffer_in_en, sB7_buffer_in_en, wB4_buffer_in_en, wB8_buffer_in_en,
				ejB10_buffer_in_en,
				nB1_buffer_out_en, nB5_buffer_out_en, eB2_buffer_out_en, eB6_buffer_out_en,
				sB3_buffer_out_en, sB7_buffer_out_en, wB4_buffer_out_en, wB8_buffer_out_en,
				inB9_buffer_out_en,
				nB1_request_status, nB5_request_status, eB2_request_status, eB6_request_status, 
				sB3_request_status, sB7_request_status, wB4_request_status, wB8_request_status,
				inB9_request_status, ejB10_request_status,
				sw_enable : std_logic;
	
begin
	--Instantiate components here to create the overall functionality
	
	--Input Link Controllers
	n_in_LC1: LinkController port map(north_neighbor_txr, 
												 north_local_rxr, 
												 north_data_in, 
												 n_data_in,
												 nB1_buffer_in_en,
												 nB1_status);
	e_in_LC2: LinkController port map(east_neighbor_txr, 
												 east_local_rxr, 
												 east_data_in, 
												 e_data_in,
												 eB2_buffer_in_en,
												 eB2_status);
	s_in_LC3: LinkController port map(south_neighbor_txr, 
												 south_local_rxr, 
												 south_data_in, 
												 s_data_in,
												 sB3_buffer_in_en,
												 sB3_status);
	w_in_LC4: LinkController port map(west_neighbor_txr, 
												 west_local_rxr, 
												 west_data_in, 
												 w_data_in,
												 wB4_buffer_in_en,
												 wB4_status);
	
	--Output Link Controllers
	n_out_LC5: LinkController port map(north_neighbor_rxr, 
												 north_local_txr, 
												 north_data_out, 
												 n_data_out,
												 nB5_buffer_out_en,
												 nB5_status);
	e_out_LC6: LinkController port map(east_neighbor_rxr, 
												 east_local_txr, 
												 east_data_out, 
												 e_data_out,
												 eB6_buffer_out_en,
												 eB6_status);
	s_out_LC7: LinkController port map(south_neighbor_rxr, 
												 south_local_txr, 
												 south_data_out, 
												 s_data_out,
												 sB7_buffer_out_en,
												 sB7_status);
	w_out_LC8: LinkController port map(west_neighbor_rxr, 
												 west_local_txr, 
												 west_data_out, 
												 w_data_out,
												 wB8_buffer_out_en,
												 wB8_status);
	--Input Buffers											 
	n_in_B1:	Buffers port map(n_data_in,
									  n_data_out_to_sw,
									  nB1_buffer_in_en,
									  nB1_buffer_out_en,
									  nB1_status,
									  nB1_request_status);
	e_in_B2:	Buffers port map(e_data_in,
									  e_data_out_to_sw,
									  eB2_buffer_in_en,
									  eB2_buffer_out_en,
									  eB2_status,
									  eB2_request_status);
	s_in_B3:	Buffers port map(s_data_in,
									  s_data_out_to_sw,
									  sB3_buffer_in_en,
									  sB3_buffer_out_en,
									  sB3_status,
									  sB3_request_status);
	w_in_B4:	Buffers port map(w_data_in,
									  w_data_out_to_sw,
									  wB4_buffer_in_en,
									  wB4_buffer_out_en,
									  wB4_status,
									  wB4_request_status);
	
	--Output Buffers
	n_out_B5: Buffers port map(n_data_in_from_sw,
									   n_data_out,
									   nB5_buffer_in_en,
									   nB5_buffer_out_en,
									   nB5_status,
									   nB5_request_status);
	e_out_B6: Buffers port map(e_data_in_from_sw,
									   e_data_out,
									   eB6_buffer_in_en,
									   eB6_buffer_out_en,
									   eB6_status,
									   eB6_request_status);
	s_out_B7: Buffers port map(s_data_in_from_sw,
									   s_data_out,
									   sB7_buffer_in_en,
									   sB7_buffer_out_en,
									   sB7_status,
									   sB7_request_status);
	w_out_B8: Buffers port map(w_data_in_from_sw,
									   w_data_out,
									   wB8_buffer_in_en,
									   wB8_buffer_out_en,
									   wB8_status,
									   wB8_request_status);
										
	--Injection/Ejection buffers
	injection_B9:	Buffers port map(injection_data,
									   injection_data_to_sw,
									   in_buffer_in_en,
									   inB9_buffer_out_en,
									   inB9_status,
									   inB9_request_status);
	ejection_B10: Buffers port map(ejection_data_from_sw,
									   ejection_data,
									   ejB10_buffer_in_en,
									   ej_buffer_out_en,
									   ejB10_status,
									   ejB10_request_status);
	
	--Switch
	sw: SwitchUnit port map(n_data_out_to_sw,
									e_data_out_to_sw,
									s_data_out_to_sw,
									w_data_out_to_sw,
									injection_data_to_sw,
									rna_results,
									sw_enable,
									n_data_in_from_sw,
									e_data_in_from_sw,
									s_data_in_from_sw,
									w_data_in_from_sw,
									ejection_data_from_sw);
	--Arbiter
	ar: Arbiter port map(n_data_out_to_sw,
								e_data_out_to_sw,
								s_data_out_to_sw,
								w_data_out_to_sw,
								injection_data,
								nB1_status,
								eB2_status,
								sB3_status,
								wB4_status,
								nB5_status,
								eB6_status,
								sB7_status,
								wB8_status,
								inB9_status,
								ejB10_status,
								nB1_request_status,
								eB2_request_status,
								sB3_request_status,
								wB4_request_status,
								nB5_request_status,
								eB6_request_status,
								sB7_request_status,
								wB8_request_status,
								inB9_request_status,
								ejB10_request_status,
								nB1_buffer_out_en,
								eB2_buffer_out_en,
								sB3_buffer_out_en,
								wB4_buffer_out_en,
								nB5_buffer_in_en,
								eB6_buffer_in_en,
								sB7_buffer_in_en,
								wB8_buffer_in_en,
								inB9_buffer_out_en,
								ejB10_buffer_in_en);
												 
end rtl;

