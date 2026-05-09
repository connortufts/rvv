###################################################################
# Placement parameters for CM0_SYS
###################################################################
set VDD "VDD"
set VSS "VSS"

proc P_VIA_GEN_MODE {} {
    setViaGenMode -reset
    setViaGenMode -ignore_DRC 0 -allow_via_expansion 0 -extend_out_wire_end 1 \
                  -inherit_wire_status 1 -keep_existing_via 2 -partial_overlap_threshold 1 \
                  -allow_wire_shape_change 0 -keep_fixed_via 1 -optimize_cross_via 1 \
                  -disable_via_merging 1 -use_cce 1 -use_fgc 1
}

proc P_PG_GEN_MODE { layer } {
    set topLayerNum [expr [dbget [dbget head.layers.name $layer -p].num] + 1]
    set topLayer    [dbget [dbget head.layers.num $topLayerNum -p].name -e]

    if {$layer eq "M3"} {
        set botlayer M2
    } else {
        set botlayer $layer
    }

    setAddStripeMode -reset
    setAddStripeMode -use_fgc 1 \
                     -remove_floating_stripe_over_block false \
                     -stacked_via_bottom_layer $botlayer \
                     -stacked_via_top_layer $topLayer \
                     -keep_pitch_after_snap false \
                     -via_using_exact_crossover_size false \
                     -ignore_nondefault_domains true \
                     -skip_via_on_pin {Pad Block Cover Standardcell Physicalpin} \
                     -stapling_nets_style end_to_end \
                     -remove_floating_stapling true \
                     -break_at selected_block
    setAddStripeMode -ignore_DRC 0
}

set USE_START_STOP 0


proc P_POST_VIA_DROPPING { layer object {cellName "TS*"} } {
    set topLayerNum [expr [dbget [dbget head.layers.name $layer -p].num] + 1]
    set topLayer    [dbget [dbget head.layers.num $topLayerNum -p].name -e]

    setViaGenMode -reset
    setViaGenMode -ignore_DRC 0 -allow_via_expansion 0 -extend_out_wire_end 1 \
                  -inherit_wire_status 1 -keep_existing_via 2 -partial_overlap_threshold 1 \
                  -allow_wire_shape_change 0 -keep_fixed_via 1 -optimize_cross_via 1 \
                  -disable_via_merging 1 -use_cce 1 -use_fgc 1

    if {$object eq "PG"} {
        deselectAll
        select_obj [dbGet top.pgNets.sWires.layer.name $topLayer -p2]
        editPowerVia -bottom_layer M1 -top_layer M2 \
                     -selected_wires 1 -exclude_stack_vias 0 \
                     -add_vias 1 -orthogonal_only 0 \
                     -via_using_exact_crossover_size 1 -uda "VIA12_Manual" \
                     -skip_via_on_pin {pad cover} \
                     -skip_via_on_wire_shape {Blockring Corewire Blockwire Iowire Padring Ring Fillwire Noshape}
        deselectAll
    } elseif {$object eq "BLK"} {
        set blkBoxes [dbget [dbget top.insts.cell.name $cellName -p2].boxes -e]
        foreach box $blkBoxes {
            editPowerVia -skip_via_on_pin {Pad Standardcell} \
                         -skip_via_on_wire_shape {Ring Blockring Followpin Corewire Blockwire Iowire Padring Fillwire Noshape} \
                         -bottom_layer $layer \
                         -skip_via_on_wire_status {Fixed Cover Shield} \
                         -add_vias 1 -top_layer $topLayer -area $box
        }
    }
}



add_tracks -honor_pitch 

clearGlobalNets
# Connect global nets (VDD and VSS)
globalNetConnect VSS -type pgpin -pin {VSS*} -all -override
globalNetConnect VDD -type pgpin -pin {VDD*} -all -override

globalNetConnect VSS -type pgpin -pin {VBB} -all -override
globalNetConnect VDD -type pgpin -pin {VPP} -all -override

applyGlobalNets

# Place TAP cells
### Boundary Cell Setting
set boundaryR          "BOUNDARY_LEFTBWP20P90"
set boundaryL          "BOUNDARY_RIGHTBWP20P90"
set boundaryLTC        "BOUNDARY_PCORNERBWP20P90"
set boundaryLBC        "BOUNDARY_NCORNERBWP20P90"
set boundaryT          "BOUNDARY_PROW2BWP20P90 BOUNDARY_PROW3BWP20P90"
set boundaryB          "BOUNDARY_NROW2BWP20P90 BOUNDARY_NROW3BWP20P90"
set boundaryLTE        "FILL3BWP20P90"
set boundaryLBE        "FILL3BWP20P90"

