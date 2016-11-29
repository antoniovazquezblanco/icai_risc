--
-- ICAI-RISC Timer pheriferial.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
	port(
		reset_n	: in std_logic;
		clk	: in std_logic;
		wr	: in std_logic;
		rd	: in std_logic;
		cs	: in std_logic;
		addr	: in std_logic_vector(14 downto 0);
		data_in	: in std_logic_vector(15 downto 0);
		data_out	: out std_logic_vector(15 downto 0)
	);
end entity;

architecture structural of Timer is

	-- Signals
	signal config_en	: std_logic;
	signal count_en	: std_logic;
	signal config	: std_logic_vector(15 downto 0);
	signal count_n	: natural;
	signal data_in_n	: natural;
	signal count	: std_logic_vector(15 downto 0);
	signal clk_count	: std_logic;
	
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
	component Reg is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			en	: in std_logic;
			d	: in std_logic_vector(15 downto 0);
			q	: out std_logic_vector(15 downto 0)
		);
	end component;
	component Muxer2 is
		generic(
			g_data_w	: integer := 16
		);
		port(
			sel	: in std_logic;
			i0	: in std_logic_vector(g_data_w-1 downto 0);
			i1	: in std_logic_vector(g_data_w-1 downto 0);
			o	: out std_logic_vector(g_data_w-1 downto 0)
		);
	end component;
	component ClockDiv is
		generic(
			g_freq_old	: integer := 50000000;
			g_freq_new	: integer := 1
		);
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			clk_o	: out std_logic
		);
	end component;
begin
	-- Signals
	Muxer2_1	: Muxer2 port map(sel=>addr(0), i0=>count, i1=>config, o=>data_out);

	-- Config register
	config_en <= wr and cs and addr(0);
	Reg_1	: Reg port map(clk=>clk, reset_n=>reset_n, en=>config_en, d=>data_in, q=>config);
	
	-- Clock divider
	ClockDiv_1	: ClockDiv generic map(g_freq_old=>50000000, g_freq_new=>10000) port map(clk=>clk, reset_n=>reset_n, clk_o=>clk_count);

	-- Counter
	count_en <= not(wr and cs and not addr(0));
	count <= std_logic_vector(to_unsigned(count_n, count'length));
	data_in_n <= to_integer(unsigned(data_in));
	Counter_1	: Counter generic map(count_min=>0, count_max=>16#FFFF#) port map(clk=>clk_count, d=>data_in_n, reset_n=>count_en, enable=>config(0), keeprunning=>config(1), q=>count_n);
end structural;