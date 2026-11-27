puts "============================================"
puts " SKY130 DETAILED ROUTE FINAL GDS STREAMOUT"
puts "============================================"

puts "===== LOAD SKY130 MAGIC TECHNOLOGY ====="
source $::env(PDKPATH)/libs.tech/magic/sky130A.magicrc

puts "===== SET GDS OUTPUT STYLE ====="
cif ostyle gdsii
gds readonly true
gds rescale false

puts "===== READ SKY130 STANDARD CELL GDS ====="
gds read $::env(STD_GDS)

puts "===== READ SKY130 TECHNOLOGY LEF ====="
lef read $::env(TECH_LEF)

puts "===== READ SKY130 STANDARD CELL LEF ====="
lef read $::env(STD_LEF)

puts "===== READ COMPLETED FAST DETAILED ROUTE DEF ====="
def read $::env(DEF_FILE)

puts "===== LOAD RISC-V TOP CELL ====="
load riscv_core

puts "===== SELECT TOP CELL ====="
select top cell

puts "===== WRITE NEW DETAILED ROUTED GDS ====="
gds write $::env(OUT_DIR)/riscv_core_detailed_routed.gds

puts "===== FINAL GDS STREAMOUT COMMAND FINISHED ====="
quit -noprompt
