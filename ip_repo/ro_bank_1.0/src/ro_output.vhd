library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library rtl;
use rtl.ro_pack.all;

entity ro_output is
    generic (
        count_g : positive := 8;
        depth_g : positive := 8;
        width_g : positive := 32
    );

    port (
        clock_i : in std_logic;
        state_i : in std_logic_vector(count_g * state_width(depth_g) - 1 downto 0);
        sel_i   : in std_logic_vector(sel_width(count_g) - 1 downto 0);
        step_o  : out std_logic_vector(width_g - 1 downto 0);
        steps_o : out std_logic_vector(count_g * state_width(depth_g) - 1 downto 0);
        state_o : out std_logic_vector(state_width(depth_g) - 1 downto 0)
    );
end ro_output;

architecture ro_output_arch of ro_output is
    type steps_array_t is array (0 to count_g - 1) of unsigned(state_width(depth_g) - 1 downto 0);

    signal last_state_s : std_logic_vector(count_g * state_width(depth_g) - 1 downto 0) := (others => '0');
    signal curr_state_s : std_logic_vector(count_g * state_width(depth_g) - 1 downto 0) := (others => '0');

begin

    states : process (clock_i)
    begin
        if rising_edge(clock_i) then
            last_state_s <= curr_state_s;
            curr_state_s <= state_i;
        else
            last_state_s <= last_state_s;
            curr_state_s <= curr_state_s;
        end if;
    end process; -- state_reg

    steps : process (state_i, sel_i)
        variable step_v : steps_array_t;
        variable curr_state_v, last_state_v : unsigned(state_width(depth_g) - 1 downto 0);
        variable sum_v : unsigned(width_g - 1 downto 0);
        variable sel_v : positive;
    begin
        sum_v := (others => '0');
        sel_v := to_integer(unsigned(sel_i));

        for i in 0 to count_g - 1 loop
            curr_state_v := unsigned(curr_state_s((i + 1) * state_width(depth_g) - 1 downto i * state_width(depth_g)));
            last_state_v := unsigned(last_state_s((i + 1) * state_width(depth_g) - 1 downto i * state_width(depth_g)));

            if last_state_v > curr_state_v then
                step_v(i) := depth_g + depth_g + curr_state_v - last_state_v;
            else
                step_v(i) := curr_state_v - last_state_v;
            end if;

            steps_o((i + 1) * state_width(depth_g) - 1 downto i * state_width(depth_g)) <= std_logic_vector(step_v(i));
            sum_v := sum_v + step_v(i);
        end loop;

        step_o <= std_logic_vector(sum_v);
        state_o <= state_i(state_width(depth_g) * (sel_v + 1) - 1 downto state_width(depth_g) * sel_v);
    end process; -- counts

end ro_output_arch; -- ro_output_arch