
# ============================================================
# RISC-V CORE - SKY130 HD
# Stage 10: Post-Route Static Timing Analysis
# OpenROAD 26Q4
# ============================================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set input_db "$root/backend/results/06_signoff/riscv_extracted.odb"
set spef "$root/backend/results/06_signoff/riscv_core.spef"
set liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"

set reports "$root/backend/reports/06_signoff"
file mkdir $reports

foreach f [list $input_db $spef $liberty $sdc] {
    if {![file exists $f]} {
        error "Required file missing: $f"
    }
}

puts "========== LOADING EXTRACTED DESIGN =========="

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty $liberty
read_db $input_db
read_sdc $sdc

puts "========== LOADING ROUTED PARASITICS =========="

read_spef $spef

set_propagated_clock [all_clocks]

puts "========== DESIGN AREA =========="
report_design_area

puts "========== POST-ROUTE SETUP TIMING =========="

report_checks -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout}

puts "========== POST-ROUTE HOLD TIMING =========="

report_checks -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout}

puts "========== POST-ROUTE CLOCK SKEW =========="

report_clock_skew -setup
report_clock_skew -hold

puts "========== POST-ROUTE STA COMPLETED =========="

