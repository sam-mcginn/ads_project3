library ieee;
use ieee.std_logic_1164.all;

-- Package to interface with a seven-segment display digit
package control_generic_pkg is
	-- Configuration for one seven-segnment digit
  type seven_segment_config is record
    a: std_logic;
	 b: std_logic;
	 c: std_logic;
	 d: std_logic;
	 e: std_logic;
	 f: std_logic;
	 g: std_logic;
  end record;

	 -- Set of seven-segment display digits
	type my_array is array (natural range <>) of seven_segment_config; 

	-- Type of seven-segment display (default = common anode)
	type lamp_configuration is (common_anode, common_cathode);
	constant default_lamp_config : lamp_configuration := common_anode;

	-- Constant seven-segment configurations for all 0's or all 1's for each segment
	constant zero: seven_segment_config := (a=>'0', b=>'0', c=>'0', d=>'0', e=>'0', f=>'0', g=>'0');
	constant one: seven_segment_config := (a=>'1', b=>'1', c=>'1', d=>'1', e=>'1', f=>'1', g=>'1');

	-- Holds seven-segment configurations for each hex digit (0-F): seven_segment_table(x) --> config. for hex digit x
	constant seven_segment_table : my_array  := (
		 -- Hexadecimal digit 0
		 (a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '0'),

		 -- Hexadecimal digit 1
		 (a => '0', b => '1', c => '1', d => '0', e => '0', f => '0', g => '0'),

		 -- Hexadecimal digit 2
		 (a => '1', b => '1', c => '0', d => '1', e => '1', f => '0', g => '1'),

		 -- Hexadecimal digit 3
		 (a => '1', b => '1', c => '1', d => '1', e => '0', f => '0', g => '1'),

		 -- Hexadecimal digit 4
		 (a => '0', b => '1', c => '1', d => '0', e => '0', f => '1', g => '1'),

		 -- Hexadecimal digit 5
		 (a => '1', b => '0', c => '1', d => '1', e => '0', f => '1', g => '1'),

		 -- Hexadecimal digit 6
		 (a => '1', b => '0', c => '1', d => '1', e => '1', f => '1', g => '1'),

		 -- Hexadecimal digit 7
		 (a => '1', b => '1', c => '1', d => '0', e => '0', f => '0', g => '0'),

		 -- Hexadecimal digit 8
		 (a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '1'),

		 -- Hexadecimal digit 9
		 (a => '1', b => '1', c => '1', d => '1', e => '0', f => '1', g => '1'),

		 -- Hexadecimal digit A
		 (a => '1', b => '1', c => '1', d => '0', e => '1', f => '1', g => '1'),

		 -- Hexadecimal digit b
		 (a => '0', b => '0', c => '1', d => '1', e => '1', f => '1', g => '1'),

		 -- Hexadecimal digit C
		 (a => '1', b => '0', c => '0', d => '1', e => '1', f => '1', g => '0'),

		 -- Hexadecimal digit d
		 (a => '0', b => '1', c => '1', d => '1', e => '1', f => '0', g => '1'),

		 -- Hexadecimal digit E
		 (a => '1', b => '0', c => '0', d => '1', e => '1', f => '1', g => '1'),

		 -- Hexadecimal digit F
		 (a => '1', b => '0', c => '0', d => '0', e => '1', f => '1', g => '1')
	);
	
	-- Hex digit stored as a natural number (range: 0-15)
	subtype hex_digit is natural range seven_segment_table'range; 

	-- Invert all segments in a configuration
	function "not" (
			digit: in seven_segment_config
		) return seven_segment_config;

	-- Convert hex digit (natural) to seven-segment config.
	function get_hex_digit (
			digit: in hex_digit;
			lamp_mode: in lamp_configuration := default_lamp_config
		) return seven_segment_config; 
		
	-- Get configuration to turn all segments off
	function lamps_off (
	lamp_mode: in lamp_configuration := default_lamp_config
	) return seven_segment_config;

end package control_generic_pkg;


package body control_generic_pkg is
	-- Invert all segments in a configuration
	function "not" (
			digit: in seven_segment_config
		) return seven_segment_config
	is
	begin
		return ( a => not digit.a, b => not digit.b, c => not digit.c, d => not digit.d, e => not digit.e,f => not digit.f,g => not digit.g);
	end function "not";
	
	-- Convert hex digit (natural) to seven-segment config.
	function get_hex_digit (
		digit: in hex_digit;
		lamp_mode: in lamp_configuration := default_lamp_config
		) return seven_segment_config
	is
	begin
		if lamp_mode = common_anode then
			return seven_segment_table(digit);
		end if;
		return not seven_segment_table(digit);
	end get_hex_digit; 

	-- Get configuration to turn all segments off
	function lamps_off (
		lamp_mode: in lamp_configuration := default_lamp_config
		) return seven_segment_config
	is
	begin
		if lamp_mode = common_anode then
			return zero;
		 else
			return one;
		end if;
	end lamps_off;

end package body control_generic_pkg;