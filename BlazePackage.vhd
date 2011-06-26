--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package router_library is
	--Universal constants Go Here (these are things that determine dimensions and can be changed on the fly)
	constant WIDTH		: integer := 31;
	constant SIZE		: integer := 10;
	constant LUT_SIZE : integer := 7;			--Start with 8 bits (move up eventually) (KVH)
	
	constant RSV_WIDTH: integer := 40; -- RSV Packets are 40 bits wide.
	
	--Buffer Status Codes Go Here
	constant FULL_FIFO				: std_logic_vector (1 downto 0) := "10";		-- CODE: 0x02 = FIFO full
	constant EMPTY_FIFO				: std_logic_vector (1 downto 0) := "01";	 	-- CODE: 0x01 = FIFO empty
	constant NORM_FIFO				: std_logic_vector (1 downto 0) := "00";		-- CODE: 0x00 = Normal FIFO operation
	constant ERR_FIFO				: std_logic_vector (1 downto 0) := "11";		-- CODE: 0x03 = FIFO Error
	
	--Definition of a flit
	subtype flit 		is std_logic_vector(WIDTH downto 0);	
	type	fifoBuf		is array (0 to SIZE) of flit;
	type  t_ram 		is array (0 to 7) of flit;
	
	--Subtypes
	subtype bit8 is std_logic_vector(7 downto 0);
	subtype bit16 is std_logic_vector(15 downto 0);
	subtype bit32 is std_logic_vector(31 downto 0);
	subtype bit64 is std_logic_vector(63 downto 0);
	subtype bit80 is std_logic_vector(79 downto 0);
	
	--Definition of LUTs
	type	t_ram8		is array (0 to LUT_SIZE) of std_logic_vector(7 downto 0);
	type	t_ram16		is array (0 to LUT_SIZE) of std_logic_vector(15 downto 0);
	type	t_ram32		is array (0 to LUT_SIZE) of std_logic_vector(31 downto 0);
	
end router_library;