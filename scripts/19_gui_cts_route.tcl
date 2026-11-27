set root     [file normalize [file join [file dirname [info script]] ../..]]
set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"

read_lef     "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef     "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
read_db      "$root/backend/results/10_clean_rerun/riscv_clean_0drc.odb"
read_sdc     "$root/backend/inputs/sdc/riscv_core.sdc"
source       "$platform/setRC.tcl"
