--
-- Register bank for an ICAI-RISC core.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity RegBank is
	port(
		clk	: in std_logic;
		reset_n	: in std_logic;
		w_en	: in std_logic;
		w_dir	: in std_logic_vector(2 downto 0);
		w_data	: in std_logic_vector(15 downto 0);
		r_dir_a	: in std_logic_vector(2 downto 0);
		r_dir_b	: in std_logic_vector(2 downto 0);
		r_a	: out std_logic_vector(15 downto 0);
		r_b	: out std_logic_vector(15 downto 0)
	);
end entity;

architecture structural of RegBank is

	-- Types
	type val_t is array(7 downto 0) of std_logic_vector(15 downto 0);

	-- Signals
	signal write_dir	: std_logic_vector(7 downto 0);
	signal enables	: std_logic_vector(7 downto 0);
	signal values	: val_t;

	-- Components
	component Reg is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			en	: in std_logic;
			d	: in std_logic_vector(15 downto 0);
			q	: out std_logic_vector(15 downto 0)
		);
	end component;
	component Muxer8 is
		port(
			sel	: in std_logic_vector(2 downto 0);
			i0	: in std_logic_vector(15 downto 0);
			i1	: in std_logic_vector(15 downto 0);
			i2	: in std_logic_vector(15 downto 0);
			i3	: in std_logic_vector(15 downto 0);
			i4	: in std_logic_vector(15 downto 0);
			i5	: in std_logic_vector(15 downto 0);
			i6	: in std_logic_vector(15 downto 0);
			i7	: in std_logic_vector(15 downto 0);
			o	: out std_logic_vector(15 downto 0)
		);
	end component;
	component Decoder is
		port(
			i	: in std_logic_vector(2 downto 0);
			o	: out std_logic_vector(7 downto 0)
		);
	end component;
begin
	-- Decode enables
	Decoder_1	: Decoder port map(i=>w_dir, o=>write_dir);
	enables <= write_dir and (write_dir'range=>w_en);

	-- Registers
	values(0) <= (others=>'0'); -- R_0 is always '0'
	Reg_1	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(1), d=>w_data, q=>values(1));
	Reg_2	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(2), d=>w_data, q=>values(2));
	Reg_3	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(3), d=>w_data, q=>values(3));
	Reg_4	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(4), d=>w_data, q=>values(4));
	Reg_5	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(5), d=>w_data, q=>values(5));
	Reg_6	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(6), d=>w_data, q=>values(6));
	Reg_7	: Reg port map(clk=>clk, reset_n=>reset_n, en=>enables(7), d=>w_data, q=>values(7));
	
	-- Outputs
	Muxer8_1	: Muxer8 port map(sel=>r_dir_a, i0=>values(0), i1=>values(1), i2=>values(2), i3=>values(3), i4=>values(4), i5=>values(5), i6=>values(6), i7=>values(7), o=>r_a);
	Muxer8_2	: Muxer8 port map(sel=>r_dir_b, i0=>values(0), i1=>values(1), i2=>values(2), i3=>values(3), i4=>values(4), i5=>values(5), i6=>values(6), i7=>values(7), o=>r_b);
	
end structural;
