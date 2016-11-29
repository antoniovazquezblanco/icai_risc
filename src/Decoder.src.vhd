--
-- Simple decoder for ICAI-RISC.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decoder is
	port(
		i	: in std_logic_vector(2 downto 0);
		o	: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioural of Decoder is
begin
	with i select
		o <=	"00000001" when "000",
			"00000010" when "001",
			"00000100" when "010",
			"00001000" when "011",
			"00010000" when "100",
			"00100000" when "101",
			"01000000" when "110",
			"10000000" when "111",
			"UUUUUUUU" when others;
end behavioural;
