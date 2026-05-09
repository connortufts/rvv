###################################################################
# Placement parameters for macro
###################################################################
set stdcell_pitch 0.576
set stdcell_hgrid 0.090

set rm_core_offset_x [expr $stdcell_pitch * 8]
set rm_core_offset_y [expr $stdcell_pitch * 8]

# Metal strap parameters
set M5_strap_width 0.82
set M6_strap_width 0.82
set M7_strap_width 2.0
set M8_strap_width 2.0

set M5_strap_spacing 0.3
set M6_strap_spacing 0.3
set M7_strap_spacing 0.6
set M8_strap_spacing 0.6

set M5_strap_pitch 12.0
set M6_strap_pitch 12.0
set M7_strap_pitch 12.0
set M8_strap_pitch 12.0


set macro_halo_spc [expr 12.0 * $stdcell_hgrid]

set macro_origin_x $rm_core_offset_x
set macro_origin_y $rm_core_offset_y


set macro_sizex [expr {1150 * $stdcell_hgrid}]
set macro_sizey [expr {1150 * $stdcell_pitch}]


#*************************
# Placement Settings
#*************************
# Block settings
set macro_llx $macro_origin_x
set macro_lly $macro_origin_y
set macro_urx [expr $macro_llx + $macro_sizex]
set macro_ury [expr $macro_lly + $macro_sizey]
