--
-- Project top level. This instanciates an ICAI-RISC processor and its pheripherials.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevel is
	port(
		CLOCK_50	: in std_logic;
		KEY		: in std_logic_vector(3 downto 0);
		UART_RXD : in std_logic;
		UART_TXD	: out std_logic
	);
end entity;

architecture structural of TopLevel is

	-- Signals
	signal clk	: std_logic;
	signal reset_n	: std_logic;
	signal c1_atomic	: std_logic;
	signal c1_atomic_priority	: std_logic;
	signal c1_rd	: std_logic;
	signal c1_rd_atom	: std_logic;
	signal c1_wr	: std_logic;
	signal c1_wr_atom	: std_logic;
	signal c1_addr	: std_logic_vector(14 downto 0);
	signal c1_data_in	: std_logic_vector(15 downto 0);
	signal c1_data_in_ram	: std_logic_vector(15 downto 0);
	signal c1_data_in_uart	: std_logic_vector(15 downto 0);
	signal c1_data_out	: std_logic_vector(15 downto 0);
	signal c1_lock	: std_logic_vector(0 downto 0);
	signal c1_lock_ram	: std_logic_vector(0 downto 0);
	signal c1_lock_uart	: std_logic_vector(0 downto 0);
	signal c2_atomic	: std_logic;
	signal c2_atomic_priority	: std_logic;
	signal c2_rd	: std_logic;
	signal c2_rd_atom	: std_logic;
	signal c2_wr	: std_logic;
	signal c2_wr_atom	: std_logic;
	signal c2_lock	: std_logic_vector(0 downto 0);
	signal c2_lock_ram	: std_logic_vector(0 downto 0);
	signal c2_lock_uart	: std_logic_vector(0 downto 0);
	signal c2_addr	: std_logic_vector(14 downto 0);
	signal c2_data_in	: std_logic_vector(15 downto 0);
	signal c2_data_in_ram	: std_logic_vector(15 downto 0);
	signal c2_data_in_uart	: std_logic_vector(15 downto 0);
	signal c2_data_out	: std_logic_vector(15 downto 0);
	signal uart_cs	: std_logic;
	signal uart_rd	: std_logic;
	signal uart_wr	: std_logic;
	signal uart_out	: std_logic_vector(15 downto 0);
	signal uart_in	: std_logic_vector(15 downto 0);
	signal uart_addr	: std_logic_vector(14 downto 0);
	signal ram_cs	: std_logic;
	signal ram_rd	: std_logic;
	signal ram_wr	: std_logic;
	signal ram_out	: std_logic_vector(15 downto 0);
	signal ram_in	: std_logic_vector(15 downto 0);
	signal ram_addr	: std_logic_vector(14 downto 0);
	
	-- Components
	component Core1 is
		port(
			reset_n	: in std_logic;
			clk	: in std_logic;
			lock	: in std_logic;
			data_in	: in std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0);
			wr	: out std_logic;
			rd	: out std_logic;
			atomic	: out std_logic;
			addr	: out std_logic_vector(14 downto 0)
		);
	end component;
	component Core2 is
		port(
			reset_n	: in std_logic;
			clk	: in std_logic;
			lock	: in std_logic;
			data_in	: in std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0);
			wr	: out std_logic;
			rd	: out std_logic;
			atomic	: out std_logic;
			addr	: out std_logic_vector(14 downto 0)
		);
	end component;
	component RAM is
		generic(
			g_addr_w	: integer	:= 15;
			g_addr_n	: integer	:= 2**15
		);
		port(
			clk	: in  std_logic;
			reset_n	: in std_logic;
			rd	: in std_logic;
			wr	: in std_logic;
			cs	: in std_logic;
			addr : in  std_logic_vector(g_addr_w-1 downto 0);
			data_in  : in  std_logic_vector(15 downto 0);
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;
	component Timer is
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
	end component;
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
	component Referee is
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
	end component;
begin

	-- Debug
	reset_n <= KEY(0);
	clk <= CLOCK_50;

	-- Lock priority
	c1_atomic_priority <= c1_atomic;
	c2_atomic_priority <= c2_atomic and not c1_atomic;
	
	-- Core 1
	--c1_rd_atom <= c1_rd; --TODO: and not (c2_atomic_priority or c3_atomic_priority or c4_atomic_priority);
	Core_1	: Core1 port map(reset_n=>reset_n, clk=>clk, lock=>c1_lock(0), data_in=>c1_data_in, data_out=>c1_data_out, wr=>c1_wr, rd=>c1_rd, addr=>c1_addr, atomic=>c1_atomic);

	-- Core_2
	Core_2	:  Core2 port map(reset_n=>reset_n, clk=>clk, lock=>c2_lock(0), data_in=>c2_data_in, data_out=>c2_data_out, wr=>c2_wr, rd=>c2_rd, addr=>c2_addr, atomic=>c2_atomic);
	
	-- RAM
	Referee_RAM	: Referee generic map(g_addr_start=>16#0000#, g_addr_end=>16#7FFD#) port map(
		perif_data_in=>ram_out,
		c1_addr=>c1_addr,
		c1_wr=>c1_wr,
		c1_rd=>c1_rd,
		c1_atom=>c1_atomic_priority,
		c1_data_in=>c1_data_out,
		c2_addr=>c2_addr,
		c2_wr=>c2_wr,
		c2_rd=>c2_rd,
		c2_atom=>c2_atomic_priority,
		c2_data_in=>c2_data_out,
		perif_data_out=>ram_in,
		perif_addr=>ram_addr,
		perif_wr=>ram_wr, 
		perif_rd=>ram_rd,
		perif_cs=>ram_cs,
		c1_lock=>c1_lock_ram(0),
		c1_data_out=>c1_data_in_ram,
		c2_lock=>c2_lock_ram(0),
		c2_data_out=>c2_data_in_ram
	);
	RAM_1	: RAM generic map(g_addr_w=>15, g_addr_n=>16#0200#) port map(
		clk=>clk,
		reset_n=>reset_n,
		rd=>ram_rd,
		wr=>ram_wr,
		cs=>ram_cs,
		addr=>ram_addr,
		data_in=>ram_in,
		data_out=>ram_out
	);

	-- UART
	Referee_UART	: Referee generic map(g_addr_start=>16#7FFE#, g_addr_end=>16#7FFF#) port map(
		perif_data_in=>uart_out,
		c1_addr=>c1_addr,
		c1_wr=>c1_wr,
		c1_rd=>c1_rd,
		c1_atom=>c1_atomic_priority,
		c1_data_in=>c1_data_out,
		c2_addr=>c2_addr,
		c2_wr=>c2_wr,
		c2_rd=>c2_rd,
		c2_atom=>c2_atomic_priority,
		c2_data_in=>c2_data_out,
		perif_data_out=>uart_in,
		perif_addr=>uart_addr,
		perif_wr=>uart_wr, 
		perif_rd=>uart_rd,
		perif_cs=>uart_cs,
		c1_lock=>c1_lock_uart(0),
		c1_data_out=>c1_data_in_uart,
		c2_lock=>c2_lock_uart(0),
		c2_data_out=>c2_data_in_uart
	);
	UART_1	: UART port map(clk=>clk, reset_n=>reset_n, wr=>uart_wr, rd=>uart_rd, data_in=>uart_in, data_out=>uart_out, rx=>UART_RXD, tx=>UART_TXD, addr=>uart_addr, cs=>uart_cs);

	-- Data select
	Muxer2_data_c1	: Muxer2 port map(sel=>ram_cs, i0=>c1_data_in_uart, i1=>c1_data_in_ram, o=>c1_data_in);
	Muxer2_data_c2	: Muxer2 port map(sel=>ram_cs, i0=>c2_data_in_uart, i1=>c2_data_in_ram, o=>c2_data_in);
	
	-- Lock select
	Muxer2_lock_c1	: Muxer2 generic map(g_data_w=>1) port map(sel=>ram_cs, i0=>c1_lock_uart, i1=>c1_lock_ram, o=>c1_lock);
	Muxer2_lock_c2	: Muxer2 generic map(g_data_w=>1) port map(sel=>ram_cs, i0=>c2_lock_uart, i1=>c2_lock_ram, o=>c2_lock);
	
end structural;
