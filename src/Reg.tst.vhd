--
-- Register testbench.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg_vhd_tst is
end Reg_vhd_tst;

architecture Reg_arch of Reg_vhd_tst is
	signal end_sim	: std_logic := '0';
	signal clk	: std_logic	:= '0';
	signal d	: std_logic_vector(15 downto 0);
	signal q	: std_logic_vector(15 downto 0);
	signal en	: std_logic;
	signal reset_n	: std_logic;

	component Reg is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			en	: in std_logic;
			d	: in std_logic_vector(15 downto 0);
			q	: out std_logic_vector(15 downto 0)
		);
	end component;
begin
	i1 : Reg port map(clk=>clk, reset_n=>reset_n, en=>en, d=>d, q=>q);

	init : process
	begin
		wait;
	end process init;

	clk <= not clk after 25 ns;
	always : process
	begin
		reset_n <= '0';
		en <= '0';
		d <= (others=>'0');
		wait for 50 ns;
		assert q = (q'range=>'0') report "[W] Reg: Default value different from 0." severity failure;
		reset_n <= '1';
		d <= std_logic_vector(to_unsigned(12345, q'length));
		wait for 50 ns;
		assert q = (q'range=>'0') report "[!] Reg: Enable is ignored." severity failure;
		en <= '1';
		wait for 50 ns;
		assert q = std_logic_vector(to_unsigned(12345, q'length)) report "[!] Reg: Output does not match input when enabling the register." severity failure;
		d <= std_logic_vector(to_unsigned(54321, q'length));
		wait for 50 ns;
		assert q = std_logic_vector(to_unsigned(54321, q'length)) report "[!] Reg: Output does not match input." severity failure;
		assert false report "[+] Reg: End of simulation." severity note;
		end_sim <= '1';
	end process always;
END Reg_arch;
