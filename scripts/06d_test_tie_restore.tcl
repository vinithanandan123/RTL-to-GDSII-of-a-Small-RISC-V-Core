set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

puts "===== LOAD TECHNOLOGY LEF ====="
read_lef "$platform/lef/sky130_fd_sc_hd.tlef"

puts "===== LOAD STANDARD CELL LEF ====="
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"

puts "===== LOAD LIBERTY ====="
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

puts "===== LOAD TIMING-REPAIRED DATABASE ====="
read_db "$root/backend/results/04_cts_repair/riscv_cts_repaired.odb"

puts "===== INSERT TIE-LOW CELLS ====="
insert_tiecells sky130_fd_sc_hd__conb_1/LO

puts "===== REPAIR TIE-LOW FANOUT ====="
repair_tie_fanout sky130_fd_sc_hd__conb_1/LO -verbose

puts "===== LEGALIZE PLACEMENT ====="
detailed_placement
check_placement -verbose

puts "===== COUNT TIE CELLS ====="
set block [ord::get_db_block]
set count 0

foreach inst [$block getInsts] {
    set master [$inst getMaster]
    if {[$master getName] == "sky130_fd_sc_hd__conb_1"} {
        incr count
        puts "FOUND: [$inst getName]"
    }
}

puts "TOTAL CONB CELLS: $count"

write_db "$root/backend/results/04_cts_repair/riscv_tie_test.odb"
write_def "$root/backend/results/04_cts_repair/riscv_tie_test.def"

puts "===== TEST FINISHED ====="
exit
