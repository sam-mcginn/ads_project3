--- top level entity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.control_generic_pkg.all;
use work.oisc_pkg.all;
use work.project4_pkg.all;

entity ads_project3 is
	generic (
		addr_width: 	natural := 4		-- FIX: VALUE ?
	);
	port (
		base_clock:			in std_logic;
		pll_src:				in std_logic;
		reset: 				in std_logic;
		seven_seg_out: 	out seven_segment_output_type(5 downto 0)
	);
end entity ads_project3;

architecture top_level of ads_project3 is
	constant data_width: natural := 12;
	-- ADC SIGNALS
	signal adc_clock_in: std_logic := '0';		-- PLL clock input (10MHz) FIX: DRIVE FROM PLL
	signal prod_clock: std_logic;					-- Output clock from ADC -> drive rest of producer side
	signal adc_ch_sel: natural;					-- ADC channel select	(5 bit value)
	signal adc_mode: std_logic;					-- ADC mode (temp sense)
	signal adc_data: natural; -- range 0 to 2**12 - 1; 	-- ADC conversion output (12 bit value)
	signal adc_soc: std_logic;						-- ADC start conversion control
	signal adc_eoc: std_logic;						-- ADC end of conversion indicator
	
	-- BUFFER/FSM SIGNALS
	constant max_ptr: natural := (2**(addr_width))-1;
	subtype pointer is natural range 0 to max_ptr;		-- FIX: DOUBLE CHECK?
	signal head_ptr: pointer := 0;									-- FIX: ADD FUNCTION TO INCREMENT HEAD/TAIL
	signal tail_ptr: pointer := 0;
	signal head_ptr_con: pointer;					-- pointer from sync to consumer FSM
	signal can_adv_con: std_logic;				-- indicates if consumer fsm/tail can advance based on head ptr
	signal do_adv_tail: std_logic;				-- value process will use to (not) update tail 
	signal tail_ptr_prod: pointer;				-- pointer from sync to producer FSM
	signal can_adv_prod: std_logic;				-- indicates if consumer fsm/head can advance based on tail ptr
	signal do_adv_head: std_logic;				-- value process will use to (not) update head 
	
	signal increment_head: std_logic;			-- indicates when head ptr. should be advanced
	signal increment_tail: std_logic;			-- indicates when tail ptr. should be advanced
	signal write_enable: std_logic;
	
	-- SYNC SIGNALS
	signal tp_in: std_logic_vector(3 downto 0);
	signal tp_out: std_logic_vector(3 downto 0);
	signal hp_in: std_logic_vector(3 downto 0);
	signal hp_out: std_logic_vector(3 downto 0);
	
	-- FIX: CONVERT ADC DATA OUT (NATURAL) --> BUFFER DATA IN (STD_LOGIC_VECTOR)
	signal buffer_data_in: std_logic_vector((data_width-1) downto 0);
	signal buffer_data_out: std_logic_vector((data_width-1) downto 0);
	
	function get_next_ptr ( curr: in pointer ) return pointer
	is
		variable ret: pointer;
	begin
		if (curr < max_ptr) then
			ret := curr + 1;
		else
			ret := 0;
		end if;
		return ret;
	end function get_next_ptr;
	
