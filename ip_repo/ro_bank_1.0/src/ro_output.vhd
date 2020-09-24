library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ro_output is
    generic (
        count_ro_g     : positive := 8;
        sampling_len_g : positive := 8;
        width_g        : positive := 32
    );
    port (
        clock_i  : in std_logic;
        state_i  : in std_logic_vector(count_ro_g * width_g - 1 downto 0);
        sel_i    : in std_logic_vector(integer(ceil(log2(real(count_ro_g)))) - 1 downto 0);
        count_o  : out std_logic_vector(width_g - 1 downto 0);
        counts_o : out std_logic_vector(count_ro_g * width_g - 1 downto 0);
        state_o  : out std_logic_vector(width_g - 1 downto 0)
    );
end ro_output;

architecture ro_output_arch of ro_output is
    type counts_array_t is array (0 to count_ro_g - 1) of unsigned(width_g - 1 downto 0);
    signal last_state_s : std_logic_vector(count_ro_g * width_g - 1 downto 0) := (others => '0');
    signal current_state_s : std_logic_vector(count_ro_g * width_g - 1 downto 0) := (others => '0');

begin

    states : process (clock_i)
    begin
        if rising_edge(clock_i) then
            last_state_s <= current_state_s;
            current_state_s <= state_i;
        else
            last_state_s <= last_state_s;
            current_state_s <= current_state_s;
        end if;
    end process; -- state_reg

    counts : process (state_i, sel_i)
        variable count_v : counts_array_t;
        variable sum_v : unsigned(width_g - 1 downto 0);
        variable current_state_v, last_state_v : unsigned(width_g - 1 downto 0);
    begin
        sum_v := (others => '0');
        for i in 0 to count_ro_g - 1 loop
            current_state_v := unsigned(current_state_s((i + 1) * width_g - 1 downto i * width_g));
            last_state_v := unsigned(last_state_s((i + 1) * width_g - 1 downto i * width_g));

            if last_state_v > current_state_v then
                count_v(i) := sampling_len_g + sampling_len_g + current_state_v - last_state_v;
            else
                count_v(i) := current_state_v - last_state_v;
            end if;

            counts_o((i + 1) * width_g - 1 downto i * width_g) <= std_logic_vector(count_v(i));
            sum_v := sum_v + count_v(i);
        end loop;

        count_o <= std_logic_vector(sum_v);
        state_o <= current_state_s(width_g * (to_integer(unsigned(sel_i)) + 1) - 1 downto width_g * to_integer(unsigned(sel_i)));
    end process; -- counts

end ro_output_arch; -- ro_output_arch