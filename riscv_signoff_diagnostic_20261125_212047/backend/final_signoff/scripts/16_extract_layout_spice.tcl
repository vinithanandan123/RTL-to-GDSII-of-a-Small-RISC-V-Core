puts "===== SKY130A LVS LAYOUT EXTRACTION ====="

source $::env(PDKPATH)/libs.tech/magic/sky130A.magicrc

puts "===== READ FINAL GDS ====="
gds readonly true
gds rescale false
gds read $::env(FINAL_GDS)

puts "===== LOAD RISC-V TOP CELL ====="
load riscv_core

puts "===== EXTRACT LAYOUT ====="
extract all

puts "===== ENABLE LVS SPICE MODE ====="
ext2spice lvs

puts "===== WRITE LAYOUT SPICE ====="
ext2spice -o $::env(LVS_DIR)/riscv_core_layout.spice

puts "===== LAYOUT EXTRACTION FINISHED ====="
quit -noprompt
