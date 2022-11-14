module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
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

logic [15:0] bus_a;
logic [15:0] bus_b;
logic [15:0] bus_c;
logic [15:0] ula_out;
logic [4:0] mem_addr;
logic [4:0] program_counter;
logic [1:0] a_addr;
logic [1:0] b_addr;
logic [1:0] c_addr;

always @(posedge clk) begin // C select
if (c_sel) begin
    bus_c = data_in; 
end else begin 
    bus_c = ula_out; 
end      
end

always_ff @(posedge clk) begin // bus a to ram
    data_out = bus_a;
end

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

always_ff @(posedge clk)begin //DECODE
if(ir_enable)begin
    mem_addr=data_in[15:11]; //Endereços que o mem_addr pega
    a_addr=data_in[10:9];
    b_addr=data_in[8:7];
    c_addr=data_in[6:5];
end 
end





//assign ram_addr = 'd0;

endmodule : data_path
