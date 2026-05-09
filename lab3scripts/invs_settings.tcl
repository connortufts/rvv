#####################################################################
# Foundry Reference Flow Innovus Settings
# Please get the reference flow settings directly from the foundry
#####################################################################

# source -verbose ../scripts/<foundry_innovus_settings>.tcl

#####################################################################
# Router Kit Innovus Settings
#####################################################################
# source -verbose $rm_invs_router_rules

#####################################################################
# User Innovus Settings
#####################################################################
setDesignMode -process 16 \
              -flowEffort standard \
              -powerEffort low

setAnalysisMode -analysisType onChipVariation \
                -aocv false \
                -cppr both \
                -usefulSkew true
                
setDelayCalMode -equivalent_waveform_model_propagation true \
                -equivalent_waveform_model_type none \
                -SIAware true
# Zirui changed eq_wavefore from ecsm to none.
               
setOptMode -allEndPoints true \
           -fixFanoutLoad true \
           -fixHoldOnExcludedClockNets true \
           -fixSISlew true \
           -holdFixingCells $rm_logic_delay_cell \
           -honorFence true \
           -maxDensity 0.75 \
           -postRouteAreaReclaim holdAndSetupAware \
           -timeDesignNumPaths 200 \
           -usefulSkew true \
           -usefulSkewCCOpt extreme \
           -usefulSkewPostRoute true \
           -usefulSkewPreCTS true \
           -verbose true

setPlaceMode -place_detail_preroute_as_obs {} \
             -place_detail_check_cut_spacing true \
             -place_detail_color_aware_legal true \
             -place_detail_use_check_drc true \
             -place_global_clock_power_driven true \
             -place_global_fast_cts false \
             -place_global_place_io_pins true \
             -place_global_cong_effort high \
             -place_global_max_density 0.75

setUsefulSkewMode -maxAllowedDelay 0.3 \
                  -useCells $rm_clock_delay_cell

setSIMode -enable_logical_correlation true \
          -enable_glitch_propagation true \
          -enable_double_clocking_check true \
          -individual_attacker_simulation_filtering true

set_global timing_aocv_analysis_mode combine_launch_capture
set timing_aocv_use_cell_depth_for_net false
set_global timing_derate_aocv_dynamic_delays true
set_global timing_enable_si_cppr true
set_global timing_disable_library_data_to_data_checks false
set_global timing_disable_library_tiehi_tielo false
set timing_disable_lib_pulsewidth_checks false

set_global timing_set_clock_source_to_output_as_data true
