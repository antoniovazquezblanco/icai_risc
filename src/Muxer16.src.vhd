--
-- Muxer for ICAI-RISC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Muxer16 is
	generic(
		g_data_w	: integer := 16
	);
	port(
		sel	: in std_logic_vector(3 downto 0);
		i0	: in std_logic_vector(g_data_w-1 downto 0);
		i1	: in std_logic_vector(g_data_w-1 downto 0);
		i2	: in std_logic_vector(g_data_w-1 downto 0);
		i3	: in std_logic_vector(g_data_w-1 downto 0);
		i4	: in std_logic_vector(g_data_w-1 downto 0);
		i5	: in std_logic_vector(g_data_w-1 downto 0);
		i6	: in std_logic_vector(g_data_w-1 downto 0);
		i7	: in std_logic_vector(g_data_w-1 downto 0);
		i8	: in std_logic_vector(g_data_w-1 downto 0);
		i9	: in std_logic_vector(g_data_w-1 downto 0);
		i10	: in std_logic_vector(g_data_w-1 downto 0);
		i11	: in std_logic_vector(g_data_w-1 downto 0);
		i12	: in std_logic_vector(g_data_w-1 downto 0);
		i13	: in std_logic_vector(g_data_w-1 downto 0);
		i14	: in std_logic_vector(g_data_w-1 downto 0);
		i15	: in std_logic_vector(g_data_w-1 downto 0);
		o	: out std_logic_vector(g_data_w-1 downto 0)
	);
end entity;

architecture behavioural of Muxer16 is
begin
	with sel select
		o <=	i0 when "0000",
			i1 when "0001",
			i2 when "0010",
			i3 when "0011",
			i4 when "0100",
			i5 when "0101",
			i6 when "0110",
			i7 when "0111",
			i8 when "1000",
			i9 when "1001",
			i10 when "1010",
			i11 when "1011",
			i12 when "1100",
			i13 when "1101",
			i14 when "1110",
			i15 when "1111",
			(others=>'U') when others;
end behavioural;
