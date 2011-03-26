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
--						 Revision 0.03 - Added functional code (KM) (not synthed yet)
--						 Revision 0.04 - Added additional signals (KM) (synthed)
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
	port ( 	sw_northIn 	: in std_logic_vector (WIDTH downto 0);		-- Incoming traffic from VC units
				sw_eastIn 	: in std_logic_vector (WIDTH downto 0);
				sw_southIn 	: in std_logic_vector (WIDTH downto 0);
				sw_westIn	: in std_logic_vector (WIDTH downto 0);
				sw_injct		: in std_logic_vector (WIDTH downto 0);		-- From Processor Logic Bus
				sw_ctrlPkt	: in std_logic_vector (WIDTH downto 0);		-- From RNA (control packet)			
				sw_ejctSel	: in std_logic_vector (1 downto 0);				-- selects for mux/dmux from rna
				sw_northSel	: in std_logic_vector (2 downto 0);
				sw_eastSel	: in std_logic_vector (2 downto 0);
				sw_southSel	: in std_logic_vector (2 downto 0);
				sw_westSel	: in std_logic_vector (2 downto 0);
				
				sw_rnaCtFl	: out std_logic;										-- control packet indicator flag
				sw_northOut	: out std_logic_vector (WIDTH downto 0);		-- Outgoing traffic
				sw_eastOut	: out std_logic_vector (WIDTH downto 0);	
				sw_southOut	: out std_logic_vector (WIDTH downto 0);
				sw_westOut 	: out std_logic_vector (WIDTH downto 0);
				sw_rnaCtrl  : out std_logic_vector (WIDTH downto 0);		-- Control packet to RNA
				sw_ejct		: out std_logic_vector (WIDTH downto 0));		-- To Processor Logic Bus
end SwitchUnit;

architecture rtl of SwitchUnit is
	
	-- injection forwarder
	signal injctPkt	: std_logic_vector (WIDTH downto 0);

	-- control sense
	alias senseOp 		: std_logic is sw_injct(0);
	
begin
	
	-- selection table
	-- north = 0
	-- east = 1
	-- south = 2
	-- west = 3
	-- injection = 5
	-- control = 7	
	
	sw_rnaCtFl <= senseOp;
	
	-- Dmux for injection (injctPkt, rna)
	sw_rnaCtrl <= sw_injct when (senseOp = '1') else (others => '0');
	injctPkt <= sw_injct when (senseOp = '0') else (others => '0');
	
	
	-- north switch (mux e, s, w, in, rna)
	sw_northOut <= sw_eastIn when(sw_northSel = "001") else
						sw_southIn when(sw_northSel = "010") else
						sw_westIn when(sw_northSel = "011") else
						injctPkt when(sw_northSel = "101") else
						sw_ctrlPkt when(sw_northSel = "111") else
						(others => '0');
	
	-- east switch (mux s, w, n, in, rna)
	sw_eastOut <=	sw_southIn when(sw_eastSel = "010") else
						sw_westIn when(sw_eastSel = "011") else
						sw_northIn when(sw_eastSel = "000") else
						injctPkt when(sw_eastSel = "101") else
						sw_ctrlPkt when(sw_eastSel = "111") else
						(others => '0');
	
	-- south switch (w, n, e, in, rna)
	sw_southOut <=	sw_westIn when(sw_southSel = "011") else
						sw_northIn when(sw_southSel = "000") else
						sw_eastIn when(sw_southSel = "001") else
						injctPkt when(sw_southSel = "101") else
						sw_ctrlPkt when(sw_southSel = "111") else
						(others => '0');
	
	-- west switch (n, e, s, in, rna)
	sw_westOut <=	sw_northIn when(sw_westSel = "000") else
						sw_eastIn when(sw_westSel = "001") else
						sw_southIn when(sw_westSel = "010") else
						injctPkt when(sw_westSel = "101") else
						sw_ctrlPkt when(sw_westSel = "111") else
						(others => '0');
			
	-- ejection switch (n, e, s, w)
	sw_ejct <= sw_northIn when(sw_ejctSel = "000") else
					sw_eastIn when(sw_ejctSel = "001") else
					sw_southIn when(sw_ejctSel = "010") else
					sw_westIn when(sw_ejctSel = "011") else
					(others => '0');

end rtl;