begin
	-- seven_seg_out <= (digit_six, digit_five, digit_four, digit_three, digit_two, digit_one);
	-- FIX: Two-stage FIFO synchronizer (between domains), need:
	-- PRODUCER: head_ptr --> head_ptr_con (CONSUMER)
	-- CONSUMER: tail_ptr --> tail_ptr_prod (PRODUCER)
	-- Producer clock: prod_clock (output clock from ADC)
	-- Consumer clock: base_clock (50MHz from board)
	tp_in <= std_logic_vector(to_unsigned(tail_ptr, tp_in'length));
	tail_ptr_prod <= to_integer(unsigned(tp_out));
	hp_in <= std_logic_vector(to_unsigned(head_ptr, hp_in'length));
	head_ptr_con <= to_integer(unsigned(hp_out));
	
	head_ptr_sync: gray_synchronizer
		generic map (
			input_width => 4
		)
		port map (
			clocka	=> prod_clock,	
			clockb	=> base_clock,
			input_signal =>  tp_in,
			output_signal => tp_out
		);
		
	tail_ptr_sync: gray_synchronizer
		generic map (
			input_width => 4
		)
		port map (
			clocka	=> base_clock,	
			clockb	=> prod_clock,
			input_signal =>  hp_in,
			output_signal => hp_out
		);


	-- Buffer RAM; side A = producer/head side, B = consumer/tail side
	buffer_data_in <= std_logic_vector(to_unsigned(adc_data, buffer_data_in'length));
	
	buffer_ram: true_dual_port_ram_dual_clock
		generic map (
			DATA_WIDTH => data_width,		-- how many bits you need for each address 
			ADDR_WIDTH => addr_width 	-- how many widths you need for addresses, if head goes from 0 to 15 then you have a 4 bit address
		)
		port map (
			clk_a		=>	prod_clock,
			clk_b		=> base_clock,
			addr_a 	=> head_ptr, --head pointer
			addr_b 	=> tail_ptr, -- tail pointer 
			data_a	=> buffer_data_in,
			data_b	=> (others => '0'),
			we_a		=> write_enable,
			we_b		=> '0',
			q_a		=> open,
			q_b		=> buffer_data_out
		);
		
	-- PRODUCER SIDE:
	-- ADC
	adc_ch_sel <= 0;				-- FIX - ????
	adc_mode <= '1';
	adc_driver: max10_adc
		port map (
			pll_clk 		=> adc_clock_in,				-- clock input (10 MHz)
			chsel 		=> adc_ch_sel,					-- channel select (5 bit num.)
			soc			=> adc_soc,						-- start of conversion
			tsen 			=> adc_mode,					-- Mode, 0=normal, 1=temp-sensing
			dout			=> adc_data,					-- dout:	data output
			eoc 			=> adc_eoc,						-- end of conversion
			clk_dft 		=> prod_clock					-- clk_dft: clock output from clock divider
		);

	-- Producer side FSM
	producer_fsm: oisc
		generic map (
			ucode_rom => producer_ucode
		)
		port map (
			clock					=> prod_clock,
			reset 				=> reset,
			external_ctl_1 	=> adc_eoc,			-- end of conversion indicator
			external_ctl_2		=> can_adv_prod,	-- can advance indicator

			driver_1				=> adc_soc,			-- drives start conversion signal
			driver_2				=>	do_adv_head,	-- drives advance head/tail signal
			driver_3				=> write_enable	-- drives write enable
		);
		

		
	-- CONSUMER SIDE:
	-- Consumer FSM
	consumer_fsm: oisc
		generic map (
			ucode_rom			=> consumer_ucode
		)
		port map (
			clock					=> base_clock, 
			reset					=> reset,
			external_ctl_1		=> '0',				-- end of conversion indicator
			external_ctl_2		=> can_adv_con,	-- can advance indicator

			driver_1				=> open,				-- drives start conversion signal
			driver_2				=> do_adv_tail,	-- drives advance head/tail signal
			driver_3				=> open				-- drives write enable
		);

	-- PROCESSES, etc.:
	-- Update pointer(s):
	advance_ptrs: process(do_adv_head, do_adv_tail, head_ptr, tail_ptr) is
	begin
		if reset='0' then
			head_ptr <= 0;
			tail_ptr <= 0;
		elsif (do_adv_head = '1') then
			head_ptr <= get_next_ptr(head_ptr);
		elsif (do_adv_tail = '1') then
			tail_ptr <= get_next_ptr(tail_ptr);
		end if;
	end process advance_ptrs;
	
	-- Indicate if FSMs can advance
	-- Consumer side: can advance if head ptr > tail ptr
	set_consumer_advance: process(base_clock) is
	begin
		if rising_edge(base_clock) then
			if tail_ptr < head_ptr_con then
				can_adv_con <= '1';
			else
				can_adv_con <= '0';
			end if;
		end if;
	end process set_consumer_advance;
	-- Producer side: can advance if head ptr != max_ptr
	set_producer_advance: process(prod_clock) is
	begin
		if rising_edge(prod_clock) then
			if head_ptr < max_ptr then
				can_adv_prod <= '1';
			else
				can_adv_prod <= '0';
			end if;
		end if;
	end process set_producer_advance;
	
	-- Update 7 segment displays at 50MHz
	blank_segments: for i in 3 to 5 generate
		seven_seg_out(i) <= lamps_off;
	end generate blank_segments;
	
	show_temp: display_driver
		generic map (
			data_width => data_width
		)
		port map (
			clock => base_clock,
			data_in => buffer_data_out,
			digits => seven_seg_out(2 downto 0)
		);
	
	adc_clk: adc_10MHz
		port map (
			inclk0 => pll_src,
			c0	=> adc_clock_in
		);
	
end architecture top_level;