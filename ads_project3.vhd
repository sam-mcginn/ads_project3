--- top level entity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.control_generic_pkg.all;
use work.osic_pkg.all;
use work.project4_pkg.all;

entity ads_project3 is
	generic (
		address_width: 	natural := 8
		data_width:			natural := 8
	);
	port (
		base_clock:			in std_logic;
		reset: 				in std_logic
	);
end entity ads_project3;

architecture top_level of ads_project3 is
	signal prod_clock: std_logic;
begin
		
	-- COMPONENTS:
	-- Buffer RAM; side A = producer/head side, B = consumer/tail side
	buffer_ram: true_dual_port_ram_dual_clock
		generic map (
			DATA_WIDTH => data_width,	-- how many bits you need for each address 
			ADDR_WIDTH => addr_width 	-- how many widths you need for addresses, if head goes from 0 to 15 then you have a 4 bit address
		)
		port map (
			clk_a	=>		,
			clk_b	=> base_clock,
			addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1, --head pointer
			addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1, -- tail pointer 
			data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0),
			data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0),
			we_a		: in std_logic := '1',
			we_b		: in std_logic := '1',
			q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0),
			q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);

	-- Producer side FSM
	producer_fsm: oisc
		generic (
			ucode_rom => producer_ucode
		)
		port (
			clock:				in std_logic,
			reset => reset,
			external_ctl_1:	in	std_logic;		-- end of conversion indicator
			external_ctl_2:	in	std_logic;		-- can advance indicator

			driver_1:			out std_logic;		-- drives start conversion signal
			driver_2:			out std_logic;		-- drives advance head/tail signal
			driver_3:			out std_logic		-- drives write enable
		);
		
	-- Binary to gray code converter (consumer domain)
	producer_b2g: bin_to_gray
		generic (
			input_width: 	positive := 4
		)
		port (
			bin_in:			in std_logic_vector(input_width-1 downto 0),
			gray_out:		out std_logic_vector(input_width-1 downto 0)
		);


	-- Gray code to binary converter (consumer domain)
	producer_g2b: gray_to_bin
		generic (
			input_width: 	positive := 4
		)
		port (
			gray_in: 		in std_logic_vector(input_width-1 downto 0),
			bin_out: 		out std_logic_vector(input_width-1 downto 0)
		);
	

	-- CONSUMER SIDE:
	-- Consumer FSM
	consumer_fsm: oisc
		generic (
			ucode_rom:	ucode_rom_type
		);
		port (
			clock:				in std_logic;
			reset:				in std_logic;
			external_ctl_1:	in	std_logic;		-- end of conversion indicator
			external_ctl_2:	in	std_logic;		-- can advance indicator

			driver_1:			out std_logic;		-- drives start conversion signal
			driver_2:			out std_logic;		-- drives advance head/tail signal
			driver_3:			out std_logic		-- drives write enable
		);

	-- Binary to gray code converter (consumer domain)
	consumer_b2g: bin_to_gray
		generic (
			input_width: 	positive := 4
		)
		port (
			bin_in:			in std_logic_vector(input_width-1 downto 0),
			gray_out:		out std_logic_vector(input_width-1 downto 0)
		);


	-- Gray code to binary converter (consumer domain)
	consumer_g2b: gray_to_bin
		generic (
			input_width: 	positive := 4
		)
		port (
			gray_in: 		in std_logic_vector(input_width-1 downto 0),
			bin_out: 		out std_logic_vector(input_width-1 downto 0)
		);
	

	-- Two-stage FIFO synchronizer (between domains)


	-- PROCESSES, etc.:
	-- Drive ADC to sample temperature at 10MHz

	-- Use output clock from ADC to drive logic related to this (producer) domain


	-- Convert index pointer of clock domain into gray code before transmitting it (?)
	-- Update 7 segment displays at 50MHz
end architecture top_level;