module flow_distributor_r #(
    parameter BITS_BLOCK = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE = 10, 
    parameter BLOCKS_REPETITION = 8192,
    parameter LANE_WIDTH = 1360,
    parameter AM_MAPPED_WIDTH = 10280 // AM mapped signal width -> 40 blocks
)(
    input logic clk, //each input of a 257-bit block
    input logic rst,
    input logic i_valid,
    input logic [BITS_BLOCK-1:0] input_blocks,
    output logic [BITS_BLOCK-1:0] flow_0,
    output logic [BITS_BLOCK-1:0] flow_1,
    output logic valid
);

reg flow_change = 0;

always_ff @(posedge clk) begin
        if (rst) begin
            valid = 0;
            flow_change = 0;
            flow_0 = 0;
            flow_1 = 0;
        end
        else if(i_valid) begin
            valid = 1;
            if(flow_change) begin
                flow_change = 0;
                flow_1 = input_blocks;
                valid = 1;
            end
            else begin
                flow_change = 1;
                flow_0 = input_blocks;
                valid = 0;
            end
        end
end


endmodule