###################################################################
# Placement parameters for macro
###################################################################

proc createPowerStripe { direction layer nets offset width spacing pitch } {
    global macro_llx macro_lly macro_urx macro_ury USE_START_STOP
    set Die [dbget top.fplan.box -e]

    if { [lindex $nets 1] > 1 } {
        set spacing [lrepeat [expr [lindex $nets 1] - 1] $spacing]
    }
    set nets [lrepeat [lindex $nets 1] [lindex $nets 0]]

    if {$direction eq "H"} {
        set direction "horizontal"
    } else {
        set direction "vertical"
    }

    
    P_VIA_GEN_MODE
    P_PG_GEN_MODE $layer

    if {$USE_START_STOP} {
        if {$direction eq "horizontal"} {
            set start [expr $macro_lly + $offset]
            set stop  $macro_ury
        } else {
            set start [expr $macro_llx + $offset]
            set stop  $macro_urx
        }
        addStripe -area $Die \
                  -direction $direction \
                  -layer $layer \
                  -nets $nets \
                  -start $start \
                  -stop $stop \
                  -width $width \
                  -spacing $spacing \
                  -set_to_set_distance $pitch \
                  -skip_via_on_wire_shape {} \
                  -snap_wire_center_to_grid Grid \
                  -uda "PG_STR"
    } else {
        addStripe -area $Die \
                  -direction $direction \
                  -layer $layer \
                  -nets $nets \
                  -start_offset $offset \
                  -width $width \
                  -spacing $spacing \
                  -set_to_set_distance $pitch \
                  -skip_via_on_wire_shape {} \
                  -snap_wire_center_to_grid Grid \
                  -uda "PG_STR"
    }

}

#-----------------------------------------
# Power Mesh Creation
#
# Strategy: Alternating VDD/VSS at half-pitch offsets
# VDD at start_offset, VSS at start_offset + pitch/2
#
# Layer  Dir  Width   Pitch   Notes
# M10    H    2.700   9.216   Top-level wide stripes
# M9     V    0.450   2.520
# M8     H    0.062   2.304
# M7     V    0.120   2.520
# M6     H    0.040   2.304
# M5     V    0.040   2.520
# M4     H    0.040   2.304
# M3     V    0.038   2.520
#-----------------------------------------

#              Dir  Layer  [Net    #Num]  Offset  Width  Spacing  Pitch
createPowerStripe "H" "M10" [list $VDD 1]  0.000   2.700  0        9.216
createPowerStripe "H" "M10" [list $VSS 1]  4.608   2.700  0        9.216

createPowerStripe "V" "M9"  [list $VDD 1]  0.000   0.450  0        2.520
createPowerStripe "V" "M9"  [list $VSS 1]  1.260   0.450  0        2.520

createPowerStripe "H" "M8"  [list $VDD 1]  0.000   0.062  0        2.304
createPowerStripe "H" "M8"  [list $VSS 1]  1.152   0.062  0        2.304

createPowerStripe "V" "M7"  [list $VDD 1]  0.000   0.120  0        2.520
createPowerStripe "V" "M7"  [list $VSS 1]  1.260   0.120  0        2.520

createPowerStripe "H" "M6"  [list $VDD 1]  0.000   0.040  0        2.304
createPowerStripe "H" "M6"  [list $VSS 1]  1.152   0.040  0        2.304

createPowerStripe "V" "M5"  [list $VDD 1]  0.000   0.040  0        2.520
createPowerStripe "V" "M5"  [list $VSS 1]  1.260   0.040  0        2.520

createPowerStripe "H" "M4"  [list $VDD 1]  0.000   0.040  0        2.304
createPowerStripe "H" "M4"  [list $VSS 1]  1.152   0.040  0        2.304

createPowerStripe "V" "M3"  [list $VDD 1]  0.000   0.038  0        2.520
createPowerStripe "V" "M3"  [list $VSS 1]  1.260   0.038  0        2.520

#-----------------------------------------
# Post VIA Dropping
#-----------------------------------------

P_POST_VIA_DROPPING M4 "BLK" "TS*"

# Drop VIA1 between M1 & M2 PG stripes
P_POST_VIA_DROPPING M1 "PG"


