#####################################################################################
# Routing optimization of the ${rm_core_top}.
#####################################################################################

set rm_task     route_opt
date

setMultiCpuUsage -localCpu 16 -cpuAutoAdjust true -verbose

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
restoreDesign ${rm_core_top}.clock_opt.enc.dat ${rm_core_top} 

# -----------------------------------------------------------------------------------
# Load Innovus settings
# -----------------------------------------------------------------------------------
# Read parameter settings
source -verbose ../scripts/floorplan_params.tcl

# Read Innovus settings
source -verbose ../scripts/invs_settings.tcl

#------------------------------------------------------------------------------------
# Update Constraints Post-CTS
#------------------------------------------------------------------------------------
set_interactive_constraint_modes [all_constraint_modes -active]
source -verbose $postcts_constraints_sdc

# Read in path groups
source -verbose ../scripts/path_groups.tcl

set_interactive_constraint_modes {}

## -----------------------------------------------------------------------------------
## Read in list of dont_use cells
## -----------------------------------------------------------------------------------
#foreach dont_use ${rm_dont_use_list} {
#  set_dont_use [get_lib_cells */${dont_use}]
#}

setViaGenMode -parameterized_via_only true

# -----------------------------------------------------------------------------------
# Connect Power nets
# -----------------------------------------------------------------------------------
# TODO: Check if PG connections don't need complete purge and re-do
# Connect Ground
globalNetConnect VSS -type pgpin -pin {VSS*} -all -override
globalNetConnect VDD -type pgpin -pin {VDD*} -all -override
globalNetConnect VSS -type pgpin -pin {VBB*} -all -override
globalNetConnect VDD -type pgpin -pin {VPP*} -all -override

setAttribute -net VDD -skip_routing false
setAttribute -net VDD -avoid_detour true -weight 20 -non_default_rule TrunkNDR -pattern trunk
setNanoRouteMode -routeAllowPowerGroundPin true
setPGPinUseSignalRoute PTBUFF*:TVDD PTINV*:TVDD TAPCELL*:VPP ISO*:VDDS BOUNDARY_*TAP*:VPP
routePGPinUseSignalRoute -maxFanout 1 -nonDefaultRule TrunkNDR

setDesignMode -flowEffort standard
setNanoRouteMode -drouteOnGridOnly {wire 4:7 via 3:6}
setNanoRouteMode -routeWithViaInPin {1:1}
setNanoRouteMode -routeTopRoutingLayer 9
setNanoRouteMode -routeBottomRoutingLayer 2
setNanoRouteMode -droutePostRouteSpreadWire false
setNanoRouteMode -dbViaWeight {*_P* -1}
setNanoRouteMode -routeReserveSpaceForMultiCut false
setNanoRouteMode -routeAutoPinAccessForBlockPin true
setNanoRouteMode -routeConcurrentMinimizeViaCountEffort high
setNanoRouteMode -droutePostRouteSwapVia false

# -----------------------------------------------------------------------------------
# Set TieHiLo Mode
# -----------------------------------------------------------------------------------
setTieHiLoMode -cell $rm_tie_hi_lo_list \
               -maxFanout 1

# -----------------------------------------------------------------------------------
# Add Nano Route properties
# -----------------------------------------------------------------------------------
setExtractRCMode -engine postRoute -effortLevel high 

setNanoRouteMode -routeWithTimingDriven true \
                 -routeWithSiDriven true \
                 -routeWithLithoDriven false \
                 -routeDesignRouteClockNetsFirst true \
                 -drouteUseMultiCutViaEffort low
                #  -routeTopRoutingLayer 6 \
                #  -routeBottomRoutingLayer 2

routeDesign

saveDesign ${rm_core_top}.route_opt_init.enc

#------------------------------------------------------------------------------------
# Optimize
#------------------------------------------------------------------------------------
setExtractRCMode -engine postRoute -effortLevel medium 
#setOptMode -verbose true
#setOptMode -highEffortOptCells $hold_fixing_cells
setOptMode -holdFixingCells $hold_fixing_cells
setOptMode -holdTargetSlack 0.07
optDesign -postRoute -drv
optDesign -postRoute -incr
optDesign -postRoute -setup
optDesign -postRoute -hold
optDesign -postRoute -setup -hold

#------------------------------------------------------------------------------------
# Additonal Hold Optimization using high accuracy
#------------------------------------------------------------------------------------
setExtractRCMode -engine postRoute -effortLevel high 
setOptMode -highEffortOptCells $hold_fixing_cells
setOptMode -holdFixingCells $hold_fixing_cells
setOptMode -verbose true -holdTargetSlack 0.07
optDesign -postRoute -hold

setAnalysisMode -analysisType onChipVariation -cppr both
setDelayCalMode -engine default -SIAware true
setSIMode -enable_glitch_report true
setOptMode -fixGlitch true
optDesign -postRoute -drv

setOptMode -highEffortOptCells $rm_logic_delay_cell
setOptMode -holdFixingCells $rm_logic_delay_cell
setOptMode -verbose true -holdTargetSlack 0.07
optDesign -postRoute -hold

#------------------------------------------------------------------------------------
# Report Timing
#------------------------------------------------------------------------------------
timeDesign -postRoute -outDir ../reports/layout/INNOVUS_RPT
timeDesign -postRoute -hold -outDir ../reports/layout/INNOVUS_RPT

# -----------------------------------------------------------------------------------
# Connect Power nets
# -----------------------------------------------------------------------------------
# TODO: Check if PG connections don't need complete purge and re-do
# Connect Ground
globalNetConnect VSS -type pgpin -pin {VSS*} -all -override
globalNetConnect VDD -type pgpin -pin {VDD*} -all -override

# -----------------------------------------------------------------------------------
# Save the design 
# -----------------------------------------------------------------------------------
saveDesign ${rm_core_top}.route_opt.enc

# -----------------------------------------------------------------------------------
# Verify Routing
# -----------------------------------------------------------------------------------
reportRoute
reportWire
checkRoute

verifyConnectivity -noAntenna
verify_drc
verifyMetalDensity
#verifyProcessAntenna

# -----------------------------------------------------------------------------------
# Additional Reports#
# -----------------------------------------------------------------------------------
report_constraint -all_violators        > ../reports/layout/${rm_core_top}-routeopt.constraint

# Report inactive arcs for the design 
report_inactive_arcs -delay_arcs_only > ../reports/layout/${rm_core_top}-routeopt.disable_timing

# Check for ignored nets for optimization
reportIgnoredNets                 -outfile ../reports/layout/${rm_core_top}-routeopt.ignored_nets

#####################################################################################
set stop_time [clock seconds]
set elapsedTime [clock format [expr $stop_time - $start_time] -format %H:%M:%S -gmt true]
puts "=============================================="
puts "         Completed step : $rm_task"
puts "        Elapsed runtime : $rm_task: $elapsedTime"
puts "=============================================="
####################################################################################

date
exit
