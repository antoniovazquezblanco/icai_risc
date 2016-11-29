--
-- Red LEDs.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity LEDRed is
	port(
		reset_n	: in std_logic;
		clk	: in std_logic;
		cs	: in std_logic;
		data	: in std_logic_vector(15 downto 0);
		ledr	: out std_logic_vector(9 downto 0)
	);
end LEDRed;

architecture behavioural of LEDRed is
begin
	process(reset_n, clk, cs)
	begin
		if reset_n = '0' then
			ledr <= (others=>'1');
		elsif rising_edge(clk) and cs = '1' then
			ledr <= data(9 downto 0);
		end if;
	end process;
end behavioural;
