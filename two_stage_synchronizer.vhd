library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_stage_synchronizer is
	port (
	clocka:		in std_logic;
	clockb:		in std_logic;
	input_signal: in std_logic;
	output_signal: out std_logic
	);
end entity two_stage_synchronizer;
	
architecture sync of two_stage_synchronizer is
signal flopa_output: std_logic;
signal internal_signal: std_logic;

begin

	flopa: process (clocka) is
		begin
			if rising_edge(clocka) then
				flopa_output <= input_signal;
			end if;
	end process flopa;

	flopsb: process (clockb) is
		begin
			if rising_edge(clockb) then
				internal_signal <= flopa_output;
				output_signal <= internal_signal;
			end if;
	end process flopsb;
end architecture sync;