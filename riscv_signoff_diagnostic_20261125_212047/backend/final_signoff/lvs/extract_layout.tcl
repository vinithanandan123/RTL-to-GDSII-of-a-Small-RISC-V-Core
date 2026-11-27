gds readonly true
gds rescale false

gds read $env(GDS_FILE)

load riscv_core

extract all
ext2spice lvs
ext2spice -o $env(LAYOUT_SPICE)

quit -noprompt
