--
-- ICAI-RISC processor core.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Core2 is
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
end entity;

architecture structural of Core2 is

	-- Signals
	signal pc_sel	: std_logic_vector(1 downto 0);
	signal pc_wr	: std_logic;
	signal pc_wr_cond	: std_logic;
	signal pc_en	: std_logic;
	signal pc_pre	: std_logic_vector(15 downto 0);
	signal pc_out	: std_logic_vector(15 downto 0);
	signal ir_en	: std_logic;
	signal ir_pre	: std_logic_vector(15 downto 0);
	signal ir_out	: std_logic_vector(15 downto 0);
	signal ir_high	: std_logic_vector(15 downto 0);
	signal ir_low	: std_logic_vector(15 downto 0);
	signal bank_reg_a	: std_logic_vector(15 downto 0);
	signal bank_reg_b	: std_logic_vector(15 downto 0);
	signal bank_sel_wdir	:	std_logic_vector(1 downto 0);
	signal bank_sel_wdata	: std_logic_vector(1 downto 0);
	signal bank_wdir	: std_logic_vector(2 downto 0);
	signal bank_wdata	: std_logic_vector(15 downto 0);
	signal bank_en	: std_logic;
	signal alu_pre	: std_logic_vector(15 downto 0);
	signal alu_out	: std_logic_vector(15 downto 0);
	signal alu_zero		: std_logic;
	signal alu_sel_a	: std_logic_vector(1 downto 0);
	signal alu_sel_b	: std_logic_vector(1 downto 0);
	signal alu_a	: std_logic_vector(15 downto 0);
	signal alu_b	: std_logic_vector(15 downto 0);
	signal alu_op	: std_logic_vector(3 downto 0);
	signal alu_en	: std_logic;
	signal mem_wr	: std_logic;
	signal mem_rd	: std_logic;
	signal rd_local	: std_logic;
	signal wr_local	: std_logic;
	signal data_in_local	: std_logic_vector(15 downto 0);
	signal input_data	: std_logic_vector(15 downto 0);
	signal data_in_timer	: std_logic_vector(15 downto 0);
	signal data_in_ram	: std_logic_vector(15 downto 0);
	signal cs_ram	: std_logic;
	signal cs_timer	: std_logic;
	
	-- Components
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
	component Reg is
		port(
			clk	: in std_logic;
			reset_n	: in std_logic;
			en	: in std_logic;
			d	: in std_logic_vector(15 downto 0);
			q	: out std_logic_vector(15 downto 0)
		);
	end component;
	component ROMC2 is
		port(
			addr	: in std_logic_vector(15 downto 0);
			data	: out std_logic_vector(15 downto 0)
		);
	end component;
	component RegBank is
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
	end component;
	component ALU is
		port(
			a	: in std_logic_vector(15 downto 0)	:= (others=>'0');
			b	: in std_logic_vector(15 downto 0)	:= (others=>'0');
			op	: in std_logic_vector(3 downto 0)	:= (others=>'0');
			o	: out std_logic_vector(15 downto 0);
			zero	: out std_logic
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
	component CoreControl is
		port(
			reset_n	: in std_logic;
			clk	: in std_logic;
			lock	: in std_logic;
			zero	: in std_logic;
			ir_cod_op	: in std_logic_vector(2 downto 0);
			ir_cod_func	: in std_logic_vector(3 downto 0);
			pc_sel	: out std_logic_vector(1 downto 0);
			ir_en	: out std_logic;
			pc_wr	: out std_logic;
			pc_wr_cond	: out std_logic;
			alu_sel_a	: out std_logic_vector(1 downto 0);
			alu_sel_b	: out std_logic_vector(1 downto 0);
			alu_op	: out std_logic_vector(3 downto 0);
			alu_en	: out std_logic;
			bank_sel_wdata	: out std_logic_vector(1 downto 0);
			bank_sel_wdir	: out std_logic_vector(1 downto 0);
			bank_en	: out std_logic;
			mem_rd	: out std_logic;
			mem_wr	: out std_logic;
			atomic	: out std_logic
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
begin
	
	-- Signals
	addr <= alu_out(14 downto 0);
	data_out <= bank_reg_b;
	wr <= mem_wr and alu_out(15);
	rd <= mem_rd and alu_out(15);
	wr_local <= mem_wr and not alu_out(15);
	rd_local <= mem_rd and not alu_out(15);
	Muxer2_Data	: Muxer2 port map(sel=>alu_out(15), i0=>data_in_local, i1=>data_in, o=>input_data);
	
	-- PC
	pc_en <= pc_wr or (pc_wr_cond and alu_zero);
	Muxer4_PC	: Muxer4 port map(sel=>pc_sel, i0=>alu_out, i1=>alu_pre, i2=>bank_reg_a, i3=>(others=>'U'), o=>pc_pre);
	Reg_PC	: Reg port map(clk=>clk, reset_n=>reset_n, en=>pc_en, d=>pc_pre, q=>pc_out);
	
	-- ROM
	ROM_1	: ROMC2 port map(addr=>pc_out, data=>ir_pre);

	-- IR
	Reg_IR	: Reg port map(clk=>clk, reset_n=>reset_n, en=>ir_en, d=>ir_pre, q=>ir_out);
	ir_high <= ir_out(9 downto 0)&"000000";
	ir_low <= std_logic_vector(resize(signed(ir_out(6 downto 0)), 16));

	-- Reg bank
	Muxer4_bank_wdir	: Muxer4 generic map(g_data_w=>3) port map(sel=>bank_sel_wdir, i0=>ir_out(6 downto 4), i1=>ir_out(9 downto 7), i2=>ir_out(12 downto 10), i3=>(others=>'U'), o=>bank_wdir);
	Muxer4_bank_wdata	: Muxer4 port map(sel=>bank_sel_wdata, i0=>alu_out, i1=>input_data, i2=>pc_out, i3=>ir_high, o=>bank_wdata);
	RegBank_1	: RegBank port map(clk=>clk, reset_n=>reset_n, w_en=>bank_en, w_dir=>bank_wdir, w_data=>bank_wdata, r_dir_a=>ir_out(12 downto 10), r_dir_b=>ir_out(9 downto 7), r_a=>bank_reg_a, r_b=>bank_reg_b);

	-- Alu
	Muxer4_Alu_1	: Muxer4 port map(sel=>alu_sel_a, i0=>bank_reg_a, i1=>pc_out, i2=>(others=>'0'), i3=>(others=>'0'), o=>alu_a);
	Muxer4_Alu_2	: Muxer4 port map(sel=>alu_sel_b, i0=>bank_reg_b, i1=>"0000000000000001", i2=>ir_low, i3=>(others=>'0'), o=>alu_b);
	ALU_1		: ALU port map(a=>alu_a, b=>alu_b, op=>alu_op, o=>alu_pre, zero=>alu_zero);
	Reg_ALU	: Reg port map(clk=>clk, reset_n=>reset_n, en=>alu_en, d=>alu_pre, q=>alu_out);
	
	-- Core control
	CoreControl_1	: CoreControl port map(reset_n=>reset_n, clk=>clk, lock=>lock, zero=>alu_zero, ir_cod_op=>ir_out(15 downto 13), ir_cod_func=>ir_out(3 downto 0), pc_sel=>pc_sel, ir_en=>ir_en, pc_wr=>pc_wr, pc_wr_cond=>pc_wr_cond, alu_sel_a=>alu_sel_a, alu_sel_b=>alu_sel_b, alu_op=>alu_op, alu_en=>alu_en, bank_sel_wdata=>bank_sel_wdata, bank_sel_wdir=>bank_sel_wdir, bank_en=>bank_en, mem_rd=>mem_rd, mem_wr=>mem_wr, atomic=>atomic);
	
	-- RAM
	ChipSelect_1	: ChipSelect generic map(g_addr_start=>16#0000#, g_addr_end=>16#7FFD#) port map(addr=>alu_out(14 downto 0), sel=>cs_ram);
	RAM_1	: RAM generic map(g_addr_w=>15, g_addr_n=>16#0200#) port map(clk=>clk, reset_n=>reset_n, rd=>rd_local, wr=>wr_local, cs=>cs_ram, addr=>alu_out(14 downto 0), data_in=>bank_reg_b, data_out=>data_in_ram);

	-- Timer
	cs_timer <= not cs_ram;
	Timer_1	: Timer port map(reset_n=>reset_n, clk=>clk, cs=>cs_timer, wr=>wr_local, rd=>rd_local, addr=>alu_out(14 downto 0), data_in=>bank_reg_b, data_out=>data_in_timer);
	
	-- Peripherials selection
	Muxer2_Peripherials	: Muxer2 port map(sel=>cs_timer, i0=>data_in_ram, i1=>data_in_timer, o=>data_in_local);
	
end structural;