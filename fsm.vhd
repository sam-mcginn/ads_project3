library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.control_generic_pkg.all;

entity fsm is
	generic (
		address_width: 	natural := 8	-- FIX: double check
	);
	port (
		-- PRODUCER domain:
		adc_clk:				in std_logic;
		adc_done:			in std_logic;
		adc_start:			out std_logic;
		write_en:			out std_logic;
		head_ptr_out:		out std_logic_vector(address_width-1 downto 0);
		tail_ptr_in:		in std_logic_vector(address_width-1 downto 0);
	
		-- CONSUMER domain:
		consumer_clk:		in std_logic;
		head_ptr_in:		in std_logic_vector(address_width-1 downto 0);
		tail_ptr_out:		out std_logic_vector(address_width-1 downto 0);
		
		-- BOTH:
		reset: 				in std_logic		-- assuming active low for now
		
	);
end entity fsm;

architecture fsm_arch of fsm is
	type producer_state_type is (idle, full_wait, start_conv, adc_wait, store_val);
	type consumer_state_type is (idle, wait_new, update_tail);
	
	-- addresses as integers (for comparison)
	constant max_address: natural := 2**address_width - 1;
	signal curr_head, curr_tail: natural range 0 to max_address := 0;
	
	signal prod_state, prod_next_state: 	producer_state_type := idle;
	signal con_state, con_next_state: 		consumer_state_type := idle;
	
	signal full_flag: std_logic;
	signal new_data_flag: std_logic;
	
	
begin
	-- Flag conditions:
	full_flag <= '1' when (curr_head = max_address) else '0';
	-- FIX:
	new_data_flag <= '1' when (curr_tail < curr_head) else '0';

	-- PRODUCER domain:
	-- Set next state based on current state, tail value, adc_done and sys. reset
	-- FIX - reset? (add to processes ?)
	prod_transition_function: process(prod_state, full_flag, adc_done) is
	begin
		case prod_state is
			when idle =>				prod_next_state <= full_wait;
			when start_conv => 		prod_next_state <= adc_wait;
			when full_wait =>
				if (full_flag = '1') then
											prod_next_state <= full_wait;
				else
											prod_next_state <= start_conv;
				end if;
			when adc_wait =>
				if (adc_done = '1') then
											prod_next_state <= store_val;
				else
											prod_next_state <= adc_wait;
				end if;
			when store_val =>			prod_next_state <= full_wait;
			when others => 			prod_next_state <= idle;
		end case;
	end process prod_transition_function;
	
	-- Update head pointer before store
	increment_head: process(adc_clk) is
	begin
		if rising_edge(adc_clk) then
			if reset = '0' then
				curr_head <= 0;
			elsif (prod_next_state = store_val) and (full_flag = '0') then
				curr_head <= curr_head + 1;
			end if;
		end if;
		head_ptr_out <= std_logic_vector(to_unsigned(curr_head, address_width));
	end process increment_head;
	
	-- Start ADC conversion
	start_conversion: process(adc_clk) is
	begin
		if rising_edge(adc_clk) then
			if reset = '0' then
				adc_start <= '0';
			elsif prod_state = start_conv then
				adc_start <= '1';
			else 	-- FIX - when to go back to '0' ?
				adc_start <= '0';
			end if;
		end if;
	end process start_conversion;
	
	-- Store value when ADC conversion is done
	store_value: process(adc_clk) is
	begin
		if rising_edge(adc_clk) then
			if reset='0' then
				write_en <= '0';
			elsif prod_state = store_val then
				write_en <= '1';
			else
				write_en <= '0';
			end if;
		end if;
	end process store_value;
	
	-- Update current state
	save_p_state: process(adc_clk) is
	begin
		if rising_edge(adc_clk) then
			if reset = '0' then
				prod_state <= idle;
			else
				prod_state <= prod_next_state;
			end if;
		end if;
	end process save_p_state;
	
	
	-- CONSUMER domain:
	-- Set next state based on current state
	con_transition_function: process(con_state, new_data_flag) is
	begin
		case con_state is
			when idle =>				con_next_state <= wait_new;
			when wait_new =>
				if (new_data_flag = '1') then
											con_next_state <= update_tail;
				else
											con_next_state <= wait_new;
				end if;
			when update_tail =>		con_next_state <= wait_new;
		end case;
	end process con_transition_function;
	
	-- Update tail pointer
	increment_tail: process(consumer_clk) is
	begin
		if rising_edge(consumer_clk) then
			if reset = '0' then
				curr_tail <= 0;
			-- double check this ?
			elsif con_state = update_tail and (curr_tail < max_address) then
				curr_tail <= curr_tail + 1;
			end if;
		end if;
		tail_ptr_out <= std_logic_vector(to_unsigned(curr_tail, address_width));
	end process increment_tail;
	
	
	-- Update current state
	save_c_state: process(consumer_clk) is
	begin
		if rising_edge(consumer_clk) then
			if reset = '0' then
				con_state <= idle;
			else
				con_state <= con_next_state;
			end if;
		end if;
	end process save_c_state;

