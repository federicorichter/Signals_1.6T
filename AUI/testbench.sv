module aui_testbench;
    // Parameters
    parameter DATA_WIDTH = 64;
    parameter NUMBER_LANES = 16;
    parameter BITS_BLOCK = 257;

    // Signals
    logic clk;
    logic rst;
    //wire flow_0;
    //wire flow_1;
    reg [3:0]hexa_output;
    /*wire [DATA_WIDTH-1:0]  tx_lane_1;
    wire [DATA_WIDTH-1:0]  tx_lane_2;
    wire [DATA_WIDTH-1:0]  tx_lane_3;
    wire [DATA_WIDTH-1:0]  tx_lane_4;
    wire [DATA_WIDTH-1:0]  tx_lane_5;
    wire [DATA_WIDTH-1:0]  tx_lane_6;
    wire [DATA_WIDTH-1:0]  tx_lane_7;
    wire [DATA_WIDTH-1:0]  tx_lane_8;*/
    //logic [DATA_WIDTH-1:0]i_data;
    wire [BITS_BLOCK-1:0]o_flow0;
    wire [BITS_BLOCK-1:0]o_flow1;

    // Instantiate the AUI generator
   /* aui_generator #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUMBER_LANES(NUMBER_LANES)
    ) generator_aui (
        .clk(clk),
        .rst_n(rst_n),
        .i_data(i_data),
        .tx_lane_1(tx_lane_1),
        .tx_lane_2(tx_lane_2),
        .tx_lane_3(tx_lane_3),
        .tx_lane_4(tx_lane_4),
        .tx_lane_5(tx_lane_5),
        .tx_lane_6(tx_lane_6),
        .tx_lane_7(tx_lane_7),
        .tx_lane_8(tx_lane_8)
    );
*/
  /*  alignment_marker_generator am_generator(
        .clk(clk),
        .rst_n(rst_n),
        //.create_amg(create_amg),
        //.flow_0(flow_0),
        //.flow_1(flow_1)
        .hexa_output(hexa_output)
    ) ;
*/
    aui_generator #(
        .BITS_BLOCK(257)
    ) aui_test (
        .clk(clk),
        .rst(rst),
        .hexa_output(hexa_output),
        .o_flow_0(o_flow0),
        .o_flow_1(o_flow1)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #2 clk = ~clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        rst = 1;
        #20 rst = 0;
        #5000;
    end

    // Simulation control
    initial begin
        // Run the simulation for a specific time
        #40000;
        $finish;
    end

    // Dump waveforms for GTKWave
    initial begin
    $dumpfile("aui_testbench.vcd");   // Specify VCD file for gtkwave
    $dumpvars(0, aui_testbench); // Start dumping signals from the top module
end

endmodule
