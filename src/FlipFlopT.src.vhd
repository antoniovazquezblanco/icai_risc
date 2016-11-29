--
-- T Flip Flop.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity FlipFlopT is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		t		: in std_logic;
		q		: out std_logic
	);
end entity;

architecture behavioural of FlipFlopT is
	signal state	: std_logic := '0';
begin
	process(clk, reset_n, t)
	begin
		if reset_n = '0' then
			state <= '0';
		elsif rising_edge(clk) and t='1' then
			state <= not state;
		end if;
	end process;
	q <= state;
end behavioural;