# setPinConstraint -pin * -depth 0.04 -width 0.04

set all_ports [get_ports *]
set all_ports_names [get_object_name [get_ports $all_ports]]

set m5_ports [concat $all_ports_names] 

set pin_llx [expr $macro_llx + 50]
set pin_urx [expr $macro_urx - 50]

setPinAssignMode -pinEditInBatch true

editPin -pin $m5_ports \
        -snap TRACK \
        -use SIGNAL \
        -spreadType RANGE \
        -spreadDirection clockwise \
        -start [list $pin_llx $macro_ury] -end [list $pin_urx $macro_ury] \
        -layer M5 \
        -side BOTTOM \
        -fixOverlap 1

setPinConstraint -cell ${rm_core_top} -pin * -layer {M2 M3 M5 M7 M9}
