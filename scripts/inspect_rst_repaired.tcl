read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_liberty ~/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db backend/results/repair_test/reset_repaired.odb

set db [ord::get_db]
set block [[$db getChip] getBlock]
set net [$block findNet rst_n]

puts "===== RESET NET ====="
puts "Net name: [$net getName]"
puts "Signal type: [$net getSigType]"

set iterms [$net getITerms]
set bterms [$net getBTerms]

puts "Instance terminals: [llength $iterms]"
puts "Block terminals: [llength $bterms]"

puts "===== RESET CONNECTED INSTANCE PINS ====="

set cell_counts [dict create]
set pin_counts [dict create]

foreach iterm $iterms {
    set inst [$iterm getInst]
    set master [$inst getMaster]
    set mterm [$iterm getMTerm]

    set cell [$master getName]
    set inst_name [$inst getName]
    set pin_name [$mterm getName]

    dict incr cell_counts $cell
    dict incr pin_counts $pin_name

    puts "$inst_name  $cell  $pin_name"
}

puts "===== CELL TYPE COUNTS ====="
foreach cell [lsort [dict keys $cell_counts]] {
    puts "$cell : [dict get $cell_counts $cell]"
}

puts "===== PIN NAME COUNTS ====="
foreach pin [lsort [dict keys $pin_counts]] {
    puts "$pin : [dict get $pin_counts $pin]"
}

puts "===== RESET BLOCK TERMINALS ====="
foreach bterm $bterms {
    puts "[$bterm getName]"
}

exit
