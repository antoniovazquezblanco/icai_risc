--
-- Muxer for ICAI-RISC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Muxer4 is
	generic(
		g_data_w	: integer := 16
	);
	port(
		sel	: in std_logic_vector(1 downto 0);
		i0	: in std_logic_vector(g_data_w-1 downto 0);
		i1	: in std_logic_vector(g_data_w-1 downto 0);
		i2	: in std_logic_vector(g_data_w-1 downto 0);
		i3	: in std_logic_vector(g_data_w-1 downto 0);
		o	: out std_logic_vector(g_data_w-1 downto 0)
	);
end entity;

architecture behavioural of Muxer4 is
begin
	with sel select
		o <=	i0 when "00",
			i1 when "01",
			i2 when "10",
			i3 when "11",
			(others=>'U') when others;
end behavioural;
