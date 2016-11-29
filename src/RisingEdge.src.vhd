--
-- Rising edge detector.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity RisingEdge is
	port(
		clk	: in std_logic;
		i	: in std_logic;
		o	: out std_logic
	);
end entity;

architecture behavioural of RisingEdge is
	type state_type is (wait1, edge, wait2);
	signal state   : state_type	:= wait1;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			case state is
				when wait1 =>
					if i = '1' then
						state <= edge;
					end if;
				when edge =>
						state <= wait2;
				when wait2 =>
					if i = '0' then
						state <= wait1;
					end if;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when wait1 =>
				o <= '0';
			when edge =>
				o <= '1';
			when wait2 =>
				o <= '0';
		end case;
	end process;
end behavioural;