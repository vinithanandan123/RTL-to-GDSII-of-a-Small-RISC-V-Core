read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_liberty ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_db backend/results/repair_test/reset_repaired.odb

set db [ord::get_db]
set block [[$db getChip] getBlock]
set inst [$block findInst fanout463]

puts "===== RESET BUFFER OUTPUT ====="
foreach iterm [$inst getITerms] {
    set pin [$iterm getMTerm]
    if {[$pin getName] == "X"} {
        set net [$iterm getNet]
        puts "Output net: [$net getName]"
        puts "Connected instance pins: [llength [$net getITerms]]"
        puts "Connected block pins: [llength [$net getBTerms]]"

        set counts [dict create]
        foreach pin_iterm [$net getITerms] {
            set cell [[$pin_iterm getInst] getMaster]
            set name [$cell getName]
            dict incr counts $name
        }

        puts "===== CONNECTED CELL TYPES ====="
        foreach name [lsort [dict keys $counts]] {
            puts "$name : [dict get $counts $name]"
        }
    }
}
exit
