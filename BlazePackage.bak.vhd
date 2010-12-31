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
	constant WIDTH		: integer := 7;
	constant SIZE		: integer := 1;
	
	--Buffer Status Codes Go Here
	constant FULL				: std_logic_vector (WIDTH downto 0) := "00000001";		-- CODE: 0x01 = No Buffer Space
	constant VACANT_SLOT		: std_logic_vector (WIDTH downto 0) := "00000010";	 	-- CODE: 0x02 = Slot is now available
	
	--Definition of a flit
	type flit is array(0 to WIDTH) of std_logic;	
	
	--Subtypes
	subtype bit8 is std_logic_vector(7 downto 0);
	subtype bit16 is std_logic_vector(15 downto 0);
	subtype bit32 is std_logic_vector(31 downto 0);
	subtype bit64 is std_logic_vector(63 downto 0);
	subtype bit80 is std_logic_vector(79 downto 0);
	
end router_library;