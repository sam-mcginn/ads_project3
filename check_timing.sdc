# Synopsys Design Constraint file - ensures design meets timing constraints
# FIX - fill in template

# main 50 MHz clock (main_clock_virt)
create_clock -period ??? [ get_ports ??? ]
create_clock -period ??? -name base_clock

# ADC 10MHz clock (adc_clock_virt)
create_clock -period ??? [ get_ports ??? ]
create_clock -period ??? -name pll_src

# ADC derived clock (clk_div)
create_generate_clock -name prod_clock -source [ get_pins ??? ] \
	-divide_by ??? -multiply_by ??? [ get_pins ???? ]