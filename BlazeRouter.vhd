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

	entity virtual_channel is
		 Port ( 	VC_din 		: in  	STD_LOGIC_VECTOR (WIDTH downto 0); 		-- Input data port (from FCU)
					VC_enq 		: in  	STD_LOGIC;										-- Enqueue latch input (from FC) (dmuxed)
					VC_deq 		: in  	STD_LOGIC;										-- Dequeue latch input (from RNA) (dmuxed)
					VC_rnaSelI 	: in  	STD_LOGIC_VECTOR (1 downto 0);			-- FIFO select for input (from RNA) 
					VC_rnaSelO 	: in  	STD_LOGIC_VECTOR (1 downto 0);			-- FIFO select for output (from RNA) 
					VC_rnaSelS	: in		STD_LOGIC_VECTOR (1 downto 0);			-- FIFO select for status (from RNA)
					VC_rst 		: in  	STD_LOGIC;										-- Master Reset (global)
					VC_strq 		: in  	STD_LOGIC;										-- Status request (from RNA) (dmuxed)
					VC_qout 		: out  	STD_LOGIC_VECTOR (WIDTH downto 0);		-- Output data port (to Switch) (muxed) 
					VC_status 	: out  	STD_LOGIC_VECTOR (1 downto 0);			-- Latched status flags of pointed FIFO (muxed)
					VC_aFull 	: out  	STD_LOGIC);										-- Asynch full flag of pointed FIFO  (muxed)
	end virtual_channel;

	-- Needed update
	component Arbiter
		port (n_data_in 			: in std_logic_vector (WIDTH downto 0);
				e_data_in			: in std_logic_vector (WIDTH downto 0);
				s_data_in			: in std_logic_vector (WIDTH downto 0);
				w_data_in			: in std_logic_vector (WIDTH downto 0);
				injection_data_in	: in std_logic_vector (WIDTH downto 0);		
				
				clk					: in std_logic;
				
				request_0			: in std_logic;
				request_1			: in std_logic;
				request_2			: in std_logic;
				request_3			: in std_logic;
				request_4			: in std_logic;
				request_5			: in std_logic;
				request_6			: in std_logic;
				request_7			: in std_logic;
				request_8			: in std_logic;
				request_9			: in std_logic;
				
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
	
	component SwitchUnit is
		port ( 	sw_northIn 	: in std_logic_vector (WIDTH downto 0);		-- Incoming traffic from VC units
					sw_eastIn 	: in std_logic_vector (WIDTH downto 0);
					sw_southIn 	: in std_logic_vector (WIDTH downto 0);
					sw_westIn	: in std_logic_vector (WIDTH downto 0);
					sw_injct		: in std_logic_vector (WIDTH downto 0);		-- From Processor Logic Bus
					sw_ctrlPkt	: in std_logic_vector (WIDTH downto 0);		-- From RNA (control packet)			
					sw_ejctSel	: in std_logic_vector (2 downto 0);				-- selects for mux/dmux from rna
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
	end component;
	
	--Define signals here that will be used to connect the components (old signals)
--	signal	n_data_in, n_data_out, n_data_out_to_sw, n_data_in_from_sw, e_data_in, e_data_out, e_data_out_to_sw,
--				e_data_in_from_sw, s_data_in, s_data_out, s_data_out_to_sw, s_data_in_from_sw, 
--				w_data_in, w_data_out, w_data_out_to_sw, w_data_in_from_sw, nB1_status, nB5_status, 
--				eB2_status, eB6_status, sB3_status, sB7_status, wB4_status, wB8_status, inB9_status,
--				ejB10_status, injection_data_to_sw, ejection_data_from_sw, rna_results: bit8;
--	
--	signal 	nB1_buffer_in_en, nB5_buffer_in_en, eB2_buffer_in_en, eB6_buffer_in_en, 
--				sB3_buffer_in_en, sB7_buffer_in_en, wB4_buffer_in_en, wB8_buffer_in_en,
--				ejB10_buffer_in_en,
--				nB1_buffer_out_en, nB5_buffer_out_en, eB2_buffer_out_en, eB6_buffer_out_en,
--				sB3_buffer_out_en, sB7_buffer_out_en, wB4_buffer_out_en, wB8_buffer_out_en,
--				inB9_buffer_out_en,
--				nB1_request_status, nB5_request_status, eB2_request_status, eB6_request_status, 
--				sB3_request_status, sB7_request_status, wB4_request_status, wB8_request_status,
--				inB9_request_status, ejB10_request_status,
--				sw_enable : std_logic;
	
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
	
	-- signals between switch and RNA (routed) (rna needs signals routed to it)
	signal swRnaCtrlFlg	: std_logic; -- Control flag indicator from Switch to RNA
	signal rnaSwNorthSel : std_logic_vector (2 downto 0); -- Switch function control from RNA to Switch
	signal rnaSwEastSel 	: std_logic_vector (2 downto 0);
	signal rnaSwSouthSel : std_logic_vector (2 downto 0);
	signal rnaSwWestSel 	: std_logic_vector (2 downto 0);
	signal rnaSwEjectSel : std_logic_vector (1 downto 0);
	signal rnaSwCtrlPktO	: std_logic_vector (WIDTH downto 0); -- Control packet from RNA to Switch (to outside)
	signal swRnaCtrlPktI	: std_logic_vector (WIDTH downto 0); -- Control packet from Switch to RNA (from PE)
	
	-- signals between switch and PE FIFOs (routed)
	signal fifoSwInjct	: std_logic_vector (WIDTH downto 0); -- Packet data from injection FIFO to Switch
	signal swFifoEject	: std_logic_vector (WIDTH downto 0); -- Packet data from Switch to FIFO to ejection
	
	-- signals between PE FIFOs and RNA
	
	
begin
	--Instantiate components here to create the overall functionality
	
	--Flow Control Unit
	-- *** denotes entity port (routed)
	-- ** denotes need route (inputs are entity based, output are signal based)
	flowCtrl: fcu port map(	n_CTRflg,		-- Clear To Recieve flag (from RNA) ** (All directions need it)
									north_data_in, -- Input data port (from neighbor) ***
									n_dStrb,			-- Data strobe (from neighbor) **
									n_vcFull,		-- Full status flag (from VC) **
									n_vcData,		-- Data port (to VC) **
									n_rnaCtrl,		-- Data port (to RNA) **
									n_rnaCtrlStrb,	-- Control packet strobe (to RNA) **
									n_CTR,			-- Clear to Recieve (to neighbor) **
									n_vcEnq,			-- enqueue command from RNA (to VC)**
				
									e_CTRflg,		-- Clear To Recieve flag (from RNA)
									east_data_in, 	-- Input data port (from neighbor)
									e_dStrb,			-- Data strobe (from neighbor) 
									e_vcFull,		-- Full status flag (from VC)
									e_vcData,		-- Data port (to VC)
									e_rnaCtrl,		-- Data port (to RNA)
									e_rnaCtrlStrb,	-- Control packet strobe (to RNA)
									e_CTR,			-- Clear to Recieve (to neighbor) 
									e_vcEnq,			-- enqueue command from RNA (to VC)
				
									s_CTRflg,		-- Clear To Recieve flag (from RNA)
									south_data_in, -- Input data port (from neighbor)
									s_dStrb,			-- Data strobe (from neighbor) 
									s_vcFull,		-- Full status flag (from VC)
									s_vcData,		-- Data port (to VC)
									s_rnaCtrl,		-- Data port (to RNA)
									s_rnaCtrlStrb,	-- Control packet strobe (to RNA)
									s_CTR,			-- Clear to Recieve (to neighbor)
									s_vcEnq,			-- enqueue command from RNA (to VC)
				
									w_CTRflg,		-- Clear To Recieve flag (from RNA)
									west_data_in, 	-- Input data port (from neighbor) 
									w_dStrb,			-- Data strobe (from neighbor) 
									w_vcFull,		-- Full status flag (from VC)
									w_vcData,		-- Data port (to VC)
									w_rnaCtrl,		-- Data port (to RNA)
									w_rnaCtrlStrb,	-- Control packet strobe (to RNA)
									w_CTR,			-- Clear to Recieve (to neighbor) 
									w_vcEnq);		-- enqueue command from RNA (to VC)
	
	
	--Virtual Channels 
	-- ** needs route to signal
	vcNorth: virtual_channel port map( 	VC_din, 			-- Input data port (from FC) ** (All directions need)
													VC_enq,			-- Enqueue latch input (from FC) (dmuxed)**
													VC_deq,			-- Dequeue latch input (from RNA) (dmuxed)**
													VC_rnaSelI,		-- FIFO select for input (from RNA) **
													VC_rnaSelO,		-- FIFO select for output (from RNA)**
													VC_rnaSelS,		-- FIFO select for status (from RNA)**
													VC_rst,			-- Master Reset (global) ** (top level needs signal)
													VC_strq,			-- Status request (from RNA) (dmuxed) **
													vcSwNorth, 		-- Output data port (to Switch) (muxed) 
													VC_status,		-- Latched status flags of pointed FIFO (to RNA) (muxed) **
													VC_aFull);		-- Asynch full flag of pointed FIFO (to FC) (muxed) **

	vcEast: virtual_channel port map( 	VC_din, 			-- Input data port (from FC)
													VC_enq,			-- Enqueue latch input (from FC) (dmuxed)
													VC_deq,			-- Dequeue latch input (from RNA) (dmuxed)
													VC_rnaSelI,		-- FIFO select for input (from RNA) 
													VC_rnaSelO,		-- FIFO select for output (from RNA)
													VC_rnaSelS,		-- FIFO select for status (from RNA)
													VC_rst,			-- Master Reset (global)
													VC_strq,			-- Status request (from RNA) (dmuxed)
													vcSwEast, 		-- Output data port (to Switch) (muxed) 
													VC_status,		-- Latched status flags of pointed FIFO (muxed)
													VC_aFull);		-- Asynch full flag of pointed FIFO  (muxed)

	vcSouth: virtual_channel port map( 	VC_din, 			-- Input data port (from FC)
													VC_enq,			-- Enqueue latch input (from FC) (dmuxed)
													VC_deq,			-- Dequeue latch input (from RNA) (dmuxed)
													VC_rnaSelI,		-- FIFO select for input (from RNA) 
													VC_rnaSelO,		-- FIFO select for output (from RNA)
													VC_rnaSelS,		-- FIFO select for status (from RNA)
													VC_rst,			-- Master Reset (global)
													VC_strq,			-- Status request (from RNA) (dmuxed)
													vcSwSouth, 		-- Output data port (to Switch) (muxed) 
													VC_status,		-- Latched status flags of pointed FIFO (muxed)
													VC_aFull);		-- Asynch full flag of pointed FIFO  (muxed)

	vcWest: virtual_channel port map( 	VC_din, 			-- Input data port (from FC)
													VC_enq,			-- Enqueue latch input (from FC) (dmuxed)
													VC_deq,			-- Dequeue latch input (from RNA) (dmuxed)
													VC_rnaSelI,		-- FIFO select for input (from RNA) 
													VC_rnaSelO,		-- FIFO select for output (from RNA)
													VC_rnaSelS,		-- FIFO select for status (from RNA)
													VC_rst,			-- Master Reset (global)
													VC_strq,			-- Status request (from RNA) (dmuxed)
													vcSwWest, 		-- Output data port (to Switch) (muxed) 
													VC_status,		-- Latched status flags of pointed FIFO (muxed)
													VC_aFull);		-- Asynch full flag of pointed FIFO  (muxed)
										

	-- Injection and Ejection buffers
	-- ** needs route
	injection: Fifo_mxn port map(	FIFO_din,		-- FIFO input port (from PE) ** (Both directions)
											FIFO_enq,		-- Enqueue item to FIFO buffer	(clocking pin)	**					
											FIFO_deq,		-- Dequeue item from FIFO buffer (clocking pin) **
											FIFO_rst,		-- Asynch reset **
											FIFO_strq,		-- Status request int **
											fifoSwInjct,	-- FIFO output port (to switch) **						
											FIFO_status,	-- FIFO status flags **
											FIFO_aStatus);	-- FIFO asynch status flags ** 							
	
	ejection: Fifo_mxn port map(	swFifoEject,	-- FIFO input port (from switch)
											FIFO_enq,		-- Enqueue item to FIFO buffer	(clocking pin)						
											FIFO_deq,		-- Dequeue item from FIFO buffer (clocking pin)
											FIFO_rst,		-- Asynch reset
											FIFO_strq,		-- Status request int
											FIFO_qout,		-- FIFO output port (to PE)						
											FIFO_status,	-- FIFO status flags
											FIFO_aStatus);	-- FIFO asynch status flags 	


	-- Switch unit (signals routed)
	sw: SwitchUnit port map (	vcSwNorth,			-- Incoming traffic from VC units
										vcSwEast,
										vcSwSouth,
										vcSwWest,
										fifoSwInjct,		-- From Processor Logic Bus
										rnaSwCtrlPktI,		-- From RNA (control packet to network)			
										rnaSwEjectSel,		-- selects for mux/dmux from rna
										rnaSwNorthSel,
										rnaSwEastSel,
										rnaSwSouthSel,
										rnaSwWestSel,
										
										swRnaCtrlFlg,		-- control packet indicator flag
										north_data_out,	-- Outgoing traffic
										east_data_out,	
										south_data_out,
										west_data_out,
										swRnaCtrlPktO,		-- Control packet from PE to RNA
										fifoSwEject);		-- To Processor Logic Bus


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

