set platform "$::env(HOME)/OpenROAD-flow-scripts/flow/platforms/sky130hd"
read_lef "$platform/lef/sky130_fd_sc_hd.tlef"
read_lef "$platform/lef/sky130_fd_sc_hd_merged.lef"
read_db  $::env(PDN_DB)
write_def $::env(OUT_DEF)
puts "=== FLOORPLAN & PDN DEF EXPORTED ==="
