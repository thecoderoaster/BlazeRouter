----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    20:26:30 03/06/2011 
-- Design Name: 	 BlazeRouter
-- Module Name:    virtual_channel - vc_4 
-- Project Name: 	 BlazeRouter
-- Description: 	 Virtual channel implmentation for the BlazeRouter design. 
--
-- Dependencies: 
--						 FIFO_mxn implmentation
-- Revision: 
-- 					 Revision 0.01 - File Created
--						 Revision 0.02 - Created entity outline (KM)
--                 Revision 0.03 - Created implmentation code (KM)
--						 Revision 0.04 - Changed some functionality to better communicate with FC (KM)
--						 Revision 0.05 - Made strobed status select indpendent from output select (KM)
--						 Revision 0.06 - Added an automated data good generator for output (KM)
--						 Revision 0.07 - Added data good generator (KM)
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

entity virtual_channel is
    Port ( 	Clk			: in 		STD_LOGIC;									-- Clock for data good generation
				VC_din 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 	-- Input data port (from FCU)
	 			VC_enq 		: in  	STD_LOGIC;									-- Enqueue latch input (from FC) (dmuxed)
				VC_deq 		: in  	STD_LOGIC;									-- Dequeue latch input (from RNA) (dmuxed)
				VC_rnaSelI 	: in  	STD_LOGIC_VECTOR (1 downto 0);		-- FIFO select for input (from RNA) 
				VC_rnaSelO 	: in  	STD_LOGIC_VECTOR (1 downto 0);		-- FIFO select for output (from RNA) 
				VC_rnaSelS	: in		STD_LOGIC_VECTOR (1 downto 0);		-- FIFO select for status (from RNA)
				VC_rst 		: in  	STD_LOGIC;									-- Master Reset (global)
				VC_strq 		: in  	STD_LOGIC;									-- Status request (from RNA) (dmuxed)
				VC_qout 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);	-- Output data port (to Switch) (muxed) 
				VC_status 	: out  	STD_LOGIC_VECTOR (1 downto 0);		-- Latched status flags of pointed FIFO (muxed)
				VC_aFull 	: out  	STD_LOGIC;									-- Asynch full flag of pointed FIFO  (muxed)
				VC_dataG		: out		STD_LOGIC);									-- Data good indicator for slected output
end virtual_channel;

architecture vc_4 of virtual_channel is

	-- using a port map of 4 FIFOs, add two dmuxes for incomming control signals on both sides of VC
	-- add mux for outgoing data bus
	
	-- select bits from a side will be use for all ops pertaining to that side
	-- (i.e fcSel = 10 will select fifo3 enq, astatus and din will point to this fifo for the FC)  

	-- FIFO definition (note: it can hold an extra flit for reasons unknown) 
	component Fifo_mxn
		
		port ( 	FIFO_din			: in  	std_logic_vector (WIDTH downto 0);	-- FIFO input port (data port)
					FIFO_enq			: in  	std_logic;									-- Enqueue item to FIFO buffer	(clocking pin)						
					FIFO_deq			: in  	std_logic;									-- Dequeue item from FIFO buffer (clocking pin)
					FIFO_rst			: in		std_logic;									-- Asynch reset 
					FIFO_strq   	: in 		std_logic;									-- Status request int
					FIFO_qout 		: out 	std_logic_vector (WIDTH downto 0);	-- FIFO output port (data port)						
					FIFO_status		: out 	std_logic_vector (1 downto 0);		-- FIFO status flags
					FIFO_aStatus	: out		std_logic_vector (1 downto 0));		-- FIFO asynch status flags (for lc)
	
	end component;


	-- signals definitions
	
	-- Data good generator signals
	signal dataGA		: std_logic;
	signal dataGB		: std_logic;
	signal dataGC		: std_logic;
	signal dataGD		: std_logic;
	signal dataGInd	: std_logic;
	signal rnaSelO		: std_logic_vector (1 downto 0);
	
	-- Data input demultiplexer signals (uses VC_fcSel)
	signal 	dataInA	: std_logic_vector (WIDTH downto 0);
	signal   dataInB  : std_logic_vector (WIDTH downto 0);
	signal	dataInC	: std_logic_vector (WIDTH downto 0);
	signal 	dataInd  : std_logic_vector (WIDTH downto 0);
	
	-- Enqueue operation demultiplexer signals (uses VC_fcSel)
	signal	enqA		: std_logic;
	signal 	enqB		: std_logic;
	signal	enqC		: std_logic;
	signal 	enqD		: std_logic;
	
	-- Dequeue operation demultiplexer signals (uses VC_rnaSel)
	signal	deqA		: std_logic;
	signal	deqB		: std_logic;
	signal	deqC		: std_logic;
	signal	deqD		: std_logic;
	
	-- Status strobe demultiplxer signals (uses VC_rnaSel)
	signal	strqA		: std_logic;
	signal	strqB		: std_logic;
	signal	strqC		: std_logic;
	signal	strqD		: std_logic;
	
	-- Data output multiplxer signals (uses VC_rnaSel)
	signal	dataOutA	: std_logic_vector (WIDTH downto 0);
	signal	dataOutB	: std_logic_vector (WIDTH downto 0);
	signal 	dataOutC	: std_logic_vector (WIDTH downto 0);
	signal 	dataOutD	: std_logic_vector (WIDTH downto 0);
	
	-- Strobed status multiplexer signals (uses VC_rnaSel)
	signal	statusA	: std_logic_vector (1 downto 0);
	signal	statusB	: std_logic_vector (1 downto 0);
	signal 	statusC	: std_logic_vector (1 downto 0);
	signal	statusD	: std_logic_vector (1 downto 0);
	
	-- Asynch status multiplexer signals (uses VC_fcSel)
	signal	aStatusA	: std_logic_vector (1 downto 0);
	signal	aStatusB	: std_logic_vector (1 downto 0);
	signal	aStatusC	: std_logic_vector (1 downto 0);
	signal	aStatusD	: std_logic_vector (1 downto 0);	
	
	-- Aliases for full status flag to FC
	alias		fullFlgA : std_logic is aStatusA(1);
	alias		fullFlgB : std_logic is aStatusB(1);
	alias		fullFlgC : std_logic is aStatusC(1);
	alias		fullFlgD : std_logic is aStatusD(1);
	
