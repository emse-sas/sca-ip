-------------------------------------------------------
--! @author Sami Dahoux (s.dahoux@emse.fr)
--! @file tdc.vhd
--! @brief FIFO acquisition controller to synchronize acquisition with crypto-algorithm
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

library work;
use work.all;

entity fifo_ctrl is
	generic (
		width_g : positive
	);
	port (
		clock_rd_i : in std_logic;
		clock_wr_i : in std_logic;
		reset_i    : in std_logic;
		read_i     : in std_logic;
		write_i    : in std_logic;
		empty_i    : in std_logic;
		full_i     : in std_logic;
		count_i    : in std_logic_vector(width_g - 1 downto 0);
		write_o    : out std_logic;
		read_o     : out std_logic;
		reset_o    : out std_logic;
		count_o    : out std_logic_vector(width_g - 1 downto 0)
	);
end fifo_ctrl;

architecture fifo_ctrl_arch of fifo_ctrl is

	component fifo_fsm is
		generic (
			width_g : positive
		);
		port (
			clock_i   : in std_logic;
			reset_i   : in std_logic;
			read_i    : in std_logic;
			write_i   : in std_logic;
			empty_i   : in std_logic;
			full_i    : in std_logic;
			target_i  : in std_logic_vector(width_g - 1 downto 0);
			count_i   : in std_logic_vector(width_g - 1 downto 0);
			write_o   : out std_logic;
			read_o    : out std_logic;
			reset_o   : out std_logic;
			en_o      : out std_logic;
			up_o      : out std_logic;
			clk_sel_o : out std_logic
		);
	end component;

	component fifo_counter is
		generic (
			width_g : positive
		);
		port (
			clock_i : in std_logic;
			reset_i : in std_logic;
			up_i    : in std_logic;
			en_i    : in std_logic;
			count_o : out std_logic_vector(width_g - 1 downto 0)
		);
	end component;
	signal count_s : std_logic_vector(width_g - 1 downto 0);
	signal clock_s, read_s, en_s, clk_sel_s, up_s : std_logic;
begin
	clock_s <= clock_wr_i when clk_sel_s = '1' else clock_rd_i;
	count_o <= count_s;
	counter : fifo_counter
	generic map(
		width_g => width_g
	)
	port map(
		clock_i => clock_s,
		reset_i => reset_i,
		up_i    => up_s,
		en_i    => en_s,
		count_o => count_s
	);

	fsm : fifo_fsm
	generic map(
		width_g => width_g
	)
	port map(
		clock_i   => clock_s,
		reset_i   => reset_i,
		read_i    => read_i,
		write_i   => write_i,
		empty_i   => empty_i,
		full_i    => full_i,
		count_i   => count_s,
		target_i  => count_i,
		write_o   => write_o,
		read_o    => read_o,
		reset_o   => reset_o,
		en_o      => en_s,
		up_o      => up_s,
		clk_sel_o => clk_sel_s
	);

end fifo_ctrl_arch; -- fifo_ctrl_arch

configuration fifo_ctrl_conf of fifo_ctrl is
	for fifo_ctrl_arch
		for all : fifo_counter
			use entity work.fifo_counter(fifo_counter_arch);
		end for;

		for all : fifo_fsm
			use entity work.fifo_fsm(fifo_fsm_arch);
		end for;
	end for;
end configuration;