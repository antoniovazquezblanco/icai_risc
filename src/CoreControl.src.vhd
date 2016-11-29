--
-- Control state machine for ICAI-RISC processor core.
--
-- Written by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CoreControl is
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
end entity;

architecture behavioural of CoreControl is
	type state_type is (reset, fetch, decod, beq3, arith3, arith4, addi3, addi4, lui3, jalr3, lwsw3, lw4, sw4, lw5, sw5, tas3, tas4, tas5, tas6, tas7, tas8);
	signal state   : state_type	:= reset;
begin
	process(reset_n, clk)
	begin
		if reset_n = '0' then
			state <= reset;
		elsif rising_edge(clk) then
			case state is
				when reset =>
					state <= fetch;
				when fetch =>
					state <= decod;
				when decod =>
					case ir_cod_op is
						when "110" => state <= beq3;
						when "000" => state <= arith3;
						when "001" => state <= addi3;
						when "011" => state <= lui3;
						when "111" => state <= jalr3;
						when "101" => state <= lwsw3;
						when "100" => state <= lwsw3;
						when "010" => state <= tas3;
						when others => state <= reset;
					end case;
				when beq3 =>
					state <= fetch;
				when arith3 =>
					state <= arith4;
				when arith4 =>
					state <= fetch;
				when addi3 =>
					state <= addi4;
				when addi4 =>
					state <= fetch;
				when lui3 =>
					state <= fetch;
				when jalr3 =>
					state <= fetch;
				when lwsw3 =>
					case ir_cod_op is
						when "101" => state <= lw4;
						when "100" => state <= sw4;
						when others => state <= reset;
					end case;
				when lw4 =>
					if lock = '0' then
						state <= lw5;
					end if;
				when sw4 =>
					if lock = '0' then
						state <= sw5;
					end if;
				when lw5 =>
					state <= fetch;
				when sw5 =>
					state <= fetch;
				when tas3 =>
					if lock = '0' then
						state <= tas4;
					end if;
				when tas4 =>
					state <= tas5;
				when tas5 =>
					if zero = '0' then
						state <= fetch;
					else
						state <= tas6;
					end if;
				when tas6 =>
					state <= tas7;
				when tas7 =>
					state <= tas8;
				when tas8 =>
					state <= fetch;
				when others =>
					state <= reset;
			end case;
		end if;
	end process;

	process(state, ir_cod_func)
	begin
		case state is
			when reset =>
				pc_sel <= "00"; -- Reset value
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when fetch =>
				pc_sel <= "01";	-- Alu
				pc_wr <= '1';		-- Store
				pc_wr_cond <= '0';
				ir_en <= '1';			-- Store instruction
				alu_sel_a <= "01";		-- PC
				alu_sel_b <= "01";	-- +1
				alu_op <= "0001";		-- Add
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when decod =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "01";		-- PC
				alu_sel_b <= "10";	-- S(IR[6..0])
				alu_op <= "0001";		-- Add
				alu_en <= '1';			-- Store
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when beq3 =>
				pc_sel <= "00";	-- Alu out
				pc_wr <= '0';
				pc_wr_cond <= '1'; -- If zero write
				ir_en <= '0';
				alu_sel_a <= "00";		-- Reg A...
				alu_sel_b <= "00";	-- Reg B...
				alu_op <= "0010";		-- Substraction...
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when arith3 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";			-- Reg A...
				alu_sel_b <= "00";		-- Reg B...
				alu_op <= ir_cod_func;	-- Function...
				alu_en <= '1';				-- Store result
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when arith4 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "00"; -- Alu register
				bank_sel_wdir <= "00";	-- IR[6..4]
				bank_en <= '1';			-- Write bank
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when addi3 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";		-- Reg A...
				alu_sel_b <= "10";	-- S(IR[6..0])
				alu_op <= "0001";		-- Add
				alu_en <= '1';			-- Store result
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when addi4 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "00"; -- Alu out
				bank_sel_wdir <= "01";	-- IR[9..7]
				bank_en <= '1';			-- Write bank
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when lui3 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "11"; -- IR[9..0]|000000
				bank_sel_wdir <= "10";	-- IR[12..10]
				bank_en <= '1';			-- Write bank
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when jalr3 =>
				pc_sel <= "10";	-- Reg A
				pc_wr <= '1';		-- Write
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "10";	-- PC
				bank_sel_wdir <= "01";	-- IR[9..7]
				bank_en <= '1';			-- Write
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when lwsw3 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";		-- RegA
				alu_sel_b <= "10";	-- S(IR[6..0])
				alu_op <= "0001";		-- Add
				alu_en <= '1';			-- Store
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '0';
			when lw4 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "01"; -- IR[9..7]
				bank_sel_wdir <= "01";	-- mem data
				bank_en <= '1';
				mem_rd <= '1';				-- Read!
				mem_wr <= '0';
				atomic <= '0';
			when lw5 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "01"; -- IR[9..7]
				bank_sel_wdir <= "01";	-- mem data
				bank_en <= '1';
				mem_rd <= '1';				-- Read!
				mem_wr <= '0';
				atomic <= '0';
			when sw4 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '1';	-- Write!
				atomic <= '0';
			when sw5 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '1';	-- Write!
				atomic <= '0';
			when tas3 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "11";
				alu_op <= "0001";
				alu_en <= '1';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '1';
				mem_wr <= '0';
				atomic <= '1';
			when tas4 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "01";
				alu_sel_b <= "10";
				alu_op <= "0001";
				alu_en <= '1';
				bank_sel_wdata <= "01";
				bank_sel_wdir <= "01";
				bank_en <= '1';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '1';
			when tas5 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '1';
				ir_en <= '0';
				alu_sel_a <= "10";
				alu_sel_b <= "00";
				alu_op <= "0001";
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '1';
			when tas6 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "10";
				alu_sel_b <= "00";
				alu_op <= "0001";
				alu_en <= '1';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '1';
			when tas7 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "11";
				alu_op <= "0001";
				alu_en <= '1';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "01";
				bank_en <= '1';
				mem_rd <= '0';
				mem_wr <= '0';
				atomic <= '1';
			when tas8 =>
				pc_sel <= "00";
				pc_wr <= '0';
				pc_wr_cond <= '0';
				ir_en <= '0';
				alu_sel_a <= "00";
				alu_sel_b <= "00";
				alu_op <= "0000";
				alu_en <= '0';
				bank_sel_wdata <= "00";
				bank_sel_wdir <= "00";
				bank_en <= '0';
				mem_rd <= '0';
				mem_wr <= '1';
				atomic <= '0';
		end case;
	end process;
end behavioural;