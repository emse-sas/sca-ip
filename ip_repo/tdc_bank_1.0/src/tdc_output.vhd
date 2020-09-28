entity tdc_output is
    generic (
        depth_g : positive := 8;
        count_g : positive := 8;
        raw_width_g : positive := 5;
        sum_width_g : positive := 32;
        sel_width_g : positive := 3;
        cat_width_g : positive := 5
    );
    port (
        clock_i   : in std_logic;
        sel_i     : in std_logic_vector(integer(ceil(log2(real(count_g)))) - 1 downto 0);
        state_i   : in std_logic_vector(4 * depth_g * count_g - 1 downto 0);
        weight_o  : out std_logic_vector(sum_width_g - 1 downto 0);
        weights_o : out std_logic_vector(integer(ceil(log2(real(4 * depth_g)))) * count_g - 1 downto 0);
        state_o   : out std_logic_vector(4 * depth_g - 1 downto 0)
    );
end tdc_output;

architecture tdc_output_arch of tdc_output is
    type weights_array_t is array (0 to count_g - 1) of unsigned(sum_width_g - 1 downto 0);
begin
    weights : process (state_i, sel_i)
        variable weight_v : weights_array_t;
        variable sum_v : unsigned(sum_width_g - 1 downto 0);
        variable sel_v : positive;
    begin
        sum_v := (others => '0');
        sel_v := to_integer(unsigned(sel_i));

        for i in 0 to count_g - 1 loop
            weight_v(i) := (others => '0');

            for j in 0 to 4 * depth_g - 1 loop
                if data_s(4 * depth_g * i + j) = '1' then
                    weight_v(i) := weight_v(i) + 1;
                end if;
            end loop;

            weights_o(sum_width_g * (i + 1) - 1 downto sum_width_g * i) <= std_logic_vector(weight_v(i));
            sum_v := sum_v + weight_v(i);
        end loop;

        weight_o <= std_logic_vector(sum_v);
        state_o <= state_i(4 * depth_g * (sel_v + 1) - 1 downto 4 * depth_g * sel_v);
    end process;

end tdc_output_arch; -- tdc_output_arch