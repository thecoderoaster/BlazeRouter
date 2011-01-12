----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    13:54:10 12/20/2010 
-- Design Name: 	 BlazeRouter
-- Module Name:    LinkController - RTL 
-- Project Name: 	 BlazeRouter
-- Target Devices: xc4vsx35-10ff668
-- Tool versions:  Using ISE 10.1.03
-- Description: 
--						 Part of the BlazeRouter design, the LinkController establishes
--						 and synchronizes with adjacent routers by asserting or rejecting
--						 incoming transfers through the (N,S,E,W) ports. 
--
-- Dependencies: 
--						 None
-- Revision: 
-- 					 Revision 0.01 - File Created
--						 Revision 0.02 - Added additional modules (KVH)
--						 Revision 0.03 - Added implmentation, changed IO ports (synthed) (KM)
--
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

entity LinkController is
    port (	clk					: in    	std_logic;									-- A clock is needed to progress the fsm
				data_in				: in		std_logic_vector(WIDTH downto 0);	-- Data from link(rx)/fifo(tx)
				lc_type			   : in		std_logic;									-- Defines if LC is a TX or RX
				status				: in    	std_logic;									-- Gets status on fifo (i.e: Full/Empty)
				CTR_flag 			: inout 	std_logic;									-- Receive Ready
				TX_latch 			: inout 	std_logic;									-- Transmission Request	
				data_out				: out 	std_logic_vector(WIDTH downto 0);	-- Data to link(tx)/fifo(rx)
				buffer_en			: out   	std_logic);									-- Add/Remove signal for fifo
				
end LinkController;



architecture rtl of LinkController is

	signal fsmctr	:std_logic_vector(1 downto 0);

begin

	-- TX fsm is made up of 4 states (lc_type = '0')
	-- state 1: idle stage - fifo to not be empty
	-- state 2: waiting stage - wait until ctr goes high from other end
	-- state 3: latching data stage - set tx_latch and wait a cycle
	-- state 4: return stage - clear tx_latch and update fifo then return to idle state
	
	-- RX fsm is made up of 4 states (lc_type = '1')
	-- state 1: idle stage - waiting for a non full fifo
	-- state 2: clear to recv stage - ready for data, awaiting transmit latch
	-- state 3: latching data stage - writing data to fifo - clear ctr
	-- state 4: return stage - clear buffer_en return to idle
	process(CTR_flag, TX_latch, clk, status, lc_type)
	begin
	
--		if(((fsmctr = "00") and (status = '0')) or 
--			((rising_edge(CTR_flag) and lc_type = '0') and (fsmctr = "01")) or
--			((rising_edge(TX_latch) and lc_type = '1') and (fsmctr = "01")) or 
--			((rising_edge(clk)) and ((fsmctr = "10") or (fsmctr = "11")))) then
--			
--			fsmctr <= fsmctr + 1;
--			
--		end if;
		if(rising_edge(clk)) then
			case fsmctr is
				when "00" =>
					if(status = '0') then
						fsmctr <= fsmctr + 1;
					end if;
				
				when "01" =>
					if(lc_type = '1') then
						if(TX_latch = '1') then
							fsmctr <= fsmctr + 1;
						end if;
					else
						if(CTR_flag = '1') then
							fsmctr <= fsmctr + 1;
						end if;
					end if;
			
				when others =>
					fsmctr <= fsmctr + 1;
			end case;	
		end if;
		
	end process;

	-- clock insensitive processing for TX LC
	TX_latch <= '1' when (fsmctr = "10" and lc_type = '0') else  
					'0' when (fsmctr /= "10" and lc_type = '0');
	
	-- clock insensitive processing for RX LC
	CTR_flag <= '1' when (fsmctr = "01" and lc_type = '1') else 
					'0' when (fsmctr /= "01" and lc_type = '1');

	-- clock insensitive processing for any type LC
	buffer_en <= '1' when ((fsmctr = "10" and lc_type = '1') or (fsmctr = "11" and lc_type = '0')) else '0';
	data_out <= data_in;
	
end rtl;



