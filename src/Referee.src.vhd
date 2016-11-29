--
-- Referee for ICAI-RISC peripherials.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity Referee is
	generic(
		g_addr_start	:	integer	:= 16#0000#;
		g_addr_end		:	integer	:= 16#0000#
	);
	port(
		perif_data_in	: in std_logic_vector(15 downto 0);
		c1_addr	: in std_logic_vector(14 downto 0);
		c1_wr	: in std_logic;
		c1_rd	: in std_logic;
		c1_atom	: in std_logic;
		c1_data_in	: in std_logic_vector(15 downto 0);
		c2_addr	: in std_logic_vector(14 downto 0);
		c2_wr	: in std_logic;
		c2_rd	: in std_logic;
		c2_atom	: in std_logic;
		c2_data_in	: in std_logic_vector(15 downto 0);
		perif_data_out	: out std_logic_vector(15 downto 0);
		perif_addr	: out std_logic_vector(14 downto 0);
		perif_wr	: out std_logic;
		perif_rd	: out std_logic;
		perif_cs	: out std_logic;
		c1_lock	: out std_logic;
		c1_data_out : out std_logic_vector(15 downto 0);
		c2_lock	: out std_logic;
		c2_data_out : out std_logic_vector(15 downto 0)
	);
end entity;

architecture structural of Referee is
	-- Signals
	signal c1_cs	: std_logic;
	signal c1_sel	: std_logic;
	signal c1_sel_p	: std_logic;
	signal c2_cs	: std_logic;
	signal c2_sel	: std_logic;
	signal c2_sel_p	: std_logic;

	-- Components
	component ChipSelect is
		generic(
			g_addr_start	:	integer	:= 16#0000#;
			g_addr_end		:	integer	:= 16#0000#
		);
		port(
			addr	: in std_logic_vector(14 downto 0);
			sel	: out std_logic
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
begin

	-- Chip selection
	ChipSelect_c1	: ChipSelect generic map(g_addr_start=>g_addr_start, g_addr_end=>g_addr_end) port map(addr=>c1_addr, sel=>c1_cs);
	ChipSelect_c2	: ChipSelect generic map(g_addr_start=>g_addr_start, g_addr_end=>g_addr_end) port map(addr=>c1_addr, sel=>c2_cs);
	
	-- Core selection
	c1_sel <= c1_cs and (c1_rd or c1_wr);
	c2_sel <= c2_cs and (c2_rd or c2_wr);
	
	-- Selection priority
	c1_sel_p <= c1_sel;
	c2_sel_p <= c2_sel and not c1_sel;
	
	-- Core lock
	c1_lock <= not c1_sel_p;
	c2_lock <= not c2_sel_p;
	
	-- Rd, wr and cs
	perif_rd <= (c1_sel_p and c1_rd) or (c2_sel_p and c2_rd);
	perif_wr <= (c1_sel_p and c1_wr) or (c2_sel_p and c2_wr);
	perif_cs <= c1_cs or c2_cs;
	
	-- Perif data out
	c1_data_out <= perif_data_in;
	c2_data_out <= perif_data_in;
	
	-- Perif data in
	Muxer2_perif_datain	: Muxer2 port map(sel=>c2_sel_p, i0=>c1_data_in, i1=>c2_data_in, o=>perif_data_out);
	
	-- Addr selection
	Muxer_addr	: Muxer2 generic map(g_data_w=>15) port map(sel=>c2_sel_p, i0=>c1_addr, i1=>c2_addr, o=>perif_addr);
	
end structural;
