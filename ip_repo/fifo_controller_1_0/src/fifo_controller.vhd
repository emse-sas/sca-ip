-------------------------------------------------------
--! @author Sami Dahoux (s.dahoux@emse.fr)
--! @file tdc.vhd
--! @brief FIFO acquisition controller to synchronize acquisition with crypto-algorithm
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_controller is
	port (
		clock_i : in std_logic;
		reset_i : in std_logic;
		read_i : in std_logic;
		write_i : in std_logic;
		empty_i : in std_logic;
		full_i : in std_logic;
		write_o : out std_logic;
		read_o : out std_logic;
		reset_o : out std_logic
	) ;
end fifo_controller;

architecture fifo_controller_arch of fifo_controller is

type fifo_state_t is (hold, pop, push, done, reset);

signal current_state, next_state : fifo_state_t;

begin
	state_register : process( clock_i, reset_i )
	begin
		if reset_i = '1' then
			current_state <= reset;
		elsif rising_edge(clock_i) then
			current_state <= next_state;
		end if;
	end process state_register;

	state_comb : process( current_state, read_i, write_i, empty_i, full_i )
			begin
			case current_state is
				when reset =>
					next_state <= hold;
				when hold =>
					if read_i = '1' and empty_i = '0' then
						next_state <= pop;
					elsif write_i = '1' and full_i = '0' then
						next_state <= push;
					else
						next_state <= hold;
					end if;
				when pop =>
						next_state <= done;
				when push =>
					 if write_i = '0' or full_i = '1' then
								next_state <= done;
					 else
								next_state <= push;  
					 end if;                   
				when done =>
						if read_i = '0' then
								next_state <= hold;
						else
								next_state <= done;
						end if;                   
				when others =>
						next_state <= reset;
			end case;
	end process state_comb;

	out_comb : process( current_state )
	begin
		case current_state is
			when reset =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '1';
			when hold =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
			when pop =>
				write_o <= '0';
				read_o <= '1';
				reset_o <= '0';
			when push =>
				write_o <= '1';
				read_o <= '0';
				reset_o <= '0';
			when done =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';    
			when others =>
				write_o <= '0';
				read_o <= '0';
				reset_o <= '0';
		end case;
	end process out_comb;
	
end fifo_controller_arch ; -- fifo_controller_arch