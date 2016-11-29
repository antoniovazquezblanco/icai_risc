--
-- UART transmission control machine.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity UARTTXControl is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		empty	: in std_logic;
		transmitting	: in std_logic;
		load	: out std_logic
	);
end entity;

architecture behavioural of UARTTXControl is
	type state_type is (transmision, load_data1, load_data2);
	signal state   : state_type	:= transmision;
begin
	process(reset_n, clk)
	begin
		if reset_n = '0' then
			state <= transmision;
		elsif rising_edge(clk) then
			case state is
				when transmision =>
					if empty = '0' and transmitting = '0' then
						state <= load_data1;
					end if;
				when load_data1 =>
					state <= load_data2;
				when load_data2 =>
					state <= transmision;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when transmision =>
				load <= '0';
			when load_data1 =>
				load <= '1';
			when load_data2 =>
				load <= '1';
		end case;
	end process;
end behavioural;