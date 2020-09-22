library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity state_coder is
    generic (
        sampling_len_g : positive := 8;
        width_g        : positive := 32
    );
    port (
        state_i : in std_logic_vector(sampling_len_g - 1 downto 0);
        state_o : out std_logic_vector(width_g - 1 downto 0)
    );
end state_coder;
architecture state_coder_arch of state_coder is

    constant sampling_len_c : unsigned(width_g - 1 downto 0) := to_unsigned(sampling_len_g, width_g);

begin
    encoder : process (state_i)
        variable weight_v : unsigned(width_g - 1 downto 0);
        
    begin

        weight_v := (others => '0');
        sum : for i in 0 to sampling_len_g - 1 loop
            if state_i(i) = '1' then
                weight_v := weight_v + 1;
            end if;
        end loop; -- sum

        if state_i(0) = '0' and state_i(sampling_len_g - 1) = '1' then
            weight_v := sampling_len_c + sampling_len_c - weight_v;
        end if;

        state_o <= std_logic_vector(weight_v);

    end process; -- encoder

end state_coder_arch; -- state_coder_arch