library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package oisc_pkg is
	 type uinstruct is record
		ctrl1: std_logic;
		ctrl2: std_logic;
		ctrl3: std_logic;
		flag1: std_logic;
		flag2: std_logic;
	end record uinstruct;
	
	type ucode_rom_type is array (natural range <>) of uinstruct;

	constant default_consumer_ucode: ucode_rom_type := (
		-- wait for new data -> wait for can_advance (ext. ctrl. 2)
		(ctrl1 => '0', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '1' ),
		-- can advance tail -> advance tail (driver 2)
		(ctrl1 => '0', ctrl2 => '1', ctrl3 => '0', flag1 => '0', flag2 => '0' )
	);
	
	constant consumer_ucode: ucode_rom_type := (
			-- wait for new data -> wait for can_advance (ext. ctrl. 2)
			(ctrl1 => '0', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '1' ),
			-- can advance tail -> advance tail (driver 2)
			(ctrl1 => '0', ctrl2 => '1', ctrl3 => '0', flag1 => '0', flag2 => '0' )
	);
	
	constant default_producer_ucode: ucode_rom_type := (
			(ctrl1 => '1', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '0' ),	-- start conversion
			(ctrl1 => '1', ctrl2 => '0', ctrl3 => '0', flag1 => '1', flag2 => '0' ),	-- wait for conversion
			(ctrl1 => '0', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '1' ),	-- can advance head
			(ctrl1 => '0', ctrl2 => '1', ctrl3 => '1', flag1 => '0', flag2 => '0' )		-- store data and advance
		);
	
	constant producer_ucode: ucode_rom_type := (
			(ctrl1 => '1', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '0' ),	-- start conversion
			(ctrl1 => '1', ctrl2 => '0', ctrl3 => '0', flag1 => '1', flag2 => '0' ),	-- wait for conversion
			(ctrl1 => '0', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '1' ),	-- can advance head
			(ctrl1 => '0', ctrl2 => '1', ctrl3 => '1', flag1 => '0', flag2 => '0' )		-- store data and advance
	);
	
		
	component oisc is
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
	end component oisc;
	
end package oisc_pkg;