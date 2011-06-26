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
--						 Revision 0.03 - Revised entity and components (KM)
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
	 
    port ( north_data_in 		: in std_logic_vector (WIDTH downto 0);	-- Datalink from neighbor (FCU)
	 		  north_din_good		: in std_logic;									-- Data good indicator from neighbor to FCU (FCU)
			  north_CTR_in			: in std_logic;									-- CTR indicator from neighbor to arbiter indicating ready to recieve (RNA)
			  north_data_out		: out std_logic_vector (WIDTH downto 0);	-- Datalink to neighbor (SW)
			  north_dout_good		: out std_logic;									-- Data good indicator to neighbor (SW)
			  north_CTR_out		: out std_logic;									-- CTR indicator from FCU to neighbor for accpeting data (FCU)
			  
			  east_data_in 		: in std_logic_vector (WIDTH downto 0);
	 		  east_din_good		: in std_logic;
			  east_CTR_in			: in std_logic;
			  east_data_out		: out std_logic_vector (WIDTH downto 0);
			  east_dout_good		: out std_logic;
			  east_CTR_out			: out std_logic; 									
			  
			  south_data_in 		: in std_logic_vector (WIDTH downto 0);
	 		  south_din_good		: in std_logic;
			  south_CTR_in			: in std_logic;
			  south_data_out		: out std_logic_vector (WIDTH downto 0);
			  south_dout_good		: out std_logic;
			  south_CTR_out		: out std_logic;
			  
			  west_data_in 		: in std_logic_vector (WIDTH downto 0);
	 		  west_din_good		: in std_logic;
			  west_CTR_in			: in std_logic;
			  west_data_out		: out std_logic_vector (WIDTH downto 0);
			  west_dout_good		: out std_logic;
			  west_CTR_out		 	: out std_logic;
			  
			  injection_data		: in  std_logic_vector (WIDTH downto 0); -- Datalink from PE
			  injection_enq		: in  std_logic;								  -- Buffer enqueue from PE
			  injection_status	: out std_logic_vector (1 downto 0);	  -- Buffer status to PE
			  
			  ejection_data		: out std_logic_vector (WIDTH downto 0); -- Datalink to PE
			  ejection_deq			: in std_logic;								  -- Buffer dequeue from PE
			  ejection_status		: out std_logic_vector (1 downto 0);	  -- Buffer status to PE
			  
			  
			  clk						: in std_logic; 	-- global clock
			  reset					: in std_logic);	-- global reset
end BlazeRouter;

