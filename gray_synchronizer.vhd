library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--synchronizer including grey/bin conversions
entity gray_synchronizer is
	generic(
	input_width: positive := 4
	);
	port (
	clocka:		in std_logic;
	clockb:		in std_logic;
	
	input_signal: in std_logic_vector (3 downto 0);
	output_signal: out std_logic_vector (3 downto 0)
	);
end entity gray_synchronizer;
	
architecture convert_sync of gray_synchronizer is
signal gray_input: std_logic_vector (3 downto 0);
signal gray_output: std_logic_vector (3 downto 0);


component synchronizer is
	port (
	clocka:		in std_logic;
	clockb:		in std_logic;
	
	input_signal: in std_logic_vector (3 downto 0);
	output_signal: out std_logic_vector (3 downto 0)
	);
end component synchronizer;

component gray_to_bin is
	generic (
		input_width: 	positive := 4
	);
	port (
		gray_in: 		in std_logic_vector(input_width-1 downto 0);
		bin_out: 		out std_logic_vector(input_width-1 downto 0)
	);
end component gray_to_bin;

component bin_to_gray is
	generic (
		input_width: 	positive := 4
	);
	port (
		bin_in: 		in std_logic_vector(input_width-1 downto 0);
		gray_out: 		out std_logic_vector(input_width-1 downto 0)
	);
end component bin_to_gray;

begin
	sync: synchronizer
		port map (
			clocka => clocka,
			clockb => clockb,
			input_signal => gray_input,
			output_signal => gray_output
		);
	
	btg: bin_to_gray
		port map(
			bin_in => input_signal,
			gray_out => gray_input
		);
	
	gtb: gray_to_bin
		port map(
			gray_in => gray_output,
			bin_out => output_signal
		);

end architecture convert_sync;
