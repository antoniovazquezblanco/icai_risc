--
-- Muxer for ICAI-RISC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Muxer8 is
	generic(
		g_data_w	: integer := 16
	);
	port(
		sel	: in std_logic_vector(2 downto 0);
		i0	: in std_logic_vector(g_data_w-1 downto 0);
		i1	: in std_logic_vector(g_data_w-1 downto 0);
		i2	: in std_logic_vector(g_data_w-1 downto 0);
		i3	: in std_logic_vector(g_data_w-1 downto 0);
		i4	: in std_logic_vector(g_data_w-1 downto 0);
		i5	: in std_logic_vector(g_data_w-1 downto 0);
		i6	: in std_logic_vector(g_data_w-1 downto 0);
		i7	: in std_logic_vector(g_data_w-1 downto 0);
		o	: out std_logic_vector(g_data_w-1 downto 0)
	);
end entity;

architecture behavioural of Muxer8 is
begin
	with sel select
		o <=	i0 when "000",
			i1 when "001",
			i2 when "010",
			i3 when "011",
			i4 when "100",
			i5 when "101",
			i6 when "110",
			i7 when "111",
			(others=>'U') when others;
end behavioural;
