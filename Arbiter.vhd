----------------------------------------------------------------------------------
-- Company:			 University of Nevada, Las Vegas 
-- Engineer: 		 Krikor Hovasapian (ECE Graduate Student)
-- 					 Kareem Matariyeh (ECE Graduate Student)
-- Create Date:    13:55:59 12/20/2010
-- Design Name: 	 BlazeRouter
-- Module Name:    Arbiter - RTL
-- Project Name: 	 BlazeRouter
-- Target Devices: xc4vsx35-10ff668
-- Tool versions:  Using ISE 12.4
-- Description: 
--						 Part of the BlazeRouter design, the Arbiter monitors the status
--						 of each buffer within the router to see if any new data has arrived
--						 in a Round Robin with Priority scheme. When data arives, a copy
--						 of the packet within the buffer is taken, analyzed by one of the
--						 routing algorithms and a result is forwarded to the RNA_RESULT
--						 port instructing the switch on configuration.
--
-- Dependencies: 
--						 None
-- Revision: 
-- 					 Revision 0.01 - File Created
--						 Revision 0.02 - Added additional modules (KVH)
--						 Revision 0.03 - Added processes to handle FSM
--						 Revision 0.04 - Works in Xilinx ISE 12.4
--						 Revision 0.05 - Added KM changes to interface with VC/FCU
--						 Revision 0.06	- Part of major revision to control unit
--						 Revision 0.07 - Plugging into BlazeRouter
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


entity Arbiter is	
	port ( 			
				--Internal
				clk					: in std_logic;
				reset					: in std_logic;
				
				--Virtual Channel Related
				n_vc_deq 			: out  	std_logic;									-- Dequeue latch input (from RNA) (dmuxed)
				n_vc_rnaSelI 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for input (from RNA) 
				n_vc_rnaSelO 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for output (from RNA) 
				n_vc_rnaSelS		: out		std_logic_vector (1 downto 0);		-- FIFO select for status (from RNA)
				n_vc_strq 			: out  	std_logic;									-- Status request (from RNA) (dmuxed)
				n_vc_status 		: in  	std_logic_vector (1 downto 0);		-- Latched status flags of pointed FIFO (muxed)
				
				e_vc_deq 			: out  	std_logic;									-- Dequeue latch input (from RNA) (dmuxed)
				e_vc_rnaSelI 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for input (from RNA) 
				e_vc_rnaSelO 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for output (from RNA) 
				e_vc_rnaSelS		: out		std_logic_vector (1 downto 0);		-- FIFO select for status (from RNA)
				e_vc_strq 			: out  	std_logic;									-- Status request (from RNA) (dmuxed)
				e_vc_status 		: in  	std_logic_vector (1 downto 0);		-- Latched status flags of pointed FIFO (muxed)
				
				s_vc_deq 			: out  	std_logic;									-- Dequeue latch input (from RNA) (dmuxed)
				s_vc_rnaSelI 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for input (from RNA) 
				s_vc_rnaSelO 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for output (from RNA) 
				s_vc_rnaSelS		: out		std_logic_vector (1 downto 0);		-- FIFO select for status (from RNA)
				s_vc_strq 			: out  	std_logic;									-- Status request (from RNA) (dmuxed)
				s_vc_status 		: in  	std_logic_vector (1 downto 0);		-- Latched status flags of pointed FIFO (muxed)
				
				w_vc_deq 			: out  	std_logic;									-- Dequeue latch input (from RNA) (dmuxed)
				w_vc_rnaSelI 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for input (from RNA) 
				w_vc_rnaSelO 		: out  	std_logic_vector (1 downto 0);		-- FIFO select for output (from RNA) 
				w_vc_rnaSelS		: out		std_logic_vector (1 downto 0);		-- FIFO select for status (from RNA)
				w_vc_strq 			: out 	std_logic;									-- Status request (from RNA) (dmuxed)
				w_vc_status 		: in  	std_logic_vector (1 downto 0);		-- Latched status flags of pointed FIFO (muxed)
			
				--FCU Related
				n_CTRflg					: out std_logic;						-- Send a CTR to neighbor for packet
				e_CTRflg					: out std_logic;													
				s_CTRflg					: out std_logic;
				w_CTRflg					: out std_logic;
			
				n_CtrlFlg				: in std_logic;						--Receive a control packet flag from neighbor 
				e_CtrlFlg				: in std_logic;						--(data good from neighbor via fcu)
				s_CtrlFlg				: in std_logic;						--After CTR goes up, and once this goes
				w_CtrlFlg				: in std_logic;						--down, we dequeue our stuff.
			
				--Scheduler Related
				n_rnaCtrl			: in std_logic_vector(WIDTH downto 0);			-- Control Packet 
				e_rnaCtrl			: in std_logic_vector(WIDTH downto 0);
				s_rnaCtrl			: in std_logic_vector(WIDTH downto 0);
				w_rnaCtrl			: in std_logic_vector(WIDTH downto 0);
								
				--Switch Related
				sw_nSel				: out std_logic_vector(2 downto 0);
				sw_eSel				: out std_logic_vector(2 downto 0);
				sw_sSel				: out std_logic_vector(2 downto 0);
				sw_wSel				: out std_logic_vector(2 downto 0);
				sw_ejectSel			: out std_logic_vector(2 downto 0);										
				sw_rnaCtFl			: in std_logic;										-- Flag from Switch for injection packet
				rna_ctrlPkt			: out std_logic_vector (WIDTH downto 0);		-- Control packet generator output				
				injt_ctrlPkt		: in std_logic_vector (WIDTH downto 0)			-- coming from switch control packet from PE	
				);						

