--
-- Arithmetic Logic Unit testbench.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_vhd_tst is
end ALU_vhd_tst;

architecture ALU_arch of ALU_vhd_tst is
	signal end_sim	: std_logic := '0';
	signal clk	: std_logic	:= '0';
	signal a		: std_logic_vector(15 downto 0) := (others=>'0');
	signal b		: std_logic_vector(15 downto 0) := (others=>'0');
	signal op	: std_logic_vector(3 downto 0) := (others=>'0');
	signal o		: std_logic_vector(15 downto 0);
	signal zero	: std_logic;

	component ALU is
		port(
			a	: in std_logic_vector(15 downto 0);
			b	: in std_logic_vector(15 downto 0);
			op	: in std_logic_vector(3 downto 0);
			o	: out std_logic_vector(15 downto 0);
			zero	: out std_logic
		);
	end component;
begin
	i1 : ALU port map(a=>a, b=>b, op=>op, o=>o, zero=>zero);

	init : process
	begin
		wait;
	end process init;

	clk <= not clk after 50 ns;

	always : process
	begin

		-- NAND operation...
		a <= std_logic_vector(to_unsigned(16#ABCD#, a'length));
		b <= std_logic_vector(to_unsigned(16#3953#, b'length));
		op <= std_logic_vector(to_unsigned(0, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#D6BE# report "[E] ALU: NAND operation failure." severity failure;
		assert zero = '0' report "[E] ALU: NAND zero signal failure." severity failure;

		-- Adder...
		a <= std_logic_vector(to_unsigned(16#0F0F#, a'length));
		b <= std_logic_vector(to_unsigned(16#00F0#, b'length));
		op <= std_logic_vector(to_unsigned(1, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#0FFF# report "[E] ALU: Add operation failure." severity failure;
		assert zero = '0' report "[E] ALU: Add zero signal failure." severity failure;

		-- Adder with overflow and zero...
		a <= std_logic_vector(to_unsigned(16#7FFF#, a'length));
		b <= std_logic_vector(to_unsigned(16#0001#, b'length));
		op <= std_logic_vector(to_unsigned(1, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#8000# report "[E] ALU: Add operation failure." severity failure;
		assert zero = '0' report "[E] ALU: Add zero signal failure." severity failure;

		-- Substractor...
		a <= std_logic_vector(to_unsigned(16#0F0F#, a'length));
		b <= std_logic_vector(to_unsigned(16#00F0#, b'length));
		op <= std_logic_vector(to_unsigned(2, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#0E1F# report "[E] ALU: Sub operation failure." severity failure;
		assert zero = '0' report "[E] ALU: Sub zero signal failure." severity failure;

		-- Substractor with overflow...
		a <= std_logic_vector(to_unsigned(16#0000#, a'length));
		b <= std_logic_vector(to_unsigned(16#FFFF#, b'length));
		op <= std_logic_vector(to_unsigned(2, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#0001# report "[E] ALU: Sub operation failure." severity failure;
		assert zero = '0' report "[E] ALU: Sub zero signal failure." severity failure;

		-- Shift left
		a <= std_logic_vector(to_unsigned(16#1111#, a'length));
		b <= std_logic_vector(to_unsigned(16#0000#, b'length));
		op <= std_logic_vector(to_unsigned(3, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#2222# report "[E] ALU: sll operation failure." severity failure;
		assert zero = '0' report "[E] ALU: sll zero signal failure." severity failure;

		-- Shift right arithmetic
		a <= std_logic_vector(to_unsigned(16#8000#, a'length));
		b <= std_logic_vector(to_unsigned(16#0000#, b'length));
		op <= std_logic_vector(to_unsigned(4, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#C000# report "[E] ALU: sra operation failure." severity failure;
		assert zero = '0' report "[E] ALU: sra zero signal failure." severity failure;
		
		-- Shift right logic
		a <= std_logic_vector(to_unsigned(16#8000#, a'length));
		b <= std_logic_vector(to_unsigned(16#0000#, b'length));
		op <= std_logic_vector(to_unsigned(5, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#4000# report "[E] ALU: srl operation failure." severity failure;
		assert zero = '0' report "[E] ALU: srl zero signal failure." severity failure;

		-- a < b? (unsigned)
		a <= std_logic_vector(to_unsigned(16#0000#, a'length));
		b <= std_logic_vector(to_unsigned(16#0001#, b'length));
		op <= std_logic_vector(to_unsigned(6, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#0001# report "[E] ALU: sltu operation failure." severity failure;
		assert zero = '0' report "[E] ALU: sltu zero signal failure." severity failure;

		-- a < b? (unsigned)
		a <= std_logic_vector(to_unsigned(16#0001#, a'length));
		b <= std_logic_vector(to_unsigned(16#0000#, b'length));
		op <= std_logic_vector(to_unsigned(6, op'length));
		wait for 50 ns;
		assert unsigned(o) = 16#0000# report "[E] ALU: sltu operation failure." severity failure;
		assert zero = '1' report "[E] ALU: sltu zero signal failure." severity failure;

		-- End of simulation...
		wait for 50 ns;
		assert false report "[+] ALU: End of simulation." severity note;
		end_sim <= '1';
	end process always;
end ALU_arch;
