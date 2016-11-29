--
-- FlipFlopSR testbench.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity FlipFlopSR_vhd_tst is
end entity;

architecture FlipFlopSR_arch of FlipFlopSR_vhd_tst is
	signal end_sim	: std_logic := '0';
	signal clk	: std_logic	:= '0';
	signal s		: std_logic := '0';
	signal r		: std_logic := '0';
	signal q		: std_logic;
	signal reset_n	: std_logic;

	component FlipFlopSR is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			s		: in std_logic;
			r		: in std_logic;
			q		: out std_logic
		);
	end component;
begin
	i1 : FlipFlopSR port map(clk=>clk, reset_n=>reset_n, s=>s, r=>r, q=>q);

	init : process
	begin
		wait;
	end process init;

	clk <= not clk after 25 ns;
	
	always : process
	begin
		reset_n <= '0';
		wait for 50 ns;
		assert q = '0' report "[!] FlipFlopSR: Default value different from 0." severity failure;
		reset_n <= '1';
		wait for 50 ns;
		assert q = '0' report "[!] FlipFlopSR: Reset up causes state change." severity failure;
		s <= '1';
		wait for 50 ns;
		s <= '0';
		assert q = '1' report "[!] FlipFlopSR: Input is ignored." severity failure;
		r <= '1';
		wait for 10 ns;
		assert q = '1' report "[!] FlipFlopSR: Clock ignored." severity failure;
		wait for 40 ns;
		assert q = '0' report "[!] FlipFlopSR: Input ignored." severity failure;
		assert false report "[+] Reg: End of simulation." severity note;
		end_sim <= '1';
	end process always;
end architecture;
