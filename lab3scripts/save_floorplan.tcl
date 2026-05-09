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


