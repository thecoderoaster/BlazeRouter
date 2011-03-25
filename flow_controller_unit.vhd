----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    18:09:00 03/22/2011 
-- Design Name: 	 BlazeRouter
-- Module Name:    fcu - fcu_4 
-- Project Name: 	 BlazeRouter
-- Description: 	 Flow controller top level unit (contains 4 flow controllers)
--
-- Dependencies: 
--					 	 flow_control - fc_4
-- Revision: 
-- 					 Revision 0.01 - File Created
--						 Revision 0.02 - Created entity outline (KM)
--                 Revision 0.03 - Created implmentation code (KM)
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.router_library.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity fcu is
			-- ports use the naming convention (neighbor_signalName. i.e. w_dataIn means the incomming data from the neighbor to the west)
	port( n_CTRflg			: in		STD_LOGIC;									-- Clear To Recieve flag (from RNA)
			n_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from neighbor)
			n_dStrb 			: in  	STD_LOGIC;									-- Data strobe (from neighbor)
			n_vcFull 		: in  	STD_LOGIC;									-- Full status flag (from VC)
			n_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to VC)
			n_rnaCtrl	 	: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to RNA)
			n_rnaCtrlStrb 	: out  	STD_LOGIC;									-- Control packet strobe (to RNA)
			n_CTR				: out		STD_LOGIC;									-- Clear to Recieve (to neighbor)
			n_vcEnq 			: out  	STD_LOGIC;									-- enqueue command from RNA (to VC)
			
			e_CTRflg			: in		STD_LOGIC;									-- Clear To Recieve flag (from RNA)
			e_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from neighbor)
			e_dStrb 			: in  	STD_LOGIC;									-- Data strobe (from neighbor)
			e_vcFull 		: in  	STD_LOGIC;									-- Full status flag (from VC)
			e_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to VC)
			e_rnaCtrl	 	: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to RNA)
			e_rnaCtrlStrb 	: out  	STD_LOGIC;									-- Control packet strobe (to RNA)
			e_CTR				: out		STD_LOGIC;									-- Clear to Recieve (to neighbor)
			e_vcEnq 			: out  	STD_LOGIC;									-- enqueue command from RNA (to VC)
			
			s_CTRflg			: in		STD_LOGIC;									-- Clear To Recieve flag (from RNA)
			s_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from neighbor)
			s_dStrb 			: in  	STD_LOGIC;									-- Data strobe (from neighbor)
			s_vcFull 		: in  	STD_LOGIC;									-- Full status flag (from VC)
			s_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to VC)
			s_rnaCtrl	 	: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to RNA)
			s_rnaCtrlStrb 	: out  	STD_LOGIC;									-- Control packet strobe (to RNA)
			s_CTR				: out		STD_LOGIC;									-- Clear to Recieve (to neighbor)
			s_vcEnq 			: out  	STD_LOGIC;									-- enqueue command from RNA (to VC)
			
			w_CTRflg			: in		STD_LOGIC;									-- Clear To Recieve flag (from RNA)
			w_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from neighbor)
			w_dStrb 			: in  	STD_LOGIC;									-- Data strobe (from neighbor)
			w_vcFull 		: in  	STD_LOGIC;									-- Full status flag (from VC)
			w_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to VC)
			w_rnaCtrl	 	: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to RNA)
			w_rnaCtrlStrb 	: out  	STD_LOGIC;									-- Control packet strobe (to RNA)
			w_CTR				: out		STD_LOGIC;									-- Clear to Recieve (to neighbor)
			w_vcEnq 			: out  	STD_LOGIC);									-- enqueue command from RNA (to VC)
end fcu;


architecture fcu_4 of fcu is

	component flow_control is
		Port (  fc_CTRflg			: in		STD_LOGIC;									-- Clear To Recieve flag (from RNA)
				  fc_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from neighbor)
				  fc_dStrb 			: in  	STD_LOGIC;									-- Data strobe (from neighbor)
				  fc_vcFull 		: in  	STD_LOGIC;									-- Full status flag (from VC)
				  fc_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to VC)
				  fc_rnaCtrl	 	: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to RNA)
				  fc_rnaCtrlStrb 	: out  	STD_LOGIC;									-- Control packet strobe (to RNA)
				  fc_CTR				: out		STD_LOGIC;									-- Clear to Recieve (to neighbor)
				  fc_vcEnq 			: out  	STD_LOGIC);									-- enqueue command from RNA (to VC)
	end component;

begin

	FC_NORTH: flow_control port map (n_CTRflg,
												n_dataIn,
												n_dStrb,
												n_vcFull,
												n_vcData,
												n_rnaCtrl,
												n_rnaCtrlStrb,
												n_CTR,		
												n_vcEnq);

	FC_EAST: flow_control port map  (e_CTRflg,
												e_dataIn,
												e_dStrb,
												e_vcFull,
												e_vcData,
												e_rnaCtrl,
												e_rnaCtrlStrb,
												e_CTR,		
												e_vcEnq);

	FC_SOUTH: flow_control port map (s_CTRflg,
												s_dataIn,
												s_dStrb,
												s_vcFull,
												s_vcData,
												s_rnaCtrl,
												s_rnaCtrlStrb,
												s_CTR,		
												s_vcEnq);

	FC_WEST: flow_control port map  (w_CTRflg,
												w_dataIn,
												w_dStrb,
												w_vcFull,
												w_vcData,
												w_rnaCtrl,
												w_rnaCtrlStrb,
												w_CTR,		
												w_vcEnq);
												
end fcu_4;

