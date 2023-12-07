library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.oisc_pkg.all;

entity oisc is
	generic (
		ucode_rom:	ucode_rom_type
	);
	port (
		clock:				in std_logic;
		reset:				in std_logic;
		external_ctl_1:	in	std_logic;
		external_ctl_2:	in	std_logic;

		driver_1:			out std_logic;
		driver_2:			out std_logic;
		driver_3:			out std_logic
		
	);
end entity oisc;

architecture fsm of oisc is
	subtype upc_type is natural range ucode_rom'range;
	signal upc: upc_type;
	signal current_uinsn: uinstruct;

	function get_next_upc (
			curr: in upc_type
		) return upc_type
	is
		variable ret: upc_type;
	begin
		if curr < ucode_rom'length - 1 then
			ret := curr + 1;
		else
			ret := 0;
		end if;
		return ret;
	end function get_next_upc;
	
begin

	current_uinsn <= ucode_rom(upc);
	driver_1 <= current_uinsn.ctrl1;
	driver_2 <= current_uinsn.ctrl2;
	driver_3 <= current_uinsn.ctrl3;
	
	sequencer: process(clock, reset) is
	begin
		if reset = '0' then
			upc <= 0;
		elsif rising_edge(clock) then
			if current_uinsn.flag1 = '1' then
				-- can only advance upc if external control signal 1 is set
				if external_ctl_1 = '1' then
					upc <= get_next_upc(upc);
				end if;
			elsif current_uinsn.flag2 = '1' then
				-- can only advance upc if external control signal 2 is set
				if external_ctl_2 = '1' then
					upc <= get_next_upc(upc);
				end if;
			else
				-- advance regardless
				upc <= get_next_upc(upc);
			end if;
		end if;
	end process sequencer;
end architecture fsm;