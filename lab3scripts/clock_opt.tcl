#####################################################################################
# Clock tree optimization of the ${rm_core_top}.
#####################################################################################

set rm_task     clock_opt
date

setMultiCpuUsage -localCpu 16 -verbose 

set start_time [clock seconds]

# -----------------------------------------------------------------------------------
# Setup the Configuration
# -----------------------------------------------------------------------------------
source -verbose ../scripts/core_config.tcl

# -----------------------------------------------------------------------------------
# Setup the Target Technology
# -----------------------------------------------------------------------------------
source -verbose ../scripts/tech.tcl

# -----------------------------------------------------------------------------------
# Restore the Design from the Floorplanning Step
# -----------------------------------------------------------------------------------
restoreDesign ${rm_core_top}.place_opt.enc.dat ${rm_core_top} 

# -----------------------------------------------------------------------------------
# Load Innovus settings
# -----------------------------------------------------------------------------------
# Read parameter settings
source -verbose ../scripts/floorplan_params.tcl

# Read Innovus settings
source -verbose ../scripts/invs_settings.tcl

# -----------------------------------------------------------------------------------
# Update to post-cts constraints
# -----------------------------------------------------------------------------------
set_interactive_constraint_modes [all_constraint_modes -active]
source -verbose $cts_constraints_sdc

# Read in path groups
source -verbose ../scripts/path_groups.tcl

set_interactive_constraint_modes {}

# -----------------------------------------------------------------------------------
# Read in list of dont_use cells
# -----------------------------------------------------------------------------------
#foreach dont_use ${rm_dont_use_list} {
#  set_dont_use [get_lib_cells */${dont_use}]
#}

# -----------------------------------------------------------------------------------
# Connect Power nets
# -----------------------------------------------------------------------------------
# TODO: Check if PG connections don't need complete purge and re-do
# Connect Ground
globalNetConnect VSS -type pgpin -pin {VSS*} -all -override
globalNetConnect VDD -type pgpin -pin {VDD*} -all -override
globalNetConnect VSS -type pgpin -pin {VBB*} -all -override
globalNetConnect VDD -type pgpin -pin {VPP*} -all -override

setDesignMode -flowEffort standard

# -----------------------------------------------------------------------------------
# Add CTS properties
# -----------------------------------------------------------------------------------
#foreach dont_use ${rm_clock_delay_cell} {
#  set_dont_use [get_lib_cells */${dont_use}] false
#}

set_ccopt_property -update_io_latency true
set_ccopt_property -force_update_io_latency true
set_ccopt_property -enable_all_views_for_io_latency_update true
set_ccopt_property -max_fanout ${rm_cts_max_fanout}
set_ccopt_property -effort high

set_ccopt_mode -cts_buffer_cells $rm_clock_buf_cap_cell \
               -cts_inverter_cells $rm_clock_inv_cap_cell \
               -cts_clock_gating_cells $rm_clock_icg_cell \
               -cts_use_min_max_path_delay false \
               -cts_target_slew $rm_max_clock_transition \
               -cts_target_skew 0 \
               -modify_clock_latency true

create_ccopt_clock_tree_spec -file ../data/${rm_core_top}-ccopt_cts.spec
create_ccopt_clock_tree_spec


clock_opt_design -check_prerequisites
clock_opt_design -outDir ../reports/layout/INNOVUS_RPT -prefix clock_opt

# Report Clocks
report_ccopt_clock_trees -filename ../reports/layout/${rm_core_top}-clockopt_ccopt.clock_trees
report_ccopt_skew_groups -filename ../reports/layout/${rm_core_top}-clockopt_ccopt.skew_groups
report_ccopt_clock_tree_structure -file ../reports/layout/${rm_core_top}-clockopt_ccopt.clock_tree_structure

#------------------------------------------------------------------------------------
# Update Constraints Post-CTS
#------------------------------------------------------------------------------------
set_interactive_constraint_modes [all_constraint_modes -active]
source -verbose $postcts_constraints_sdc

# Read in path groups
source -verbose ../scripts/path_groups.tcl

set_interactive_constraint_modes {}

#------------------------------------------------------------------------------------
# Optimize
#------------------------------------------------------------------------------------
optDesign -postCTS -drv
optDesign -postCTS -incr
optDesign -postCTS -hold
optDesign -postCTS -hold -setup -holdVioData ../reports/layout/${rm_core_top}-clockopt.holdVio

# -----------------------------------------------------------------------------------
# Connect Power nets
# -----------------------------------------------------------------------------------
# TODO: Check if PG connections don't need complete purge and re-do
# Connect Ground
globalNetConnect VSS -type pgpin -pin {VSS*} -all -override
globalNetConnect VDD -type pgpin -pin {VDD*} -all -override
globalNetConnect VSS -type pgpin -pin {VBB*} -all -override
globalNetConnect VDD -type pgpin -pin {VPP*} -all -override

#------------------------------------------------------------------------------------
# Report Timing
#------------------------------------------------------------------------------------
timeDesign -postCTS -outDir ../reports/layout/INNOVUS_RPT
timeDesign -postCTS -hold -outDir ../reports/layout/INNOVUS_RPT

# -----------------------------------------------------------------------------------
# Save the design 
# -----------------------------------------------------------------------------------
saveDesign ${rm_core_top}.clock_opt.enc

# Report Clocks
report_ccopt_clock_trees -filename ../reports/layout/${rm_core_top}-clockopt.clock_trees
report_ccopt_skew_groups -filename ../reports/layout/${rm_core_top}-clockopt.skew_groups
report_ccopt_clock_tree_structure -file ../reports/layout/${rm_core_top}-clockopt.clock_tree_structure

report_constraint -all_violators        > ../reports/layout/${rm_core_top}-clockopt.constraint

# Report inactive arcs for the design 
report_inactive_arcs -delay_arcs_only > ../reports/layout/${rm_core_top}-clockopt.disable_timing

# Check for ignored nets for optimization
reportIgnoredNets                 -outfile ../reports/layout/${rm_core_top}-clockopt.ignored_nets

#####################################################################################
set stop_time [clock seconds]
set elapsedTime [clock format [expr $stop_time - $start_time] -format %H:%M:%S -gmt true]
puts "=============================================="
puts "         Completed step : $rm_task"
puts "        Elapsed runtime : $rm_task: $elapsedTime"
puts "=============================================="
#####################################################################################

date
#exit
