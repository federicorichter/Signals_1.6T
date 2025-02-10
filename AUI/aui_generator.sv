module aui_generator #(
    parameter BITS_BLOCK = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE = 10, 
    parameter BLOCKS_REPETITION = 8192,
    parameter LANE_WIDTH = 1360
)(
    input logic clk,
    input logic rst,
    output logic [3:0] hexa_output,
    output logic [BITS_BLOCK-1:0] o_flow_0,
    output logic [BITS_BLOCK-1:0] o_flow_1,

    output logic [LANE_WIDTH-1:0] o_lane_0,
    output logic sync_lane_0,
    output logic [LANE_WIDTH-1:0] o_lane_1,
    output logic sync_lane_1,
    output logic [LANE_WIDTH-1:0] o_lane_2,
    output logic sync_lane_2,
    output logic [LANE_WIDTH-1:0] o_lane_3,
    output logic sync_lane_3,
    output logic [LANE_WIDTH-1:0] o_lane_4,
    output logic sync_lane_4,
    output logic [LANE_WIDTH-1:0] o_lane_5,
    output logic sync_lane_5,
    output logic [LANE_WIDTH-1:0] o_lane_6,
    output logic sync_lane_6,
    output logic [LANE_WIDTH-1:0] o_lane_7,
    output logic sync_lane_7,
    output logic [LANE_WIDTH-1:0] o_lane_8,
    output logic sync_lane_8,
    output logic [LANE_WIDTH-1:0] o_lane_9,
    output logic sync_lane_9,
    output logic [LANE_WIDTH-1:0] o_lane_10,
    output logic sync_lane_10,
    output logic [LANE_WIDTH-1:0] o_lane_11,
    output logic sync_lane_11,
    output logic [LANE_WIDTH-1:0] o_lane_12,
    output logic sync_lane_12,
    output logic [LANE_WIDTH-1:0] o_lane_13,
    output logic sync_lane_13,
    output logic [LANE_WIDTH-1:0] o_lane_14,
    output logic sync_lane_14,
    output logic [LANE_WIDTH-1:0] o_lane_15,
    output logic sync_lane_15
);

    // Define individual localparams for each row
    logic [119:0] am [0:15];
    logic [119:0]am_inverted[0:15];
    reg option = 0;

    function automatic logic [7:0] reverse_octet(input logic [7:0] octet);
        logic [7:0] result;
        for (int i = 0; i < 8; i++) begin
            result[i] = octet[7-i];
        end
        return result;
    endfunction

    initial begin
        if(option == 1) begin
            am[0] =  120'h010000000000000000000000000001;
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
        end else begin
            am[0] =  120'h9A4A26B665B5D9D9FE8E0C260171F3;
            am[1] =  120'h9A4A260465b5d967a52181985ade7e;
            am[2] =  120'h9a4a264665b5d9fec10ca9013ef356;
            am[3] =  120'h9a4a265a65b5d984797f2f7b8680d0;
            am[4] =  120'h9a4a26e165b5d919d5ae0de62a51f2;
            am[5] =  120'h9a4a26f265b5d94eedb02eb1124fd1;
            am[6] =  120'h9a4a263d65b5d9eebd635e11429ca1;
            am[7] =  120'h9a4a262265b5d9322989a4cdd6765b;
            am[8] =  120'h9a4a266065b5d99f1e8c8a60e17375;
            am[9] =  120'h9a4a266b65b5d9a28e3bc35d71c43c;
            am[10] =  120'h9a4a26fa65b5d9046a1427fb95ebd8;
            am[11] =  120'h9a4a266c65b5d971dd99c78e226638;
            am[12] =  120'h9a4a261865b5d95b5d096aa4a2f695;
            am[13] =  120'h9a4a261465b5d9ccce683c333197c3;
            am[14] =  120'h9a4a26d065b5d9b13504594ecafba6;
            am[15] =  120'h9a4a26b465b5d956594586a9a6ba79;

            for (int i = 0; i < 16; i++) begin
                am_inverted[i] = 0; // Inicializar a cero
                for (int j = 0; j < 15; j++) begin // 15 octetos en 120 bits
                    // Invertir los bits del octeto
                    logic [7:0] reversed_octet = am[i][(j*8)+:8]; //reverse_octet(am[i][(j*8)+:8]);
                    // Colocar el octeto invertido en la posición opuesta
                    am_inverted[i][(14-j)*8 +: 8] = reversed_octet;
                end
            end

            for (int i = 0; i < 16; i++) begin
                am[i] = am_inverted[i];
                $display("am_flipped[%0d] = %h", i, am_inverted[i]);
            end

        end
        
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
    logic [1359:0] lane_2;
    logic [1359:0] lane_3;
    logic [1359:0] lane_4;
    logic [1359:0] lane_5;
    logic [1359:0] lane_6;
    logic [1359:0] lane_7;
    logic [1359:0] lane_8;
    logic [1359:0] lane_9;
    logic [1359:0] lane_10;
    logic [1359:0] lane_11;
    logic [1359:0] lane_12;
    logic [1359:0] lane_13;
    logic [1359:0] lane_14;
    logic [1359:0] lane_15;

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
        assign tx_scrambled_f1[(MAX_BLOCKS_AM*BITS_BLOCK)-1:0] = {{9252{1'd0}}, am_mapped_f1[1027:0]};
        
        for(l = 0; l < 544; l++) begin //5439         5430
            assign message_codeword_a[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f0[(20*l+9):(20*l)];
            assign message_codeword_b[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f0[(20*l+19):(20*l + 10)];
            assign message_codeword_c[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f1[(20*l+9):(20*l)];
            assign message_codeword_d[((544-l)*10)-1:((544-l)*10)-10] = tx_scrambled_f1[(20*l+19):(20*l + 10)];
        end

        //Reed-Solomon
        assign message_codeword_a[299:0] = {300{4'd1}};
        assign message_codeword_b[299:0] = {300{4'd2}};
        assign message_codeword_c[299:0] = {300{4'd3}};
        assign message_codeword_d[299:0] = {300{4'd4}};

        for(k = 0;k <= 33; k++) begin
            //for(j = 0;j <= 15;j++)begin
            assign lane_0[(40*k) + 9: 40*k] = message_codeword_a[(544-16*k)*10-1:(544-16*k)*10-10];
            assign lane_0[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-16*k)*10-1:(544-16*k)*10-10];
            assign lane_0[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-16*k)*10-1:(544-16*k)*10-10];
            assign lane_0[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-16*k)*10-1:(544-16*k)*10-10];

            assign lane_1[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 1)*10-1:(544-(16*k)- 1)*10-10];
            assign lane_1[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 1)*10-1:(544-(16*k)- 1)*10-10];
            assign lane_1[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 1)*10-1:(544-(16*k)- 1)*10-10];
            assign lane_1[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 1)*10-1:(544-(16*k)- 1)*10-10];

            assign lane_2[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 2)*10-1:(544-(16*k)- 2)*10-10];
            assign lane_2[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 2)*10-1:(544-(16*k)- 2)*10-10];
            assign lane_2[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 2)*10-1:(544-(16*k)- 2)*10-10];
            assign lane_2[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 2)*10-1:(544-(16*k)- 2)*10-10];

            assign lane_3[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 3)*10-1:(544-(16*k)- 3)*10-10];
            assign lane_3[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 3)*10-1:(544-(16*k)- 3)*10-10];
            assign lane_3[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 3)*10-1:(544-(16*k)- 3)*10-10];
            assign lane_3[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 3)*10-1:(544-(16*k)- 3)*10-10];

            assign lane_4[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 4)*10-1:(544-(16*k)- 4)*10-10];
            assign lane_4[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 4)*10-1:(544-(16*k)- 4)*10-10];
            assign lane_4[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 4)*10-1:(544-(16*k)- 4)*10-10];
            assign lane_4[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 4)*10-1:(544-(16*k)- 4)*10-10];

            assign lane_5[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 5)*10-1:(544-(16*k)- 5)*10-10];
            assign lane_5[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 5)*10-1:(544-(16*k)- 5)*10-10];
            assign lane_5[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 5)*10-1:(544-(16*k)- 5)*10-10];
            assign lane_5[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 5)*10-1:(544-(16*k)- 5)*10-10];

            assign lane_6[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 6)*10-1:(544-(16*k)- 6)*10-10];
            assign lane_6[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 6)*10-1:(544-(16*k)- 6)*10-10];
            assign lane_6[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 6)*10-1:(544-(16*k)- 6)*10-10];
            assign lane_6[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 6)*10-1:(544-(16*k)- 6)*10-10];

            assign lane_7[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 7)*10-1:(544-(16*k)- 7)*10-10];
            assign lane_7[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 7)*10-1:(544-(16*k)- 7)*10-10];
            assign lane_7[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 7)*10-1:(544-(16*k)- 7)*10-10];
            assign lane_7[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 7)*10-1:(544-(16*k)- 7)*10-10];

            assign lane_8[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 8)*10-1:(544-(16*k)- 8)*10-10];
            assign lane_8[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 8)*10-1:(544-(16*k)- 8)*10-10];
            assign lane_8[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 8)*10-1:(544-(16*k)- 8)*10-10];
            assign lane_8[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 8)*10-1:(544-(16*k)- 8)*10-10];

            assign lane_9[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 9)*10-1:(544-(16*k)- 9)*10-10];
            assign lane_9[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 9)*10-1:(544-(16*k)- 9)*10-10];
            assign lane_9[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 9)*10-1:(544-(16*k)- 9)*10-10];
            assign lane_9[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 9)*10-1:(544-(16*k)- 9)*10-10];

            assign lane_10[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 10)*10-1:(544-(16*k)- 10)*10-10];
            assign lane_10[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 10)*10-1:(544-(16*k)- 10)*10-10];
            assign lane_10[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 10)*10-1:(544-(16*k)- 10)*10-10];
            assign lane_10[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 10)*10-1:(544-(16*k)- 10)*10-10];

            assign lane_11[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 11)*10-1:(544-(16*k)- 11)*10-10];
            assign lane_11[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 11)*10-1:(544-(16*k)- 11)*10-10];
            assign lane_11[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 11)*10-1:(544-(16*k)- 11)*10-10];
            assign lane_11[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 11)*10-1:(544-(16*k)- 11)*10-10];

            assign lane_12[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 12)*10-1:(544-(16*k)- 12)*10-10];
            assign lane_12[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 12)*10-1:(544-(16*k)- 12)*10-10];
            assign lane_12[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 12)*10-1:(544-(16*k)- 12)*10-10];
            assign lane_12[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 12)*10-1:(544-(16*k)- 12)*10-10];

            assign lane_13[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 13)*10-1:(544-(16*k)- 13)*10-10];
            assign lane_13[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 13)*10-1:(544-(16*k)- 13)*10-10];
            assign lane_13[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 13)*10-1:(544-(16*k)- 13)*10-10];
            assign lane_13[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 13)*10-1:(544-(16*k)- 13)*10-10];

            assign lane_14[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 14)*10-1:(544-(16*k)- 14)*10-10];
            assign lane_14[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 14)*10-1:(544-(16*k)- 14)*10-10];
            assign lane_14[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 14)*10-1:(544-(16*k)- 14)*10-10];
            assign lane_14[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 14)*10-1:(544-(16*k)- 14)*10-10];

            assign lane_15[(40*k) + 9: 40*k] = message_codeword_a[(544-(16*k)- 15)*10-1:(544-(16*k)- 15)*10-10];
            assign lane_15[(40*k) + 19: 40*k + 10] = message_codeword_b[(544-(16*k)- 15)*10-1:(544-(16*k)- 15)*10-10];
            assign lane_15[(40*k) + 29: 40*k + 20] = message_codeword_c[(544-(16*k)- 15)*10-1:(544-(16*k)- 15)*10-10];
            assign lane_15[(40*k) + 39: 40*k + 30] = message_codeword_d[(544-(16*k)- 15)*10-1:(544-(16*k)- 15)*10-10];
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
        o_block_next = (o_block + 1) % BLOCKS_REPETITION;
        o_hexa_next = (o_hexa + 1) % MAX_BLOCKS_AM;
    end

    // Data selection
    always_comb begin
        if(o_block == 0) begin
            o_lane_0 = lane_0;
            sync_lane_0 = 1;
            o_lane_1 = lane_1;
            sync_lane_1 = 1;
            o_lane_2 = lane_2;
            sync_lane_2 = 1;
            o_lane_3 = lane_3;
            sync_lane_3 = 1;
            o_lane_4 = lane_4;
            sync_lane_4 = 1;
            o_lane_5 = lane_5;
            sync_lane_5 = 1;
            o_lane_6 = lane_6;
            sync_lane_6 = 1;
            o_lane_7 = lane_7;
            sync_lane_7 = 1;
            o_lane_8 = lane_8;
            sync_lane_8 = 1;
            o_lane_9 = lane_9;
            sync_lane_9 = 1;
            o_lane_10 = lane_10;
            sync_lane_10 = 1;
            o_lane_11 = lane_11;
            sync_lane_11 = 1;
            o_lane_12 = lane_12;
            sync_lane_12 = 1;
            o_lane_13 = lane_13;
            sync_lane_13 = 1;
            o_lane_14 = lane_14;
            sync_lane_14 = 1;
            o_lane_15 = lane_15;
            sync_lane_15 = 1;
        end 
        else begin
            o_lane_0 = {LANE_WIDTH{1'b1}};
            sync_lane_0 = 0;
            o_lane_1 = {LANE_WIDTH{1'b1}};
            sync_lane_1 = 0;
            o_lane_2 = {LANE_WIDTH{1'b1}};
            sync_lane_2 = 0;
            o_lane_3 = {LANE_WIDTH{1'b1}};
            sync_lane_3 = 0;
            o_lane_4 = {LANE_WIDTH{1'b1}};
            sync_lane_4 = 0;
            o_lane_5 = {LANE_WIDTH{1'b1}};
            sync_lane_5 = 0;
            o_lane_6 = {LANE_WIDTH{1'b1}};
            sync_lane_6 = 0;
            o_lane_7 = {LANE_WIDTH{1'b1}};
            sync_lane_7 = 0;
            o_lane_8 = {LANE_WIDTH{1'b1}};
            sync_lane_8 = 0;
            o_lane_9 = {LANE_WIDTH{1'b1}};
            sync_lane_9 = 0;
            o_lane_10 = {LANE_WIDTH{1'b1}};
            sync_lane_10 = 0;
            o_lane_11 = {LANE_WIDTH{1'b1}};
            sync_lane_11 = 0;
            o_lane_12 = {LANE_WIDTH{1'b1}};
            sync_lane_12 = 0;
            o_lane_13 = {LANE_WIDTH{1'b1}};
            sync_lane_13 = 0;
            o_lane_14 = {LANE_WIDTH{1'b1}};
            sync_lane_14 = 0;
            o_lane_15 = {LANE_WIDTH{1'b1}};
            sync_lane_15 = 0;
        end
        
    end
    

endmodule