end Arbiter;

architecture rtl of Arbiter is
	component ReservationTable
	generic(word_size 	: natural;
			  address_size	: natural);
   port (  d 			: in  std_logic_vector(word_size-1 downto 0);
			  clk		   : in  std_logic;
			  addr   	: in  std_logic_vector(address_size-1 downto 0);
           en 			: in  std_logic;
           q 			: out std_logic_vector(word_size-1 downto 0)
		   );
	end component;
	
	component RoutingTable
	generic(word_size		: natural;
			  address_size : natural);
	port (  d 			: in  std_logic_vector(word_size-1 downto 0);
			  clk			: in  std_logic;
			  addr   	: in  std_logic_vector(address_size-1 downto 0);
           en 			: in  std_logic;
           q 			: out std_logic_vector(word_size-1 downto 0)
		   );
	end component;
	
	component SchedulerTable
	generic(word_size		: natural;
			  address_size : natural);
	port (  d 			: in  std_logic_vector(word_size-1 downto 0);
			  clk			: in  std_logic;
			  addr   	: in  std_logic_vector(address_size-1 downto 0);
           en 			: in  std_logic;
           q 			: out std_logic_vector(word_size-1 downto 0)
		   );
	end component;
	
	component AddressLUT
	generic(word_size		: natural;
			  address_size : natural);
	port (  d 			: in  std_logic_vector(word_size-1 downto 0);
			  clk			: in std_logic;
			  addr 		: in std_logic_vector(address_size-1 downto 0);
           en 			: in  std_logic;
			  search		: in std_logic;
			  result		: out std_logic_vector(address_size-1 downto 0);
           q 			: out std_logic_vector(word_size-1 downto 0));
	end component;
	
	component ControlUnit
	generic(cp_size		: natural;
			  address_size : natural;
			  rsv_size 		: natural;
			  rte_size		: natural;
			  sch_size		: natural;
			  adr_size		: natural);
	port(
			clk				   : in std_logic;
			rst					: in std_logic;
			rsv_data_in			: in std_logic_vector (rsv_size-1 downto 0);
			rsv_data_out		: out std_logic_vector (rsv_size-1 downto 0);
			rte_data_in			: in std_logic_vector(rte_size-1 downto 0);
			rte_data_out		: out std_logic_vector(rte_size-1 downto 0);
			sch_data_in			: in std_logic_vector (sch_size-1 downto 0);
			sch_data_out		: out std_logic_vector (sch_size-1 downto 0);
			adr_data_in			: in 	std_logic_vector (adr_size-1 downto 0);
			adr_data_out		: out std_logic_vector (adr_size-1 downto 0);
			address				: out std_logic_vector (address_size-1 downto 0);
			rsv_en				: out std_logic;
			rte_en				: out std_logic;
			sch_en 				: out std_logic;
			adr_en				: out std_logic;
			adr_search			: out std_logic;
			adr_result			: in 	std_logic_vector (address_size-1 downto 0);
			n_vc_deq 			: out  std_logic;
			n_vc_rnaSelI 		: out  std_logic_vector (1 downto 0);		 
			n_vc_rnaSelO 		: out  std_logic_vector (1 downto 0);		
			n_vc_rnaSelS		: out	std_logic_vector (1 downto 0);		
			n_vc_strq 			: out  std_logic;									
			n_vc_status 		: in std_logic_vector (1 downto 0);		
			e_vc_deq 			: out  std_logic;									
			e_vc_rnaSelI 		: out  std_logic_vector (1 downto 0);		
			e_vc_rnaSelO 		: out  std_logic_vector (1 downto 0);		 
			e_vc_rnaSelS		: out	std_logic_vector (1 downto 0);
			e_vc_strq 			: out std_logic;
			e_vc_status 		: in std_logic_vector (1 downto 0);
			s_vc_deq 			: out  std_logic;							
			s_vc_rnaSelI 		: out  std_logic_vector (1 downto 0); 
			s_vc_rnaSelO 		: out  std_logic_vector (1 downto 0); 
			s_vc_rnaSelS		: out	std_logic_vector (1 downto 0);
			s_vc_strq 			: out  std_logic;							
			s_vc_status 		: in std_logic_vector (1 downto 0);
			w_vc_deq 			: out  std_logic;
			w_vc_rnaSelI 		: out  std_logic_vector (1 downto 0); 
			w_vc_rnaSelO 		: out  std_logic_vector (1 downto 0); 
			w_vc_rnaSelS		: out	std_logic_vector (1 downto 0);
			w_vc_strq 			: out  std_logic;
			w_vc_status 		: in std_logic_vector (1 downto 0);
			n_CTRflg				: out std_logic;
			n_CtrlFlg			: in std_logic;
			n_rnaCtrl			: in std_logic_vector(cp_size-1 downto 0);
			e_CTRflg				: out std_logic;
			e_CtrlFlg			: in std_logic;
			e_rnaCtrl			: in std_logic_vector(cp_size-1 downto 0);
			s_CTRflg				: out std_logic;
			s_CtrlFlg			: in std_logic;
			s_rnaCtrl			: in std_logic_vector(cp_size-1 downto 0);
			w_CTRflg				: out std_logic;
			w_CtrlFlg			: in std_logic;
			w_rnaCtrl			: in std_logic_vector(cp_size-1 downto 0);
			sw_nSel				: out std_logic_vector(2 downto 0);
			sw_eSel				: out std_logic_vector(2 downto 0);
			sw_sSel				: out std_logic_vector(2 downto 0);
			sw_wSel				: out std_logic_vector(2 downto 0);
			sw_ejectSel			: out std_logic_vector(2 downto 0);
			sw_rnaCtFl			: in std_logic;
			rna_ctrlPkt			: out std_logic_vector(cp_size-1 downto 0);
			injt_ctrlPkt		: in std_logic_vector (cp_size-1 downto 0)

		);
	end component;

	--RoutingTable Related
	signal rsv_data_in			: std_logic_vector (RSV_WIDTH-1 downto 0);
	signal rsv_data_out			: std_logic_vector (RSV_WIDTH-1 downto 0);
	signal rsv_en					: std_logic;
	signal rte_data_in			: std_logic_vector (RTE_WIDTH-1 downto 0);
	signal rte_data_out			: std_logic_vector (RTE_WIDTH-1 downto 0);
	signal rte_en					: std_logic;
	signal sch_data_in			: std_logic_vector (SCH_WIDTH-1 downto 0);
	signal sch_data_out			: std_logic_vector (SCH_WIDTH-1 downto 0);
	signal sch_en					: std_logic;
	signal adr_data_in			: std_logic_vector (ADR_WIDTH-1 downto 0);
	signal adr_data_out			: std_logic_vector (ADR_WIDTH-1 downto 0);
	signal adr_en					: std_logic;
	signal adr_search				: std_logic;
	signal adr_result				: std_logic_vector (ADDR_WIDTH-1 downto 0);
	signal address					: std_logic_vector (ADDR_WIDTH-1 downto 0);
	
	
