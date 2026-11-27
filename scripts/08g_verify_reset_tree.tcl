# ============================================================
# RESET TREE VERIFICATION - OpenROAD / Sky130 HD
# ============================================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set db "$root/backend/results/06_repaired_route/riscv_reset_repaired_global_route.odb"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"
set lib "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# Load technology and design
read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty $lib
read_db $db
read_sdc $sdc
source "$platform/setRC.tcl"

# Database objects
set block [ord::get_db_block]

# Counters and visited tracking
array set visited_nets {}
array set visited_cells {}
array set reset_sinks {}

set reset_sink_count 0
set branch_cell_count 0
set other_input_count 0
set output_net_count 0

# ============================================================
# Recursive reset-net traversal
# ============================================================

proc trace_reset_net {net depth} {
    global visited_nets visited_cells reset_sinks
    global reset_sink_count branch_cell_count
    global other_input_count output_net_count

    if {$net == "NULL"} {
        return
    }

    set netname [$net getName]

    # Prevent cycles / duplicate traversal
    if {[info exists visited_nets($netname)]} {
        return
    }

    set visited_nets($netname) 1

    set indent [string repeat "  " $depth]

    puts ""
    puts "${indent}===== NET:$netname ====="

    foreach iterm [$net getITerms] {
        set inst [$iterm getInst]
        set instname [$inst getName]
        set master [$inst getMaster]
        set mastername [$master getName]

        set mterm [$iterm getMTerm]
        set pinname [$mterm getName]
        set direction [$iterm getIoType]

        if {$direction eq "INPUT"} {
            if {[regexp -nocase {RESET_B|RESET|RST} $pinname]} {
                set sinkkey "$instname/$pinname"
                if {![info exists reset_sinks($sinkkey)]} {
                    set reset_sinks($sinkkey) 1
                    incr reset_sink_count
                }
            } else {
                incr other_input_count
                puts "${indent}LOAD:$instname/$pinname ($mastername)"

                if {![info exists visited_cells($instname)]} {
                    set visited_cells($instname) 1
                    incr branch_cell_count

                    foreach outterm [$inst getITerms] {
                        if {[$outterm getIoType] eq "OUTPUT"} {
                            set outnet [$outterm getNet]
                            if {$outnet != "NULL"} {
                                set outnetname [$outnet getName]
                                set outmterm [$outterm getMTerm]
                                set outpinname [$outmterm getName]

                                puts "${indent}  BRANCH OUTPUT:$instname/$outpinname ->$outnetname"
                                incr output_net_count

                                trace_reset_net $outnet [expr {$depth + 1}]
                            }
                        }
                    }
                }
            }
        }
    }

    foreach bterm [$net getBTerms] {
        set portname [$bterm getName]
        puts "${indent}TOP-LEVEL PORT:$portname"
    }
}

# ============================================================
# Start from rst_n
# ============================================================

puts ""
puts "============================================================"
puts "RESET DISTRIBUTION TREE VERIFICATION"
puts "============================================================"

set reset_port [$block findBTerm rst_n]

if {$reset_port == "NULL"} {
    puts "ERROR: rst_n top-level port not found"
} else {
    set reset_net [$reset_port getNet]
    if {$reset_net == "NULL"} {
        puts "ERROR: rst_n is not connected to a net"
    } else {
        puts "RESET PORT: rst_n"
        puts "RESET NET: [$reset_net getName]"
        trace_reset_net $reset_net 0
    }
}

# ============================================================
# Cross-check against ALL RESET_B pins in the design
# ============================================================

set total_design_reset_pins 0
set unreached_pins {}

foreach inst [$block getInsts] {
    set instname [$inst getName]
    foreach iterm [$inst getITerms] {
        set mterm [$iterm getMTerm]
        set pinname [$mterm getName]
        if {[regexp -nocase {^RESET_B$}$pinname]} {
            incr total_design_reset_pins
            set key "$instname/$pinname"
            if {![info exists reset_sinks($key)]} {
                lappend unreached_pins $key
            }
        }
    }
}

# ============================================================
# Summary
# ============================================================

puts ""
puts "============================================================"
puts "RESET TREE VERIFICATION SUMMARY"
puts "============================================================"
puts "TOTAL RESET_B PINS IN DESIGN : $total_design_reset_pins"
puts "REACHED RESET SINK PINS      : $reset_sink_count"
puts "UNREACHED RESET_B PINS       : [llength $unreached_pins]"
puts "BRANCH INSTANCES VISITED     : $branch_cell_count"
puts "OTHER INPUT LOADS            : $other_input_count"
puts "OUTPUT NETS TRACED           : $output_net_count"
puts "UNIQUE NETS VISITED          : [array size visited_nets]"

