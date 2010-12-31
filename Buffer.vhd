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
-- 					Revision 0.01 - File Created
--						Revision 0.02 - Added additional modules (KVH)
--						Revision 0.03 - Changed entity definition, added functional code (KM)
--						Revision 0.04 - Made both input and output be able use different speeds (KM)
--						Revision 0.05 - Fixed possible metastability bug (KM)
--						Revision 0.06 - Added status request process (KM)
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

entity Fifo_mxn is 
    port ( 	FIFO_din		: in  	std_logic_vector (WIDTH downto 0);	-- FIFO input port (data port)
				FIFO_enq		: in  	std_logic;									-- Enqueue item to FIFO buffer	(clocking pin)						
				FIFO_deq		: in  	std_logic;									-- Dequeue item from FIFO buffer (clocking pin)
				FIFO_rst		: in		std_logic;									-- Asynch reset
				FIFO_strq   : in 		std_logic;									-- Status request int
				FIFO_qout 	: out 	std_logic_vector (WIDTH downto 0);	-- FIFO output port (data port)						
				FIFO_status	: out 	std_logic_vector (1 downto 0));		-- FIFO status flags							
end Fifo_mxn;

architecture rtl of FIFO_MXN is

	-- signals
	signal 	hdCnt, tlCnt 				: integer range 0 to SIZE;
	signal 	fifoReg						: fifoBuf;
	signal 	full_flag, empty_flag	: std_logic;
	signal 	need_tlInc_flag			: std_logic;
	signal  	almost_full_flag			: std_logic;

begin
	
	-- FIFO enqueue process 
	process(FIFO_enq, FIFO_rst)
	begin
	
		if(FIFO_rst = '1') then
				almost_full_flag <= '0';
				need_tlInc_flag <= '0';
				tlCnt <= 0;
		

		-- if there is an empty condition then reset the flags
		--	if(empty_flag = '1') then
		--		almost_full_flag <= '0';
		--		need_tlInc_flag <= '0';
		--	end if;

		elsif (rising_edge(FIFO_enq) and FIFO_rst = '0') then
		
			-- TODO: update this comment block
			-- enqueue a flit into the fifo 
			-- there must be no full condition
			-- writing is immediate
			-- tell the flag processes that a write has occured
			
			if(full_flag = '0') then
				
				-- if we need to make an emergency inc of the tail counter before writing
				if(need_tlInc_flag = '1' and (tlCnt + 1 /= hdCnt)) then
					tlCnt <= tlCnt + 1;
					need_tlInc_flag <= '0';
					
					-- See if we are still near full condition 
					if(tlCnt + 1 = hdCnt) then
						almost_full_flag <= '1';
					else
						almost_full_flag <= '0';
					end if;
				end if;
			
				-- write the flit to the buffer
				fifoReg(tlCnt) <= FIFO_din;
				
				if(almost_full_flag = '0') then -- check if we are on the verge of filling up the buffer
					tlCnt <= tlCnt + 1;
					if(tlCnt + 1 = hdCnt) then
						almost_full_flag <= '1';
					end if;
				else 
					if(tlCnt + 1 = hdCnt) then -- last free space filled
						need_tlInc_flag <= '1';
						almost_full_flag <= '0';
					end if;					
				end if;
				
			end if;
		end if;
	end process;

	-- FIFO dequeue process
	process (FIFO_deq, FIFO_rst)
	begin	
		
		if(FIFO_rst = '1') then
				hdCnt <= 0;
		
	
		elsif (rising_edge(FIFO_deq) and FIFO_rst = '0') then
		
			-- dequque a flit from the fifo
			-- there must be no empty condition
			-- increase the head counter 
			-- we dont care about clearing data since cell is 'marked' as unused
			-- tell the flag processes that a read has occured

			if(empty_flag = '0') then
					hdCnt <= hdCnt + 1;
			end if;
		end if;
	end process;

	-- FIFO status request process
	process(FIFO_strq)
	begin
	
		if(rising_edge(FIFO_strq)) then
			FIFO_status <= full_flag & empty_flag;
		end if;
	
	end process;

	-- Clock insensitive processing (output stuff)
	
	-- output front of fifo buffer - first flit in queue is always put on the output	
	FIFO_qout <= fifoReg(hdCnt);

	-- check and update the full and empty flags anytime something changes
	-- The buffer will still report full until the need_tlInc flag is cleared
	full_flag <= '1' when (((tlCnt + 1) = hdCnt) and almost_full_flag = '0') else '0';
	empty_flag <= '1' when (tlCnt = hdCnt) else '0';

end rtl;