begin
	
	RsvTable : ReservationTable
		generic map (RSV_WIDTH, ADDR_WIDTH)
		port map (rsv_data_in, clk, address, rsv_en, rsv_data_out);
	
	RteTable: RoutingTable
		generic map (RTE_WIDTH, ADDR_WIDTH)
		port map (rte_data_in, clk, address, rte_en, rte_data_out);
	
	SchTable: SchedulerTable
		generic map (SCH_WIDTH, ADDR_WIDTH)
		port map (sch_data_in, clk, address, sch_en, sch_data_out);
	
	AdrTable: AddressLUT
		generic map (ADR_WIDTH, ADDR_WIDTH)
		port map (adr_data_in, clk, address, adr_en, adr_search, adr_result, adr_data_out);
	
	Control	: ControlUnit
		generic map (CP_WIDTH, ADDR_WIDTH, RSV_WIDTH, RTE_WIDTH, SCH_WIDTH, ADR_WIDTH)
		port map (clk, reset, rsv_data_out, rsv_data_in, rte_data_out, rte_data_in, 
					sch_data_out, sch_data_in, adr_data_out, adr_data_in, address, 
					rsv_en, rte_en, sch_en, adr_en, adr_search, adr_result,
					n_vc_deq, n_vc_rnaSelI, n_vc_rnaSelO, n_vc_rnaSelS, n_vc_strq, n_vc_status,
					e_vc_deq, e_vc_rnaSelI, e_vc_rnaSelO, e_vc_rnaSelS, e_vc_strq, e_vc_status,
					s_vc_deq, s_vc_rnaSelI, s_vc_rnaSelO, s_vc_rnaSelS, s_vc_strq, s_vc_status,
					w_vc_deq, w_vc_rnaSelI, w_vc_rnaSelO, w_vc_rnaSelS, w_vc_strq, w_vc_status,
					n_CTRFlg, n_CtrlFlg, n_rnaCtrl, e_CTRFlg, e_CtrlFlg, e_rnaCtrl, s_CTRFlg, s_CtrlFlg, s_rnaCtrl,
					w_CTRFlg, w_CtrlFlg, w_rnaCtrl, sw_nSel, sw_eSel, sw_sSel, sw_wSel, sw_ejectSel, sw_rnaCtFl, 
					rna_ctrlPkt, injt_ctrlPkt);
	
	
end rtl;

