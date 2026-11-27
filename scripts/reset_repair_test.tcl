read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef

read_liberty ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db backend/results/05_routing/riscv_global_route.odb
read_sdc backend/inputs/sdc/riscv_core.sdc

source ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl

puts "===== RUN DESIGN REPAIR ====="
repair_design -verbose

puts "===== SAVE TEST DATABASE ====="
write_db backend/results/repair_test/reset_repaired.odb

puts "===== REPAIR TEST COMPLETE ====="
exit
