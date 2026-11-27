# ==========================================
# RISC-V CORE - SKY130 HD PDN GENERATION
# ==========================================

set root $::env(PROJECT_ROOT)
set platform $::env(PLATFORM)

set input_db "$root/backend/results/01_floorplan/riscv_io.odb"
set output_dir "$root/backend/results/02_pdn"

file mkdir $output_dir

# Physical cell configuration
set ::env(TAP_CELL_NAME) sky130_fd_sc_hd__tapvpwrvgnd_1

puts "=========================================="
puts "RISC-V PDN GENERATION"
puts "=========================================="

# 1. Load IO-placed database
read_db $input_db

# 2. Create routing tracks
source "$platform/make_tracks.tcl"

# 3. Insert tapcells
puts "Inserting Sky130 tapcells..."
source "$platform/tapcell.tcl"

# 4. Configure power connections and PDN
puts "Configuring VDD and VSS..."
source "$platform/pdn.tcl"

# 5. Generate power delivery network
puts "Generating power delivery network..."
pdngen

# 6. Save database and DEF
write_db "$output_dir/riscv_pdn.odb"
write_def "$output_dir/riscv_pdn.def"

puts "=========================================="
puts "PDN GENERATION COMPLETED"
puts "=========================================="

exit
