set root     [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_db  "$root/backend/results/08_final_gds/riscv_final.odb"

write_verilog -include_pwr_gnd "$root/backend/results/09_signoff/riscv_final_pg.v"
puts "=== POWERED VERILOG EXPORTED ==="
