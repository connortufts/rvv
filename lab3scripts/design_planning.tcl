#####################################################################################
# Setup script for INVS-DP
#####################################################################################

set rm_task     design_planning
date

setMultiCpuUsage -localCpu 4 -cpuAutoAdjust true -verbose

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
# Initialize Design 
# -----------------------------------------------------------------------------------
source -verbose ../scripts/init_invs.tcl

# Read in path groups
source -verbose ../scripts/path_groups.tcl

# Read Innovus settings
source -verbose ../scripts/invs_settings.tcl

# -----------------------------------------------
# Set floorplan parameters
# -----------------------------------------------

source -verbose ../scripts/floorplan_params.tcl


# Create Floorplan

if {$rm_task == "design_planning"} {

floorPlan -s $macro_sizex $macro_sizey 6.48 6.48 6.48 6.48 \
          -noSnapToGrid
}

# -----------------------------------------------------------------------------------
# Create power delivery network
# -----------------------------------------------------------------------------------

source -verbose ../scripts/preroute_std_cells.tcl

source -verbose ../scripts/power_mesh.tcl

# -----------------------------------------------------------------------------------
# Edit Pin Placement
# -----------------------------------------------------------------------------------

source -verbose ../scripts/place_pins.tcl
   

# -----------------------------------------------------------------------------------
# Save design
# -----------------------------------------------------------------------------------
#deleteRouteBlk -all
saveDesign ${rm_core_top}.design_planning.enc

# ----------------------------------------------------------------------------------------------------------------------
# Verify Design
# ----------------------------------------------------------------------------------------------------------------------

checkFPlan

verify_PG_short -no_routing_blkg -no_cell_blkg -report ../reports/layout/${rm_core_top}-dp.pg-short

verify_drc

# -----------------------------------------------------------------------------------
# QOR & design reports
# -----------------------------------------------------------------------------------
report_design                          >  ../reports/layout/${rm_core_top}-dp.summary
report_case_analysis -all -nosplit     >  ../reports/layout/${rm_core_top}-dp.set_case
#report_inactive_arcs -delay_arcs_only  >  ../reports/layout/${rm_core_top}-dp.disable_timing

# -----------------------------------------------------------------------------------
# Floorplan replay scripts
# -----------------------------------------------------------------------------------
# Dump replay files that can be used if floorplan gets modified.
saveFPlan ../reports/layout/${rm_core_top}-dp_dump.fp

#####################################################################################
set stop_time [clock seconds]
set elapsedTime [clock format [expr $stop_time - $start_time] -format %H:%M:%S -gmt true]
puts "=============================================="
puts "         Completed step : $rm_task"
puts "        Elapsed runtime : $rm_task: $elapsedTime"
puts "=============================================="
#####################################################################################

date
exit
