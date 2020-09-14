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
		up_o      : out std_logic;
		clk_sel_o : out std_logic
	);
end fifo_fsm;

architecture fifo_fsm_arch of fifo_fsm is

	type fifo_state_t is (hold, pop, push, popped, reset);

	signal current_state, next_state : fifo_state_t;
begin

	state_reg : process (clock_i, reset_i)
	begin
		if reset_i = '1' then
			current_state <= reset;
		elsif rising_edge(clock_i) then
			current_state <= next_state;
		end if;
	end process state_reg;

	state_comb : process (current_state, read_i, write_i, empty_i, full_i, locked_i)
	begin
		case current_state is
			when reset =>
				next_state <= hold;
			when hold =>
				if locked_i = '0' then
					if read_i = '1' and empty_i = '0' then
						next_state <= pop;
					elsif write_i = '1' and full_i = '0' then
						next_state <= push;
					else
						next_state <= hold;
					end if;
				else
					next_state <= hold;
				end if;
			when pop =>
				next_state <= popped;
			when push =>
				if write_i = '0' or full_i = '1' or locked_i = '1' then
					next_state <= hold;
				else
					next_state <= push;
				end if;
			when popped =>
				if read_i = '0' then
					next_state <= hold;
				else
					next_state <= popped;
				end if;
			when others =>
				next_state <= reset;
		end case;
	end process state_comb;

	out_comb : process (current_state, locked_i, full_i)
	begin
		case current_state is
			when reset =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '1';
				en_o <= '0';
				up_o <= '0';
				clk_sel_o <= '0';
			when hold =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				up_o <= '1';
				clk_sel_o <= '0';
			when pop =>
				write_o <= '0';
				read_o <= '1';
				reset_o <= '0';
				en_o <= '1';
				up_o <= '0';
				clk_sel_o <= '0';
			when push =>
				write_o <= not locked_i and not full_i;
				read_o <= '0';
				reset_o <= '0';
				en_o <= not locked_i and not full_i;
				up_o <= '1';
				clk_sel_o <= '1';
			when popped =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				up_o <= '0';
				clk_sel_o <= '0';
			when others =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
				en_o <= '0';
				up_o <= '0';
				clk_sel_o <= '0';
		end case;
	end process out_comb;
end fifo_fsm_arch; -- fifo_fsm_arch