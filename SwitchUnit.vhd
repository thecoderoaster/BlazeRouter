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
--						 Revision 0.05 - Added data good handler/generator (KM)
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
	port ( 	Clk			: in std_logic;										-- Clock for data good
				sw_northIn 	: in std_logic_vector (WIDTH downto 0);		-- Incoming traffic from VC units
				sw_eastIn 	: in std_logic_vector (WIDTH downto 0);
				sw_southIn 	: in std_logic_vector (WIDTH downto 0);
				sw_westIn	: in std_logic_vector (WIDTH downto 0);
				sw_injct		: in std_logic_vector (WIDTH downto 0);		-- From PE
				sw_ctrlPkt	: in std_logic_vector (WIDTH downto 0);		-- From RNA (control packet)			
				sw_ejctSel	: in std_logic_vector (2 downto 0);				-- selects for mux/dmux from rna
				sw_northSel	: in std_logic_vector (2 downto 0);
				sw_eastSel	: in std_logic_vector (2 downto 0);
				sw_southSel	: in std_logic_vector (2 downto 0);
				sw_westSel	: in std_logic_vector (2 downto 0);
				
				sw_dGNorth  : in std_logic;										-- Data good signals from VC
				sw_dGEast	: in std_logic;
				sw_dGSouth	: in std_logic;
				sw_dGWest	: in std_logic;
				sw_rst		: in std_logic;										-- Switch reset for data good
				sw_injctSt	: in std_logic_vector (1 downto 0);
				
				
				sw_rnaCtFl	: out std_logic;										-- control packet indicator flag from injection packet
				sw_northOut	: out std_logic_vector (WIDTH downto 0);		-- Outgoing traffic
				sw_eastOut	: out std_logic_vector (WIDTH downto 0);	
				sw_southOut	: out std_logic_vector (WIDTH downto 0);
				sw_westOut 	: out std_logic_vector (WIDTH downto 0);
				sw_rnaCtrl  : out std_logic_vector (WIDTH downto 0);		-- Control packet to RNA
				sw_ejct		: out std_logic_vector (WIDTH downto 0);		-- To PE
				sw_dGNorthO : out std_logic;										-- Data good signal to neighbors
				sw_dGEastO	: out std_logic;
				sw_dGSouthO	: out std_logic;
				sw_dGWestO	: out std_logic);										-- This might be needed in a arbiter update (might automate by looking at packet)
				
end SwitchUnit;

architecture rtl of SwitchUnit is
	
	-- Data good generator
	signal dataGI		: std_logic;
	signal dataGA		: std_logic;
	signal dataGIndN	: std_logic;
	signal dataGIndE	: std_logic;
	signal dataGIndS	: std_logic;
	signal dataGIndW	: std_logic;
	signal northSel	: std_logic_vector (2 downto 0);
	signal eastSel		: std_logic_vector (2 downto 0);
	signal southSel	: std_logic_vector (2 downto 0);
	signal westSel		: std_logic_vector (2 downto 0);
	
	-- injection forwarder
	signal injctPkt	: std_logic_vector (WIDTH downto 0);

	-- control sense
	alias senseOp 		: std_logic is sw_injct(0);
	alias rnaSens		: std_logic is sw_ctrlPkt(0);
	