begin

	-- Port map of FIFO
	
	
	FIFO_A : Fifo_mxn port map ( dataInA,
											  enqA,
											  deqA,
											VC_rst,
											 strqA,
										 dataOutA,
										  statusA,
										 aStatusA);
	
	FIFO_B : Fifo_mxn port map ( dataInB,
											  enqB,
											  deqB,
											VC_rst,
											 strqB,
										 dataOutB,
										  statusB,
										 aStatusB);
										 
	FIFO_C : Fifo_mxn port map ( dataInC,
											  enqC,
											  deqC,
											VC_rst,
											 strqC,
										 dataOutC,
										  statusC,
										 aStatusC);
										 
	FIFO_D : Fifo_mxn port map ( dataInD,
											  enqD,
											  deqD,
											VC_rst,
											 strqD,
										 dataOutD,
										  statusD,
										 aStatusD);										 


	-- Data good generation component
	-- general case (data from VC to switch to neighbor):

	-- VC generates a data good for all of its buffers if data exists.
	-- VC picks one of the signals (mux) depending on the output select.
	-- If the output select changes the main data good signal going out goes low for one clock cycle then back to the signals real state.
	-- If the output selected buffer goes empty the good signal goes low.

	-- The switch takes the data good signal from the VC and sends it through the switch along with the data.
	-- If the switch output select changes the data good signal going out goes low for one clock cycle and then back to the signals real state.
	-- The data good signal from the switch goes to the neighboring router.

	-- If a dequeue is being performed then the data good will do low momentarailty.

	-- data good generators
	dataGA <= '1' when (aStatusA = "00" or aStatusA = "10") else '0';
	dataGB <= '1' when (aStatusB = "00" or aStatusB = "10") else '0';
	dataGC <= '1' when (aStatusC = "00" or aStatusC = "10") else '0';
	dataGD <= '1' when (aStatusD = "00" or aStatusD = "10") else '0';

	-- data good output control
	process (Clk, VC_deq)
	begin
	
		if(rising_edge(CLK)) then
			if (VC_rst = '1') then
				rnaSelO <= "00";
				dataGInd <= '0';	
			elsif (rnaSelO /= VC_rnaSelO and VC_rst = '0') then
				dataGInd <= '0';
				rnaSelO <= VC_rnaSelO;
			elsif(rnaSelO = VC_rnaSelO and VC_rst = '0') then
					dataGInd <= '1';
			end if;
		end if;
	
	end process;

	-- data good out mux
	VC_dataG <= dataGA when (VC_rnaSelO = "00" and dataGInd = '1' and VC_deq = '0') else
					dataGB when (VC_rnaSelO = "01" and dataGInd = '1' and VC_deq = '0') else
					dataGC when (VC_rnaSelO = "10" and dataGInd = '1' and VC_deq = '0') else
					dataGD when (VC_rnaSelO = "11" and dataGInd = '1' and VC_deq = '0') else
					'0';

	-- Demux/Mux Land
	
	-- FIFO A = "00"
	-- FIFO B = "01"
	-- FIFO C = "10"
	-- FIFO D = "11"
	
	-- data bus
	dataInA <= VC_din;
	dataInB <= VC_din;
	dataInC <= VC_din;
	dataInD <= VC_din;
	
	-- enqueue demux
	enqA <= VC_enq when (VC_rnaSelI = "00") else '0';
	enqB <= VC_enq when (VC_rnaSelI = "01") else '0';
	enqC <= VC_enq when (VC_rnaSelI = "10") else '0';
	enqD <= VC_enq when (VC_rnaSelI = "11") else '0';
	
	-- dequeue demux
	deqA <= VC_deq when (VC_rnaSelO = "00") else '0';
	deqB <= VC_deq when (VC_rnaSelO = "01") else '0';
	deqC <= VC_deq when (VC_rnaSelO = "10") else '0';
	deqD <= VC_deq when (VC_rnaSelO = "11") else '0';
	
	-- status strobe demux
	strqA <= VC_strq when (VC_rnaSelS = "00") else '0';
	strqB <= VC_strq when (VC_rnaSelS = "01") else '0';
	strqC <= VC_strq when (VC_rnaSelS = "10") else '0';
	strqD <= VC_strq when (VC_rnaSelS = "11") else '0';	
	
	-- data out mux
	VC_qout <= 	dataOutA when (VC_rnaSelO = "00") else
					dataOutB when (VC_rnaSelO = "01") else
					dataOutC when (VC_rnaSelO = "10") else
					dataOutD when (VC_rnaSelO = "11") else
					(others => '0');

	-- strobe status out mux
	VC_status <= 	statusA when (VC_rnaSelS = "00") else
						statusB when (VC_rnaSelS = "01") else
						statusC when (VC_rnaSelS = "10") else
						statusD when (VC_rnaSelS = "11") else
						(others => '0');
	
	-- aFull status out mux
	VC_aFull	 <= 	fullFlgA when (VC_rnaSelI = "00") else
						fullFlgB when (VC_rnaSelI = "01") else
						fullFlgC when (VC_rnaSelI = "10") else
						fullFlgD when (VC_rnaSelI = "11") else
						'0';

end vc_4;