end architecture fsm_arch;


architecture oisc of fsm is
	type ucode_line is record
		rst: std_logic;
		mem_full: boolean;
		new_data: boolean;
		w_en: std_logic;
		start_conv: std_logic;
		conv_done: std_logic;
	end record;
	
	type ucode_instruct_type is array(natural range<>) of ucode_line;
	-- FIX - w_en, conv_done ??
	constant ucode_instructs: ucode_instruct_type := (
		-- both idle
		(rst => '0', mem_full => false, new_data => false, w_en => '0', start_conv => '0', conv_done => '0')
		-- prod: wait for space, con: update tail
		(rst => '1', mem_full => true, new_data => true, w_en => '0', start_conv => '0', conv_done => '0')
		-- prod: start_conv, con: update tail
		(rst => '1', mem_full => false, new_data => true, w_en => '0', start_conv => '1', conv_done => '0')
		-- prod: start_conv, con: wait
		(rst => '1', mem_full => false, new_data => false, w_en => '0', start_conv => '1', conv_done => '0')
		-- prod: wait for adc, con: update tail
		(rst => '1', mem_full => false, new_data => true, w_en => '0', start_conv => '1', conv_done => '0')
		-- prod: wait for adc, con: wait
		(rst => '1', mem_full => false, new_data => false, w_en => '0', start_conv => '1', conv_done => '0')
		-- prod: store, con: update tail
		(rst => '1', mem_full => false, new_data => true, w_en => '1', start_conv => '0', conv_done => '1')
		-- prod: store, con: wait
		(rst => '1', mem_full => false, new_data => false, w_en => '1', start_conv => '0', conv_done => '1')
	);
	
	constant max_address: natural := 2**address_width - 1;
	signal curr_head, curr_tail: natural range 0 to max_address := 0;
	signal curr_ucode: natural range ucode_instructs'range := 0;
begin

	ucode_sequencer: process(adc_clk, consumer_clk) is
	begin
		if rising_edge(consumer_clk) and rising_edge(adc_clk) then
			-- Check to update both producer and consumer
			if reset = '0' then
				curr_ucode <= 0;
			else
				case curr_ucode is
					-- Both idle -> both waits
					when 0 => 					curr_ucode <= 1
					-- Wait full, update tail -> wait full or start, wait
					when 1 =>
					-- Start, update -> wait adc, wait
					when 2 =>
					-- Start, wait -> wait adc, wait or update
					when 3 =>
					-- Wait adc, update -> wait or store, wait
					when 4 =>
					-- Wait adc, wait -> wait or store, wait or update
					when 5 =>
					-- store, update -> wait full, wait
					when 6 =>
					-- store, wait -> wait full, wait or update
					when 7 =>
		elsif rising_edge(consumer_clk) then
			-- Only update consumer
			if reset = '0' then
					curr_ucode <= 0;
		elsif rising_edge(adc_clk) then
			-- Only update producer
			if reset = '0' then
					curr_ucode <= 0;
		end if;
	end process ucode_sequencer;

end architecture oisc;