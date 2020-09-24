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
        counts_o : out std_logic_vector(count_ro_g * width_g - 1 downto 0);
        count_o  : out std_logic_vector(width_g - 1 downto 0);
        state_o  : out std_logic_vector(width_g - 1 downto 0)
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

    component ro_coder is
        generic (
            sampling_len_g : positive := 8;
            width_g        : positive := 32
        );
        port (
            state_i : in std_logic_vector(sampling_len_g - 1 downto 0);
            state_o : out std_logic_vector(width_g - 1 downto 0)
        );
    end component;

    component ro_output is
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
    end component;

    signal raw_state_s : std_logic_vector(count_ro_g * sampling_len_g - 1 downto 0);
    signal coded_state_s : std_logic_vector(count_ro_g * width_g - 1 downto 0);
begin

    bank : for i in 0 to count_ro_g - 1 generate
        sensors : ro
        generic map(
            sampling_len_g => sampling_len_g
        )
        port map(
            clock_i => clock_i,
            state_o => raw_state_s((i + 1) * sampling_len_g - 1 downto i * sampling_len_g)
        );

        encoders : ro_coder
        generic map(
            width_g => width_g
        )
        port map(
            state_i => raw_state_s((i + 1) * sampling_len_g - 1 downto i * sampling_len_g),
            state_o => coded_state_s((i + 1) * width_g - 1 downto i * width_g)
        );
    end generate; -- bank

    output : ro_output
    generic map(
        sampling_len_g => sampling_len_g,
        width_g        => width_g,
        count_ro_g     => count_ro_g
    )
    port map(
        clock_i => clock_i,
        state_i => coded_state_s,
        sel_i   => sel_i,
        count_o => count_o,
        counts_o => counts_o,
        state_o => state_o
    );

end ro_bank_arch; -- ro_bank_arch