set boundaryTapB       "BOUNDARY_NTAPBWP20P90_VPP_VSS"
set boundaryTapT       "BOUNDARY_PTAPBWP20P90_VPP_VSS"
set boundaryTap        "TAPCELLBWP20P90_VPP_VSS"

### TapCell Setting
set tapCell {{TAPCELLBWP20P90_VPP_VSS rule 50.76}}

setEndCapMode -rightEdge        $boundaryR \
              -leftEdge         $boundaryL \
              -leftTopCorner    $boundaryLTC \
              -leftBottomCorner $boundaryLBC \
              -topEdge          $boundaryT \
              -bottomEdge       $boundaryB \
              -rightTopEdge     $boundaryLTE \
              -rightBottomEdge  $boundaryLBE \
              -fitGap true \
              -boundary_tap true

set_well_tap_mode \
   -rule 50.76 \
   -bottom_tap_cell $boundaryTapB \
   -top_tap_cell    $boundaryTapT \
   -cell            $boundaryTap

addEndCap

set_well_tap_mode -reset
# set_well_tap_mode -insert_cells $tapCell
addWellTap -cell TAPCELLBWP20P90_VPP_VSS -cellInterval 50.76 -prefix tap

# verifyWellTap -report ../reports/layout/reportWellTap.rpt


proc initializeRegionBKG {} {
    variable curRegionBKG
    array unset curRegionBKG

    set Die            [dbget top.fplan.box -e]
    set Core           [dbget top.fplan.coreBox -e]
    set STD            [dbget top.fplan.rows.box -e]
    #set MEM            [dbShape [dbShape [dbget [dbget top.insts.cell.name TS* -p2].boxes] SIZEX 3.0] SIZEX -3.0 -output polygon]
    
    set curRegionBKG(Core)            [dbshape $Die ANDNOT $Core -output rect]
    #set curRegionBKG(MEM)             [dbshape $Die ANDNOT $MEM -output rect]
    set curRegionBKG(STD)             [dbshape $Die ANDNOT [dbShape $STD SIZEY 0.1] -output rect]
}


proc createPowerStripe { region direction layer nets offset width spacing pitch  } {
    variable curRegionBKG

    if { [lindex $nets 1] > 1 } {
        set spacing [lrepeat [expr [lindex $nets 1] - 1] $spacing]
    } 
    set nets      [lrepeat [lindex $nets 1] [lindex $nets 0]]
    set direction [expr {$direction eq "H" ? "horizontal" : "vertical" }]
    set blockage  [expr { [info exists curRegionBKG($region)] ? $curRegionBKG($region) : "" }] 
    set Die       [dbget top.fplan.box -e]
   
    P_VIA_GEN_MODE
    P_PG_GEN_MODE $layer 

    addStripe -area $Die -area_blockage $blockage -direction $direction -layer $layer -nets $nets -start_offset $offset -width $width -spacing $spacing -set_to_set_distance $pitch -skip_via_on_wire_shape {}  -snap_wire_center_to_grid Grid -uda "PG_STR"
}


initializeRegionBKG

createPowerStripe STD "H"  "M2"   [list $VSS   1]  0.096    0.064   0         1.152
createPowerStripe STD "H"  "M1"   [list $VSS   1]  0.116    0.090   0         1.152


createPowerStripe STD "H"  "M2"   [list $VDD   1]  -0.448    0.064   0         1.152
createPowerStripe STD "H"  "M1"   [list $VDD   1]  -0.448    0.090   0         1.152


editPowerVia -add_vias 1 -orthogonal_only 0
# M2 is narrower than M1 (0.064 vs stdcell_hgrid 0.090) per N16 PDK rules.
# Shift start by half the width difference so M2 centers exactly on the M1 rail.
set M1_width    $stdcell_hgrid
set M2_width    0.064
set strap_start [expr {6.435 + ($M1_width - $M2_width) / 2.0}]

setViaGenMode -reset

# Post VIA1 Dropping in M1 & M2 PG
P_POST_VIA_DROPPING M1 "PG"

