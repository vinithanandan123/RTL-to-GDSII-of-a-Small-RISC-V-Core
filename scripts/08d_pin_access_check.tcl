set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set db "$root/backend/results/06_repaired_route/riscv_reset_repaired_global_route.odb"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"
set lib "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty $lib
read_db $db
read_sdc $sdc

source "$platform/setRC.tcl"
set_propagated_clock [all_clocks]
set_routing_layers -signal met1-met5 -clock met3-met5

puts "========== RUNNING PIN ACCESS CHECK =========="
pin_access -verbose 2
puts "========== PIN ACCESS CHECK FINISHED =========="
