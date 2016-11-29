--
-- Switch pheripherial.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Switch is
	port(
		clk	: in std_logic;
		switches: in std_logic_vector(9 downto 0);
		data	: out std_logic_vector(15 downto 0)
	);
end Switch;

architecture behavioural of Switch is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			data(9 downto 0) <= switches;
			data(15 downto 10) <= (others=>'0');
		end if;
	end process;
end behavioural;
