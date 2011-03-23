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
	port( n_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 
			n_dGood 			: in  	STD_LOGIC;									
			n_ctrlFlg 		: in  	STD_LOGIC;									
			n_vcStat 		: in  	STD_LOGIC_VECTOR (1 downto 0);		
			n_rnaCTR 		: in  	STD_LOGIC;									
			n_rnaSel 		: in  	STD_LOGIC_VECTOR (1 downto 0);									
			n_doEnq			: in		STD_LOGIC;									
			n_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			n_rnaCtrl 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			n_CTR 			: out  	STD_LOGIC;									
			n_stat 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			n_vcSel 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			n_rnaCtrlFlg 	: out  	STD_LOGIC;									
			n_rnaDg			: out		STD_LOGIC;									
			n_vcEnq 			: out  	STD_LOGIC;
			
			e_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 
			e_dGood 			: in  	STD_LOGIC;									
			e_ctrlFlg 		: in  	STD_LOGIC;									
			e_vcStat 		: in  	STD_LOGIC_VECTOR (1 downto 0);		
			e_rnaCTR 		: in  	STD_LOGIC;									
			e_rnaSel 		: in  	STD_LOGIC_VECTOR (1 downto 0);									
			e_doEnq			: in		STD_LOGIC;									
			e_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			e_rnaCtrl 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			e_CTR 			: out  	STD_LOGIC;									
			e_stat 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			e_vcSel 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			e_rnaCtrlFlg 	: out  	STD_LOGIC;									
			e_rnaDg			: out		STD_LOGIC;									
			e_vcEnq 			: out  	STD_LOGIC;
			
			s_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 
			s_dGood 			: in  	STD_LOGIC;									
			s_ctrlFlg 		: in  	STD_LOGIC;									
			s_vcStat 		: in  	STD_LOGIC_VECTOR (1 downto 0);		
			s_rnaCTR 		: in  	STD_LOGIC;									
			s_rnaSel 		: in  	STD_LOGIC_VECTOR (1 downto 0);										
			s_doEnq			: in		STD_LOGIC;									
			s_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			s_rnaCtrl 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			s_CTR 			: out  	STD_LOGIC;									
			s_stat 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			s_vcSel 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			s_rnaCtrlFlg 	: out  	STD_LOGIC;									
			s_rnaDg			: out		STD_LOGIC;									
			s_vcEnq 			: out  	STD_LOGIC;
			
			w_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 
			w_dGood 			: in  	STD_LOGIC;									
			w_ctrlFlg 		: in  	STD_LOGIC;									
			w_vcStat 		: in  	STD_LOGIC_VECTOR (1 downto 0);		
			w_rnaCTR 		: in  	STD_LOGIC;									
			w_rnaSel 		: in  	STD_LOGIC_VECTOR (1 downto 0);									
			w_doEnq			: in		STD_LOGIC;									
			w_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			w_rnaCtrl 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	
			w_CTR 			: out  	STD_LOGIC;									
			w_stat 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			w_vcSel 			: out  	STD_LOGIC_VECTOR (1 downto 0);		
			w_rnaCtrlFlg 	: out  	STD_LOGIC;									
			w_rnaDg			: out		STD_LOGIC;									
			w_vcEnq 			: out  	STD_LOGIC);
end fcu;


architecture fcu_4 of fcu is

	component flow_control is
		 Port ( fc_dataIn 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from neighbor dmuxed ctrld by fc_dGood)
				  fc_dGood 			: in  	STD_LOGIC;									-- Data good strobe (from neighbor)
				  fc_ctrlFlg 		: in  	STD_LOGIC;									-- Control packet indicator (from neighbor)
				  fc_vcStat 		: in  	STD_LOGIC_VECTOR (1 downto 0);		-- Status from local Virtual Channel (to neighbor and RNA)
				  fc_rnaCTR 		: in  	STD_LOGIC;									-- Clear to Recieve flag (to neighbor)
				  fc_rnaSel 		: in  	STD_LOGIC_VECTOR (1 downto 0);		-- Buffer select (to VC)
				  fc_doEnq			: in		STD_LOGIC;									-- Tell VC to enqueue data (from RNA)
				  fc_vcData 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to VC)
				  fc_rnaCtrl 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Data port (to RNA)
				  fc_CTR 			: out  	STD_LOGIC;									-- Clear to Recieve flag (from RNA)
				  fc_stat 			: out  	STD_LOGIC_VECTOR (1 downto 0);		-- VC status (to RNA and neighbor)
				  fc_vcSel 			: out  	STD_LOGIC_VECTOR (1 downto 0);		-- VC select (to VC)
				  fc_rnaCtrlFlg 	: out  	STD_LOGIC;									-- Control packet indicator (to RNA)
				  fc_rnaDg			: out		STD_LOGIC;									-- Data good strobe (to RNA)
				  fc_vcEnq 			: out  	STD_LOGIC);									-- enqueue command from RNA (to VC)
	end component;

begin

	FC_NORTH: flow_control port map (n_dataIn,
												n_dGood, 									
												n_ctrlFlg, 										
												n_vcStat, 				
												n_rnaCTR, 											
												n_rnaSel, 										
												n_doEnq,												
												n_vcData, 		
												n_rnaCtrl, 		
												n_CTR, 											
												n_stat, 		
												n_vcSel,		
												n_rnaCtrlFlg,									
												n_rnaDg,								
												n_vcEnq);

	FC_EAST: flow_control port map  (e_dataIn,
												e_dGood, 									
												e_ctrlFlg, 										
												e_vcStat, 				
												e_rnaCTR, 											
												e_rnaSel, 										
												e_doEnq,												
												e_vcData, 		
												e_rnaCtrl, 		
												e_CTR, 											
												e_stat, 		
												e_vcSel,		
												e_rnaCtrlFlg,									
												e_rnaDg,								
												e_vcEnq);

	FC_SOUTH: flow_control port map (s_dataIn,
												s_dGood, 									
												s_ctrlFlg, 										
												s_vcStat, 				
												s_rnaCTR, 											
												s_rnaSel, 										
												s_doEnq,												
												s_vcData, 		
												s_rnaCtrl, 		
												s_CTR, 											
												s_stat, 		
												s_vcSel,		
												s_rnaCtrlFlg,									
												s_rnaDg,								
												s_vcEnq);

	FC_WEST: flow_control port map  (w_dataIn,
												w_dGood, 									
												w_ctrlFlg, 										
												w_vcStat, 				
												w_rnaCTR, 											
												w_rnaSel, 										
												w_doEnq,												
												w_vcData, 		
												w_rnaCtrl, 		
												w_CTR, 											
												w_stat, 		
												w_vcSel,		
												w_rnaCtrlFlg,									
												w_rnaDg,								
												w_vcEnq);
												
end fcu_4;

