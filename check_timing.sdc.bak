# Synopsys Design Constraint file - ensures design meets timing constraints
# FIX - fill in template

# main 50 MHz clock
create_clock -period ??? [ get_ports ??? ]
create_clock -period ??? -name main_clock_virt

# ADC 10MHz clock
create_clock -period ??? [ get_ports ??? ]
create_clock -period ??? -name adc_clock_virt

# ADC derived clock
create_generate_clock -name clk_div -source [ get_pins ??? ] \
	-divide_by ??? -multiply_by ??? [ get_pins ???? ]