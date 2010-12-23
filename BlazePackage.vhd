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
	Type flit is array(0 to WIDTH) of std_logic;	
end router_library;