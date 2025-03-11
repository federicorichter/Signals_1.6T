module aui_block_testbench;

localparam AM_MAPPED_WIDTH = 10280;
localparam WIDTH_WORD_RS = 5440;
localparam LANE_WIDTH = 1360;
localparam BITS_BLOCK = 257;

logic clk, rst;
wire [AM_MAPPED_WIDTH-1:0]tx_scrambled_f0, tx_scrambled_f1;
wire [WIDTH_WORD_RS-1:0] word_A, word_B, word_C, word_D;
reg [256:0] blocks;
wire [256:0] flow_0, flow_1;
wire valid, valid1, valid_rs;

wire [LANE_WIDTH-1:0]lane_0, lane_1, lane_2, lane_3, lane_4,
                     lane_5, lane_6, lane_7, lane_8, lane_9,
                     lane_10, lane_11, lane_12, lane_13, lane_14, lane_15;


wire sync_lane_0, sync_lane_1, sync_lane_2, sync_lane_3, sync_lane_4,
     sync_lane_5, sync_lane_6, sync_lane_7, sync_lane_8, sync_lane_9,
     sync_lane_10, sync_lane_11, sync_lane_12, sync_lane_13, sync_lane_14, sync_lane_15;
 

initial begin
    clk = 0;
    forever #2 clk = ~clk; // 100 MHz clock
end

initial begin
    #5000;
end

initial begin
    rst = 1;
    #20 rst = 0;
    // Run the simulation for a specific time
    for (int i = 0; i < 100; i++) begin
        @(posedge clk);
        gen_test_scrambler = {257{1'b1}};
        @(posedge clk);
        gen_test_scrambler = {257{1'd0}};
        @(posedge clk);
        gen_test_scrambler = {257{1'd1}};
        @(posedge clk);
        gen_test_scrambler = {257{1'd0}};
    end
    #4000000;
    $finish;
end

wire valid_generator;

block_generator blocks_generated(
    .clk(clk),
    .rst(rst),
        .i_config(2'b00),   //.i_config(2'b10),
    .data_out(blocks),
    .valid_gen(valid_generator)
);

flow_distributor_r flow_distributor_real (
    .clk(clk),
    .rst(rst),
    .i_valid(valid_generator),
    .input_blocks(blocks),
    .flow_0(flow_0),    // Output
    .flow_1(flow_1),    // Output
    .valid(valid)       // Output
);

reg [BITS_BLOCK-1:0] gen_test_scrambler;
wire [BITS_BLOCK-1:0] flow_0_scrambled, flow_1_scrambled, test_scrambler_i, test_scrambler_o;
wire valid_scrambler, valid_scrambler_1;
/*
lfsr_scramble  #(
    .DATA_WIDTH(BITS_BLOCK)
)
test_scrambler(
    .clk(clk),
    .rst(rst),
    .data_in(gen_test_scrambler),
    .data_out(test_scrambler_i),
    //.valid(valid_scrambler_1)
    .data_in_valid(clk)
);

lfsr_scramble #(
    .DATA_WIDTH(BITS_BLOCK)
    ) descrambler
    (
    .clk(clk),
    .rst(rst),
    .data_in(test_scrambler_i),
    .data_out(test_scrambler_o),
    .data_in_valid(clk)
);*/

scrambler x85_scrambler_f0(
    .clk(valid),
    .rst(rst),
    .data_in(flow_0),
    .data_out(flow_0_scrambled),
    .valid(valid_scrambler)
);

scrambler x85_scrambler_f1(
    .clk(valid),
    .rst(rst),
    .data_in(flow_1),                   // Input
    .data_out(flow_1_scrambled)         // Output
);

am_insertion aui_blocks(
    .clk(clk),
    .i_valid(valid),
    .rst(rst),
    .flow_0(flow_0_scrambled), //.flow_0(flow_0),                    // Input
    .flow_1(flow_1_scrambled), //.flow_1(flow_1),                    // Input
    .tx_scrambled_f0(tx_scrambled_f0),  // Output
    .tx_scrambled_f1(tx_scrambled_f1),  // Output
    .valid_signal(valid1)
);

rs_module reed_salomon (
    .clk(clk),
    .i_valid(valid1),
    .rst(rst),
    .tx_scrambled_f0(tx_scrambled_f0),  // Input
    .tx_scrambled_f1(tx_scrambled_f1),  // Input
    .valid(valid_rs),
    .word_A(word_A),
    .word_B(word_B),
    .word_C(word_C),
    .word_D(word_D)
);

lanes lanes_output(
    .clk(clk),
    .i_valid(valid_rs),
    .rst(rst),
    .word_A(word_A),
    .word_B(word_B),
    .word_C(word_C),
    .word_D(word_D),
    .o_lane_0(lane_0),
    .o_lane_1(lane_1),
    .o_lane_2(lane_2),
    .o_lane_3(lane_3),
    .o_lane_4(lane_4),
    .o_lane_5(lane_5),
    .o_lane_6(lane_6),
    .o_lane_7(lane_7),
    .o_lane_8(lane_8),
    .o_lane_9(lane_9),
    .o_lane_10(lane_10),
    .o_lane_11(lane_11),
    .o_lane_12(lane_12),
    .o_lane_13(lane_13),
    .o_lane_14(lane_14),
    .o_lane_15(lane_15),
    .sync_lane_0(sync_lane_0),
    .sync_lane_1(sync_lane_1),
    .sync_lane_2(sync_lane_2),
    .sync_lane_3(sync_lane_3),
    .sync_lane_4(sync_lane_4),
    .sync_lane_5(sync_lane_5),
    .sync_lane_6(sync_lane_6),
    .sync_lane_7(sync_lane_7),
    .sync_lane_8(sync_lane_8),
    .sync_lane_9(sync_lane_9),
    .sync_lane_10(sync_lane_10),
    .sync_lane_11(sync_lane_11),
    .sync_lane_12(sync_lane_12),
    .sync_lane_13(sync_lane_13),
    .sync_lane_14(sync_lane_14),
    .sync_lane_15(sync_lane_15)
    
);

aui_checker #(
        .LANE_WIDTH(LANE_WIDTH),
        .BITS_BLOCK(BITS_BLOCK)
    ) aui_chk (
        .clk(clk),
        .rst(rst),
        .i_lane_0(lane_0),
        .i_lane_1(lane_1),
        .i_lane_2(lane_2),
        .i_lane_3(lane_3),
        .i_lane_4(lane_4),
        .i_lane_5(lane_5),
        .i_lane_6(lane_6),
        .i_lane_7(lane_7),
        .i_lane_8(lane_8),
        .i_lane_9(lane_9),
        .i_lane_10(lane_10),
        .i_lane_11(lane_11),
        .i_lane_12(lane_12),
        .i_lane_13(lane_13),
        .i_lane_14(lane_14),
        .i_lane_15(lane_15),
        .sync_lane_0(sync_lane_0),
        .sync_lane_1(sync_lane_1),
        .sync_lane_2(sync_lane_2),
        .sync_lane_3(sync_lane_3),
        .sync_lane_4(sync_lane_4),
        .sync_lane_5(sync_lane_5),
        .sync_lane_6(sync_lane_6),
        .sync_lane_7(sync_lane_7),
        .sync_lane_8(sync_lane_8),
        .sync_lane_9(sync_lane_9),
        .sync_lane_10(sync_lane_10),
        .sync_lane_11(sync_lane_11),
        .sync_lane_12(sync_lane_12),
        .sync_lane_13(sync_lane_13),
        .sync_lane_14(sync_lane_14),
        .sync_lane_15(sync_lane_15)
    );

endmodule