--
-- Chip select for the ICAI-RiSC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ChipSelect is
	generic(
		g_addr_start	:	integer	:= 16#0000#;
		g_addr_end		:	integer	:= 16#0000#
	);
	port(
		addr	: in std_logic_vector(14 downto 0);
		sel	: out std_logic
	);
end entity;

architecture behavioural of ChipSelect is
begin
	sel <= '1' when (to_integer(unsigned(addr)) >= g_addr_start and to_integer(unsigned(addr)) <= g_addr_end) else
			 '0';
end behavioural;
