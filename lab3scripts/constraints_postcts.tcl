#############################################
# Clock Constraints 
#############################################
set_propagated_clock [get_clocks CLK]
reset_clock_uncertainty -from [all_clocks] -to [all_clocks]

set_clock_uncertainty -setup [expr ${rm_post_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks CLK]
set_clock_uncertainty -hold [expr  ${rm_hold_margin}] [get_clocks CLK]

set_clock_uncertainty -setup [expr ${rm_post_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks VCLK]
set_clock_uncertainty -hold [expr ${rm_hold_margin}] [get_clocks VCLK]

