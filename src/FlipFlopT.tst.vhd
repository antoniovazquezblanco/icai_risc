--
-- FlipFlopT testbench.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity FlipFlopT_vhd_tst is
end entity;

architecture FlipFlopT_arch of FlipFlopT_vhd_tst is
	signal end_sim	: std_logic := '0';
	signal clk	: std_logic	:= '0';
	signal t		: std_logic := '0';
	signal q		: std_logic;
	signal reset_n	: std_logic;

	component FlipFlopT is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			t		: in std_logic;
			q		: out std_logic
		);
	end component;
begin
	i1 : FlipFlopT port map(clk=>clk, reset_n=>reset_n, t=>t, q=>q);

	init : process
	begin
		wait;
	end process init;

	clk <= not clk after 25 ns;
	
	always : process
	begin
		reset_n <= '0';
		wait for 50 ns;
		assert q = '0' report "[!] FlipFlopT: Default value different from 0." severity failure;
		reset_n <= '1';
		wait for 50 ns;
		assert q = '0' report "[!] FlipFlopT: Reset up causes state change." severity failure;
		t <= '1';
		wait for 50 ns;
		t <= '0';
		assert q = '1' report "[!] FlipFlopT: Input is ignored." severity failure;
		t <= '1';
		wait for 10 ns;
		assert q = '1' report "[!] FlipFlopT: Clock ignored." severity failure;
		assert false report "[+] Reg: End of simulation." severity note;
		end_sim <= '1';
	end process always;
end architecture;
