--
-- UART reception control machine.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity UARTRXControl is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		rx	: in std_logic;
		sample	: out std_logic;
		store	: out std_logic
	);
end entity;

architecture behavioural of UARTRXControl is
	type state_type is (idle, wait8, receiving, stop);
	signal state   : state_type	:= idle;
	signal count : integer := 0;
begin
	process(reset_n, clk)
	begin
		if reset_n = '0' then
			state <= idle;
		elsif rising_edge(clk) then
			case state is
				when idle =>
					if rx = '1' then
						count <= 0;
						state <= receiving;
					end if;
				when wait8 =>
					if count = 7 then
						count <= 0;
						state <= receiving;
					end if;
					count <= count + 1;
				when receiving =>
					if count = 155 then
						count <= 0;
						state <= stop;
					end if;
					count <= count + 1;
				when stop =>
					if rx = '0' then
						state <= idle;
					end if;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when idle =>
				sample <= '0';
				store <= '0';
			when wait8 =>
				sample <= '0';
				store <= '0';
			when receiving =>
				sample <= '1';
				store <= '0';
			when stop =>
				sample <= '0';
				store <= '1';
		end case;
	end process;
end behavioural;