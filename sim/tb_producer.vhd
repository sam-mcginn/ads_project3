library ieee;
use ieee.std_logic_1164.all;

use work.oisc_pkg.all;

entity tb_producer is
	generic (
		cycles_total: positive := 20
	);
end entity tb_producer;

architecture test of tb_producer is
	constant producer_ucode: ucode_rom_type := (
			(ctrl1 => '1', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '0' ),	-- start conversion
			(ctrl1 => '1', ctrl2 => '0', ctrl3 => '0', flag1 => '1', flag2 => '0' ),	-- wait for conversion
			(ctrl1 => '0', ctrl2 => '0', ctrl3 => '0', flag1 => '0', flag2 => '1' ),	-- can advance head
			(ctrl1 => '0', ctrl2 => '1', ctrl3 => '1', flag1 => '0', flag2 => '0' )		-- store data and advance
		);

	signal reset: std_logic := '0';
	signal clock: std_logic := '0';
	signal test_done: boolean := false;

	signal eoc, can_advance: std_logic := '0';
	signal start_conversion, advance_head, write_enable: std_Logic;
begin
	clock <= not clock after 2 ps when not test_done else '0';

	dut: oisc
		generic map (
			ucode_rom => producer_ucode
		)
		port map (
			clock =>	clock,
			reset =>	reset,
			external_ctl_1 => eoc,			-- flag1
			external_ctl_2 => can_advance,		-- flag2
			driver_1 =>	start_conversion,	-- ctrl1
			driver_2 =>	advance_head,		-- ctrl2
			driver_3 =>	write_enable		-- ctrl3
		);
	
	-- simulate ADC behavior
	eoc_driver: process(start_conversion) is
	begin
		if start_conversion = '1' then
			eoc <= '1' after 15 ps;
		else
			eoc <= '0' after 2 ps;
		end if;
	end process eoc_driver;

	-- simulate head check
	can_advance_driver: process is
	begin
		wait until rising_edge(clock);
		wait until rising_edge(clock);
		can_advance <= not can_advance;
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
