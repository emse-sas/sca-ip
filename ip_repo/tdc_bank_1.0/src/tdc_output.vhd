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
    type weights_array_t is array (0 to count_g - 1) of unsigned(width_g - 1 downto 0);

    constant sel_width_c : positive := sel_width(count_g);
    constant state_width_c : positive := state_width(depth_g);
    constant weights_width_c : positive := weights_width(count_g, depth_g);
    constant weight_width_c : positive := weights_width(1, depth_g);
begin
    weights : process (state_i, sel_i)
        type weights_array_t is array (0 to count_g - 1) of unsigned(weight_width_c - 1 downto 0);
        variable weight_v : weights_array_t;
        variable sum_v : unsigned(width_g - 1 downto 0);
        variable sel_v : positive;
    begin
        sel_v := to_integer(unsigned(sel_i));
        sum_v := (others => '0');
        concat : for k in 0 to count_g - 1 loop
            weight_v(k) := (others => '0');
            filter : for j in 0 to state_width_c - 1 loop
                if state_i(state_width_c * k + j) = '1' then
                    weight_v(k) := weight_v(k) + 1;
                end if;
            end loop; -- weights
            weights_o(weight_width_c * (k + 1) - 1 downto weights_width_c * k) <= std_logic_vector(weight_v(k));
            sum_v := sum_v + weight_v(k);
        end loop; -- concat 
        weight_o <= std_logic_vector(sum_v);
        state_o <= state_i(state_width_c * (sel_v + 1) - 1 downto state_width_c * sel_v);
    end process;
end tdc_output_arch; -- tdc_output_arch