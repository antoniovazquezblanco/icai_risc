--
-- Set/Reset Flip Flop.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity FlipFlopSR is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		s		: in std_logic;
		r		: in std_logic;
		q		: out std_logic
	);
end entity;

architecture behavioural of FlipFlopSR is
	signal state	: std_logic := '0';
begin
	process(clk, reset_n, s, r)
	begin
		if reset_n = '0' then
			state <= '0';
		elsif rising_edge(clk) then
			if r = '1' then
				state <= '0';
			elsif s = '1' then
				state <= '1';
			end if;
		end if;
	end process;
	q <= state;
end behavioural;