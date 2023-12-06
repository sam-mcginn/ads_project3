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
		reset: 				in std_logic
		
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
	
	signal full_flag: std_logic := '0';
	signal new_data_flag: std_logic := '0';
	
begin
	-- PRODUCER domain:
	-- Set next state based on current state, tail value, adc_done and sys. reset
	-- FIX - add reset?
	prod_transition_function: process(prod_state,  curr_tail, adc_done) is
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
	
	
	-- CONSUMER domain:
	-- Set next state based on current state
	con_transition_function: process(consumer_clk, reset) is
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

end architecture fsm_arch;