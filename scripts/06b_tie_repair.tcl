set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_db "$root/backend/results/04_cts_repair/riscv_cts_repaired.odb"
read_sdc "$root/backend/inputs/sdc/riscv_core.sdc"

source "$platform/setRC.tcl"
set_propagated_clock [all_clocks]

puts "===== REPAIR TIE-LOW FANOUT ====="
repair_tie_fanout sky130_fd_sc_hd__conb_1/LO -verbose

detailed_placement
check_placement -verbose

write_db "$root/backend/results/04_cts_repair/riscv_tie_repaired.odb"
write_def "$root/backend/results/04_cts_repair/riscv_tie_repaired.def"

puts "===== TIE REPAIR COMPLETED ====="
exit
