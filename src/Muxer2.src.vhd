--
-- Muxer for ICAI-RISC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Muxer2 is
	generic(
		g_data_w	: integer := 16
	);
	port(
		sel	: in std_logic;
		i0	: in std_logic_vector(g_data_w-1 downto 0);
		i1	: in std_logic_vector(g_data_w-1 downto 0);
		o	: out std_logic_vector(g_data_w-1 downto 0)
	);
end entity;

architecture behavioural of Muxer2 is
begin
	with sel select
		o <=	i0 when '0',
			i1 when '1',
			(others=>'U') when others;
end behavioural;
