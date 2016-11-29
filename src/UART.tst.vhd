--
-- UART testbench.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_vhd_tst is
end UART_vhd_tst;

architecture UART_arch of UART_vhd_tst is
	signal end_sim	: std_logic := '0';
	signal clk	: std_logic	:= '0';
	signal reset_n	: std_logic := '0';
	signal wr	: std_logic := '0';
	signal rd	: std_logic := '0';
	signal wire	: std_logic := '0';
	signal data_in	: std_logic_vector(15 downto 0) := (others=>'0');
	signal data_out	: std_logic_vector(15 downto 0) := (others=>'0');
	signal addr	: std_logic_vector(14 downto 0);
	signal cs	: std_logic;
	
	component UART is
		generic(
			g_bauds	: integer := 9600
		);
		port(
			reset_n	: in std_logic;
			clk	: in std_logic;
			wr	: in std_logic;
			rd	: in std_logic;
			cs	: in std_logic;
			addr	: in std_logic_vector(14 downto 0);
			data_in	: in std_logic_vector(15 downto 0);
			rx	: in std_logic;
			tx	: out std_logic;
			data_out	: out std_logic_vector(15 downto 0)
		);
	end component;
begin
	i1 : UART port map(reset_n=>reset_n, clk=>clk, wr=>wr, rd=>rd, cs=>cs, data_in=>data_in, data_out=>data_out, rx=>wire, tx=>wire, addr=>addr);

	init : process
	begin
		wait;
	end process init;

	clk <= not clk after 10 ns;

	always : process
	begin

		-- Reset...
		wait for 50 ns;
		reset_n <= '1';
		rd <= '0';
		wr <= '0';
		cs <= '1';
		addr <= (others=>'0');
		wait for 50 ns;

		-- Feed some data...
		data_in <= std_logic_vector(to_unsigned(16#0041#, data_in'length));
		wr <= '1';
		wait for 50 ns;
		wr <= '0';
		wait for 50 ns;
		data_in <= std_logic_vector(to_unsigned(16#0088#, data_in'length));
		wr <= '1';
		wait for 50 ns;
		wr <= '0';
		wait for 50 ns;
		
		-- Wait for the transmission to take place...
		wait for 3000000 ns;
		
		-- Check if it is received properly...
		rd <= '1';
		wait for 40 ns;
		assert unsigned(data_out) = 16#0041# report "[!] UART: Missmatching data." severity failure;
		rd <= '0';
		wait for 40 ns;
		rd <= '1';
		wait for 40 ns;
		assert unsigned(data_out) = 16#0088# report "[!] UART: Missmatching data." severity failure;
		
		-- End of simulation...
		wait for 50 ns;
		assert false report "[+] UART: End of simulation." severity note;
		end_sim <= '1';
	end process always;
end UART_arch;
