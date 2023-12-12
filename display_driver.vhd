library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.control_generic_pkg.all;

entity display_driver is
	generic (
		data_width:			natural := 12
	);
	port (
		clock: in std_logic;
		data_in: in std_logic_vector(data_width-1 downto 0);
		digits: out seven_segment_output_type(2 downto 0)
--		digit_one: out seven_segment_config;
--		digit_two: out seven_segment_config;
--		digit_three: out seven_segment_config;
--		digit_four: out seven_segment_config;
--		digit_five: out seven_segment_config;
--		digit_six: out seven_segment_config
	);
end entity display_driver;

architecture arch of display_driver is
	type hex_digit_array_type is array(2 downto 0) of hex_digit;
	signal hex_array: hex_digit_array_type;
	
	function vector_to_hex_array (
			vect_in: in std_logic_vector(11 downto 0)
		) return hex_digit_array_type
	is
		variable ret: hex_digit_array_type;
		variable slice: std_logic_vector(3 downto 0);
	begin
		for i in ret'range loop
			slice := vect_in(4*i + 3 downto 4*i);
			ret(i) := to_integer(unsigned(slice));
		end loop;
		return ret;
	end function vector_to_hex_array;
	
	function get_digit_output(
			vect_in: in std_logic_vector(11 downto 0)
		) return seven_segment_output_type
	is
		variable tmp: hex_digit_array_type;
		variable ret: seven_segment_output_type(digits'range);
	begin
		tmp := vector_to_hex_array(vect_in);
		for i in tmp'range loop
			ret(i) := get_hex_digit(tmp(i));
		end loop;
		return ret;
	end function get_digit_output;
	
begin

	digits <= get_digit_output(data_in);
--
--	data_dec <= unsigned(data_in);
--	--digit_two <= lamps_off();
--	--digit_one <= get_hex_digit(12);
--	
--	
--	
--	drive_display: process(clock) is
--	begin
--		if rising_edge(clock) then
--			digit_six <= lamps_off(common_anode);
--			digit_five <= hex_array(2);
--			digit_four <= hex_array(1);
--			digit_three <= hex_array(0);
--			digit_two <= lamps_off(common_anode);
--			digit_one <= get_hex_digit(12);
--		end if;
--	end process drive_display;
--	
--	split_dec: process(data_in) is
--	begin
--		hex_array <= vector_to_hex_array(data_in);
--	end process split_dec;
end architecture arch;