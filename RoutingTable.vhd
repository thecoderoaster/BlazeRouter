----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:05:10 06/18/2011 
-- Design Name: 
-- Module Name:    RoutingTable - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.router_library.all;

entity RoutingTable is
	generic(word_size 	: natural;
			  address_size	: natural);
   port (  d 			: in 	std_logic_vector(word_size-1 downto 0);
			  clk			: in 	std_logic;
			  addr 		: in 	std_logic_vector(address_size-1 downto 0);
           en 			: in 	std_logic;
           q 			: out std_logic_vector(word_size-1 downto 0));
end RoutingTable;

architecture Behavioral of RoutingTable is
	type memory_type is array(0 to 2**address_size-1) of
		std_logic_vector(word_size-1 downto 0);
	signal rte_table: memory_type;
	
begin

	--main process:		Stores and Loads memory values based on address
	process
	begin
		wait until rising_edge(clk);
			
		--Read
		q <= rte_table(conv_integer(addr));
		
		--Write
		if en = '1' then
			rte_table(conv_integer(addr)) <= d;
		end if;
	end process;

end Behavioral;

