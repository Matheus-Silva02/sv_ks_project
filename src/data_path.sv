module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    input  logic              [1:0] addr_A,
    input  logic              [1:0] addr_B,
    input  logic              [1:0] addr_C,
    input  logic                    branch,
    input  logic                    pc_enable,
    input  logic                    ir_enable,
    input  logic                    addr_sel,
    input  logic                    c_sel,
    input  logic              [1:0] operation,
    input  logic                    write_reg_enable,
    input  logic                    flags_reg_enable,
    output decoded_instruction_type decoded_instruction,
    output logic                    zero_op,
    output logic                    neg_op,
    output logic                    unsigned_overflow,
    output logic                    signed_overflow,
    output logic              [4:0] ram_addr,
    output logic             [15:0] data_out,
    input  logic             [15:0] data_in


);
logic [15:0] A;
logic [15:0] B;
logic [15:0] C;
logic [4:0] mem_addr;
logic [4:0] program_counter;
//logic [1:0] a_addr;
//logic [1:0] b_addr;
//logic [1:0] c_addr;
logic [15:0] ula_out;
logic ula_uo;
logic ula_so;
logic ula_zero;
logic ula_neg;

always_ff @(posedge clk) begin // A to ram
    data_out <= A;
end

always_ff @(posedge clk) begin
  if (flags_reg_enable) begin
    unsigned_overflow <= ula_uo;
    signed_overflow <= ula_so;
    zero_op <= ula_zero;
    neg_op <= ula_neg;
  end
end
assign C = (c_sel?data_in:ula_out);

always_comb begin
  case(operation)
    2'b00: {unsigned_overflow,ula_out} = A + B;
    2'b01: {unsigned_overflow,ula_out} = A - B;
    2'b10: {signed_overflow,ula_out} = A + B;
    2'b11: {signed_overflow,ula_out} = A - B;
  endcase
end

assign ula_zero = ((ula_out=='d0)?1'b1:1'b0);
assign ula_neg = ula_out[15];

//banco de reg

logic [15:0] rf [16] = '{ default: 8'd87}; 

always_ff @(posedge clk) begin
  if (write_reg_enable)
    rf[addr_C] <= C;
end
assign A = rf[addr_A];
assign B = rf[addr_B];


always_ff @(posedge clk)begin //Pc enable
if (branch) begin
  program_counter=mem_addr; 
end else begin
  program_counter++;
end
end

always @(posedge clk)begin // addr select
if (addr_sel) begin
  ram_addr=mem_addr; 
end else begin
  ram_addr=program_counter;
end
end


endmodule : data_path
