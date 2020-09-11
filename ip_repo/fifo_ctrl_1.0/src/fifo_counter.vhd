library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fifo_counter is
    generic (
        width_g : positive
    );
    port (
        clock_i  : in std_logic;
        reset_i  : in std_logic;
        up_i     : in std_logic;
        en_i     : in std_logic;
        target_i : in std_logic_vector(width_g - 1 downto 0);
        count_o  : out std_logic_vector(width_g - 1 downto 0);
        locked_o : out std_logic
    );
end fifo_counter;

architecture fifo_counter_arch of fifo_counter is
    type counter_state_t is (reset, hold, run, locked);
    signal current_count, next_count : unsigned(width_g - 1 downto 0);
    signal current_target, next_target : unsigned(width_g - 1 downto 0);
    signal current_state, next_state : counter_state_t;

begin
    locked_o <= '1' when current_state = locked else '0';
    count_o <= std_logic_vector(current_count);

    counter : process (clock_i, reset_i)
    begin
        if reset_i = '1' then
            current_state <= reset;
            current_count <= (others => '0');
            current_target <= (others => '0');
        elsif rising_edge(clock_i) then
            current_state <= next_state;
            current_count <= next_count;
            current_target <= next_target;
        end if;
    end process counter;

    state_comb : process (current_state, current_count, current_target, target_i, en_i, up_i)
    begin
        case current_state is
            when reset =>
                next_state <= hold;
                next_target <= current_target;
                next_count <= current_count;
                
            when hold =>
                if en_i = '1' then
                    next_state <= run;
                else
                    next_state <= hold;
                end if;
                next_count <= current_count;
                next_target <= unsigned(target_i);

            when run =>
                if en_i = '1' then
                    if current_count = current_target - 1 or current_count = current_target + 1 then
                        next_state <= locked;
                    else
                        next_state <= run;
                    end if;

                    if up_i = '1' then
                        next_count <= current_count + 1;
                    else
                        next_count <= current_count - 1;
                    end if;
                else
                    next_state <= hold;
                    next_count <= current_count;
                end if;
                next_target <= current_target;

            when locked =>
                if unsigned(target_i) /= current_target then
                    next_state <= hold;
                else
                    next_state <= locked;
                end if;
                next_target <= current_target;
                next_count <= current_count;

            when others =>
                next_target <= current_target;
                next_state <= current_state;
                next_count <= current_count;
        end case;
    end process; -- state_comb

end fifo_counter_arch; -- fifo_counter_arch