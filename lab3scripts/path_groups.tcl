#############################################
# Path Group Settings for CM0
# SolvNet Reference: Other Documents Documents > Synopsys Timing Constraints and Optimization User Guide, version M-2016.12 > Timing Paths
#############################################
set inputs [remove_from_collection [all_inputs] ${rm_clock_ports}]

group_path -name Inputs -from $inputs
group_path -name Outputs -to [all_outputs]
group_path -name Feedthrough  -from $inputs -to [all_outputs]

# paths between regs / memories
set all_regs [all_registers]

# Differentiate between regs filtering in Synopsys DC and Cadence Innovus
# both commants produce the same set of registers
if {$rm_task == "synthesis"} { 
  set regs [remove_from_collection [all_registers] [get_cells -filter "is_sequential==true && clock_gating_integrated_cell =~ *latch* && is_memory_cell != true" -hier]]
} else {
  set regs [filter_collection [all_registers] "is_integrated_clock_gating_cell != true && is_memory_cell != true"]
}

set memories [filter_collection $all_regs "is_memory_cell == true"]

# path groups
group_path -name FromRegs -from $regs
group_path -name ToRegs   -to   $regs

group_path -name FromMems -from $memories
group_path -name ToMems   -to   $memories

###########################################################
# Set path group options for Innovus
###########################################################
if {($rm_task != "sta") && ($rm_task != "ptpx") && ($rm_task != "synthesis")} {
  setPathGroupOptions FromRegs -effortLevel high
  setPathGroupOptions ToRegs -effortLevel high
  setPathGroupOptions FromMems -effortLevel high
  setPathGroupOptions ToMems -effortLevel high

}
