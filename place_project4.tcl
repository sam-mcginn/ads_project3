# Pin assignments for Project 2

# clock assignment to chip clock
set_location_assignment PIN_P11 -to base_clock
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to base_clock

# clock assignment to ADC/PLL clock
set_location_assignment PIN_N5 -to pll_src
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pll_src

# reset assignment to push button
set_location_assignment PIN_B8 -to reset
set_instance_assignment -name IO_STANDARD "3.3 V Schmitt Trigger" -to reset


# FIX !!!
set seven_seg { \
		{C14 E15 C15 C16 E16 D17 C17} \
		{C18 D18 E18 B16 A17 A18 B17} \
		{B20 A20 B19 A21 B21 C22 B22} \
		{F21 E22 E21 C19 C20 D19 E17} \
		{F18 E20 E19 J18 H19 F19 F20} \
		{J20 K20 L18 N18 M20 N19 N20} \
	}

# 7 segment display assignment	
# iterate through each digit
for { set i 0 } { ${i} < 6 } { incr i } {
	# iterate through each segment of digit
	set j 0
	foreach lamp { a b c d e f g } {
		set pin [ lindex [ lindex ${seven_seg} ${i} ] ${j} ]
		set_location_assignment PIN_${pin} -to seven_seg_out\[${i}\].${lamp}
		incr j
	}
	# for { set j 0 } { ${j} < 6} { incr j } {
	#	switch $j
	#		0 {
	#			set pin [ lindex ${seven_seg_}{i}	# FIX
	#			set_location_assignment PIN_${pin} -to seven_seg_out\[${i}\].a
	#			set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to seven_seg_out\[${i}\].a
	#		}
			
	# Assign red_pins[i] --> pin
	#set pin [ lindex ${red_pins} ${i} ]
	# Assign r_out[i] --> red_pins[i]
	#set_location_assignment PIN_${pin} -to r_out\[${i}\]
	#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r_out\[${i}\]
	#}
}
