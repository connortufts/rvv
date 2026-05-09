#####################################################################################
# Placement optimization of the ${rm_core_top}. 
#####################################################################################

set rm_task     place_opt
date

setMultiCpuUsage -localCpu 4 -cpuAutoAdjust false -verbose

set start_time [clock seconds]

# -----------------------------------------------------------------------------------
# Setup the Configuration
# -----------------------------------------------------------------------------------
source -verbose ../scripts/core_config.tcl

# -----------------------------------------------------------------------------------
# Setup the Target Technology
# -----------------------------------------------------------------------------------
source -verbose ../scripts/tech.tcl

setLibraryUnit -cap 1pf \
               -time 1ns

# -----------------------------------------------------------------------------------
# Restore the Design from the Floorplanning Step
# -----------------------------------------------------------------------------------
restoreDesign ${rm_core_top}.design_planning.enc.dat ${rm_core_top}

# -----------------------------------------------------------------------------------
# Load Innovus settings
# -----------------------------------------------------------------------------------
# Read parameter settings
source -verbose ../scripts/floorplan_params.tcl

# Read Innovus settings
source -verbose ../scripts/invs_settings.tcl

# Read in path groups
source -verbose ../scripts/path_groups.tcl

# Constrain Legal Routing Layers
setDesignMode -flowEffort extreme -idealHoldFixing true -earlyClockFlow true -congEffort high

setDesignMode -process 16

setViaGenMode -parameterized_via_only true

#Min-Vt & OD Jog Settings##
setPlaceMode -place_detail_use_no_diffusion_one_site_filler true
setPlaceMode -place_detail_no_filler_without_implant true

# OD.S.17 
setPlaceMode -place_detail_check_diffusion_forbidden_spacing true


# -----------------------------------------------------------------------------------
# Connect Power nets
# -----------------------------------------------------------------------------------

globalNetConnect VSS -type pgpin -pin {VSS*} -all -override
globalNetConnect VDD -type pgpin -pin {VDD*} -all -override
globalNetConnect VSS -type pgpin -pin {VBB*} -all -override
globalNetConnect VDD -type pgpin -pin {VPP*} -all -override

# -----------------------------------------------------------------------------------
# PLACEMENT
# -----------------------------------------------------------------------------------

place_opt_design -out_dir ../reports/layout/ -prefix place
place_opt_design -incremental -out_dir ../reports/layout/ -prefix place
refinePlace -preserveRouting true

# -----------------------------------------------------------------------------------
# Generate Timing Reports
# -----------------------------------------------------------------------------------
timeDesign -preCTS -outDir ../reports/layout/

# -----------------------------------------------------------------------------------
# Save the Design
# -----------------------------------------------------------------------------------
saveDesign ${rm_core_top}.place_opt.enc

# -----------------------------------------------------------------------------------
# Report on the Design
# -----------------------------------------------------------------------------------
report_timing -max_paths 200 \
                                   > ../reports/layout/${rm_core_top}-placeopt.timing
report_constraint -all_violators        > ../reports/layout/${rm_core_top}-placeopt.constraint
report_area -out_file                ../reports/layout/${rm_core_top}-placeopt.area
report_design                      > ../reports/layout/${rm_core_top}-placeopt.design
reportFanoutViolation -max         -outfile ../reports/layout/${rm_core_top}-placeopt.fanout
reportCongestion -hotSpot -includeBlockage -overflow \
                                   > ../reports/layout/${rm_core_top}-placeopt.congestion
# Report case analysis in the design
report_case_analysis -all -nosplit \
                                > ../reports/layout/${rm_core_top}-placeopt.set_case

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
