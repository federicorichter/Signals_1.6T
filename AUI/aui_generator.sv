module aui_generator #(
    parameter BITS_BLOCK = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE = 10
)(
    input logic clk,
    input logic rst,
    output logic [3:0] hexa_output,
    output logic [BITS_BLOCK-1:0] o_flow_0,
    output logic [BITS_BLOCK-1:0] o_flow_1,
    output logic [(WORD_SIZE*4)-1:0] o_lane_0
);

    // Define individual localparams for each row
    logic [119:0] am [0:15];

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

    logic [1027:0] am_mapped_f0;
    logic [1027:0] am_mapped_f1;
    integer i;
    integer shift_counter = 1027;
    logic [(MAX_BLOCKS_AM*BITS_BLOCK)-1:0] tx_scrambled_f0; //= {am_mapped_f0, 3{4'd1111}};
    logic [(MAX_BLOCKS_AM*BITS_BLOCK)-1:0] tx_scrambled_f1; //= {am_mapped_f1, 3{4'hf}};
    logic [5440-1:0] message_codeword_a;
    logic [5440-1:0] message_codeword_b;
    logic [5440-1:0] message_codeword_c;
    logic [5440-1:0] message_codeword_d;
    logic [1359:0] lane_0;
    logic [1359:0] lane_1;

    integer base_idx_f0, base_idx_f1;
    integer am_start_idx;

    // Example initialization for alignment markers
    genvar k, j, l, m;
    generate
        for (k = 0; k <= 2; k++) begin : loop_k
        for (j = 0; j <= 15; j++) begin : loop_j
            localparam int base_idx_f0 = 320 * k + 20 * j;
            localparam int am_start_idx = 40 * k;
            
            // Mapping for am_mapped_f0 -> AM Insertion
            assign am_mapped_f0[base_idx_f0 + 9 : base_idx_f0]     = am[j][am_start_idx + 9 : am_start_idx];
            assign am_mapped_f0[base_idx_f0 + 19 : base_idx_f0 + 10] = am[j][am_start_idx + 19 : am_start_idx + 10];

            // Mapping for am_mapped_f1 -> AM Insertion
            assign am_mapped_f1[base_idx_f0 + 9 : base_idx_f0]     = am[j][am_start_idx + 29 : am_start_idx + 20];
            assign am_mapped_f1[base_idx_f0 + 19 : base_idx_f0 + 10] = am[j][am_start_idx + 39 : am_start_idx + 30];
        end
        end

        assign am_mapped_f0[1027:960] = 68'h66666666666666666;
        assign am_mapped_f1[1024:960] = 65'h6666666666666666; //"prbs9"

        //Status field
        assign am_mapped_f1[1027:1025] = 3'b111;

        assign tx_scrambled_f0[(MAX_BLOCKS_AM*BITS_BLOCK)-1:0] = {{9252{1'd1}}, am_mapped_f0[1027:0]}; //am + data blocks
        assign tx_scrambled_f1[(MAX_BLOCKS_AM*BITS_BLOCK)-1:0] = {{9252{1'd1}}, am_mapped_f1[1027:0]};
        
        for(l = 0; l < 544; l++) begin //5439         5430
            assign message_codeword_a[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f0[(20*l+9):(20*l)];
            assign message_codeword_b[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f0[(20*l+19):(20*l + 10)];
            assign message_codeword_c[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f0[(20*l+9):(20*l)];
            assign message_codeword_d[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f0[(20*l+19):(20*l + 10)];
        end

        //Reed-Solomon
        assign message_codeword_a[299:0] = {300{4'd1}};
        assign message_codeword_b[299:0] = {300{4'd2}};
        assign message_codeword_c[299:0] = {300{4'd3}};
        assign message_codeword_d[299:0] = {300{4'd4}};

        for(k = 0;k <= 33; k++) begin
            //for(j = 0;j <= 15;j++)begin
            assign lane_0[(40*k) + 9: 40*k] = message_codeword_a[(544*10)-(16*k)-1:(544*10)-(16*k)-10];
            assign lane_0[(40*k) + 19: 40*k + 10] = message_codeword_b[(544*10)-(16*k)-1:(544*10)-(16*k)-10];
            assign lane_0[(40*k) + 29: 40*k + 20] = message_codeword_c[(544*10)-(16*k)-1:(544*10)-(16*k)-10];
            assign lane_0[(40*k) + 39: 40*k + 30] = message_codeword_d[(544*10)-(16*k)-1:(544*10)-(16*k)-10];

            assign lane_1[(40*k) + 9: 40*k] = message_codeword_a[(544*10)-(16*(k - 1))-1:(544*10)-(16*(k - 1))-10];
            assign lane_1[(40*k) + 19: 40*k + 10] = message_codeword_b[(544*10)-(16*(k-1))-1:(544*10)-(16*(k - 1))-10];
            assign lane_1[(40*k) + 29: 40*k + 20] = message_codeword_c[(544*10)-(16*(k-1))-1:(544*10)-(16*(k - 1))-10];
            assign lane_1[(40*k) + 39: 40*k + 30] = message_codeword_d[(544*10)-(16*(k-1))-1:(544*10)-(16*(k - 1))-10];
            //end
        end

    endgenerate

    integer o_block = 0;
    integer o_block_next;
    integer o_block_end;
    integer o_hexa, o_hexa_next;

    always_ff @(posedge clk) begin
        if (rst) begin
            o_block <= 0;
            o_hexa <= 0;
        end else begin
            o_block <= o_block_next;
            o_block_end <= (BITS_BLOCK * o_block);
        end
    end

    // Next-state logic
    always_comb begin
        o_block_next = (o_block + 1) % MAX_BLOCKS_AM;
        o_hexa_next = (o_hexa + 1) % MAX_BLOCKS_AM;
    end

    // Data selection
    always_comb begin
        /*if(o_block <= 3)begin
            o_flow_0 = am_mapped_f0[(BITS_BLOCK * o_block) +: BITS_BLOCK];
            o_flow_1 = am_mapped_f1[(BITS_BLOCK * o_block) +: BITS_BLOCK];
        end
        else begin
            o_flow_0 = 257'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
            o_flow_1 = 257'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        end*/
        //o_flow_0 = tx_scrambled_f0[(BITS_BLOCK * o_block) +: BITS_BLOCK];
        //o_flow_1 = tx_scrambled_f1[(BITS_BLOCK * o_block) +: BITS_BLOCK];
        //o_lane_0 = {message_codeword_a[5449]}
    end
    

endmodule
