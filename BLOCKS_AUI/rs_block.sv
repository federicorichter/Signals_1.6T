module rs_module #(
    parameter BITS_BLOCK = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE = 10, 
    parameter BLOCKS_REPETITION = 8192,
    parameter LANE_WIDTH = 1360,
    parameter AM_MAPPED_WIDTH = 10280, // AM mapped signal width -> 40 blocks,
    parameter WIDTH_WORD_RS = 5440
) (
    input logic clk,
    input logic rst,

    input logic [AM_MAPPED_WIDTH-1:0] tx_scrambled_f0,
    input logic [AM_MAPPED_WIDTH-1:0] tx_scrambled_f1, 

    input logic i_valid,

    output logic valid,

    output logic [WIDTH_WORD_RS-1:0] word_A,
    output logic [WIDTH_WORD_RS-1:0] word_B,
    output logic [WIDTH_WORD_RS-1:0] word_C,
    output logic [WIDTH_WORD_RS-1:0] word_D
);

reg [WIDTH_WORD_RS-1:0] message_codeword_a, message_codeword_b, message_codeword_c, message_codeword_d,
                        message_codeword_a_temp, message_codeword_b_temp, message_codeword_c_temp, message_codeword_d_temp;



always_comb begin
    for (int l = 0; l < 514; l++) begin
        message_codeword_a_temp[(544-l)*10-:10] = tx_scrambled_f0[(20*l)+:10];
        message_codeword_b_temp[(544-l)*10-:10] = tx_scrambled_f0[(20*l+10)+:10];
        message_codeword_c_temp[(544-l)*10-:10] = tx_scrambled_f1[(20*l)+:10];
        message_codeword_d_temp[(544-l)*10-:10] = tx_scrambled_f1[(20*l+10)+:10];
    end
    message_codeword_a_temp[299:0] = {300{2'd0}};
    message_codeword_b_temp[299:0] = {300{2'd1}};
    message_codeword_c_temp[299:0] = {300{2'd2}};
    message_codeword_d_temp[299:0] = {300{2'd3}};
end

always_ff @(posedge clk) begin
    if(rst) begin
        message_codeword_a <= {WIDTH_WORD_RS{1'b0}};
        message_codeword_b <= {WIDTH_WORD_RS{1'b0}};
        message_codeword_c <= {WIDTH_WORD_RS{1'b0}};
        message_codeword_d <= {WIDTH_WORD_RS{1'b0}};
    end
    else if(i_valid) begin
        message_codeword_a <= message_codeword_a_temp;
        message_codeword_b <= message_codeword_b_temp;
        message_codeword_c <= message_codeword_c_temp;
        message_codeword_d <= message_codeword_d_temp;
    end
end


assign word_A = message_codeword_a;
assign word_B = message_codeword_b;
assign word_C = message_codeword_c;
assign word_D = message_codeword_d;
assign valid = i_valid;
    
endmodule
