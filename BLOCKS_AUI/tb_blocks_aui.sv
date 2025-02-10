module aui_block_testbench;

localparam AM_MAPPED_WIDTH = 10280;
localparam WIDTH_WORD_RS = 5440;
localparam LANE_WIDTH = 1360;

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
        blocks = {257{3'b1}};
        @(posedge clk);
        blocks = {257{3'd2}};
        @(posedge clk);
        blocks = {257{3'd3}};
        @(posedge clk);
        blocks = {257{3'd4}};
    end
    #40000;
    $finish;
end

flow_distributor_r flow_distributor_real (
    .clk(clk),
    .rst(rst),
    .input_blocks(blocks),
    .flow_0(flow_0),
    .flow_1(flow_1),
    .valid(valid)
);

flow_distributor aui_blocks(
    .clk(clk),
    .i_valid(valid),
    .rst(rst),
    .flow_0(flow_0),
    .flow_1(flow_1),
    .tx_scrambled_f0(tx_scrambled_f0),
    .tx_scrambled_f1(tx_scrambled_f1),
    .valid_signal(valid1)
);

rs_module reed_salomon (
    .clk(clk),
    .i_valid(valid1),
    .rst(rst),
    .tx_scrambled_f0(tx_scrambled_f0),
    .tx_scrambled_f1(tx_scrambled_f1),
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

endmodule