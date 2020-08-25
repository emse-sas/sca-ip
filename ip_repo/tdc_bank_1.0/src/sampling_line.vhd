-------------------------------------------------------
--! @author Sami Dahoux (s.dahoux@emse.fr)
--! @file sampling_line.vhd
--! @brief Serial assembly of sampling blocks
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sampling_line is
  generic (
    len_g : positive
  ) ;
  port (
    clock_i : in std_logic;
    delta_i : in std_logic;
    delta_o : out std_logic;
    data_o : out std_logic_vector(4 * len_g - 1 downto 0)
  );
  attribute dont_touch : string;
  attribute dont_touch of sampling_line: entity is "true";
end sampling_line;

architecture sampling_line_arch of sampling_line is

    signal delta_s : std_logic_vector(len_g downto 0);
    attribute dont_touch of delta_s: signal is "true";

    component sampling_block
        port (
          clock_i : in std_logic;
          delta_i : in std_logic;
          delta_o : out std_logic;
          data_o : out std_logic_vector(3 downto 0)
        ) ;
    end component;
begin
    delta_s(0) <= delta_i;
    delta_o <= delta_s(len_g);
    delay_line : for n in 0 to len_g - 1 generate
        block_n : sampling_block
        port map (
            clock_i => clock_i,
            delta_i => delta_s(n),
            delta_o => delta_s(n + 1),
            data_o => data_o(4 * n + 3 downto 4 * n)
        );
    end generate ; -- blocks

end sampling_line_arch ; -- sampling_line_arch