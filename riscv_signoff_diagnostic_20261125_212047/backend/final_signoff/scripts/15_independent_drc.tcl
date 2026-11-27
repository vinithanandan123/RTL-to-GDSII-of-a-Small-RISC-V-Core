puts "===== SKY130A INDEPENDENT DRC ====="

puts "===== LOAD SKY130A TECHNOLOGY ====="
source $::env(PDKPATH)/libs.tech/magic/sky130A.magicrc

puts "===== READ FINAL GDS ====="
gds readonly true
gds rescale false
gds read $::env(FINAL_GDS)

puts "===== LOAD RISC-V TOP CELL ====="
load riscv_core

puts "===== RUN SKY130A DRC CHECK ====="
drc check

puts "===== DRC COUNT ====="
drc count

puts "===== DRC VIOLATION DETAILS ====="
drc listall

puts "===== DRC CHECK FINISHED ====="
quit -noprompt
