module aui_testbench;
    // Parameters
    parameter DATA_WIDTH = 64;
    parameter NUMBER_LANES = 16;

    // Signals
    logic clk;
    logic rst_n;
    //wire flow_0;
    //wire flow_1;
    reg [3:0]hexa_output;
    wire [DATA_WIDTH-1:0]  tx_lane_1;
    wire [DATA_WIDTH-1:0]  tx_lane_2;
    wire [DATA_WIDTH-1:0]  tx_lane_3;
    wire [DATA_WIDTH-1:0]  tx_lane_4;
    wire [DATA_WIDTH-1:0]  tx_lane_5;
    wire [DATA_WIDTH-1:0]  tx_lane_6;
    wire [DATA_WIDTH-1:0]  tx_lane_7;
    wire [DATA_WIDTH-1:0]  tx_lane_8;
    logic [DATA_WIDTH-1:0]i_data;

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
    alignment_marker_generator am_generator(
        .clk(clk),
        .rst_n(rst_n),
        //.create_amg(create_amg),
        //.flow_0(flow_0),
        //.flow_1(flow_1)
        .hexa_output(hexa_output)
    ) ;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        i_data = 64'hFFFF;
        #20 rst_n = 1;
        #500;
        i_data = 64'h5555554;
    end

    // Simulation control
    initial begin
        // Run the simulation for a specific time
        #1000;
        $finish;
    end

    // Dump waveforms for GTKWave
    initial begin
    $dumpfile("aui_testbench.vcd");   // Specify VCD file for gtkwave
    $dumpvars(0, aui_testbench); // Start dumping signals from the top module
end

endmodule
