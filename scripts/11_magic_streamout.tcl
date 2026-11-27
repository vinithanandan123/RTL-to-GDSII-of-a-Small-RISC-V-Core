crashbackups stop

puts "===== 1. READ SKY130 STANDARD CELL GDS ====="
gds readonly true
gds rescale false
gds read $::env(STD_GDS)

puts "===== 2. READ SKY130 STANDARD CELL LEF ====="
lef read $::env(STD_LEF)

puts "===== 3. IMPORT GLOBAL ROUTE DEF ====="
def read $::env(DEF_FILE)

puts "===== 4. SELECT RISC-V TOP CELL ====="
load riscv_core
select top cell

puts "===== 5. WRITE PRELIMINARY GDS ====="
gds write $::env(OUT_DIR)/riscv_core_global_route.gds

puts "===== STREAM-OUT SCRIPT FINISHED ====="
quit -noprompt
