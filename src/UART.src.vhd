--
-- ICAI-RISC UART pheriferial.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity UART is
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
end entity;

architecture structural of UART is

	signal tx_clk	: std_logic;
	signal tx_data	: std_logic_vector(15 downto 0);
	signal tx_message	: std_logic_vector(9 downto 0);
	signal tx_empty	: std_logic;
	signal tx_load	: std_logic;
	signal tx_piso_reset	: std_logic;
	signal tx_piso_out	: std_logic;
	signal tx_transmitting	: std_logic;
	signal rx_ctrl_clk	: std_logic;
	signal rx_sample_clk	: std_logic;
	signal rx_sample	: std_logic;
	signal rx_store	: std_logic;
	signal rx_message	: std_logic_vector(9 downto 0);
	signal rx_data	: std_logic_vector(15 downto 0);
	signal rx_rd	: std_logic;
	signal rx_n	: std_logic;
	signal config_en	: std_logic;
	signal config_out 	: std_logic_vector(15 downto 0);
	signal rx_data_out	: std_logic_vector(15 downto 0);
	signal tx_wr	: std_logic;
	signal rx_empty	: std_logic;
	signal tx_full	: std_logic;
	
	component FIFO is
		generic(
			g_data_w	: integer := 16;
			g_depth	: integer := 16
		);
		port(
			reset_n	: in std_logic;
			clk	: in std_logic;
			wr	: in std_logic;
			rd	: in std_logic;
			data_in	: in std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0);
			empty	:	out std_logic;
			full	: out std_logic
		);
	end component;
	component PISOReg is
		generic(
			g_data_w	: integer := 16
		);
		port(
			reset_n	: in std_logic;
			clk	: in std_logic;
			data_in	: in std_logic_vector(g_data_w-1 downto 0);
			data_out	: out std_logic;
			done_n	: out std_logic
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
	component UARTTXControl is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			empty	: in std_logic;
			transmitting	: in std_logic;
			load	: out std_logic
		);
	end component;
	component Muxer4 is
		generic(
			g_data_w	: integer := 16
		);
		port(
			sel	: in std_logic_vector(1 downto 0);
			i0	: in std_logic_vector(g_data_w-1 downto 0);
			i1	: in std_logic_vector(g_data_w-1 downto 0);
			i2	: in std_logic_vector(g_data_w-1 downto 0);
			i3	: in std_logic_vector(g_data_w-1 downto 0);
			o	: out std_logic_vector(g_data_w-1 downto 0)
		);
	end component;
	component SIPOReg is
		generic(
			g_data_w	: integer := 16
		);
		port(
			reset_n	: in std_logic;
			clk	:in std_logic;
			data_in		: in std_logic;
			data_out		: inout std_logic_vector(g_data_w-1 downto 0)
		);
	end component;
	component UARTRXControl is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			rx	: in std_logic;
			sample	: out std_logic;
			store	: out std_logic
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

	-- Config register
	config_en <= rd and cs and addr(0);
	config_out(0) <= not rx_empty;
	config_out(1) <= tx_full;
	config_out(15 downto 2) <= (others=>'0');
	Muxer2_1	:	Muxer2 port map(sel=>config_en, i0=>rx_data_out, i1=>config_out, o=>data_out);
	
	-- TX clock generator
	ClockDiv_1	: ClockDiv generic map(g_freq_old=>50000000, g_freq_new=>g_bauds) port map(clk=>clk, reset_n=>reset_n, clk_o=>tx_clk);
	
	-- TX FIFO
	tx_wr <= wr and cs and not addr(0);
	FIFO_1	: FIFO port map(reset_n=>reset_n, clk=>clk, wr=>tx_wr, rd=>tx_load, data_in=>data_in, data_out=>tx_data, empty=>tx_empty, full=>tx_full);
	
	-- TX loading logic...
	UARTTXControl_1	: UARTTXControl port map(reset_n=>reset_n, clk=>clk, empty=>tx_empty, transmitting=>tx_transmitting, load=>tx_load);
	
	-- TX message building...
	tx_message(9) <= '1';	-- Start bit...
	tx_message(8) <= not tx_data(0);	-- Content...
	tx_message(7) <= not tx_data(1);	-- Content...
	tx_message(6) <= not tx_data(2);	-- Content...
	tx_message(5) <= not tx_data(3);	-- Content...
	tx_message(4) <= not tx_data(4);	-- Content...
	tx_message(3) <= not tx_data(5);	-- Content...
	tx_message(2) <= not tx_data(6);	-- Content...
	tx_message(1) <= not tx_data(7);	-- Content...
	tx_message(0) <= '0';	-- Stop bit...
	
	-- TX PISO register
	tx_piso_reset <= not tx_load;
	PISOReg_1	: PISOReg generic map(g_data_w=>10) port map(reset_n=>tx_piso_reset, clk=>tx_clk, data_in=>tx_message, data_out=>tx_piso_out, done_n=>tx_transmitting);
	tx <= not tx_piso_out;
	
	-- RX signal
	rx_n <= not rx;
	
	-- RX control clock generator
	ClockDiv_2	: ClockDiv generic map(g_freq_old=>50000000, g_freq_new=>g_bauds*16) port map(clk=>clk, reset_n=>reset_n, clk_o=>rx_ctrl_clk);

	-- RX sample clock generator
	ClockDiv_3	: ClockDiv generic map(g_freq_old=>15, g_freq_new=>1) port map(clk=>rx_ctrl_clk, reset_n=>rx_sample, clk_o=>rx_sample_clk);

	-- RX SIPO register
	SIPOReg_1	: SIPOReg generic map(g_data_w=>10) port map(reset_n=>reset_n, clk=>rx_sample_clk, data_in=>rx_n, data_out=>rx_message);
	
	-- RX control machine
	UARTRXControl_1	: UARTRXControl port map(clk=>rx_ctrl_clk, reset_n=>reset_n, rx=>rx_n, sample=>rx_sample, store=>rx_store);
	
	-- RX message reconstruction...
	rx_data(7) <= not rx_message(1);
	rx_data(6) <= not rx_message(2);
	rx_data(5) <= not rx_message(3);
	rx_data(4) <= not rx_message(4);
	rx_data(3) <= not rx_message(5);
	rx_data(2) <= not rx_message(6);
	rx_data(1) <= not rx_message(7);
	rx_data(0) <= not rx_message(8);
	rx_data(15 downto 8) <= (others=>'0');
	
	-- RX FIFO
	rx_rd <= rd and cs and not addr(0);
	FIFO_2	: FIFO port map(reset_n=>reset_n, clk=>clk, wr=>rx_store, rd=>rx_rd, data_in=>rx_data, data_out=>rx_data_out, empty=>rx_empty);
	
end structural;