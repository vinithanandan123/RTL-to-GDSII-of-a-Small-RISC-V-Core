set root     [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"
set in_db    $::env(PDN_DB)
set out_dir  "$root/backend/results/10_clean_rerun"
file mkdir $out_dir

read_lef     "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef     "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db      $in_db
read_sdc     "$root/backend/inputs/sdc/riscv_core.sdc"
source       "$platform/setRC.tcl"

# 1. Clean single tracks
set block [ord::get_db_block]
foreach tg [$block getTrackGrids] {
    odb::dbTrackGrid_destroy $tg
}
source "$platform/make_tracks.tcl"

# 2. Prevent Sky130 LVS-incompatible probe cells
set_dont_use {sky130_fd_sc_hd__probec_p_8 sky130_fd_sc_hd__probe_p_8}

# 3. Routability-driven global placement to eliminate local met1 hotspots
set_placement_padding -global -left 2 -right 2
global_placement -routability_driven -density 0.50 -pad_left 2 -pad_right 2
detailed_placement
check_placement -verbose

# 4. Pre-CTS repair & Clock Tree Synthesis
set_wire_rc -signal -layer met2
set_wire_rc -clock  -layer met5
estimate_parasitics -placement
repair_design
detailed_placement

clock_tree_synthesis \
    -root_buf sky130_fd_sc_hd__clkbuf_16 \
    -buf_list "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_16" \
    -sink_clustering_enable
repair_clock_nets
detailed_placement
check_placement -verbose

# 5. Fix DRT-0305 on zero_ net before detailed routing
foreach net [$block getNets] {
    set name  [$net getName]
    set stype [$net getSigType]
    if {($stype eq "GROUND" || $stype eq "POWER") && $name ne "VDD" && $name ne "VSS"} {
        set has_driver 0
        foreach it [$net getITerms] {
            if {[[$it getMTerm] getIoType] eq "OUTPUT"} {
                set has_driver 1
            }
        }
        if {$has_driver} {
            $net setSigType "SIGNAL"
        } else {
            $net setSpecial
        }
    }
}

# 6. Global & Detailed Routing (hard cap at 6 iterations; stops immediately at 0)
set_routing_layers -signal met1-met5 -clock met3-met5
set_global_routing_layer_adjustment met1 0.85
set_global_routing_layer_adjustment met2 0.30
set_global_routing_layer_adjustment met3-met5 0.20

global_route -congestion_iterations 50 -allow_congestion -verbose
write_db "$out_dir/riscv_pre_droute.odb"

detailed_route \
    -output_drc "$out_dir/riscv_clean_0drc.drc" \
    -droute_end_iter 6 \
    -verbose 1

write_db  "$out_dir/riscv_clean_0drc.odb"
write_def "$out_dir/riscv_clean_0drc.def"
puts "=== CLEAN RE-PLACEMENT TO ROUTE COMPLETED ==="
