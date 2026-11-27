set circuit1 [readnet spice $::env(EXT_SPICE)]
set circuit2 [readnet spice $::env(STDCELL_SPICE)]
readnet verilog $::env(PG_VERILOG) $circuit2

lvs "$circuit1 riscv_core" "$circuit2 riscv_core" $::env(LVS_SETUP) $::env(LVS_REPORT)
quit
