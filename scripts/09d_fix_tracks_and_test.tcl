set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set in_db   "$root/backend/results/06_repaired_route/riscv_reset_repaired.odb"
set out_dir "$root/backend/results/07_track_fix_test"
file mkdir $out_dir

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db $in_db
read_sdc "$root/backend/inputs/sdc/riscv_core.sdc"
source "$platform/setRC.tcl"

set block [ord::get_db_block]

puts "=== TRACK GRIDS BEFORE CLEANUP ==="
set old_grids [$block getTrackGrids]
foreach tg $old_grids {
    set lname [[$tg getTechLayer] getName]
    puts "  $lname : X_patterns=[$tg getNumGridPatternsX] Y_patterns=[$tg getNumGridPatternsY]"
}

# Destroy duplicate track grids and recreate official Sky130 HD tracks ONCE
foreach tg $old_grids {
    odb::dbTrackGrid_destroy $tg
}

make_tracks li1  -x_offset 0.23 -x_pitch 0.46 -y_offset 0.17 -y_pitch 0.34
make_tracks met1 -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met2 -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met3 -x_offset 0.34 -x_pitch 0.68 -y_offset 0.34 -y_pitch 0.68
make_tracks met4 -x_offset 0.46 -x_pitch 0.92 -y_offset 0.46 -y_pitch 0.92
make_tracks met5 -x_offset 1.70 -x_pitch 3.40 -y_offset 1.70 -y_pitch 3.40

puts "=== TRACK GRIDS AFTER CLEANUP ==="
foreach tg [$block getTrackGrids] {
    set lname [[$tg getTechLayer] getName]
    puts "  $lname : X_patterns=[$tg getNumGridPatternsX] Y_patterns=[$tg getNumGridPatternsY]"
}

# Legalize repair cells without extra padding
remove_fillers
detailed_placement
check_placement -verbose

# Global route with clean single track grid
set_routing_layers -signal met1-met5 -clock met3-met5
global_route -congestion_iterations 50 -verbose

# Fast 2-iteration detailed-route test to measure new violation count and capture DRC markers
detailed_route \
  -output_drc "$out_dir/test_iter2.drc" \
  -droute_end_iter 2 \
  -verbose 1

write_db  "$out_dir/riscv_track_fixed_test.odb"
write_def "$out_dir/riscv_track_fixed_test.def"

puts "=== TRACK FIX TEST COMPLETED ==="
