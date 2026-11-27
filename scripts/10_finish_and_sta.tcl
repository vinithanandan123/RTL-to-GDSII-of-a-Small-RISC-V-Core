set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set in_db "/home/vinith/vlsi_projects/riscv_frontend/backend/results/10_clean_rerun/riscv_clean_0drc.odb"
set out_dir "$root/backend/results/08_final_gds"
file mkdir $out_dir

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db $in_db
read_sdc "$root/backend/inputs/sdc/riscv_core.sdc"
source "$platform/setRC.tcl"

# 1. Insert filler cells to close empty standard-cell row gaps
filler_placement {sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8}
check_placement -verbose

# 2. Extract parasitics (SPEF) and run post-route STA
set rcx_rules "$platform/rcx_patterns.rules"
if {[file exists $rcx_rules]} {
    define_process_corner -ext_model_index 0 X
    extract_parasitics -ext_model_file $rcx_rules
    write_spef "$out_dir/riscv_final.spef"
    read_spef "$out_dir/riscv_final.spef"
} else {
    puts "WARNING: rcx_patterns.rules not found; estimating parasitics from global routing."
    estimate_parasitics -global_routing
}

puts "=== POST-ROUTE TIMING SUMMARY ==="
report_wns
report_tns
report_checks -path_delay max -fields {slew cap input_pins nets fanout} -digits 3
report_checks -path_delay min -digits 3

# 3. Export final post-route database, DEF, and netlist
write_db      "$out_dir/riscv_final.odb"
write_def     "$out_dir/riscv_final.def"
write_verilog "$out_dir/riscv_final.v"

puts "=== FINISH AND STA COMPLETED ==="
