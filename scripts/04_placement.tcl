# ==========================================
# RISC-V CORE - SKY130 HD PLACEMENT
# ==========================================

set root $::env(PROJECT_ROOT)
set platform $::env(PLATFORM)

set liberty "$platform/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set input_db "$root/backend/results/02_pdn/riscv_pdn.odb"
set output_dir "$root/backend/results/03_placement"

file mkdir $output_dir

puts "=========================================="
puts "RISC-V GLOBAL AND DETAILED PLACEMENT"
puts "=========================================="

# 1. Load timing library and PDN database
read_liberty $liberty
read_db $input_db

# 2. Load timing constraints
read_sdc "$root/backend/inputs/sdc/riscv_core.sdc"

# 3. Global placement
puts "Starting global placement..."
global_placement -density 0.60

# 4. Detailed placement
puts "Starting detailed placement..."
detailed_placement

# 5. Check placement legality
puts "Checking placement..."
check_placement -verbose

# 6. Save results
write_db "$output_dir/riscv_placed.odb"
write_def "$output_dir/riscv_placed.def"

puts "=========================================="
puts "PLACEMENT STAGE COMPLETED"
puts "=========================================="
