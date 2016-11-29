--
-- Arithmetic Logic Unit for the ICAI-RISC processor core.
-- Available operations:
-- 0 -> NAND
-- 1 -> Add
-- 2 -> Sub
-- 3 -> <<
-- 4 -> >> arith
-- 5 -> >> logic
-- 6 -> a < b? (no sign)
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		a	: in std_logic_vector(15 downto 0)	:= (others=>'0');
		b	: in std_logic_vector(15 downto 0)	:= (others=>'0');
		op	: in std_logic_vector(3 downto 0)	:= (others=>'0');
		o	: out std_logic_vector(15 downto 0);
		zero	: out std_logic
	);
end entity;

architecture behavioural of ALU is
	function to_std_logic(x : boolean) return std_logic is
	begin
		case x is
			when false => return '0';
			when true  => return '1';
			when others => return 'U';
		end case;
	end to_std_logic;
  
	signal nand_op	: std_logic_vector(15 downto 0)	:= (others=>'0');
	signal sum_op	: std_logic_vector(16 downto 0)	:= (others=>'0');
	signal sub_op	: std_logic_vector(16 downto 0)	:= (others=>'0');
	signal sll_op	: std_logic_vector(15 downto 0)	:= (others=>'0');
	signal sra_op	: std_logic_vector(15 downto 0)	:= (others=>'0');
	signal srl_op	: std_logic_vector(15 downto 0)	:= (others=>'0');
	signal sltu_op	: std_logic_vector(15 downto 0)	:= (others=>'0');
	signal res		: std_logic_vector(15 downto 0)	:= (others=>'0');
begin

	-- NAND
	nand_op <= a nand b;

	-- Adder
	sum_op <= std_logic_vector(resize(signed(a), 17)+resize(signed(b), 17));

	-- Substractor
	sub_op <= std_logic_vector(resize(unsigned(a), 17)-resize(unsigned(b), 17));

	-- Shift left
	sll_op <= std_logic_vector(shift_left(unsigned(a), 1));

	-- Shift right arithmetic
	sra_op <= std_logic_vector(shift_right(signed(a), 1));

	-- Shift right logic
	srl_op <= std_logic_vector(shift_right(unsigned(a), 1));

	-- Is a < b? (Unsigned)
	process(a, b)
	begin
		if unsigned(a) < unsigned(b) then
			sltu_op <= (0=>'1', others => '0');
		else
			sltu_op <= (others => '0');
		end if;
	end process;

	-- Select result...
	with op select
		res <=	nand_op when "0000",
			sum_op(15 downto 0) when "0001",
			sub_op(15 downto 0) when "0010",
			sll_op when "0011",
			sra_op when "0100",
			srl_op when "0101",
			sltu_op when "0110",
			(others=>'U') when others;

	-- Is output = 0?
	process(res)
	begin
		if res = (res'range => '0') then
			zero <= '1';
		else
			zero <= '0';
		end if;
	end process;

	-- Output result...
	o <= res;

end behavioural;
