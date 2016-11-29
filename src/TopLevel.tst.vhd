--
-- TopLevel testbench.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity TopLevel_vhd_tst is
end entity;

architecture TopLevel_arch of TopLevel_vhd_tst is
	signal end_sim	: std_logic := '0';
	signal clk	: std_logic	:= '0';
	signal key	: std_logic_vector(3 downto 0) := "1111";
	signal tx	: std_logic;
	signal rx	: std_logic;

	component TopLevel is
		port(
			CLOCK_50	: in std_logic;
			KEY		: in std_logic_vector(3 downto 0);
			UART_RXD : in std_logic;
			UART_TXD	: out std_logic
		);
	end component;
begin
	i1 : TopLevel port map(CLOCK_50=>clk, KEY=>key, UART_RXD=>rx, UART_TXD=>tx);

	init : process
	begin
		wait;
	end process init;

	clk <= not clk after 10 ns;
	
	always : process
	begin
		wait for 50 ns;
		key(0) <= '0';	-- Reset
		wait for 50 ns;
		key(0) <= '1'; -- Release reset
		wait for 1000000 ns;
		assert false report "[+] TopLevel: End of simulation." severity failure;
	end process always;
end architecture;
