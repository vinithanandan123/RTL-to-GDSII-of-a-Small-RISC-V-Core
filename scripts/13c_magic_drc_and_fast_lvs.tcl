gds read $::env(GDS_FILE)
load riscv_core
select top cell
drc style drc(full)
drc on
drc euclidean on
drc catchup
puts "=== MAGIC DRC TOTAL ==="
drc count total
extract no all
extract do local
extract unique
extract all
ext2spice lvs
ext2spice -o $::env(OUT_SPICE)
puts "=== MAGIC DRC & FAST LVS EXTRACTION COMPLETE ==="
quit -noprompt
