--
-- ICAI-RISC Serial In Parallel Out register.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity SIPOReg is
	generic(
		g_data_w	: integer := 16
	);
   port(
		reset_n	: in std_logic;
		clk	:in std_logic;
		data_in		: in std_logic;
      data_out		: inout std_logic_vector(g_data_w-1 downto 0)
	);
end SIPOReg;

architecture behavioural of SIPOReg is
	signal tmp	: std_logic_vector(g_data_w-1 downto 0);
begin
	process(clk, reset_n, tmp)
	begin
		if reset_n = '0' then
			tmp <= (others=>'0');
		elsif rising_edge(clk) then
			tmp(g_data_w-1 downto 1) <= tmp(g_data_w-2 downto 0);
			tmp(0) <= data_in;
		end if;
		data_out <= tmp;
	end process;
end behavioural;