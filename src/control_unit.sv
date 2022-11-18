//control unit
module control_unit
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    output logic                    branch,
    output logic                    pc_enable,
    output logic                    ir_enable,
    output logic                    write_reg_enable,
    output logic                    addr_sel,
    output logic                    c_sel,
    output logic              [1:0] operation,
    output logic                    flags_reg_enable,
    input  decoded_instruction_type decoded_instruction,
    input  logic                    zero_op,
    input  logic                    neg_op,
    input  logic                    unsigned_overflow,
    input  logic                    signed_overflow,
    output logic                    ram_write_enable,
    output logic                    halt
);

always_ff @(posedge clk) begin
    if(decoded_instruction[15:13]== 3'b101) begin
          case(decoded_instruction[11:8])
              4'b1xxx:  operation[1:0]= 2'b00; //add     
              4'bx1xx:  operation[1:0]= 2'b01; //sub     
              4'bxx1x:  operation[1:0]= 2'b10; //and     
              4'bxxx1:  operation[1:0]= 2'b11; //or     
          endcase 
    end
end

always_ff @(posedge clk) begin
    if(decoded_instruction[15:13]== 3'b100) begin
         if(decoded_instruction[12:9]== 4'bxxx1) begin
               ir_enable = 1'b0;          
               c_sel= 1'b1;    
               write_reg_enable= 1'b1;  
         end //load  
    end
end


always_ff @(posedge clk) begin
    if(decoded_instruction[15]==1'b0) begin
          case(decoded_instruction[10:8])
              3'b1xx:  branch=1'b1;   
              3'bx1x:  branch=1'b1;   
              3'bxx1:  branch=1'b1;     
          endcase 
    end
end





endmodule : control_unit
