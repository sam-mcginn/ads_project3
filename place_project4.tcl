# Pin assignments for Project 2

# clock assignment to chip clock
set_location_assignment PIN_P11 -to base_clock
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to base_clock

# reset assignment to push button
set_location_assignment PIN_B8 -to reset
set_instance_assignment -name IO_STANDARD "3.3 V Schmitt Trigger" -to reset


# FIX !!!

# VGA vertical sync assignment
set_location_assignment PIN_N1 -to vert_sync
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to vert_sync

# VGA red assignment
# VGA red pins on board:
set red_pins {AA1 V1 Y2 Y1}	
for { set i 0 } { ${i} < 4 } { incr i } {
	# Assign red_pins[i] --> pin
	set pin [ lindex ${red_pins} ${i} ]
	# Assign r_out[i] --> red_pins[i]
	set_location_assignment PIN_${pin} -to r_out\[${i}\]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r_out\[${i}\]
}