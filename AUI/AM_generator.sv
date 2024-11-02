module alignment_marker_generator (
    input logic clk,
    input logic rst_n,
    output logic [3:0] hexa_output
    //output logic [1027:0] am_mapped_f0,
    //output logic [1027:0] am_mapped_f1
);

    // Define individual localparams for each row
    logic [119:0] am [0:15];
    integer i;
 
    localparam [119:0] MATRIX [0:2] = {
    120'h000000000000000000000000,
    120'h000000000000000000000000,
    120'h000000000000000000000000
  };

    initial begin
        am[0] =  120'h000000000000000000000000000000;
        am[1] =  120'h111111111111111111111111111111;
        am[2] =  120'h222222222222222222222222222222;
        am[3] =  120'h333333333333333333333333333333;
        am[4] =  120'h444444444444444444444444444444;
        am[5] =  120'h555555555555555555555555555555;
        am[6] =  120'h666666666666666666666666666666;
        am[7] =  120'h777777777777777777777777777777;
        am[8] =  120'h888888888888888888888888888888;
        am[9] =  120'h999999999999999999999999999999;
        am[10] =  120'hAAAAAAAAAAAAAAAAAAAAAAAAaAAAAA;
        am[11] =  120'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB;
        am[12] =  120'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;
        am[13] =  120'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD;
        am[14] =  120'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
        am[15] =  120'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        
        #100;

    end
    // Combine these into an array
    //localparam [119:0] am [0:15] = '{am_0, am_1, am_2, am_3, am_4, am_5, am_6, am_7, am_8, am_9, am_10, am_11, am_12, am_13, am_14, am_15};

    logic [1027:0] am_mapped_f0;
    logic [1027:0] am_mapped_f1;

    integer shift_counter = 1027;

    integer base_idx_f0, base_idx_f1;
    integer am_start_idx;

    // Example initialization for alignment markers
    genvar k, j;
    generate
        for (k = 0; k < 2; k++) begin : loop_k
        for (j = 0; j < 15; j++) begin : loop_j
            localparam int base_idx_f0 = 320 * k + 20 * j;
            localparam int am_start_idx = 40 * k;
            
            // Mapping for am_mapped_f0
            assign am_mapped_f0[base_idx_f0 + 9 : base_idx_f0]     = am[j][am_start_idx + 9 : am_start_idx];
            assign am_mapped_f0[base_idx_f0 + 19 : base_idx_f0 + 10] = am[j][am_start_idx + 19 : am_start_idx + 10];

            // Mapping for am_mapped_f1
            assign am_mapped_f1[base_idx_f0 + 9 : base_idx_f0]     = am[j][am_start_idx + 29 : am_start_idx + 20];
            assign am_mapped_f1[base_idx_f0 + 19 : base_idx_f0 + 10] = am[j][am_start_idx + 39 : am_start_idx + 30];
        end
        end

        assign am_mapped_f0[1027:960] = 68'h666666666;
        assign am_mapped_f1[1024:960] = 65'h666666666; //prbs9

        //Status field
        assign am_mapped_f1[1027:1025] = 3'b111;

    endgenerate

    always_ff@(posedge clk)begin
        hexa_output <= am_mapped_f0[shift_counter -: 4];
         $display("hexa_output[%0d]: %h", i, hexa_output);
        // Decrement shift counter by 4 to access the next segment
        if (shift_counter >= 4)
            shift_counter <= shift_counter - 4;
        else
            shift_counter <= 1027; // Reset to start from MSB again
    end

endmodule