architecture rtl of BlazeRouter is
	--Define Components here that will make up the design
	--Refer to each .vhd module for definitions on ports

	-- For injection and ejection buffers
	component Fifo_mxn is 
		 port ( 	FIFO_din			: in  	std_logic_vector (WIDTH downto 0);	-- FIFO input port (data port)
					FIFO_enq			: in  	std_logic;									-- Enqueue item to FIFO buffer	(clocking pin)						
					FIFO_deq			: in  	std_logic;									-- Dequeue item from FIFO buffer (clocking pin)
					FIFO_rst			: in		std_logic;									-- Asynch reset
					FIFO_strq   	: in 		std_logic;									-- Status request int
					FIFO_qout 		: out 	std_logic_vector (WIDTH downto 0);	-- FIFO output port (data port)						
					FIFO_status		: out 	std_logic_vector (1 downto 0);		-- FIFO status flags
					FIFO_aStatus	: out		std_logic_vector (1 downto 0));		-- FIFO asynch status flags (for lc)							
	end component;
	
	-- For storage of data from network
	component virtual_channel is
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
	end component;
	
	-- Router control unit
	component Arbiter is
		port (
			--Internal
			clk : in std_logic;
			reset : in std_logic;
			
			-- VC related
			n_vc_fStatSel : out std_logic_vector (1 downto 0);
			n_vc_enqSel : out std_logic_vector (1 downto 0);
			n_vc_statSel : out std_logic_vector (1 downto 0);
			n_vc_status : in std_logic_vector (1 downto 0);
			n_vc_statStrbSel : out std_logic_vector (1 downto 0);
			n_vc_statStrb : out std_logic;
			n_vc_dataOutSel : out std_logic_vector (1 downto 0);
			n_vc_deqSel : out std_logic_vector (1 downto 0);
			n_vc_deq : out std_logic;

			e_vc_fStatSel : out std_logic_vector (1 downto 0);
			e_vc_enqSel : out std_logic_vector (1 downto 0);
			e_vc_statSel : out std_logic_vector (1 downto 0);
			e_vc_status : in std_logic_vector (1 downto 0);
			e_vc_statStrbSel : out std_logic_vector (1 downto 0);
			e_vc_statStrb : out std_logic;
			e_vc_dataOutSel : out std_logic_vector (1 downto 0);
			e_vc_deqSel : out std_logic_vector (1 downto 0);
			e_vc_deq : out std_logic;

			s_vc_fStatSel : out std_logic_vector (1 downto 0);
			s_vc_enqSel : out std_logic_vector (1 downto 0);
			s_vc_statSel : out std_logic_vector (1 downto 0);
			s_vc_status : in std_logic_vector (1 downto 0);
			s_vc_statStrbSel : out std_logic_vector (1 downto 0);
			s_vc_statStrb : out std_logic;
			s_vc_dataOutSel : out std_logic_vector (1 downto 0);
			s_vc_deqSel : out std_logic_vector (1 downto 0);
			s_vc_deq : out std_logic;

			w_vc_fStatSel : out std_logic_vector (1 downto 0);
			w_vc_enqSel : out std_logic_vector (1 downto 0);
			w_vc_statSel : out std_logic_vector (1 downto 0);
			w_vc_status : in std_logic_vector (1 downto 0);
			w_vc_statStrbSel : out std_logic_vector (1 downto 0);
			w_vc_statStrb : out std_logic;
			w_vc_dataOutSel : out std_logic_vector (1 downto 0);
			w_vc_deqSel : out std_logic_vector (1 downto 0);
			w_vc_deq : out std_logic;
			
			--FCU Related
			n_CTRflg : out std_logic; -- Send a CTR to neighbor for packet
			e_CTRflg : out std_logic;
			s_CTRflg : out std_logic;
			w_CTRflg : out std_logic;
			n_CtrlFlg : in std_logic; --Receive a control packet flag from neighbor 
			e_CtrlFlg : in std_logic; --(data good from neighbor via fcu)
			s_CtrlFlg : in std_logic;
			w_CtrlFlg : in std_logic;

			--Scheduler Related (FCU)
			n_rnaCtrl : in std_logic_vector(RSV_WIDTH-1 downto 0); -- Control Packet 
			e_rnaCtrl : in std_logic_vector(RSV_WIDTH-1 downto 0);
			s_rnaCtrl : in std_logic_vector(RSV_WIDTH-1 downto 0);
			w_rnaCtrl : in std_logic_vector(RSV_WIDTH-1 downto 0);
			
			--Switch Related 
			n_dSel : out std_logic_vector (2 downto 0); -- Select lines for data direction
			e_dSel : out std_logic_vector (2 downto 0);
			s_dSel : out std_logic_vector (2 downto 0);
			w_dSel : out std_logic_vector (2 downto 0);
			ejct_dSel : out std_logic_vector (2 downto 0);

			rna_ctrlPkt : out std_logic_vector (RSV_WIDTH-1 downto 0); -- Control packet generator output
			injt_ctrlPkt : in std_logic_vector (WIDTH downto 0)); -- Control packet from PE

		end component;

	-- Flow control for network neighbors
	component fcu is
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
	end component;
	
	-- Switch unit for router
	component SwitchUnit is
		port (Clk			: in std_logic;										-- Clock for data good
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
				
				sw_rnaCtFl	: out std_logic;										-- control packet indicator flag
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
				
	end component;
	
	-- Signal Definitions
	-- signals between VC and RNA (need to route) (rna needs signals routed to it)
	signal rnaVcNorthDq		: std_logic;							-- Dequeue signal from RNA to VC
	signal rnaVcEastDq		: std_logic;
	signal rnaVcSouthDq		: std_logic;
	signal rnaVcWestDq		: std_logic;
	signal rnaVcNorthSelI	: std_logic_vector (1 downto 0); -- VC input select from RNA to VC
	signal rnaVcEastSelI		: std_logic_vector (1 downto 0);
	signal rnaVcSouthSelI	: std_logic_vector (1 downto 0);
	signal rnaVcWestSelI		: std_logic_vector (1 downto 0);
	signal rnaVcNorthSelO	: std_logic_vector (1 downto 0); -- VC output select from RNA to VC
	signal rnaVcEastSelO		: std_logic_vector (1 downto 0);	
	signal rnaVcSouthSelO	: std_logic_vector (1 downto 0);
	signal rnaVcWestSelO		: std_logic_vector (1 downto 0);
	signal rnaVcNorthSelS	: std_logic_vector (1 downto 0); -- Status select from RNA to VC
	signal rnaVcEastSelS		: std_logic_vector (1 downto 0);
	signal rnaVcSouthSelS	: std_logic_vector (1 downto 0);
	signal rnaVcWestSelS		: std_logic_vector (1 downto 0);
	signal rnaVcNorthStrq	: std_logic; -- Status strobe from RNA to VC
	signal rnaVcEastStrq		: std_logic;	
	signal rnaVcSouthStrq	: std_logic;
	signal rnaVcWestStrq		: std_logic;
	signal vcRnaNorthStat	: std_logic_vector (1 downto 0); -- Status word from VC to RNA
	signal vcRnaEastStat		: std_logic_vector (1 downto 0);
	signal vcRnaSouthStat	: std_logic_vector (1 downto 0);
	signal vcRnaWestStat		: std_logic_vector (1 downto 0);	
	
	-- signals between FC and VC (need to route)
	signal fcVcNorth		: std_logic_vector (WIDTH downto 0); -- Data from FC to VC
	signal fcVcEast		: std_logic_vector (WIDTH downto 0);
	signal fcVcSouth		: std_logic_vector (WIDTH downto 0);
	signal fcVcWest		: std_logic_vector (WIDTH downto 0);
	signal fcVcNorthEnq	: std_logic; -- Enqueue from FC to VC
	signal fcVcEastEnq	: std_logic;
	signal fcVcSouthEnq	: std_logic;
	signal fcVcWestEnq	: std_logic;
	signal vcFcNorthFull : std_logic; -- Fuall status flag from VC to FC
	signal vcFcEastFull  : std_logic;
	signal vcFcSouthFull : std_logic;
	signal vcFcWestFull  : std_logic;
	
	-- signals between FC and neighbor (change entity)
	
	-- signals between FC and RNA (need to route) (rna needs signals routed to it)
	signal rnaFcNorthCtrFlg	: std_logic;	-- Control Flag from RNA to FC
	signal rnaFcEastCtrFlg	: std_logic;
	signal rnaFcSouthCtrFlg	: std_logic;
	signal rnaFcWestCtrFlg	: std_logic;
	signal fcRnaNorthCtPkt	: std_logic_vector (WIDTH to 0); -- Data from FC to RNA (control packets)
	signal fcRnaEastCtPkt	: std_logic_vector (WIDTH to 0);
	signal fcRnaSouthCtPkt	: std_logic_vector (WIDTH to 0);
	signal fcRnaWestCtPkt	: std_logic_vector (WIDTH to 0);	
	signal fcRnaNorthCStrb	: std_logic;	-- Control strobe indicator from FC to RNA
	signal fcRnaEastCStrb	: std_logic;
	signal fcRnaSouthCStrb	: std_logic;
	signal fcRnaWestCStrb	: std_logic;	
	
	-- signals between switch and VC (routed)
	signal vcSwNorth 		: std_logic_vector(WIDTH downto 0); -- Data output from VC to Switch
	signal vcSwEast  		: std_logic_vector(WIDTH downto 0); 	
	signal vcSwSouth 		: std_logic_vector(WIDTH downto 0); 
	signal vcSwWest  		: std_logic_vector(WIDTH downto 0); 
	signal vcSwDGNorth	: std_logic;
	signal vcSwDGEast		: std_logic;
	signal vcSwDGSouth	: std_logic;
	signal vcSwDGWest		: std_logic;
	
	-- signals between switch and RNA (routed) (rna needs signals routed to it)
	signal swRnaCtrlFlg	: std_logic; -- Control flag indicator from Switch to RNA
	signal rnaSwNorthSel : std_logic_vector (2 downto 0); -- Switch function control from RNA to Switch
	signal rnaSwEastSel 	: std_logic_vector (2 downto 0);
	signal rnaSwSouthSel : std_logic_vector (2 downto 0);
	signal rnaSwWestSel 	: std_logic_vector (2 downto 0);
	signal rnaSwEjectSel : std_logic_vector (2 downto 0);
	signal rnaSwCtrlPktO	: std_logic_vector (WIDTH downto 0); -- Control packet from RNA to Switch (to outside)
	signal swRnaCtrlPktI	: std_logic_vector (WIDTH downto 0); -- Control packet from Switch to RNA (from PE)
	
	-- signals between switch and PE FIFOs (routed)
	signal fifoSwInjct	: std_logic_vector (WIDTH downto 0); -- Packet data from injection FIFO to Switch
	signal swFifoEject	: std_logic_vector (WIDTH downto 0); -- Packet data from Switch to ejection FIFO 
	
	-- signals between PE FIFOs and RNA
	signal rnaeFifoEnq		: std_logic; 							-- for ejection fifo
	signal rnaiFifoDeq		: std_logic; 							-- for injection fifo
	signal rnaiFifoStrq		: std_logic; 							-- statust request for fifos
	signal rnaeFifoStrq		: std_logic;
	signal iFifoRnaStat		: std_logic_vector (1 downto 0);	-- Status signals for fifos
	signal eFifoRnaStat		: std_logic_vector (1 downto 0); 
	signal iFifoaStat			: std_logic_vector (1 downto 0);
	
begin
	--Instantiate components here to create the overall functionality
	
	-- Arbiter Unit
	ar: Arbiter port map (	clk,  -- *** -- Internal
									reset, -- ***
									
									n_vc_fStatSel, -- not needed controled by I
									rnaVcNorthSelI,
									n_vc_statSel, -- not needed  controlled by S
									vcRnaNorthStat,
									rnaVcNorthSelS,
									rnaVcNorthStrq,
									rnaVcNorthSelO,
									n_vc_deqSel, -- not needed controled by O
									rnaVcNorthDq,

									e_vc_fStatSel, -- not needed controled by I
									rnaVcEastSelI,
									e_vc_statSel, -- not needed  controlled by S
									vcRnaEastStat,
									rnaVcEastSelS,
									rnaVcEastStrq,
									rnaVcEastSelO,
									e_vc_deqSel, -- not needed controled by O
									rnaVcEastDq,

									s_vc_fStatSel, -- not needed controled by I
									rnaVcSouthSelI,
									s_vc_statSel, -- not needed  controlled by S
									vcRnaSouthStat,
									rnaVcSouthSelS,
									rnaVcSouthStrq,
									rnaVcSouthSelO,
									s_vc_deqSel, -- not needed controled by O
									rnaVcSouthDq,

									w_vc_fStatSel, -- not needed controled by I
									rnaVcWestSelI,
									w_vc_statSel, -- not needed  controlled by S
									vcRnaWestStat,
									rnaVcWestSelS,
									rnaVcWestStrq,
									rnaVcWestSelO,
									w_vc_deqSel, -- not needed controled by O
									rnaVcWestDq,
									
									--FCU Related
									rnaFcNorthCtrFlg, -- Send a CTR to neighbor for packet
									rnaFcEastCtrFlg,
									rnaFcSouthCtrFlg,
									rnaFcWestCtrFlg,
									fcRnaNorthCStrb, --Receive a control packet flag from neighbor 
									fcRnaEastCStrb, --(data good from neighbor via fcu)
									fcRnaSouthCStrb,
									fcRnaWestCStrb,

									--Scheduler Related
									fcRnaNorthCtPkt, -- Control Packet 
									fcRnaEastCtPkt,
									fcRnaSouthCtPkt,
									fcRnaWestCtPkt,
									
									--Switch Related
									rnaSwNorthSel, -- Select lines for data direction
									rnaSwEastSel,
									rnaSwSouthSel,
									rnaSwWestSel,
									rnaSwEjectSel,
									
									rnaSwCtrlPktO, -- Control packet generator output
									swRnaCtrlPktI); -- Control packet from PE
									
	
	--Flow Control Unit (Routed except for TLM ports)
	-- *** denotes a connection to the TLM entity port.
	flowCtrl: fcu port map(	rnaFcNorthCtrFlg,	-- Clear To Recieve flag (from RNA)  (All directions need it)
									north_data_in, 	-- Input data port (from neighbor) ***
									north_din_good,	-- Data strobe (from neighbor) ***
									vcFcNorthFull,		-- Full status flag (from VC) 
									fcVcNorth,			-- Data port (to VC) 
									fcRnaNorthCtPkt,	-- Data port (to RNA) 
									fcRnaNorthCStrb,	-- Control packet strobe (to RNA) 
									north_CTR_out,		-- Clear to Recieve (to neighbor) ***
									fcVcNorthEnq,		-- enqueue command from RNA (to VC)
				
									rnaFcEastCtrFlg,	-- Clear To Recieve flag (from RNA)
									east_data_in, 		-- Input data port (from neighbor) ***
									east_din_good,		-- Data strobe (from neighbor) ***
									vcFcEastFull,		-- Full status flag (from VC)
									fcVcEast,			-- Data port (to VC)
									fcRnaEastCtPkt,	-- Data port (to RNA)
									fcRnaEastCStrb,	-- Control packet strobe (to RNA)
									east_CTR_out,		-- Clear to Recieve (to neighbor) ***
									fcVcEastEnq,		-- enqueue command from RNA (to VC)
				
									rnaFcSouthCtrFlg,	-- Clear To Recieve flag (from RNA)
									south_data_in, 	-- Input data port (from neighbor) ***
									south_din_good,	-- Data strobe (from neighbor) ***
									vcFcSouthFull,		-- Full status flag (from VC)
									fcVcSouth,			-- Data port (to VC)
									fcRnaSouthCtPkt,	-- Data port (to RNA)
									fcRnaSouthCStrb,	-- Control packet strobe (to RNA)
									south_CTR_out,		-- Clear to Recieve (to neighbor) ***
									fcVcSouthEnq,		-- enqueue command from RNA (to VC)
				
									rnaFcWestCtrFlg,	-- Clear To Recieve flag (from RNA)
									west_data_in, 		-- Input data port (from neighbor) ***
									west_din_good,		-- Data strobe (from neighbor) ***
									vcFcWestFull,		-- Full status flag (from VC)
									fcVcWest,			-- Data port (to VC)
									fcRnaWestCtPkt,	-- Data port (to RNA)
									fcRnaWestCStrb,	-- Control packet strobe (to RNA)
									west_CTR_out,		-- Clear to Recieve (to neighbor) ***
									fcVcWestEnq);		-- enqueue command from RNA (to VC)
	
	
	--Virtual Channels 
	-- ** needs route to signal
	vcNorth: virtual_channel port map( 	clk,					-- Clock pin ***
													fcVcNorth, 			-- Input data port (from FC)
													fcVcNorthEnq,		-- Enqueue latch input (from FC) dmuxed
													rnaVcNorthDq,		-- Dequeue latch input (from RNA) dmuxed
													rnaVcNorthSelI,	-- FIFO select for input (from RNA)
													rnaVcNorthSelO,	-- FIFO select for output (from RNA)
													rnaVcNorthSelS,	-- FIFO select for status (from RNA)
													reset,				-- Master Reset (global) *** 
													rnaVcNorthStrq,	-- Status request (from RNA) (dmuxed) 
													vcSwNorth, 			-- Output data port (to Switch) (muxed) 
													vcRnaNorthStat,	-- Latched status flags of pointed FIFO (to RNA) (muxed)
													vcFcNorthFull,		-- Asynch full flag of pointed FIFO (to FC) (muxed)
													vcSwDGNorth);		-- Data good signal (to switch)

	vcEast: virtual_channel port map( 	clk,					-- Clock pin ***
													fcVcEast, 			-- Input data port (from FC)
													fcVcEastEnq,		-- Enqueue latch input (from FC) (dmuxed)
													rnaVcEastDq,		-- Dequeue latch input (from RNA) (dmuxed)
													rnaVcEastSelI,		-- FIFO select for input (from RNA) 
													rnaVcEastSelO,		-- FIFO select for output (from RNA)
													rnaVcEastSelS,		-- FIFO select for status (from RNA)
													reset,				-- Master Reset (global) ***
													rnaVcEastStrq,		-- Status request (from RNA) (dmuxed)
													vcSwEast, 			-- Output data port (to Switch) (muxed) 
													vcRnaEastStat,		-- Latched status flags of pointed FIFO (muxed)
													vcFcEastFull,		-- Asynch full flag of pointed FIFO  (muxed)
													vcSwDGEast);		-- Data good signal (to switch)

	vcSouth: virtual_channel port map( 	clk,					-- Clock pin ***
													fcVcSouth, 			-- Input data port (from FC)
													fcVcSouthEnq,		-- Enqueue latch input (from FC) (dmuxed)
													rnaVcSouthDq,		-- Dequeue latch input (from RNA) (dmuxed)
													rnaVcSouthSelI,	-- FIFO select for input (from RNA) 
													rnaVcSouthSelO,	-- FIFO select for output (from RNA)
													rnaVcSouthSelS,	-- FIFO select for status (from RNA)
													reset,				-- Master Reset (global) ***
													rnaVcSouthStrq,	-- Status request (from RNA) (dmuxed)
													vcSwSouth, 			-- Output data port (to Switch) (muxed) 
													vcRnaSouthStat,	-- Latched status flags of pointed FIFO (muxed)
													vcFcSouthFull,		-- Asynch full flag of pointed FIFO  (muxed)
													vcSwDGSouth);		-- Data good signal (to switch)

	vcWest: virtual_channel port map( 	clk,					-- Clock pin ***
													fcVcWest, 			-- Input data port (from FC)
													fcVcWestEnq,		-- Enqueue latch input (from FC) (dmuxed)
													rnaVcWestDq,		-- Dequeue latch input (from RNA) (dmuxed)
													rnaVcWestSelI,		-- FIFO select for input (from RNA) 
													rnaVcWestSelO,		-- FIFO select for output (from RNA)
													rnaVcWestSelS,		-- FIFO select for status (from RNA)
													reset,				-- Master Reset (global) ***
													rnaVcWestStrq,		-- Status request (from RNA) (dmuxed)
													vcSwWest, 			-- Output data port (to Switch) (muxed) 
													vcRnaWestStat,		-- Latched status flags of pointed FIFO (muxed)
													vcFcWestFull,		-- Asynch full flag of pointed FIFO  (muxed)
													vcSwDGWest);		-- Data good signal (to switch)
										

	-- Injection and Ejection buffers
	-- ** needs route
	injection: Fifo_mxn port map(	injection_data,	-- FIFO input port (from PE) *** (Both directions)
											injection_enq,		-- Enqueue item to FIFO buffer ***	 (from PE) (clocking pin)					
											rnaiFifoDeq,		-- Dequeue item from FIFO buffer  (from RNA) (clocking pin) 
											reset,				-- Asynch reset ***
											rnaiFifoStrq,		-- Status request int (from RNA)
											fifoSwInjct,		-- FIFO output port (to switch) 						
											iFifoRnaStat,		-- FIFO status flags (to RNA)
											iFifoaStat);		-- FIFO asynch status flags (to PE and switch)	***						
	
	ejection: Fifo_mxn port map(	swFifoEject,		-- FIFO input port (from switch)
											rnaeFifoEnq,		-- Enqueue item to FIFO buffer	(clocking pin)						
											ejection_deq,		-- Dequeue item from FIFO buffer (clocking pin) ***
											reset,				-- Asynch reset ***
											rnaeFifoStrq,		-- Status request int
											ejection_data,		-- FIFO output port (to PE) ***						
											eFifoRnaStat,		-- FIFO status flags
											ejection_status);	-- FIFO asynch status flags ***	


	-- Switch unit (signals routed)
	sw: SwitchUnit port map (	clk,					-- Clock pin ***
										vcSwNorth,			-- Incoming traffic from VC units
										vcSwEast,
										vcSwSouth,
										vcSwWest,
										fifoSwInjct,		-- From PE
										rnaSwCtrlPktO,		-- From RNA (control packet to network)			
										rnaSwEjectSel,		-- selects for mux/dmux from rna
										rnaSwNorthSel,
										rnaSwEastSel,
										rnaSwSouthSel,
										rnaSwWestSel,
										
										vcSwDGNorth,		-- Data good signals from VC
										vcSwDGEast,
										vcSwDGSouth,
										vcSwDGWest,
										reset,				-- Switch reset for data good ***
										iFifoaStat,			
										
										swRnaCtrlFlg,		-- control packet indicator flag
										north_data_out,	-- Outgoing traffic ***
										east_data_out,	
										south_data_out,
										west_data_out,
										swRnaCtrlPktI,		-- Control packet from PE to RNA
										swFifoEject,		-- To PE
										north_dout_good,	-- Data good signal to neighbors ***
										east_dout_good,
										south_dout_good,
										west_dout_good);	
	
-- asynch outputs
injection_status <= 	iFifoaStat;
	
end rtl;

