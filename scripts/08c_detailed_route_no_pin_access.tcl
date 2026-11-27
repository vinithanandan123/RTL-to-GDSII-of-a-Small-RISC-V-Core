# ==========================================================
# DETAILED ROUTING - RESET BUFFER REPAIRED RISC-V CORE
# SKY130 HD | OpenROAD 26Q4
# ==========================================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set db "$root/backend/results/06_repaired_route/riscv_reset_repaired_global_route.odb"
set guide "$root/backend/results/06_repaired_route/riscv_reset_repaired.guide"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"

set out "$root/backend/results/06_repaired_route"
set reports "$root/backend/reports/06_repaired_route"

file mkdir $out
file mkdir $reports

puts "========== LOAD SKY130 LEFS =========="
read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"

puts "========== LOAD SKY130 LIBERTY =========="
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

puts "========== LOAD REPAIRED GLOBAL ROUTE DB =========="
read_db $db

puts "========== LOAD SDC =========="
read_sdc $sdc

puts "========== LOAD RC CONFIGURATION =========="
source "$platform/setRC.tcl"

set_propagated_clock [all_clocks]

puts "========== LOAD REPAIRED GLOBAL ROUTE GUIDES =========="
read_guides $guide

puts "========== START DETAILED ROUTING: ITERATION 1 =========="

detailed_route \
    -output_drc "$reports/reset_repaired_noPA_drc.rpt" \
    -output_maze "$reports/reset_repaired_noPA_maze.log" \
    -output_guide_coverage "$reports/reset_repaired_noPA_guide_coverage.log" \
    -no_pin_access -droute_end_iter 1 \
    -verbose 1

puts "========== CHECK ROUTING COMPLETENESS =========="

design_is_routed -verbose

puts "========== SAVE DATABASE =========="

write_db "$out/riscv_reset_repaired_noPA_iter1.odb"
write_def "$out/riscv_reset_repaired_noPA_iter1.def"

puts "========== DETAILED ROUTING ITERATION 1 FINISHED =========="
