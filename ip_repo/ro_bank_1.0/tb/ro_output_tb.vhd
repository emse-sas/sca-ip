de: olibrary ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.all;

entity ro_output_tb is
end ro_output_tb;

architecture ro_output_tb_arch of ro_output_tb is

    constant sampling_len_c : positive := 8;
    constant width_c : positive := 8;
    constant count_ro_c : positive := 2;
    constant width_ro_c : positive := integer(ceil(log2(real(count_ro_c))));

    signal clock_s : std_logic := '0';
    signal count_s : std_logic_vector(width_c - 1 downto 0);
    signal counts_s : std_logic_vector(count_ro_c * width_c - 1 downto 0);
    signal state_s : std_logic_vector(count_ro_c * width_c - 1 downto 0) := (others => '0');
    signal sel_s : std_logic_vector(width_ro_c - 1 downto 0) := (others => '0');

begin
    clock_s <= not clock_s after 10 ns;

    DUT : entity work.ro_output(ro_output_arch)
        generic map(
            sampling_len_g => sampling_len_c,
            width_g        => width_c,
            count_ro_g     => count_ro_c
        )
        port map(
            clock_i  => clock_s,
            state_i  => state_s,
            sel_i    => sel_s,
            count_o  => count_s,
            counts_o => counts_s
        );

    PUT : process (clock_s)
        variable state_v : std_logic_vector(width_c - 1 downto 0);
        variable sel_v : positive;
    begin
        sel_v := to_integer(unsigned(sel_s));
        if rising_edge(clock_s) then
            state_v := state_s(width_c * (sel_v + 1) - 1 downto width_c * sel_v);
            if to_integer(unsigned(state_v)) < sampling_len_c + sampling_len_c - 1 then
                state_s(width_c * (sel_v + 1) - 1 downto width_c * sel_v) <= std_logic_vector(unsigned(state_v) + 1);
                sel_s <= sel_s;
            else
                sel_s <= std_logic_vector(unsigned(sel_s) + 1);
                state_s <= (others => '0');
            end if;
        else
            sel_s <= sel_s;
            state_s <= state_s;
        end if;
    end process; -- PUT

end ro_output_tb_arch; -- ro_output_tb_arch