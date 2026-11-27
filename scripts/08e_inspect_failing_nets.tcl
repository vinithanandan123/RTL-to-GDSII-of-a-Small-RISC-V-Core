set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set db "$root/backend/results/06_repaired_route/riscv_reset_repaired_global_route.odb"

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_db $db

set block [ord::get_db_block]

set failing_insts {
    wire375 fanout383 fanout388 fanout393 fanout390
    wire380 fanout410 wire411 wire414 load_slew415
    load_slew418 max_cap419 fanout420 fanout434
    max_cap430 load_slew422 load_slew432 max_cap412
    load_slew436 load_slew440 wire442 fanout463
    fanout464 fanout465 max_cap441 load_slew449
    load_slew456 load_slew460 load_slew451
}

foreach name $failing_insts {
    puts ""
    puts "================================================"
    puts "INSTANCE: $name"
    puts "================================================"

    set inst [$block findInst $name]

    if {$inst == "NULL"} {
        puts "ERROR: Instance not found"
        continue
    }

    set master [$inst getMaster]
    puts "MASTER: [$master getName]"

    foreach iterm [$inst getITerms] {
        set mterm [$iterm getMTerm]
        set pin_name [$mterm getName]
        set net [$iterm getNet]

        puts ""
        puts "PIN: $name/$pin_name"

        if {$net == "NULL"} {
            puts "CONNECTED NET: NONE"
            continue
        }

        puts "CONNECTED NET: [$net getName]"
        puts "CONNECTED INSTANCE PINS:"

        foreach other [$net getITerms] {
            set other_inst [$other getInst]
            set other_mterm [$other getMTerm]

            puts "  [$other_inst getName]/[$other_mterm getName]"
        }

        puts "CONNECTED TOP-LEVEL PORTS:"

        foreach port [$net getBTerms] {
            puts "  [$port getName]"
        }
    }
}
puts ""
puts "========== CONNECTIVITY INSPECTION COMPLETE =========="
