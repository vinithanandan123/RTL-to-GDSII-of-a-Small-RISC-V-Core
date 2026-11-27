
# ============================================================
# RISC-V CORE - SKY130 HD
# Stage 06: Post-CTS Timing Repair
# Tool: OpenROAD 26Q4
# Input: Preserved original CTS database
# ============================================================

set project_root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set input_db "$project_root/backend/results/04_cts_repair/riscv_cts_before_repair.odb"
set sdc_file "$project_root/backend/inputs/sdc/riscv_core.sdc"
set liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set rc_file "$platform/setRC.tcl"

set output_dir "$project_root/backend/results/04_cts_repair"
set report_dir "$project_root/backend/reports/04_cts_repair"

file mkdir $output_dir
file mkdir $report_dir

puts "=============================================="
puts "POST-CTS TIMING REPAIR"
puts "=============================================="

# Check input files
foreach file [list $input_db $sdc_file $liberty $rc_file] {
    if {![file exists $file]} {
        error "Required file not found: $file"
    }
}

# Read library and original CTS database
read_liberty $liberty
read_db $input_db

# Read timing constraints and RC configuration
read_sdc $sdc_file
source $rc_file

# Propagated clock and initial parasitics
set_propagated_clock [all_clocks]
estimate_parasitics -placement

puts "========== INITIAL SETUP TIMING =========="
report_checks -path_delay max -format full_clock_expanded

puts "========== INITIAL HOLD TIMING =========="
report_checks -path_delay min -format full_clock_expanded

# ------------------------------------------------------------
# STEP 2: SETUP REPAIR
# ------------------------------------------------------------

puts "========== STARTING SETUP REPAIR =========="

repair_timing -setup
estimate_parasitics -placement

puts "========== SETUP AFTER REPAIR =========="
report_checks -path_delay max -format full_clock_expanded

# ------------------------------------------------------------
# STEP 3: HOLD REPAIR
# ------------------------------------------------------------

puts "========== STARTING HOLD REPAIR =========="

repair_timing -hold
estimate_parasitics -placement

# ------------------------------------------------------------
# STEP 4: DETAILED PLACEMENT / LEGALIZATION
# ------------------------------------------------------------

puts "=============================================="
puts "STARTING POST-REPAIR DETAILED PLACEMENT"
puts "=============================================="

detailed_placement

# Re-estimate parasitics after cell movement
estimate_parasitics -placement

# ------------------------------------------------------------
# STEP 5: PLACEMENT LEGALITY CHECK
# ------------------------------------------------------------

puts "=============================================="
puts "CHECKING PLACEMENT LEGALITY"
puts "=============================================="

set placement_status [catch {
    check_placement -verbose
} placement_error]

# ------------------------------------------------------------
# STEP 6: FINAL TIMING REPORTS
# ------------------------------------------------------------

puts "========== FINAL SETUP TIMING =========="
report_checks -path_delay max -format full_clock_expanded

puts "========== FINAL HOLD TIMING =========="
report_checks -path_delay min -format full_clock_expanded

# ------------------------------------------------------------
# STEP 7: SAVE DATABASE AND DEF
# Save even if placement check fails, for diagnosis.
# ------------------------------------------------------------

write_db "$output_dir/riscv_cts_repaired.odb"
write_def "$output_dir/riscv_cts_repaired.def"

puts "=============================================="

if {$placement_status != 0} {
    puts "PLACEMENT CHECK FAILED:"
    puts $placement_error
    puts "Diagnostic database and DEF have been saved."
    error "Timing repair saved, but placement legality is NOT confirmed."
}

puts "TIMING REPAIR AND PLACEMENT CHECK COMPLETED"
puts "=============================================="

