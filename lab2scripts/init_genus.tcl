#####################################################################################
# Genus Initialization script for the ${rm_core_top}
#####################################################################################

read_mmmc ../scripts/viewDefinitions.tcl
read_physical -lef $rm_lef_reflib

read_hdl -f ../scripts/rtl_src/macro.vc -language sv
elaborate ${rm_core_top}
#read_vcd -static -vcd_scope tb/myfir ../rtl/FIR_63TAP.vcd

init_design

