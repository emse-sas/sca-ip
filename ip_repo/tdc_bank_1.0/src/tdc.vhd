-------------------------------------------------------
--! @author Sami Dahoux (s.dahoux@emse.fr)
--! @file tdc.vhd
--! @brief Top level wrapper
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tdc is
  generic (
    coarse_len_g   : positive;
    fine_len_g     : positive;
    sampling_len_g : positive
  );
  port (
    clock_i        : in std_logic;
    delta_i        : in std_logic;
    coarse_delay_i : in std_logic_vector(1 downto 0);
    fine_delay_i   : in std_logic_vector(3 downto 0);
    delta_o        : out std_logic;
    data_o         : out std_logic_vector(4 * sampling_len_g - 1 downto 0)
  );
  attribute dont_touch : string;
  attribute dont_touch of tdc : entity is "true";
end tdc;

architecture tdc_arch of tdc is

  signal delta_fine_s : std_logic;
  signal delta_coarse_s : std_logic;

  component fine_line
    generic (
      len_g : positive
    );
    port (
      delta_i : in std_logic;
      delta_o : out std_logic;
      clock_o : out std_logic;
      delay_i : in std_logic_vector(3 downto 0)
    );
  end component;

  component coarse_line
    generic (
      len_g : positive
    );
    port (
      delta_i : in std_logic;
      delta_o : out std_logic;
      clock_o : out std_logic;
      delay_i : in std_logic_vector(1 downto 0)
    );
  end component;

  component sampling_line
    generic (
      len_g : positive
    );
    port (
      clock_i : in std_logic;
      delta_i : in std_logic;
      delta_o : out std_logic;
      data_o  : out std_logic_vector(4 * len_g - 1 downto 0)
    );
  end component;

begin

  coarse : coarse_line
  generic map(
    len_g => coarse_len_g
  )
  port map(
    delta_i => delta_i,
    clock_o => delta_coarse_s,
    delay_i => coarse_delay_i
  );

  fine : fine_line
  generic map(
    len_g => fine_len_g
  )
  port map(
    delta_i => delta_coarse_s,
    clock_o => delta_fine_s,
    delay_i => fine_delay_i
  );

  sampling : sampling_line
  generic map(
    len_g => sampling_len_g
  )
  port map(
    clock_i => clock_i,
    delta_i => delta_fine_s,
    delta_o => delta_o,
    data_o  => data_o
  );

end tdc_arch; -- tdc_arch