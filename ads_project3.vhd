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
		address_width: 	natural := 8		-- FIX: VALUE ?
		data_width:			natural := 8		-- FIX: VALUE ?
	);
	port (
		base_clock:			in std_logic;
		reset: 				in std_logic
	);
end entity ads_project3;

architecture top_level of ads_project3 is
	-- ADC SIGNALS
	signal adc_clock_in: std_logic := '0';		-- PLL clock input (10MHz) FIX: DRIVE FROM PLL
	signal prod_clock: std_logic;					-- Output clock from ADC -> drive rest of producer side
	signal adc_ch_sel: natural;					-- ADC channel select	(5 bit value)
	signal adc_mode: std_logic;					-- ADC mode (temp sense)
	signal adc_data: natural range 0 to 2**12 - 1 	-- ADC conversion output (12 bit value)
	signal adc_soc: std_logic;						-- ADC start conversion control
	signal adc_eoc: std_logic;						-- ADC end of conversion indicator
	
	-- BUFFER/FSM SIGNALS
	type pointer is natural range 0 to 2**(addr_width)-1;		-- FIX: DOUBLE CHECK?
	signal head_ptr: pointer := 0;									-- FIX: ADD FUNCTION TO INCREMENT HEAD/TAIL
	signal tail_ptr: pointer := 0;
	signal head_ptr_gray: pointer;		-- pointer from sync to consumer FSM
	signal tail_ptr_gray: pointer;		-- pointer from sync to producer FSM
	
	
	-- FIX: CONVERT ADC DATA OUT (NATURAL) --> BUFFER DATA IN (STD_LOGIC_VECTOR)
	
begin
	-- Buffer RAM; side A = producer/head side, B = consumer/tail side
	buffer_ram: true_dual_port_ram_dual_clock
		generic map (
			DATA_WIDTH => 12		-- how many bits you need for each address 
			ADDR_WIDTH => addr_width 	-- how many widths you need for addresses, if head goes from 0 to 15 then you have a 4 bit address
		)
		port map (
			clk_a		=>	prod_clock,
			clk_b		=> base_clock,
			addr_a 	=> head_ptr, --head pointer
			addr_b 	=> tail_ptr, -- tail pointer 
			data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0),
			data_b	=> open,
			we_a		: in std_logic := '1',
			we_b		=> open,
			q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0),
			q_b		=> open
		);
		
	-- PRODUCER SIDE:
	-- ADC
	adc_clock_in <= not adc_clock_in after -- FIX - DRIVE FROM PLL (10MHZ)
	adc_ch_sel => 1;				-- FIX - ????
	adc_mode => '1';
	adc_driver: max10_adc
		port (
			pll_clk 		<= adc_clock_in,				-- clock input (10 MHz)
			chsel 		<= adc_ch_sel,					-- channel select (5 bit num.)
			soc			<= adc_soc,						-- start of conversion
			tsen 			<= adc_mode,					-- Mode, 0=normal, 1=temp-sensing
			dout:			<= adc_data,					-- dout:	data output
			eoc 			<= adc_eoc,						-- end of conversion
			clk_dft 		<= prod_clock					-- clk_dft: clock output from clock divider
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