
# ==========================================================
# RISC-V CORE - SKY130 HD
# STAGE 08: DETAILED ROUTING
# ==========================================================

puts "========== LOAD SKY130 TECH LEF =========="

read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef

puts "========== LOAD SKY130 STANDARD CELL LEF =========="

read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef

puts "========== LOAD SKY130 LIBERTY =========="

read_liberty ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

puts "========== LOAD GLOBAL ROUTE DATABASE =========="

read_db backend/results/05_routing/riscv_global_route.odb

puts "========== LOAD SDC =========="

read_sdc backend/inputs/sdc/riscv_core.sdc

puts "========== LOAD RC CONFIGURATION =========="

source ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl

puts "========== SET PROPAGATED CLOCK =========="

set_propagated_clock [all_clocks]

puts "========== LOAD GLOBAL ROUTE GUIDES =========="

read_guides backend/results/05_routing/riscv_global_route.guide

puts "========== START DETAILED ROUTING =========="

detailed_route \
    -output_drc backend/reports/riscv_route_drc.rpt \
    -output_maze backend/reports/riscv_route_maze.log \
    -verbose 2

puts "========== CHECK ROUTING COMPLETENESS =========="

design_is_routed -verbose

puts "========== SAVE DETAILED ROUTE DATABASE =========="

write_db backend/results/06_detailed_route/riscv_detailed_route.odb

write_def backend/results/06_detailed_route/riscv_detailed_route.def

puts "========== DETAILED ROUTING SCRIPT FINISHED =========="

