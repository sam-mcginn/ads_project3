library ieee;
use ieee.std_logic_1164.all;

library work;
use work.oisc_pkg.all;
--use work.control_generic_pkg.all

package project4_pkg is
	-- Gray to binary converter
	component gray_to_bin is
		generic (
			input_width: 	positive := 4
		);
		port (
			gray_in: 		in std_logic_vector(input_width-1 downto 0);
			bin_out: 		out std_logic_vector(input_width-1 downto 0)
		);
	end component gray_to_bin;
	
	-- Binary to gray converter
	component bin_to_gray is
		generic (
			input_width: 	positive := 4
		);
		port (
			bin_in:			in std_logic_vector(input_width-1 downto 0);
			gray_out:		out std_logic_vector(input_width-1 downto 0)
		);
	end component bin_to_gray;
		
	-- Buffer RAM; side A = producer/head side, B = consumer/tail side
	component true_dual_port_ram_dual_clock is
		generic 
		(
			DATA_WIDTH : natural := 8; -- how many bits you need for each address 
			ADDR_WIDTH : natural := 6 -- how many widths you need for addresses, if head goes from 0 to 15 then you have a 4 bit address
		);
		port 
		(
			clk_a	: in std_logic;
			clk_b	: in std_logic;
			addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1; --head pointer
			addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1; -- tail pointer 
			data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			we_a	: in std_logic := '1';
			we_b	: in std_logic := '1';
			q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
			q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);
	end component true_dual_port_ram_dual_clock;


	-- ADC Module
	component max10_adc is
		port (
			pll_clk:		in	std_logic;								-- pll_clk:	clock input (10 MHz)
			chsel:		in	natural range 0 to 2**5 - 1;		-- chsel:	channel select
			soc:			in	std_logic;								-- soc:		start of conversion
			tsen:			in	std_logic;								-- Mode, 0=normal, 1=temp-sensing
			dout:			out natural range 0 to 2**12 - 1;	-- dout:	data output
			eoc:			out std_logic;								-- eoc: end of conversion
			clk_dft:		out std_logic								-- clk_dft: clock output from clock divider
		);
	end component max10_adc;

end package project4_pkg;