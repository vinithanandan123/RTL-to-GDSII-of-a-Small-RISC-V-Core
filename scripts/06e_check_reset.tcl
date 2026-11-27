set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_db backend/results/04_cts_repair/riscv_cts_repaired.odb

puts "========== RESET NET PHYSICAL CONNECTIONS =========="
report_net rst_n

puts "========== RESET NET TIMING =========="
report_checks -to rst_n -path_delay max -format full_clock_expanded
