library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity ro_bank is
    generic (
        count_ro_g     : positive := 8;
        sampling_len_g : positive := 8;
        width_g        : positive := 32
    );
    port (
        clock_i  : in std_logic;
        sel_i    : in std_logic_vector(integer(ceil(log2(real(count_ro_g)))) - 1 downto 0);
        state_o  : out std_logic_vector(width_g - 1 downto 0);
        counts_o : out std_logic_vector(count_ro_g * width_g - 1 downto 0);
        count_o  : out std_logic_vector(width_g - 1 downto 0)
    );
end ro_bank;

architecture ro_bank_arch of ro_bank is

    component ro is
        generic (
            sampling_len_g : positive := 8
        );
        port (
            clock_i : in std_logic;
            state_o : out std_logic_vector(sampling_len_g - 1 downto 0)
        );
    end component;

    component state_coder is
        generic (
            sampling_len_g : positive := 8;
            width_g        : positive := 32
        );
        port (
            state_i : in std_logic_vector(sampling_len_g - 1 downto 0);
            state_o : out std_logic_vector(width_g - 1 downto 0)
        );
    end component;

    signal state_is : std_logic_vector(count_ro_g * sampling_len_g - 1 downto 0);
    signal state_os : std_logic_vector(count_ro_g * width_g - 1 downto 0);
    signal last_state_os : std_logic_vector(count_ro_g * width_g - 1 downto 0) := (others => '0');

begin

    bank : for i in 0 to count_ro_g - 1 generate
        sensors : ro
        generic map(
            sampling_len_g => sampling_len_g
        )
        port map(
            clock_i => clock_i,
            state_o => state_is((i + 1) * sampling_len_g - 1 downto i * sampling_len_g)
        );

        encoders : state_coder
        generic map(
            width_g => width_g
        )
        port map(
            state_i => state_is((i + 1) * sampling_len_g - 1 downto i * sampling_len_g),
            state_o => state_os((i + 1) * width_g - 1 downto i * width_g)
        );
    end generate; -- bank

    state_reg : process (clock_i)
    begin
        if rising_edge(clock_i) then
            last_state_os <= state_os;
        else
            last_state_os <= last_state_os;
        end if;
    end process; -- state_reg

    counts : process (state_os)
        type counts_array_t is array (0 to count_ro_g - 1) of signed(width_g - 1 downto 0);
        variable count_v : counts_array_t;
        variable sum_v : unsigned(31 downto 0);
    begin
        for i in 0 to count_ro_g - 1 loop
            count_v(i) := signed(state_os((i + 1) * width_g - 1 downto i * width_g)) - signed(last_state_os((i + 1) * width_g - 1 downto i * width_g));
            if count_v(i) < 0 then
                count_v(i) := count_v(i) + 2 * sampling_len_g;
            end if;
            counts_o((i + 1) * width_g - 1 downto i * width_g) <= std_logic_vector(unsigned(count_v(i)));
            sum_v := sum_v + unsigned(count_v(i));
        end loop;
        count_o <= std_logic_vector(sum_v);
    end process; -- counts

    state_o <= state_os(width_g * (to_integer(unsigned(sel_i)) + 1) - 1 downto width_g * to_integer(unsigned(sel_i)));

end ro_bank_arch; -- ro_bank_arch