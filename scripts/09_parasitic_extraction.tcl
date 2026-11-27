# ==========================================
# STAGE 09 - PARASITIC EXTRACTION
# ==========================================

set root [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

set db "$root/backend/results/05_routing/riscv_detailed_route.odb"
set sdc "$root/backend/inputs/sdc/riscv_core.sdc"
set lib "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set rc "$platform/setRC.tcl"

set out "$root/backend/results/06_signoff"
file mkdir $out

read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty $lib
read_db $db
read_sdc $sdc

source $rc

# Extract routed parasitics
extract_parasitics

# Save SPEF
write_spef "$out/riscv_core.spef"

puts "=================================="
puts "PARASITIC EXTRACTION COMPLETED"
puts "SPEF: $out/riscv_core.spef"
puts "=================================="
