----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:07:51 09/11/2011 
-- Design Name: 
-- Module Name:    AddressLUT - Behavioral 
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

entity AddressLUT is
	generic(word_size 	: natural;
			  address_size	: natural);
   port (  d 			: in  std_logic_vector(word_size-1 downto 0);
			  clk			: in std_logic;
			  addr 		: in std_logic_vector(address_size-1 downto 0);
           en 			: in  std_logic;
			  search		: in std_logic;
			  result		: out std_logic_vector(address_size-1 downto 0);
           q 			: out std_logic_vector(word_size-1 downto 0));
end AddressLUT;

architecture Behavioral of AddressLUT is

type memory_type is array (0 to 2**address_size-1) of
		std_logic_vector(word_size-1 downto 0);
	signal id_table : memory_type;  
	
begin

	--main process:		Stores and Loads memory values based on address
	process
	begin
		wait until rising_edge(clk);
		
		--Read
		q <= id_table(conv_integer(addr));
			
		--Write
		if en = '1' then
			id_table(conv_integer(addr)) <= d;
		end if;
	end process;
	
	process(search)
		variable found : std_logic_vector(address_size-1 downto 0);
		begin
			if search = '1' then
				found := std_logic_vector(to_unsigned(0, found'length));
				for i in id_table'range loop
					exit when id_table(i) = d;
					found := found + "0001";
				end loop;
			end if;
			
			result <= found;
	end process;

end Behavioral;

