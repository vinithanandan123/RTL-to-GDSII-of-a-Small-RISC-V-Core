
# ==========================================
# RISC-V SKY130 - OPENSTA 3.1.0
# Pre-layout timing analysis
# ==========================================

set LIB "$env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set NETLIST "synthesis/netlist/riscv_core_sky130.v"
set SDC "constraints/riscv_core.sdc"

puts "\n===== READ SKY130 LIBRARY ====="
read_liberty $LIB

puts "\n===== READ MAPPED NETLIST ====="
read_verilog $NETLIST

puts "\n===== LINK DESIGN ====="
link_design riscv_core

puts "\n===== READ TIMING CONSTRAINTS ====="
read_sdc $SDC

puts "\n===== TIMING UNITS ====="
report_units

puts "\n===== DESIGN CHECK ====="
check_setup -verbose

puts "\n===== SETUP ANALYSIS ====="
report_checks -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap fanout} \
    -digits 3

report_worst_slack -max
report_tns -max

puts "\n===== HOLD ANALYSIS ====="
report_checks -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap fanout} \
    -digits 3

report_worst_slack -min
report_tns -min

puts "\n===== OPENSTA COMPLETED ====="

