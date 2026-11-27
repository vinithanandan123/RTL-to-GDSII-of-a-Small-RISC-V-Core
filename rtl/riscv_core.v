
module riscv_core (
    input  wire        clk,
    input  wire        rst_n,

    // Instruction interface
    output wire [31:0] instr_addr,
    input  wire [31:0] instr_rdata,

    // Data memory interface
    output reg  [31:0] data_addr,
    output reg  [31:0] data_wdata,
    output reg         data_we,
    output reg         data_re,
    input  wire [31:0] data_rdata
);

    // Program Counter
    reg [31:0] pc;

    // 32 x 32-bit Register File
    reg [31:0] regs [0:31];

    // Instruction fields
    wire [6:0] opcode = instr_rdata[6:0];
    wire [4:0] rd     = instr_rdata[11:7];
    wire [2:0] funct3 = instr_rdata[14:12];
    wire [4:0] rs1    = instr_rdata[19:15];
    wire [4:0] rs2    = instr_rdata[24:20];
    wire [6:0] funct7 = instr_rdata[31:25];

    // Register read
    wire [31:0] rs1_val =
        (rs1 == 0) ? 32'b0 : regs[rs1];

    wire [31:0] rs2_val =
        (rs2 == 0) ? 32'b0 : regs[rs2];

    // Immediate generation
    wire [31:0] imm_i =
        {{20{instr_rdata[31]}}, instr_rdata[31:20]};

    wire [31:0] imm_s =
        {{20{instr_rdata[31]}},
         instr_rdata[31:25], instr_rdata[11:7]};

    wire [31:0] imm_b =
        {{19{instr_rdata[31]}},
         instr_rdata[31],
         instr_rdata[7],
         instr_rdata[30:25],
         instr_rdata[11:8],
         1'b0};

    wire [31:0] imm_j =
        {{11{instr_rdata[31]}},
         instr_rdata[31],
         instr_rdata[19:12],
         instr_rdata[20],
         instr_rdata[30:21],
         1'b0};

    // Control signals
    reg [31:0] next_pc;
    reg [31:0] rd_value;
    reg        reg_write;

    // Instruction address
    assign instr_addr = pc;

    // Instruction decoder and ALU
    always @(*) begin

        next_pc   = pc + 4;
        rd_value  = 32'b0;
        reg_write = 1'b0;

        data_addr  = 32'b0;
        data_wdata = rs2_val;
        data_we    = 1'b0;
        data_re    = 1'b0;

        case (opcode)

            // ADDI, ANDI, ORI, XORI
            7'b0010011: begin

                reg_write = 1'b1;

                case (funct3)

                    3'b000: rd_value = rs1_val + imm_i;
                    3'b111: rd_value = rs1_val & imm_i;
                    3'b110: rd_value = rs1_val | imm_i;
                    3'b100: rd_value = rs1_val ^ imm_i;

                    default: begin
                        reg_write = 1'b0;
                        rd_value = 0;
                    end

                endcase
            end

            // ADD, SUB, AND, OR, XOR
            7'b0110011: begin

                reg_write = 1'b1;

                case ({funct7, funct3})

                    {7'b0000000, 3'b000}:
                        rd_value = rs1_val + rs2_val;

                    {7'b0100000, 3'b000}:
                        rd_value = rs1_val - rs2_val;

                    {7'b0000000, 3'b111}:
                        rd_value = rs1_val & rs2_val;

                    {7'b0000000, 3'b110}:
                        rd_value = rs1_val | rs2_val;

                    {7'b0000000, 3'b100}:
                        rd_value = rs1_val ^ rs2_val;

                    default: begin
                        reg_write = 1'b0;
                        rd_value = 0;
                    end

                endcase
            end

            // LW
            7'b0000011: begin

                if (funct3 == 3'b010) begin
                    data_addr = rs1_val + imm_i;
                    data_re = 1'b1;
                    rd_value = data_rdata;
                    reg_write = 1'b1;
                end

            end

            // SW
            7'b0100011: begin

                if (funct3 == 3'b010) begin
                    data_addr = rs1_val + imm_s;
                    data_wdata = rs2_val;
                    data_we = 1'b1;
                end

            end

            // BEQ
            7'b1100011: begin

                if (funct3 == 3'b000) begin
                    if (rs1_val == rs2_val)
                        next_pc = pc + imm_b;
                end

            end

            // JAL
            7'b1101111: begin

                rd_value = pc + 4;
                reg_write = 1'b1;
                next_pc = pc + imm_j;

            end

            default: begin
                reg_write = 1'b0;
            end

        endcase
    end

    // Sequential logic
    integer i;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            pc <= 32'b0;

            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;

        end
        else begin

            pc <= next_pc;

            if (reg_write && rd != 0)
                regs[rd] <= rd_value;

            regs[0] <= 32'b0;

        end

    end

endmodule

