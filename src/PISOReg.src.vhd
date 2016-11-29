--
-- ICAI-RISC Parallel In Serial Out register.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity PISOReg is
	generic(
		g_data_w	: integer := 16
	);
	port(
		reset_n	: in std_logic;
		clk	: in std_logic;
		data_in	: in std_logic_vector(g_data_w-1 downto 0);
		data_out	: out std_logic	:= '0';
		done_n	: out std_logic	:= '0'
	);
end entity;

architecture behavioural of PISOReg is
	signal tmp	: std_logic_vector(g_data_w-1 downto 0) := (others=>'0');
begin
	process(clk, reset_n, data_in)
		variable position	: integer range -1 to g_data_w-1;
	begin
		if reset_n = '0' then
			tmp <= data_in;
			position := g_data_w-1;
			done_n <= '1';
			data_out <= '0';
		elsif rising_edge(clk) then
			if position = -1 then
				data_out <= '0';
				done_n <= '0';
				tmp <= (others=>'0');
			else
				data_out <= tmp(position);
				position := position - 1;
				done_n <= '1';
			end if;
		end if;
	end process;
end behavioural;