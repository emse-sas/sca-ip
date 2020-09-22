library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity state_coder_tb is
end state_coder_tb;

architecture state_coder_tb_arch of state_coder_tb is

    constant sampling_len_g : positive := 8;
    constant width_g : positive := 8;

    signal clock_s : std_logic := '0';
    signal state_is : std_logic_vector(sampling_len_g - 1 downto 0);
    signal state_os : std_logic_vector(width_g - 1 downto 0);
    signal count_s : positive := 0;
begin

    clock_s <= not clock_s after 10 ns;

    DUT : entity work.state_coder(state_coder_arch)
        generic map(
            sampling_len_g => sampling_len_g,
            width_g        => width_g
        )
        port map(
            state_i => state_is,
            state_o => state_os
        );

    PUT : process(count_s)
    begin
        if count_s < sampling_len_g then
            state_is(count_s - 1 downto 0) <= (others => '1');
            state_is(sampling_len_g - 1 downto count_s) <= (others => '0');
        else
            state_is(count_s - sampling_len_g - 1 downto 0) <= (others => '0');
            state_is(sampling_len_g - 1 downto count_s - sampling_len_g) <= (others => '1');
        end if;
    end process; -- PUT

    counter : process (clock_s)
    begin
        if rising_edge(clock_s) then
            if count_s < 2 * sampling_len_g then
                count_s <= count_s + 1;
            else
                count_s <= 0;
            end if;
        end if;
    end process; -- counter
end state_coder_tb_arch; -- state_coder_tb_arch