--
-- ICAI-RISC FIFO Stack.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;

entity FIFO is
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
end entity;

architecture behavioural of FIFO is
	type mem_t is array (0 to g_depth-1) of std_logic_vector(g_data_w-1 downto 0);
	signal mem	: mem_t;
begin
	process(clk, reset_n, rd, wr)
		variable ptr_in	: natural range 0 to g_depth;
		variable ptr_out	: natural range 0 to g_depth;
		variable looped	: boolean := false;
		variable rd_old	: std_logic := '0';
		variable wr_old	: std_logic := '0';
	begin
		if reset_n = '0' then
			ptr_in := 0;
			ptr_out := 0;
			looped := false;
			data_out <= (others=>'0');
			empty <= '1';
			rd_old := rd;
			wr_old := wr;
		elsif rising_edge(clk) then
			-- If rd is '1' show content if present
			if rd_old='0' and rd = '1' and (ptr_out/=ptr_in or (ptr_out=ptr_in and looped)) then
				data_out <= mem(ptr_out);
				ptr_out := ptr_out + 1;
				if ptr_out = g_depth then
					ptr_out := 0;
					looped := not looped;
				end if;
			end if;
			
			-- Write if there's room
			if wr_old='0' and wr = '1' and not (ptr_in=ptr_out and looped) then
				mem(ptr_in) <= data_in;
				ptr_in := ptr_in + 1;
				if ptr_in = g_depth then
					ptr_in := 0;
					looped := not looped;
				end if;
			end if;
			
			-- Update full and empty status
			if ptr_in = ptr_out and not looped then
				empty <= '1';
			else
				empty <= '0';
			end if;
			if ptr_in = ptr_out and looped then
				full <= '1';
			else 
				full <= '0';
			end if;
			
			-- Update old values
			rd_old := rd;
			wr_old := wr;
		end if;
	end process;
end behavioural;