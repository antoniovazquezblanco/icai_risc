--
-- Counter for ICAI-RiSC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
	generic(
		count_min : natural := 0;
		count_max : natural := 255
	);
	port(
		clk		: in std_logic;
		reset_n		: in std_logic;
		enable	: in std_logic;
		keeprunning	: in std_logic;
		d			: in integer range count_min to count_max;
		q			: out integer range count_min to count_max;
		ov			: out std_logic
	);
end entity;

architecture behavioural of Counter is
begin
	process(clk, reset_n, enable, d, keeprunning)
		variable cnt	: integer range count_min to count_max;
	begin
		if reset_n = '0' then
			cnt := d;
		elsif rising_edge(clk) and enable = '1' then
			if cnt = count_max then
				ov <= '1';
				if keeprunning = '1' then
					cnt := 0;
				end if;
			else
				ov <= '0';
				cnt := cnt + 1;
			end if;
		end if;
		q <= cnt;
	end process;
end behavioural;
