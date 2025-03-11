module am_insertion #(
    parameter BITS_BLOCK = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE = 10, 
    parameter BLOCKS_REPETITION = 8192,
    parameter LANE_WIDTH = 1360,
    parameter AM_MAPPED_WIDTH = 10280 // AM mapped signal width -> 40 blocks
)(
    input logic clk, //each input of a 257-bit block
    input logic rst,
    input logic i_valid,
    input logic [BITS_BLOCK-1:0] flow_0,
    input logic [BITS_BLOCK-1:0] flow_1,

    output logic [AM_MAPPED_WIDTH-1:0] tx_scrambled_f0,
    output logic [AM_MAPPED_WIDTH-1:0] tx_scrambled_f1,

    output logic valid_signal

);

    logic [AM_MAPPED_WIDTH-1:0] tx_scrambled_f0_next; // AM mapped signal -> fixed, constant
    logic [AM_MAPPED_WIDTH-1:0] tx_scrambled_f1_next;

    logic [119:0] am [0:15];
    logic [119:0]am_inverted[0:15];
    reg option = 0;
    integer counter_blocks; // checks buffer overflow
    integer counter_am;     // checks wether we should insert AM or not

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
        
        //#100;
    end

    integer base_idx_f0, base_idx_f1;
    integer am_start_idx;
    logic [1027:0] am_mapped_f0;
    logic [1027:0] am_mapped_f1;
    
    logic [BITS_BLOCK-1:0] flow_buffer [0:40]; // Buffer de 80 valores (257 bits cada uno)
    integer counter_store; // Índice del buffer

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

    endgenerate

    always_ff @(posedge clk) begin
        valid_signal <= 0;
        if (rst) begin
            counter_blocks <= 4; // we already start with AM
            counter_store <= 0;           
            tx_scrambled_f0_next[1027:0] <= am_mapped_f0;
            tx_scrambled_f0 <= {AM_MAPPED_WIDTH{1'b0}};
            tx_scrambled_f1 <= {AM_MAPPED_WIDTH{1'b0}};
            tx_scrambled_f0_next[10279:1028] <= {9251{1'd0}};
            tx_scrambled_f1_next[1027:0] <= am_mapped_f1;
            tx_scrambled_f1_next[10279:1028] <= {9251{1'd0}};
            counter_am <= 4;
            valid_signal <= 0;
        end else if(i_valid) begin
            valid_signal <= 0;
            
            
            
            // Almacenar en buffer alternadamente (flow_0 en pares, flow_1 en impares)
            if (counter_store < 40) begin
                if (counter_store % 2 == 0) begin
                    flow_buffer[counter_store] <= flow_0;
                end else begin
                    flow_buffer[counter_store] <= flow_1;
                end
                counter_store <= counter_store + 1;
            end
            else begin
                counter_store <= 0;
            end
            
            if(counter_am < 327680 ) begin  
                counter_am <= counter_am + 1;
                if(counter_blocks < 40 ) begin
                    counter_blocks <= counter_blocks + 1;
                    tx_scrambled_f0_next[((counter_blocks * 257) - 1) +: 257] <= flow_0;
                    tx_scrambled_f1_next[((counter_blocks * 257) - 1) +: 257] <= flow_1;
                end
                else begin // restart block for output
                    counter_blocks <= 1;
                    tx_scrambled_f0 <= tx_scrambled_f0_next;
                    tx_scrambled_f1 <= tx_scrambled_f1_next;
                    valid_signal <= 1;
                end
            end
            
            else begin //we should restart and insert AM
                counter_am <= 5;
                counter_blocks <= 5; // we already start with AM
                counter_store <= 0; // Reiniciar almacenamiento
                tx_scrambled_f0_next[1027:0] <= am_mapped_f0;
                tx_scrambled_f1_next[1027:0] <= am_mapped_f1;
                tx_scrambled_f0_next[(1028+257):1028] <= flow_0;
                tx_scrambled_f1_next[(1028+257):1028] <= flow_1;
                valid_signal <= 1;
            end
        end
    end

endmodule