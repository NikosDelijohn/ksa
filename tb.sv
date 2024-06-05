module tb_kogge_stone_adder;

    parameter PRECISION = 32;
    parameter NUMBER_OF_TESTS = 10000;
    
    // DUT inputs
    reg [PRECISION-1:0] operand_a_i;
    reg [PRECISION-1:0] operand_b_i;

    // DUT outputs
    wire [PRECISION-1:0] result_o;
    wire                 overflow_o;

    // Reference outputs
    reg [PRECISION:0] expected_result;

    kogge_stone_adder #(.PRECISION(PRECISION)) dut 
    (
        .operand_a_i ( operand_a_i ),
        .operand_b_i ( operand_b_i ),
        .result_o    ( result_o    ),
        .overflow_o  ( overflow_o  )
    );

    // Test stimulus
    initial begin
        
        // Random tests
        repeat (NUMBER_OF_TESTS) begin
            operand_a_i = $random;
            operand_b_i = $random;
            #1;
            expected_result = operand_a_i + operand_b_i;
            check_result(expected_result[PRECISION-1:0], expected_result[PRECISION]);
        end

        // End simulation
        $finish;
    end

    // Task to check result
    task check_result;
        input [PRECISION-1:0] expected_sum;
        input expected_overflow;
        begin
            if (result_o !== expected_sum || overflow_o !== expected_overflow) begin
                $display("Mismatch: A = %d, B = %d, Expected Sum = %d, Actual Sum = %b, Expected Overflow = %b, Actual Overflow = %b",
                         operand_a_i, operand_b_i, expected_sum, result_o, expected_overflow, overflow_o);
            end else begin
                $display("Match: A = %d, B = %d, Sum = %d, Overflow = %b", operand_a_i, operand_b_i, result_o, overflow_o);
            end
        end
    endtask

endmodule
