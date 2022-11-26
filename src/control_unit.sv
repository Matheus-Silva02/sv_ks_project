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

typedef enum {
    BUSCA_INSTR
   ,REG_INSTR
   ,DECODIFICA
   ,LOAD_1
   ,LOAD_2
   ,STORE_1
   ,STORE_2
   ,HALT_P
   ,BRANCH
   ,ADD_1
   ,SUB_1
   ,OR_1
   ,AND_1
}state_t;

state_t state;
state_t next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= BUSCA_INSTR;
    else
        state <= next_state;
end

always_comb begin
    case(state)
       BUSCA_INSTR: next_state = DECODIFICA;
       DECODIFICA: next_state = BUSCA_INSTR;
    endcase
end

always_comb begin
      branch = 1'b0;       
      pc_enable = 1'b0;         
      ir_enable = 1'b0;       
      write_reg_enable = 1'b0; 
      addr_sel = 1'b0;    
      c_sel = 1'b0;        
      operation = 2'b00;   
      flags_reg_enable = 1'b0; 
      ram_write_enable = 1'b0; 
      halt = 1'b0;
      case(state)
        BUSCA_INSTR: begin
            next_state = REG_INSTR;
        end
        REG_INSTR: begin
            next_state = DECODIFICA;
            ir_enable = 1'b1;
            pc_enable = 1'b1;
        end
        DECODIFICA: begin
            next_state = BUSCA_INSTR;
            case(decoded_instruction)
                I_HALT: next_state = HALT_P;
                I_LOAD: begin
                    next_state = LOAD_1;
                    addr_sel = 1'b1;
                end
                I_STORE: begin
                    next_state = STORE_1;
                    addr_sel = 1'b1;
                end
                I_BRANCH: begin
                    next_state = BRANCH;
                    branch =1'b1;
                end
                I_ADD: begin
                    next_state = ADD_1;
                end
                I_SUB: begin
                    next_state = SUB_1;
                end
                I_OR: begin
                    next_state = OR_1;
                end
                I_AND: begin
                    next_state = AND_1;
                end
            endcase
        end
        ADD_1: begin
            next_state = BUSCA_INSTR;
            write_reg_enable = 1'b1;
        end
        SUB_1: begin
            next_state = BUSCA_INSTR;
            write_reg_enable = 1'b1;
        end
        OR_1: begin
            next_state = BUSCA_INSTR;
            write_reg_enable = 1'b1;
        end
        AND_1: begin
            next_state = BUSCA_INSTR;
            write_reg_enable = 1'b1;
        end
        BRANCH: begin
             next_state = BUSCA_INSTR;    
             branch =1'b1;
             pc_enable =1'b1;
        end
        LOAD_1: begin
             next_state = LOAD_2;   
             addr_sel = 1'b1;
             c_sel = 1'b1;
        end
        LOAD_2: begin
             next_state = BUSCA_INSTR;   
             addr_sel = 1'b1;
             c_sel = 1'b1;
             write_reg_enable = 1'b1;
        end
        STORE_1: begin
            next_state = STORE_2; 
            addr_sel = 1'b1;
        end
        STORE_2: begin
            next_state = BUSCA_INSTR;
            addr_sel = 1'b1;
            ram_write_enable = 1'b1;
        end  
        HALT_P: begin
            next_state = HALT_P;
            halt = 1'b1;
        end
      endcase      
  end

endmodule : control_unit
