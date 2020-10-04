library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library rtl;
use rtl.tdc_pack.all;

entity tdc_output is
    generic (
        depth_g : positive := 4;
        count_g : positive := 2;
        width_g : positive := 32
    );
    port (
        clock_i   : in std_logic;
        sel_i     : in std_logic_vector(sel_width(count_g) - 1 downto 0);
        state_i   : in std_logic_vector(state_width(depth_g) * count_g - 1 downto 0);
        weight_o  : out std_logic_vector(width_g - 1 downto 0);
        weights_o : out std_logic_vector(weights_width(count_g, depth_g) - 1 downto 0);
        state_o   : out std_logic_vector(state_width(depth_g) - 1 downto 0)
    );
end tdc_output;

architecture tdc_output_arch of tdc_output is
    constant sel_width_c : positive := sel_width(count_g);
    constant state_width_c : positive := state_width(depth_g);
    constant weights_width_c : positive := weights_width(count_g, depth_g);
    constant weight_width_c : positive := weights_width(1, depth_g);

    type weight_array_t is array (0 to count_g - 1) of std_logic_vector(weight_width_c - 1 downto 0);
    type state_array_t is array (0 to count_g - 1) of std_logic_vector(state_width_c - 1 downto 0);

    signal states_s : state_array_t;
    signal next_weights_s, curr_weights_s : weight_array_t;
    signal next_weight_s, curr_weight_s : std_logic_vector(width_g - 1 downto 0);
begin

    state_o <= states_s(to_integer(unsigned(sel_i)));
    weight_o <= curr_weight_s;

    concat_state : for i in 0 to count_g - 1 generate
        states_s(i) <= state_i(state_width_c * (i + 1) - 1 downto state_width_c * i);
    end generate; -- concat_state

    concat_weight : for i in 0 to count_g - 1 generate
        weights_o(weight_width_c * (i + 1) - 1 downto weights_width_c * i) <= curr_weights_s(i);
    end generate; -- concat_weight

    weights_reg : process (clock_i)
    begin
        if rising_edge(clock_i) then
            curr_weights_s <= next_weights_s;
        else
            curr_weights_s <= curr_weights_s;
        end if;
    end process; -- weights_reg

    weight_reg : process (clock_i)
    begin
        if rising_edge(clock_i) then
            curr_weight_s <= next_weight_s;
        else
            curr_weight_s <= curr_weight_s;
        end if;
    end process; -- weight_reg

    concat_sum : process (state_i)
        variable weights_v : weight_array_t;
    begin
        weights : for i in 0 to count_g - 1 loop
            weights_v(i) := (others => '0');
            filter : for j in 0 to state_width_c - 1 loop
                weights_v(i) := std_logic_vector(unsigned(weights_v(i)) + unsigned(state_i(state_width_c * i + j downto state_width_c * i + j)));
            end loop; -- filter
        end loop; -- weights
        next_weights_s <= weights_v;
    end process; -- concat_sum

    sum : process (curr_weights_s)
        variable weight_v : std_logic_vector(width_g - 1 downto 0);
    begin
        weight_v := (others => '0');
        weight : for i in 0 to count_g - 1 loop
            weight_v := std_logic_vector(unsigned(weight_v) + unsigned(curr_weights_s(i)));
        end loop; -- weight
        next_weight_s <= weight_v;
    end process; -- sum

end tdc_output_arch; -- tdc_output_arch