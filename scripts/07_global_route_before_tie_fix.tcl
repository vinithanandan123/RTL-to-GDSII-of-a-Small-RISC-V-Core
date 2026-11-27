
# ============================================================
# RISC-V CORE - SKY130 HD
# Stage 07: Global Routing
# OpenROAD 26Q4
# ============================================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set input_db "$root/backend/results/04_cts_repair/riscv_cts_repaired.odb"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"
set liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set out "$root/backend/results/05_routing"
file mkdir $out

foreach f [list $input_db $sdc $liberty "$platform/setRC.tcl"] {
    if {![file exists $f]} {
        error "Required input missing: $f"
    }
}

puts "========== LOADING REPAIRED DESIGN =========="

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
    -guide_file "$out/riscv_global_route.guide"

puts "========== GLOBAL ROUTING PARASITICS =========="

estimate_parasitics -global_routing

puts "========== SAVING GLOBAL ROUTING DATABASE =========="

write_db "$out/riscv_global_route.odb"
write_def "$out/riscv_global_route.def"

puts "========== GLOBAL ROUTING COMPLETED =========="
