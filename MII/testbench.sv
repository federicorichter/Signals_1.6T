`timescale 1ns/100ps
//`include "MII/generator.sv"
//`include "MII/checker_sm.sv"
//`include "MII/mac_generator2.sv"

// iverilog -g2012 -o tb/tb1 tb/tb1.sv
// vvp tb/tb1
// gtkwave tb/tb1.vcd

module tb1;

    // DUT Inputs
    //logic               clk;
    //logic               rst_n;
    logic               start;
    logic [47:0]        dest_address;
    logic [47:0]        src_address;
    logic [15:0]        eth_type;
    logic [15:0]        payload_length;
    logic [7:0]         payload[PAYLOAD_MAX_SIZE-1:0]; // Payload array

    // DUT Outputs
    logic               valid;
    logic [63:0]        frame_out;
    logic               done;
    logic [7:0]         tx_control;

    // Parameters
    localparam int DATA_WIDTH = 64;
    localparam int CTRL_WIDTH = 8;
    localparam PAYLOAD_MAX_SIZE = 64;
    // Signals
    logic clk;
    logic i_rst, rst_n;
    //logic [DATA_WIDTH-1:0] o_tx_data;
    //logic [CTRL_WIDTH-1:0] o_tx_ctrl;
    logic other_error, payload_error, intergap_error;

    // Instantiate the generator module
     mac_generator //#(
        //.PAYLOAD_MAX_SIZE(PAYLOAD_MAX_SIZE),
        //.PAYLOAD_CHAR_PATTERN(),
        //.PAYLOAD_LENGTH()
    //) 
    DUT (
        .clk(clk),
        .i_rst(i_rst),
        .i_start(start),
        .i_dst_addr(dest_address),
        .i_src_addr(src_address),
        .i_type(eth_type),
        //.i_payload_length(payload_length),
        //.i_payload(payload),
        //.o_valid(valid),
        .o_tx_data(frame_out),
        .o_tx_ctrl(tx_control),
        //.o_done(done)
    );

    // Instantiate the checker module
    mii_checker #(
        .DATA_WIDTH(DATA_WIDTH),
        .CTRL_WIDTH(CTRL_WIDTH),
        .IDLE_CODE(8'h07),
        .START_CODE(8'hFB),
        .TERM_CODE(8'hFD)
    ) tb1 (
        .clk(clk),
        .i_rst(i_rst),
        .i_tx_data(frame_out),
        .i_tx_ctrl(tx_control),
        .payload_error(payload_error),
        .intergap_error(intergap_error),
        .other_error(other_error)
    );


    // Clock generation
    initial begin
        clk = 0;
        forever #2 clk = ~clk; // 100 MHz clock
    end // 100 MHz clock
   
    // Test procedure
    initial begin
        rst_n = 0;
        i_rst = 1;
        start = 0;
        dest_address = 48'hFF_FF_FF_FF_FF_FF; // Broadcast MAC address
        src_address = 48'h11_22_33_44_55_66;  // Example source MAC address
        eth_type = 16'h0800;                  // IPv4 EtherType
        payload_length = 0;
        for (int i = 0; i < PAYLOAD_MAX_SIZE; i++) begin
            payload[i] = 8'h00; // Initialize all payload bytes to zero
        end

        // Reset sequence
        #20 rst_n = 1;
        i_rst = 0;

        // Test Case 1: Small payload
        @(posedge clk);
        preload_payload(6, '{8'hDE, 8'hAD, 8'hBE, 8'hEF, 8'h12, 8'h34}); // Preload payload
        payload_length = 6; // Payload length = 6 bytes
        start = 1; // Trigger frame generation
        repeat (50)@(posedge clk);
        start = 0; // Deassert start

        wait(done); // Wait for the frame generation to complete
        $display("Frame generation (Test Case 1) complete!");//he simulation for a certain period
        #2000;
        wait(done);
        $display("Frame generation (Test Case 2) complete!");
        
        $finish;

    end

    task preload_payload(input int len, input byte payload_data[]);
        for (int i = 0; i < len; i++) begin
            payload[i] = payload_data[i];
        end
    endtask

endmodule