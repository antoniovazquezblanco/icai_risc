--
-- Hexadecimal displays.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity HexDisp is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		en	: in std_logic;
		data	: in std_logic_vector(15 downto 0);
		hex0	: out std_logic_vector(6 downto 0);
		hex1	: out std_logic_vector(6 downto 0);
		hex2	: out std_logic_vector(6 downto 0);
		hex3	: out std_logic_vector(6 downto 0)
	);
end entity;

architecture behavioural of HexDisp is

	-- Signals
	signal stored	: std_logic_vector(15 downto 0);

	-- Components
	component BinToSevenSeg is
		port
		(
			e : in std_logic_vector(3 downto 0);
			s : out std_logic_vector(6 downto 0)
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
begin
	--Reg_1	: Reg port map(clk=>clk, reset_n=>reset_n, en=>en, d=>data, q=>stored);
	BinToSevenSeg_1	: BinToSevenSeg port map(e=>data(3 downto 0), s=>hex0);
	BinToSevenSeg_2	: BinToSevenSeg port map(e=>data(7 downto 4), s=>hex1);
	BinToSevenSeg_3	: BinToSevenSeg port map(e=>data(11 downto 8), s=>hex2);
	BinToSevenSeg_4	: BinToSevenSeg port map(e=>data(15 downto 12), s=>hex3);
end behavioural;
