#####################################################################################
# Hold fix optimization of the ${rm_core_top}.
#####################################################################################

set rm_task     fixhold
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
# Restore the Design from the Floorplanning Step
# -----------------------------------------------------------------------------------
restoreDesign ${rm_core_top}.signoff.enc.dat ${rm_core_top} 

# -----------------------------------------------------------------------------------
# Load Innovus settings
# -----------------------------------------------------------------------------------
# Read parameter settings
source -verbose ../scripts/floorplan_params.tcl

# Read Innovus settings
source -verbose ../scripts/invs_settings.tcl

# Remove filler cells

deleteFiller


set endpoints { \

RC_CG_HIER_INST0/RC_CGIC_INST/E \

}

foreach endpoint $endpoints {
    ecoAddRepeater -term $endpoint -cell ${hold_fixing_cells}
}


addFiller -cell {FILL64BWP16P90 FILL32BWP16P90 FILL16BWP16P90 FILL8BWP16P90 FILL4BWP16P90 FILL2BWP16P90 FILL1BWP16P90} -prefix FILLER_
ecoRoute -target
ecoRoute -fix_drc

verify_drc -limit 1000000000

# -----------------------------------------------------------------------------------
# Generate signoff Timing models
# -----------------------------------------------------------------------------------
puts "RUNNING TIMING MODEL extraction..."

# Generate timing models
set_analysis_view -setup [list normBC typical normWC] \
                  -hold [list normBC typical normWC]

set lib_views [list normWC ss0p72vm40c  rc_worst_m40c \
                    typical tt0p8v25c rc_typ_25c \
                    normBC ff0p88v125c rc_best_125c \
]


foreach {view corner rc_corner} $lib_views {
  setExtractRCMode -engine postRoute -effortLevel signoff
  extractRC


  rcOut -spef ../models/parasitic/${rm_core_top}_${rc_corner}.spef.gz -rc_corner ${rc_corner}

  spefIn -rc_corner ${rc_corner} ../models/parasitic/${rm_core_top}_${rc_corner}.spef.gz

  write_sdf -version 3.0 \
            -target_application verilog \
            -precision 4 \
            -condelse \
            -collapse_internal_pins \
            -view $view \
            ../models/sdf/${rm_core_top}_${corner}.sdf

  do_extract_model -pg -view $view \
                   -cell_name ${rm_core_top} \
                   -lib_name ${rm_core_top}_${corner} \
                   ../models/lib/${rm_core_top}_${corner}.lib

}

# -----------------------------------------------------------------------------------
# Generate LEF
# -----------------------------------------------------------------------------------
write_lef_abstract -5.8 -specifyTopLayer M11 \
                   -PGpinLayers {M8} -stripePin \
                   -cutObsMinSpacing \
                   ../models/lef/${rm_core_top}.lef 

# -----------------------------------------------------------------------------------
# Generate GDS
# -----------------------------------------------------------------------------------
# This removes the ":" in the power port names which causes an LVS discrepancy
setStreamOutMode -virtualConnection false -snapToMGrid true
streamOut -mapFile ${rm_gds_layer_map} -stripes 1 ../data/${rm_core_top}.gds2 -mode ALL

# -----------------------------------------------------------------------------------
# Generate Netlist
# -----------------------------------------------------------------------------------
# Save non-pg netlist for GLS
saveNetlist ../models/verilog/${rm_core_top}.v -excludeLeafCell 

# Save pg netlist for LVS
set DECAP_CELL_LIST   [dbGet -e [dbGet head.libCells {[string match DCAP* .name] || [string match DECAP* .name]}].name]
set FILLER_CELL_LIST  [dbGet -e [dbGet head.libCells {[string match FILL* .name]}].name]
saveNetlist ../data/${rm_core_top}.pg.flat.v -flat -excludeLeafCell -includePowerGround -includePhysicalCell "$DECAP_CELL_LIST" -excludeCellInst "$FILLER_CELL_LIST"

# -----------------------------------------------------------------------------------
# Save the design 
# -----------------------------------------------------------------------------------
saveDesign ${rm_core_top}.${rm_task}.enc

# -----------------------------------------------------------------------------------
# Report summary  / Gate Count stats
# -----------------------------------------------------------------------------------
summaryReport -noHtml -outfile ../reports/layout/${rm_core_top}-${rm_task}.summary
timeDesign -signoff -hold -pathReports -slackReports -numPaths 50 -outDir ../reports/layout/ -prefix ${rm_core_top}-${rm_task}
timeDesign -signoff -pathReports -slackReports -numPaths 20 -outDir ../reports/layout/ -prefix ${rm_core_top}-${rm_task}

report_area > ../reports/layout/${rm_core_top}-${rm_task}.area 
report_power > ../reports/layout/${rm_core_top}-${rm_task}.power

# Calculating gate count in terms of NAND2 X1 gate
set dbgSitesPerGate 4  
# Adjust this value if needed for the new technology
reportGateCount -stdCellOnly -outfile ../reports/layout/${rm_core_top}-${rm_task}.gatecount

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
