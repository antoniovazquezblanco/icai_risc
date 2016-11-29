--
-- Register for the ICAI-RISC processor.
-- Register is a reserved keyword so we use Reg for the entity name.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Reg is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		en	: in std_logic;
		d	: in std_logic_vector(15 downto 0);
		q	: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behavioural of Reg is
begin
	process(clk, reset_n, en)
	begin
		if reset_n = '0' then
			q <= (others=>'0');
		elsif rising_edge(clk) and en = '1' then
			q <= d;
		end if;
	end process;
end behavioural;
