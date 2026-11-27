read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef

read_liberty ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db backend/results/05_routing/riscv_global_route.odb
read_sdc backend/inputs/sdc/riscv_core.sdc

source ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl

set_propagated_clock [all_clocks]

read_guides backend/results/05_routing/riscv_global_route.guide

puts "===== LIMITED DETAILED ROUTING DIAGNOSTIC ====="

detailed_route \
    -output_drc backend/reports/diagnostic/route_drc.rpt \
    -output_maze backend/reports/diagnostic/route_maze.log \
    -output_guide_coverage backend/reports/diagnostic/guide_coverage.log \
    -droute_end_iter 1 \
    -verbose 1

puts "===== DIAGNOSTIC ROUTING FINISHED ====="
