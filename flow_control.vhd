----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    18:47:06 03/15/2011 
-- Design Name: 	 BlazeRouter
-- Module Name:    flow_control - fc_4 
-- Project Name: 	 BlazeRouter
-- Description: 	 individual flow control for one direction in
--
-- Dependencies: 
--						 None
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

entity flow_control is
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
end flow_control;

architecture fc_4 of flow_control is

begin

-- This is setup is pretty much a large forwarder with dmux for control packet forwarding to RNA.	

-- Dmux for data/control packets
fc_vcData <= fc_dataIn when(fc_ctrlFlg = '0') else (others => '0');
fc_rnaCtrl <= fc_dataIn when(fc_ctrlFlg = '1') else (others => '0');

-- Control flag indicator
fc_rnaCtrlFlg <= fc_ctrlFlg;

-- Data good strobe
fc_rnaDg <= fc_dGood;

-- VC enqueue signal
fc_vcEnq <= fc_doEnq;

-- virtual channel select
fc_vcSel <= fc_rnaSel; 

-- Status flags
fc_stat <= fc_vcStat;

-- CTR indicator
fc_CTR <= fc_rnaCTR;

end fc_4;

