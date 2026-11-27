# Sky130 preliminary GDS export
# Source: global-route DEF
# Top cell: riscv_core

puts "========== LOAD STANDARD CELL LEF =========="
lef read $::env(PDK)/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef

puts "========== LOAD STANDARD CELL GDS =========="
gds read $::env(PDK)/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds

puts "========== READ GLOBAL ROUTE DEF =========="
def read backend/results/05_routing/riscv_global_route.def

puts "========== LOAD TOP CELL =========="
load riscv_core

puts "========== WRITE PRELIMINARY GDS =========="
gds write backend/results/07_gds/riscv_core_global_route.gds

puts "========== GDS EXPORT SCRIPT FINISHED =========="
quit -noprompt