if {[llength $unreached_pins] > 0} {
    puts ""
    puts "FIRST 20 UNREACHED RESET_B PINS:"
    foreach p [lrange $unreached_pins 0 19] {
openroad -exit backend/scripts/08g_verify_reset_tree.tcl | tee backend/logs/06_repaired_route/08g_verify_reset_tree.log | tail -n 35
cd ~/vlsi_projects/riscv_frontend
cp backend/scripts/08g_verify_reset_tree.tcl backend/scripts/08g_verify_reset_tree.tcl.bak

cat << 'EOF' > backend/scripts/08g_verify_reset_tree.tcl
# ============================================================
# RESET TREE VERIFICATION - OpenROAD / Sky130 HD
# ============================================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set db "$root/backend/results/06_repaired_route/riscv_reset_repaired_global_route.odb"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"
set lib "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# Load technology and design
read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty $lib
read_db $db
read_sdc $sdc
source "$platform/setRC.tcl"

# Database objects
set block [ord::get_db_block]

# Counters and visited tracking
array set visited_nets {}
array set visited_cells {}
array set reset_sinks {}

set reset_sink_count 0
set branch_cell_count 0
set other_input_count 0
set output_net_count 0

# ============================================================
# Recursive reset-net traversal
# ============================================================

proc trace_reset_net {net depth} {
    global visited_nets visited_cells reset_sinks
    global reset_sink_count branch_cell_count
    global other_input_count output_net_count

    if {$net == "NULL"} {
        return
    }

    set netname [$net getName]

    # Prevent cycles / duplicate traversal
    if {[info exists visited_nets($netname)]} {
        return
    }

    set visited_nets($netname) 1

    set indent [string repeat "  " $depth]

    puts ""
    puts "${indent}===== NET: $netname ====="

    foreach iterm [$net getITerms] {
        set inst [$iterm getInst]
        set instname [$inst getName]
        set master [$inst getMaster]
        set mastername [$master getName]

        set mterm [$iterm getMTerm]
        set pinname [$mterm getName]
        set direction [$iterm getIoType]

        if {$direction eq "INPUT"} {
            if {[regexp -nocase {RESET_B|RESET|RST} $pinname]} {
                set sinkkey "$instname/$pinname"
                if {![info exists reset_sinks($sinkkey)]} {
                    set reset_sinks($sinkkey) 1
                    incr reset_sink_count
                }
            } else {
                incr other_input_count
                puts "${indent}LOAD: $instname/$pinname ($mastername)"

                if {![info exists visited_cells($instname)]} {
                    set visited_cells($instname) 1
                    incr branch_cell_count

                    foreach outterm [$inst getITerms] {
                        if {[$outterm getIoType] eq "OUTPUT"} {
                            set outnet [$outterm getNet]
                            if {$outnet != "NULL"} {
                                set outnetname [$outnet getName]
                                set outmterm [$outterm getMTerm]
                                set outpinname [$outmterm getName]

                                puts "${indent}  BRANCH OUTPUT: $instname/$outpinname -> $outnetname"
                                incr output_net_count

                                trace_reset_net $outnet [expr {$depth + 1}]
                            }
                        }
                    }
                }
            }
        }
    }

    foreach bterm [$net getBTerms] {
        set portname [$bterm getName]
        puts "${indent}TOP-LEVEL PORT: $portname"
    }
}

# ============================================================
# Start from rst_n
# ============================================================

puts ""
puts "============================================================"
puts "RESET DISTRIBUTION TREE VERIFICATION"
puts "============================================================"

set reset_port [$block findBTerm rst_n]

if {$reset_port == "NULL"} {
    puts "ERROR: rst_n top-level port not found"
} else {
    set reset_net [$reset_port getNet]
    if {$reset_net == "NULL"} {
        puts "ERROR: rst_n is not connected to a net"
    } else {
        puts "RESET PORT: rst_n"
        puts "RESET NET: [$reset_net getName]"
        trace_reset_net $reset_net 0
    }
}

# ============================================================
# Cross-check against ALL RESET_B pins in the design
# ============================================================

set total_design_reset_pins 0
set unreached_pins {}

foreach inst [$block getInsts] {
    set instname [$inst getName]
    foreach iterm [$inst getITerms] {
        set mterm [$iterm getMTerm]
        set pinname [$mterm getName]
        if {[regexp -nocase {^RESET_B$} $pinname]} {
            incr total_design_reset_pins
            set key "$instname/$pinname"
            if {![info exists reset_sinks($key)]} {
                lappend unreached_pins $key
            }
        }
    }
}

# ============================================================
# Summary
# ============================================================

puts ""
puts "============================================================"
puts "RESET TREE VERIFICATION SUMMARY"
puts "============================================================"
puts "TOTAL RESET_B PINS IN DESIGN : $total_design_reset_pins"
puts "REACHED RESET SINK PINS      : $reset_sink_count"
puts "UNREACHED RESET_B PINS       : [llength $unreached_pins]"
puts "BRANCH INSTANCES VISITED     : $branch_cell_count"
puts "OTHER INPUT LOADS            : $other_input_count"
puts "OUTPUT NETS TRACED           : $output_net_count"
puts "UNIQUE NETS VISITED          : [array size visited_nets]"

if {[llength $unreached_pins] > 0} {
    puts ""
    puts "FIRST 20 UNREACHED RESET_B PINS:"
    foreach p [lrange $unreached_pins 0 19] {
        puts "  $p"
    }
}

puts "============================================================"
puts "RESET TREE SCRIPT COMPLETED"
puts "============================================================"
