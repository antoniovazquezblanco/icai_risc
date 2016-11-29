--
-- Rising edge detector.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity EdgeDetector is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		i		: in std_logic;
		o		: out std_logic
	);
end entity;

architecture behavioural of EdgeDetector is
	type state_type is (s0, s1, s2);
	signal state   : state_type	:= s0;
begin
	process(clk, reset_n, i)
	begin
		if reset_n = '0' then
			state <= s0;
		elsif rising_edge(clk) then
			case state is
				when s0 =>
					if i = '0' then
						state <= s1;
					end if;
				when s1 =>
					if i = '1' then
						state <= s2;
					end if;
				when s2 =>
					state <= s0;
				when others =>
					state <= s0;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when s0 => o <= '0';
			when s1 => o <= '0';
			when s2 => o <= '1';
		end case;
	end process;
end behavioural;