begin
	
	-- selection table
	-- north = 0
	-- east = 1
	-- south = 2
	-- west = 3
	-- injection = 5
	-- control = 7	
	
	-- Control packet sense
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
					sw_ctrlPkt when (sw_ejctSel = "111") else
					(others => '0');
			
	-- Data good generator and output
	-- general case (data from VC to switch to neighbor):

	-- VC generates a data good for all of its buffers if data exists.
	-- VC picks one of the signals (mux) depending on the output select.
	-- If the output select changes the main data good signal going out goes low for one clock cycle then back to the signals real state.
	-- If the output selected buffer goes empty the good signal goes low.
	-- The switch takes the data good signal from the VC and sends it through the switch along with the data.
	-- If the switch output select changes the data good signal going out goes low for one clock cycle and then back to the signals real state.
	-- The data good signal from the switch goes to the neighboring router.
	
	-- injection case (data from pe to switch to neighbor):
	-- switch looks at injection fifo status, if the fifo has data then data good signal gets generated as high
	-- normal data good rules from general case apply. 

	-- arbiter case (control packet from rna to switch to neighbor):
	-- arbiter will need to generate a data good unless ouput is normally zero then switch can detect for it.
	-- normal rules from general case apply.
	dataGI <= '1' when (sw_injctSt = "00" or sw_injctSt = "10") else '0'; -- injection data good generator
	dataGA <= '1' when (rnaSens = '1') else '0'; -- Arbiter data good generator 
	
	-- data good output control
	process (Clk)
	begin
	
		if(rising_edge(clk)) then
			if(sw_rst = '1') then
				northSel <= "000";
				dataGIndN <= '0';
			elsif (northSel /= sw_northSel and sw_rst = '0') then
				northSel <= sw_northSel;
				dataGIndN <= '0';
			elsif(northSel = sw_northSel and sw_rst = '0') then
				dataGIndN <= '1';
			end if;
		end if;
	
	end process;

	process (Clk)
	begin
	
		if(rising_edge(clk)) then
			if(sw_rst = '1') then
				eastSel <= "000";
				dataGIndE <= '0';
			elsif (eastSel /= sw_eastSel and sw_rst = '0') then
				eastSel <= sw_eastSel;
				dataGIndE <= '0';
			elsif(eastSel = sw_eastSel and sw_rst = '0') then
				dataGIndE <= '1';
			end if;
		end if;
	
	end process;

	process (Clk)
	begin
	
		if(rising_edge(clk)) then
			if(sw_rst = '1') then
				southSel <= "000";
				dataGIndS <= '0';
			elsif (southSel /= sw_southSel and sw_rst = '0') then
				southSel <= sw_southSel;
				dataGIndS <= '0';
			elsif(southSel = sw_southSel and sw_rst = '0') then
				dataGIndS <= '1';
			end if;
		end if;
	
	end process;
		
	process (Clk)
	begin
	
		if(rising_edge(clk)) then
			if(sw_rst = '1') then
				westSel <= "000";
				dataGIndW <= '0';
			elsif (westSel /= sw_westSel and sw_rst = '0') then
				westSel <= sw_westSel;
				dataGIndW <= '0';
			elsif(westSel = sw_westSel and sw_rst = '0') then
				dataGIndW <= '1';
			end if;
		end if;
	
	end process;
	
	-- north data good switch (mux e, s, w, in, rna)
	sw_dGNorthO <= sw_dGEast when(sw_northSel = "001" and dataGIndN = '1') else
						sw_dGSouth when(sw_northSel = "010" and dataGIndN = '1') else
						sw_dGWest when(sw_northSel = "011" and dataGIndN = '1') else
						dataGI when(sw_northSel = "101" and dataGIndN = '1') else
						dataGA when(sw_northSel = "111" and dataGIndN = '1') else
						'0';
	
	-- east data good switch (mux s, w, n, in, rna)
	sw_dGEastO <=	sw_dGSouth when(sw_eastSel = "010" and dataGIndE = '1') else
						sw_dGWest when(sw_eastSel = "011" and dataGIndE = '1') else
						sw_dGNorth when(sw_eastSel = "000" and dataGIndE = '1') else
						dataGI when(sw_eastSel = "101" and dataGIndE = '1') else
						dataGA when(sw_eastSel = "111" and dataGIndE = '1') else
						'0';
	
	-- south switch (w, n, e, in, rna)
	sw_dGSouthO <=	sw_dGWest when(sw_southSel = "011" and dataGIndS = '1') else
						sw_dGNorth when(sw_southSel = "000" and dataGIndS = '1') else
						sw_dGEast when(sw_southSel = "001" and dataGIndS = '1') else
						dataGI when(sw_southSel = "101" and dataGIndS = '1') else
						dataGA when(sw_southSel = "111" and dataGIndS = '1') else
						'0';
	
	-- west switch (n, e, s, in, rna)
	sw_dGWestO <=	sw_dGNorth when(sw_westSel = "000" and dataGIndW = '1') else
						sw_dGEast when(sw_westSel = "001" and dataGIndW = '1') else
						sw_dGSouth when(sw_westSel = "010" and dataGIndW = '1') else
						dataGI when(sw_westSel = "101" and dataGIndW = '1') else
						dataGA when(sw_westSel = "111" and dataGIndW = '1') else
						'0';
	
	
end rtl;

