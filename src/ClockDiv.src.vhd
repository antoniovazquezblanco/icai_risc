--
-- Clock divider
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity ClockDiv is
	generic(
		g_freq_old	: integer := 50000000;
		g_freq_new	: integer := 1
	);
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		clk_o	: out std_logic
	);
end entity;

architecture structural of ClockDiv is

	-- Signals
	signal t	: std_logic;

	-- Components
	component Counter is
		generic(
			count_min : natural := 0;
			count_max : natural := 255
		);
		port(
			clk		: in std_logic;
			reset_n		: in std_logic;
			enable	: in std_logic;
			keeprunning	: in std_logic;
			d			: in integer range count_min to count_max;
			q			: out integer range count_min to count_max;
			ov			: out std_logic
		);
	end component;
	component FlipFlopT is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			t		: in std_logic;
			q		: out std_logic
		);
	end component;
begin
	Counter_1	: Counter generic map(count_min=>0, count_max=>g_freq_old/(2*g_freq_new)) port map(clk=>clk, reset_n=>reset_n, enable=>'1', keeprunning=>'1', d=>0, ov=>t);
	FlipFlopT_1	: FlipFlopT port map(clk=>clk, reset_n=>reset_n, t=>t, q=>clk_o);
end structural;