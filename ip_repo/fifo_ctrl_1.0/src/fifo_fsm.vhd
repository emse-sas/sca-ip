library ieee;
use ieee.std_logic_1164.all;

entity fifo_fsm is
	port (
		clock_i   : in std_logic;
		reset_i   : in std_logic;
		read_i    : in std_logic;
		write_i   : in std_logic;
		empty_i   : in std_logic;
		full_i    : in std_logic;
		locked_i  : in std_logic;
		write_o   : out std_logic;
		read_o    : out std_logic;
		reset_o   : out std_logic;
		en_o      : out std_logic;
		clk_sel_o : out std_logic
	);
end fifo_fsm;

architecture fifo_fsm_arch of fifo_fsm is

	type fifo_state_t is (hold, start_pop, start_push, pop, push, done_push, done_pop, reset);

	signal current_state, next_state : fifo_state_t;
begin

	state_reg : process (clock_i, reset_i, locked_i, full_i, write_i)
	begin
		if reset_i = '1' then
			current_state <= reset;
		elsif locked_i = '1' and write_i = '1' then
			current_state <= done_push;
		elsif full_i = '1' and write_i = '1' then
			current_state <= done_push;
		elsif rising_edge(clock_i) then
			current_state <= next_state;
		end if;
	end process state_reg;

	state_comb : process (current_state, read_i, write_i, empty_i, full_i)
	begin
		case current_state is
			when reset =>
				next_state <= hold;
			when hold =>
				if read_i = '1' and empty_i = '0' then
					next_state <= start_pop;
				elsif write_i = '1' and full_i = '0' then
					next_state <= start_push;
				else
					next_state <= hold;
				end if;
			when start_push =>
				next_state <= push;
			when start_pop =>
				next_state <= pop;
			when pop =>
				next_state <= done_pop;
			when push =>
				if write_i = '0' then
					next_state <= done_push;
				else
					next_state <= push;
				end if;
			when done_push =>
				next_state <= hold;
			when done_pop =>
				if read_i = '0' then
					next_state <= hold;
				else
					next_state <= done_pop;
				end if;
			when others =>
				next_state <= reset;
		end case;
	end process state_comb;

	out_comb : process (current_state)
	begin
		case current_state is
			when reset =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '1';
				en_o <= '0';
				clk_sel_o <= '0';
			when hold =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				clk_sel_o <= '0';
			when start_push =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '1';
				clk_sel_o <= '1';
			when start_pop =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '1';
				clk_sel_o <= '0';
			when pop =>
				write_o <= '0';
				read_o <= '1';
				reset_o <= '0';
				en_o <= '1';
				clk_sel_o <= '0';
			when push =>
				write_o <= '1';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '1';
				clk_sel_o <= '1';
			when done_push =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				clk_sel_o <= '0';
			when done_pop =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				clk_sel_o <= '0';
			when others =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				clk_sel_o <= '0';
		end case;
	end process out_comb;
end fifo_fsm_arch; -- fifo_fsm_arch