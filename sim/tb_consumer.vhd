library ieee;
use ieee.std_logic_1164.all;

use work.oisc_pkg.all;

entity tb_consumer is
	generic (
		cycles_total: positive := 20
	);
end entity tb_consumer;

architecture test of tb_consumer is
	constant consumer_ucode: ucode_rom_type := (
			-- wait for new data -> wait for can_advance (ext. ctrl. 2)
			(ctrl1 => '0', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '1' ),
			-- can advance tail -> advance tail (driver 2)
			(ctrl1 => '0', ctrl2 => '1', ctrl3 => '0', flag1 => '0', flag2 => '0' )
		);

	signal reset: std_logic := '0';
	signal clock: std_logic := '0';
	signal test_done: boolean := false;

	signal can_advance: std_logic := '0';
	signal advance_tail: std_logic;
begin
	clock <= not clock after 2 ps when not test_done else '0';

	-- when flag1 is set -> can only advance upc if external control signal 1 is set
	-- when flag2 is set -> can only advance upc if external control signal 2 is set
	-- ^ same for ctrl# -> driver_#
	dut: oisc
		generic map (
			ucode_rom => consumer_ucode
		)
		port map (
			clock =>	clock,
			reset =>	reset,
			external_ctl_1 => '0',			-- flag1
			external_ctl_2 => can_advance,-- flag2
			driver_1 =>	open,					-- ctrl1
			driver_2 =>	advance_tail,		-- ctrl2
			driver_3 =>	open					-- ctrl3
		);
	

	-- simulate ADC behavior
	--eoc_driver: process(start_conversion) is
	--begin
--		if start_conversion = '1' then
--			eoc <= '1' after 15 ps;
--		else
--			eoc <= '0' after 2 ps;
--		end if;
--	end process eoc_driver;

	-- simulate head check
	can_advance_driver: process is
	begin
		wait until rising_edge(clock);
		wait until rising_edge(clock);
		can_advance <= not can_advance after 1 ps;
	end process can_advance_driver;

	stimulus: process is
	begin
		reset <= '0';
		wait until rising_edge(clock);
		reset <= '1';

		for i in 1 to cycles_total loop
			wait until rising_edge(clock);
		end loop;
		test_done <= true;
		wait;
	end process stimulus;

end architecture test;
