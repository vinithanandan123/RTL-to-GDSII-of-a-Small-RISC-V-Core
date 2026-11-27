crashbackups stop

puts "===== 1. READ SKY130 STANDARD CELL GDS ====="
gds readonly true
gds rescale false
gds read $::env(STD_GDS)

puts "===== 2. READ SKY130 TECHNOLOGY LEF ====="
lef read $::env(TLEF)

puts "===== 3. READ SKY130 STANDARD CELL LEF ====="
lef read $::env(STD_LEF)

puts "===== 4. READ COMPLETED DETAILED ROUTE DEF ====="
def read $::env(DEF_FILE)

puts "===== 5. SELECT RISC-V TOP CELL ====="
load riscv_core
select top cell

puts "===== 6. WRITE DETAILED ROUTED GDS ====="
gds write $::env(OUT_DIR)/riscv_core_detailed_routed.gds

puts "===== STREAMOUT FINISHED ====="
quit -noprompt
