set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_db "$root/backend/results/04_cts_repair/riscv_cts_repaired.odb"

puts "===== CHECK TIE CELL IN REPAIRED ODB ====="
set block [ord::get_db_block]
set count 0

foreach inst [$block getInsts] {
    set master [$inst getMaster]
    if {[$master getName] == "sky130_fd_sc_hd__conb_1"} {
        incr count
        puts "FOUND: [$inst getName] at [$inst getLocation]"
    }
}

puts "TOTAL CONB CELLS: $count"
exit
