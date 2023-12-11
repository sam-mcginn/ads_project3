library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.control_generic_pkg.all;

entity display_driver is
	generic (
		data_width: natural := 12
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		data_in: in std_logic_vector(data_width-1 downto 0);
		digit_one: out seven_segment_config;
		digit_two: out seven_segment_config;
		digit_three: out seven_segment_config;
		digit_four: out seven_segment_config;
		digit_five: out seven_segment_config;
		digit_six: out seven_segment_config
	);
end entity display_driver;

architecture arch of display_driver is
	constant dec_width: natural := 4;
	signal data_dec: unsigned;
	type dec_arr is array(dec_width-1 downto 0) of hex_digit;
	signal dec_digits: dec_arr;
begin
	data_dec <= unsigned(data_in);
	digit_two <= lamps_off();
	digit_one <= get_hex_digit(12);
	
	drive_display: process(clock) is
	begin
		if rising_edge(clock) then
			if dec_arr(3) > 0 then
				digit_four <= get_hex_digit(dec_arr(3));
			end if;
			if dec_arr(2) > 0 then
				digit_three <= get_hex_digit(dec_arr(2));
			end if;
			if dec_arr(1) > 0 then
				digit_two <= get_hex_digit(dec_arr(1));
			end if;
			if dec_arr(0) > 0 then
				digit_one <= get_hex_digit(dec_arr(0));
			end if;
		end if;
	end process drive_display;
	
--	split_dec: process(data_in) is
--	begin
--		for i in dec_width downto 0 loop
--			if data_dec >= 10**i then
--				dec_digits(i) <= data_dec*(1/(10**i));
--			else
--				dec_digits(i) <= 0;
--			end if;
--		end loop;
--	end process split_dec;
end architecture arch;