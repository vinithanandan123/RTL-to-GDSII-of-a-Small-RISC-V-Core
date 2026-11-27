# ============================================================
# GLOBAL ROUTING - RESET BUFFER REPAIRED DATABASE
# ============================================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set input_db "$root/backend/results/06_repaired_route/riscv_reset_repaired.odb"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"
set liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set out "$root/backend/results/06_repaired_route"
set reports "$root/backend/reports/06_repaired_route"

file mkdir $out
file mkdir $reports

foreach f [list $input_db $sdc $liberty "$platform/setRC.tcl"] {
    if {![file exists $f]} {
        error "Required input missing: $f"
    }
}

puts "========== LOADING RESET-REPAIRED DATABASE =========="

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty $liberty
read_db $input_db
read_sdc $sdc

source "$platform/setRC.tcl"

set_propagated_clock [all_clocks]
estimate_parasitics -placement

puts "========== SETTING ROUTING LAYERS =========="

set_routing_layers -signal met1-met5 -clock met3-met5

puts "========== STARTING GLOBAL ROUTING =========="

global_route \
    -congestion_iterations 30 \
    -verbose \
    -guide_file "$out/riscv_reset_repaired.guide"

puts "========== GLOBAL ROUTING PARASITICS =========="

estimate_parasitics -global_routing

puts "========== SAVING DATABASE =========="

write_db "$out/riscv_reset_repaired_global_route.odb"
write_def "$out/riscv_reset_repaired_global_route.def"

puts "========== GLOBAL ROUTING COMPLETED =========="
