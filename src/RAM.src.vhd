--
-- ICAI-RISC RAM.
-- This file contains both a generic implementation for any FPGA and
-- an Altera Megafunction implementation that requires less RAM and
-- time to synthesize.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity RAM is
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
end entity;

architecture behavioural of RAM is
	-- Generic RAM implementation
   --type ram_type is array (0 to g_addr_n-1) of std_logic_vector(data_in'range);
   --signal ram : ram_type;
	
	-- Altera Megafunction
	constant ram_w : integer := integer(ceil(log2(real(g_addr_n))));
	signal address	: std_logic_vector(ram_w-1 downto 0);
	signal r	: std_logic;
	signal w	: std_logic;
	component altsyncram is
		generic(
			address_reg_b				: string;
			clock_enable_input_a			: string;
			clock_enable_input_b			: string;
			clock_enable_output_a			: string;
			clock_enable_output_b			: string;
			intended_device_family			: string;
			lpm_type				: string;
			numwords_a				: natural;
			numwords_b				: natural;
			operation_mode				: string;
			outdata_aclr_b				: string;
			outdata_reg_b				: string;
			power_up_uninitialized			: string;
			rdcontrol_reg_b				: string;
			read_during_write_mode_mixed_ports	: string;
			widthad_a				: natural;
			widthad_b				: natural;
			width_a					: natural;
			width_b					: natural;
			width_byteena_a				: natural
		);
		port(
			address_a	: in std_logic_vector(ram_w-1 downto 0);
			clock0		: in std_logic;
			data_a		: in std_logic_vector(15 downto 0);
			q_b		: out std_logic_vector(15 downto 0);
			rden_b		: in std_logic;
			wren_a		: in std_logic;
			address_b	: in std_logic_vector(ram_w-1 downto 0)
		);
	end component;
begin
	-- Generic RAM implementation
	-- process(clk, reset_n, cs, rd) is
	-- begin
	-- 	if reset_n = '0' then
	-- 		ram <= (others=>(others=>'0'));
	-- 	elsif rising_edge(clk) and cs='1' then
	-- 		if rd = '1' then
	-- 			if to_integer(unsigned(addr)) > g_addr_n then
	-- 				data_out <= (others=>'0');
	-- 			else
	-- 				data_out <= ram(to_integer(unsigned(addr)));
	-- 			end if;
	-- 		elsif wr = '1' then
	-- 			if to_integer(unsigned(addr)) <= g_addr_n then
	-- 				ram(to_integer(unsigned(addr))) <= data_in;
	-- 			end if;
	-- 		end if;
	-- 	end if;
	-- end process;
	
	-- Altera Megafunction
	assert 2**ram_w=g_addr_n report "RAM: Not using the entire address space..." severity failure;
	address <= addr(ram_w-1 downto 0);
	r <= rd and cs;
	w <= wr and cs;
	altsyncram_1 : altsyncram generic map(
			address_reg_b=>"CLOCK0",
			clock_enable_input_a=>"BYPASS",
			clock_enable_input_b=>"BYPASS",
			clock_enable_output_a=>"BYPASS",
			clock_enable_output_b=>"BYPASS",
			intended_device_family=>"Cyclone II",
			lpm_type=>"altsyncram",
			numwords_a=>g_addr_n,
			numwords_b=>g_addr_n,
			operation_mode=>"DUAL_PORT",
			outdata_aclr_b=>"NONE",
			outdata_reg_b=>"CLOCK0",
			power_up_uninitialized=>"FALSE",
			rdcontrol_reg_b=>"CLOCK0",
			read_during_write_mode_mixed_ports=>"DONT_CARE",
			widthad_a=>ram_w,
			widthad_b=>ram_w,
			width_a=>16,
			width_b=>16,
			width_byteena_a=>1
		)
		port map(
			address_a=>address,
			clock0=>clk,
			data_a=>data_in,
			rden_b=>r,
			wren_a=>w,
			address_b=>address,
			q_b=>data_out
		);
end behavioural;