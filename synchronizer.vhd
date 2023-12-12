library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--4 bit synchronizer, no grey/bin conversions
entity synchronizer is
	generic(
	input_width: positive := 4
	);
	port (
	clocka:		in std_logic;
	clockb:		in std_logic;
	
	input_signal: in std_logic_vector (3 downto 0);
	output_signal: out std_logic_vector (3 downto 0)
	);
end entity synchronizer;
	
architecture sync of synchronizer is

signal flopa_output: std_logic;
signal internal_signal: std_logic;

component two_stage_synchronizer is
	port (
	clocka:		in std_logic;
	clockb:		in std_logic;
	input_signal: in std_logic;
	output_signal: out std_logic
	);
end component two_stage_synchronizer;

begin
	syncs: for num in 0 to input_width-1 generate
		sync: two_stage_synchronizer
			port map (
				clocka => clocka,
				clockb => clockb,
				input_signal => input_signal(num),
				output_signal => output_signal(num)
			);
	end generate syncs;
end architecture sync;


	