module aui_testbench;
    // Parameters
    parameter DATA_WIDTH = 64;
    parameter NUMBER_LANES = 16;

    // Signals
    logic clk;
    logic rst_n;
    wire [DATA_WIDTH-1:0]  tx_lane[NUMBER_LANES-1:0];
    logic [DATA_WIDTH-1:0]i_data;

    // Instantiate the AUI generator
    aui_generator #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUMBER_LANES(NUMBER_LANES)
    ) generator_aui (
        .clk(clk),
        .rst_n(rst_n),
        .i_data(i_data),
        .tx_lane(tx_lane)
    );

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

    // Monitor and display lane values (optional for debugging)
    /*always @(posedge clk) begin
        if (rst_n) begin
            for (int i = 0; i < NUMBER_LANES; i++) begin
                $display("Time: %0t, tx_lane[%0d] = %h", $time, i, tx_lane[i]);
            end
        end
    end*/
endmodule
