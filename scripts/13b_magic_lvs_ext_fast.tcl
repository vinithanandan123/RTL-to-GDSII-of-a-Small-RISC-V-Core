gds read $::env(GDS_FILE)
load riscv_core
select top cell
extract no all
extract do local
extract unique
extract all
ext2spice lvs
ext2spice -o $::env(OUT_SPICE)
puts "=== FAST LVS EXTRACTION COMPLETE ==="
quit -noprompt
