module kogge_stone_adder #(parameter PRECISION = 32)
(
    input  wire [PRECISION-1:0] operand_a_i,
    input  wire [PRECISION-1:0] operand_b_i,
    output wire [PRECISION-1:0] result_o,
    output wire overflow_o
);

    // The total number of P,G levels (k)
    localparam num_steps = $clog2(PRECISION);

    wire [PRECISION-1:0] generates  [0:num_steps  ];
    wire [PRECISION-1:0] propagates [0:num_steps-1];

    genvar k, idx;
    generate

        for (k = 0; k <= num_steps; k++) begin : adder_steps
            
            for (idx = 0; idx < PRECISION; idx++) begin : step

                if (k == 0) begin : first_step
                    assign generates[k][idx]  = operand_a_i[idx] & operand_b_i[idx];
                    assign propagates[k][idx] = operand_a_i[idx] ^ operand_b_i[idx];
                end

                else if (k < num_steps) begin : intermediate_steps

                    assign generates[k][idx] = (idx >= (1 << (k-1))) ?
                           (generates[k-1][idx] | (generates[k-1][idx-(1 << (k-1))] & propagates[k-1][idx])) :
                           generates[k-1][idx];
                    
                    assign propagates[k][idx] = (idx >= (1 << k)) ?
                            (propagates[k-1][idx] & propagates[k-1][idx-(1 << (k-1))]) :
                            1'b 0; // This P value will never be requested hence set to 0.

                end else begin : final_step
                    
                    assign generates[k][idx] = (idx >= (1 << (k-1))) ?
                        generates[k-1][idx] | ( generates[k-1][idx-(1 << (k-1))] & propagates[k-1][idx]) :
                        generates[k-1][idx];
                end

            end

        end

 //  ___ _   _ _ __ ___   //
 // / __| | | | '_ ` _ \  //
 // \__ \ |_| | | | | | | //
 // |___/\__,_|_| |_| |_| //

        assign result_o[0] = propagates[0][0];

        for (idx = 1; idx < PRECISION; idx++) begin : sum
            assign result_o[idx] = propagates[0][idx] ^ generates[num_steps][idx-1];
        end 

        assign overflow_o = generates[num_steps][PRECISION-1];

    endgenerate

endmodule