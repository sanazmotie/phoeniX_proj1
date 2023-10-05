/*
  =====================================================================
  Module: User Divider
  Description: Divider module with configurable accuracy (optional)
  PLEASE DO NOT REMOVE THE COMMENTS IN THIS MODULE
  =====================================================================
  Inputs:
  - CLK: Source clock signal
  - input_1:  32-bit input operand 1.
  - input_2:  32-bit input operand 2.
  - accuracy: 8-bit accuracy setting.
  Outputs:
  - busy: Output indicating the busy status of the divider.
  - result: 32-bit result of the divtiplication.
  =====================================================================
  Naming Convention:
  All user-defined divider modules should follow this format:
  - Inputs: CLK, input_1, input_2, accuracy
  - Outputs: busy, result, remainder
  ======================================================================
*/

// *** Include your headers and modules here ***
`include "../Approximate_Arithmetic_Units/Approximate_Accuracy_Controlable_Divider.v"
// *** End of including headers and modules ***

module Divider_Unit #(parameter DIV_X_EXTENISION = 0, parameter DIV_USER_DESIGN = 0, parameter DIV_APX_ACC_CONTROL = 0)
(
    input CLK,
    input [6 : 0] opcode,
    input [6 : 0] funct7,
    input [2 : 0] funct3,

    input [7 : 0] accuracy_level,

    input [31 : 0] rs1,
    input [31 : 0] rs2,

    output reg div_unit_busy,
    output reg [31 : 0] div_output
);

    // Data forwarding will be considered in the core file (phoeniX.v)
    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;
    reg  [31 : 0] input_1;
    reg  [31 : 0] input_2;
    reg  [7  : 0] accuracy;
    wire [31 : 0] result;
    wire [31 : 0] remainder;

    // Latching operands coming from data bus
    always @(*) begin
        operand_1 = rs1;
        operand_2 = rs2;
        // Checking if the module is accuracy controlable or not
        if (DIV_X_EXTENISION == 0 && DIV_USER_DESIGN == 1 && DIV_APX_ACC_CONTROL == 0)
        begin
            accuracy = 8'bz; // Module is not approximate and accuracy controlable but is user designed -> input signal = Z
        end
        else if (DIV_X_EXTENISION == 0 && DIV_USER_DESIGN == 0 && DIV_APX_ACC_CONTROL == 0)
        begin
            accuracy = 8'bz; // Module is not approximate,accuracy controlable and user designed -> input signal = Z
        end
        else if (DIV_X_EXTENISION == 0 && DIV_USER_DESIGN == 0 && DIV_APX_ACC_CONTROL == 1)
        begin
            accuracy = 8'bz; // Module is not approximate and accuracy controlable -> input signal = Z
        end
        else if (DIV_X_EXTENISION == 1 && DIV_USER_DESIGN == 1 && DIV_APX_ACC_CONTROL == 0)
        begin
            accuracy = 8'bz; // Module is approximate but not accuracy controlable -> input signal = Z
        end
        else if (DIV_X_EXTENISION == 1 && DIV_USER_DESIGN == 1 && DIV_APX_ACC_CONTROL == 1)
        begin
            accuracy = accuracy_level; // Module is  approximate and accuracy controlable
        end
        // If the module is accuracy controlable, the accuarcy will be extracted from CSRs.
        // The extracted accuracy level will be directly give to `accuracy_level` and `accuracy`
    end

    always @(*) 
    begin
        div_unit_busy = busy;
        casex ({funct7, funct3, opcode})
            17'b0000001_100_0110011 : begin  // DIV
                input_1 = operand_1;
                input_2 = $signed(operand_2);
                div_output = result;
            end
            17'b0000001_101_0110011 : begin  // DIV
                input_1 = operand_1;
                input_2 = operand_2;
                div_output = result;
            end
            17'b0000001_110_0110011 : begin  // REM
                div_output = remainder;
            end
            17'b0000001_111_0110011 : begin  // REMU
                div_output = $signed(remainder);
            end
            default: begin div_output = 32'bz; div_unit_busy = 1'bz; end // Wrong opcode                
        endcase
    end

    // *** Instantiate your divider here ***
    // Please instantiate your divider module using the guidelines and phoeniX naming conventions
    Sample_Divider div (CLK, input_1, input_2, accuracy, busy, result, remainder);
    // *** End of divider instantiation ***

endmodule