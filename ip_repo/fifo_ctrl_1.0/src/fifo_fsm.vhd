library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fifo_fsm is
	generic (
		width_g : positive
	);
	port (
		clock_i   : in std_logic;
		reset_i   : in std_logic;
		read_i    : in std_logic;
		write_i   : in std_logic;
		empty_i   : in std_logic;
		full_i    : in std_logic;
		target_i  : in std_logic_vector(width_g - 1 downto 0);
		count_i   : in std_logic_vector(width_g - 1 downto 0);
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

	state_comb : process (current_state, read_i, write_i, empty_i, full_i, target_i, count_i)
	variable count_v, target_v : unsigned(width_g - 1 downto 0);
		
	begin
		count_v := unsigned(count_i); 
		target_v := unsigned(target_i); 

		case current_state is
			when reset =>
				next_state <= hold;
			when hold =>
				if count_v = target_v then
					next_state <= hold;
				else
					if read_i = '1' and empty_i = '0' then
						next_state <= pop;
					elsif write_i = '1' and full_i = '0' then
						next_state <= push;
					else
						next_state <= hold;
					end if;
				end if;
			when pop =>
				next_state <= popped;
			when push =>
				if write_i = '0' or full_i = '1' or count_v + 1 = target_v then
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

	out_comb : process (current_state, full_i)
	begin
		case current_state is
			when reset =>
				write_o <= '0';
				read_o <= '0';
				resetœ_o <= '1';
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
				write_o <= not full_i;
				read_o <= '0';
				reset_o <= '0';
				en_o <= not full_i;
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