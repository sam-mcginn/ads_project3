--- top level entity
library ieee;
use ieee.std_logic_1164.all;
use iee.numeric_std.all

library work;
use control_generic_pkg.all;

entity ads_project3 is
end entity ads_project3;

architecture top_level of ads_project3 is
begin
-- COMPONENTS:
-- ADC (producer domain)

-- ADC control unit (producer domain)

-- Binary to gray code converter (consumer domain)

-- Gray code to binary converter (consumer domain)

-- Two-stage FIFO synchronizer (between domains)


-- PROCESSES, etc.:
-- Drive ADC to sample temperature at 10MHz

-- Use output clock from ADC to drive logic related to this (producer) domain


-- Convert index pointer of clock domain into gray code before transmitting it (?)
-- Update 7 segment displays at 50MHz


end architecture top_level;