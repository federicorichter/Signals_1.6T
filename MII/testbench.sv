module gmii_testbench;
    // Parameters
    parameter DATA_WIDTH = 64;
    parameter DATA_CHAR_PROBABILITY = 80;

    // Signals
    logic clk;
    logic rst_n;
    logic [DATA_WIDTH-1:0] data_out;
    logic [DATA_WIDTH/8-1:0] ctrl_out;
    logic start_monitoring;

    // Instantiate the generator
    gmii_generator #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_CHAR_PROBABILITY(DATA_CHAR_PROBABILITY)
    ) generator_mii (
        .clk(clk),
        .rst_n(rst_n),
        .data_out(data_out),
        .ctrl_out(ctrl_out)
    );

    // Instantiate the checker
    gmii_checker #(
        .DATA_WIDTH(DATA_WIDTH)
    ) checker_gmii (
        .clk(clk),
        .rst_n(rst_n),
        .start_monitoring(start_monitoring),
        .ctrl_in(ctrl_out),
        .data_in(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
        start_monitoring = 1;
    end

    // Simulation control
    initial begin
        // Run the simulation for a specific time

        #1000;
        start_monitoring = 0;
        #20;
        $finish;
    end

    // Dump waveforms for GTKWave
    initial begin
        $dumpfile("gmii_testbench.vcd");
        $dumpvars(0, gmii_testbench);
    end
endmodule
