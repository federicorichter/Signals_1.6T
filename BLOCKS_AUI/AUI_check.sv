module aui_checker #(
    parameter BITS_BLOCK    = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE     = 10, 
    parameter LANE_WIDTH    = 1360,
    parameter CODEWORD_WIDTH = 5440
)(
    input logic clk,
    input logic rst,
    input logic [LANE_WIDTH-1:0] i_lane_0,  // 16 lanes de 1360 bits c/u
    input logic sync_lane_0,
    input logic [LANE_WIDTH-1:0] i_lane_1,
    input logic sync_lane_1,
    input logic [LANE_WIDTH-1:0] i_lane_2,
    input logic sync_lane_2,
    input logic [LANE_WIDTH-1:0] i_lane_3,
    input logic sync_lane_3,
    input logic [LANE_WIDTH-1:0] i_lane_4,
    input logic sync_lane_4,
    input logic [LANE_WIDTH-1:0] i_lane_5,
    input logic sync_lane_5,
    input logic [LANE_WIDTH-1:0] i_lane_6,
    input logic sync_lane_6,
    input logic [LANE_WIDTH-1:0] i_lane_7,
    input logic sync_lane_7,
    input logic [LANE_WIDTH-1:0] i_lane_8,
    input logic sync_lane_8,
    input logic [LANE_WIDTH-1:0] i_lane_9,
    input logic sync_lane_9,
    input logic [LANE_WIDTH-1:0] i_lane_10,
    input logic sync_lane_10,
    input logic [LANE_WIDTH-1:0] i_lane_11,
    input logic sync_lane_11,
    input logic [LANE_WIDTH-1:0] i_lane_12,
    input logic sync_lane_12,
    input logic [LANE_WIDTH-1:0] i_lane_13,
    input logic sync_lane_13,
    input logic [LANE_WIDTH-1:0] i_lane_14,
    input logic sync_lane_14,
    input logic [LANE_WIDTH-1:0] i_lane_15,
    input logic sync_lane_15,
    
    input logic  [BITS_BLOCK-1 : 0] descrambled_0,  // Entrada desescrambleada del flujo 0
    input logic  [BITS_BLOCK-1 : 0] descrambled_1,
    output logic [BITS_BLOCK-1 : 0] tx_scr_0_out,   // Salida escrambleada
    output logic [BITS_BLOCK-1 : 0] tx_scr_1_out,
    output logic desc_clk    // Clock para el descrambler
);


    localparam AM_WIDTH = 120; // ancho de los AMs
    localparam AM_LANES = 16; // cantidad de lineas
    //localparam AM_LANES_WIDTH = $clog2(AM_LANES); // ancho de las lineas
    localparam AM_LANES_WIDTH = 4; // ancho de las lineas
    localparam BYTE_SIZE = 8; 
    localparam TOTAL_CYCLES = 8191; // cantidad de ciclos hasta la aparicion de los AM's
    localparam TOTAL_CYCLES_WIDTH = $clog2(TOTAL_CYCLES);
    localparam ROUND_ROBIN_BITS = 10;
    localparam TOTAL_CODEWORDS = 4;
    localparam TOTAL_ITERATIONS = LANE_WIDTH / (TOTAL_CODEWORDS * ROUND_ROBIN_BITS);
    localparam FEC_WIDTH = 300;
    localparam CODEWORD_WIDTH_WO_FEC = CODEWORD_WIDTH - FEC_WIDTH;  // 5440 - 300 = 5140
    localparam BLOCK_W_AM_WIDTH = CODEWORD_WIDTH_WO_FEC * 2;        // 5140 * 2 = 10280
    localparam AM_MAPPED_WIDTH = 1028;
    localparam BLOCK_WO_AM_WIDTH = BLOCK_W_AM_WIDTH - AM_MAPPED_WIDTH; // 10280 - 1028 = 9220
    localparam NUM_BLOCKS = 40; // Bloques con data util


    // AMs ya invertidos para comparar directamente con los que ingresan
    localparam [AM_WIDTH - 1 : 0]
        EXPECTED_AM_LANE_0  = 120'hF37101260C8EFED9D9B565B6264A9A,
        EXPECTED_AM_LANE_1  = 120'h7EDE5A988121A567D9B56504264A9A,
        EXPECTED_AM_LANE_2  = 120'h56F33E01A90CC1FED9B56546264A9A,
        EXPECTED_AM_LANE_3  = 120'hD080867B2F7F7984D9B5655A264A9A,
        EXPECTED_AM_LANE_4  = 120'hF2512AE60DAED519D9B565E1264A9A,
        EXPECTED_AM_LANE_5  = 120'hD14F12B12EB0ED4ED9B565F2264A9A,
        EXPECTED_AM_LANE_6  = 120'hA19C42115E63BDEED9B5653D264A9A,
        EXPECTED_AM_LANE_7  = 120'h5B76D6CDA4892932D9B56522264A9A,
        EXPECTED_AM_LANE_8  = 120'h7573E1608A8C1E9FD9B56560264A9A,
        EXPECTED_AM_LANE_9  = 120'h3CC4715DC33B8EA2D9B5656B264A9A,
        EXPECTED_AM_LANE_10 = 120'hD8EB95FB27146A04D9B565FA264A9A,
        EXPECTED_AM_LANE_11 = 120'h3866228EC799DD71D9B5656C264A9A,
        EXPECTED_AM_LANE_12 = 120'h95F6A2A46A095D5BD9B56518264A9A,
        EXPECTED_AM_LANE_13 = 120'hC39731333C68CECCD9B56514264A9A,
        EXPECTED_AM_LANE_14 = 120'hA6FBCA4E590435B1D9B565D0264A9A,
        EXPECTED_AM_LANE_15 = 120'h79BAA6A986455956D9B565B4264A9A;
    
    // Índices por defecto de las lanes
    localparam [AM_LANES_WIDTH-1 : 0] AM_LANE [0 : AM_LANES-1] = '{
        4'h0, 4'h1, 4'h2, 4'h3,
        4'h4, 4'h5, 4'h6, 4'h7,
        4'h8, 4'h9, 4'hA, 4'hB,
        4'hC, 4'hD, 4'hE, 4'hF
    };

    // Alignment markers esperados segun estandar
    logic [AM_WIDTH              - 1 : 0] expected_am     [0 : AM_LANES - 1];    // 16 vias de 120 bits cada una
    logic [AM_WIDTH              - 1 : 0] extracted_am    [0 : AM_LANES - 1];    // Registros para los primeros 120 bits de cada lane
    logic [LANE_WIDTH            - 1 : 0] stored_lanes    [0 : AM_LANES - 1];    // Registros para almacenar cada lane
    
    // Para almacenar los valores de extracted_am de la iteración anterior, se usa para sincronizar 
    logic [AM_WIDTH            - 1 : 0] last_am         [0 : AM_LANES - 1];
    logic [AM_LANES            - 1 : 0] continue_am_error_flag; // Bandera de error para AMs que no se repiten
    logic [AM_LANES            - 1 : 0] sync_lanes; // Bandera de sincronización para cada lane 
    logic [AM_LANES            - 1 : 0] expected_am_flag;
    logic [AM_LANES            - 1 : 0] lane_locked;

    // Esto es para identificar que lane es cual
    logic [3:0] lane_mapping [0:AM_LANES-1];
    logic mapping_complete;

    // Contadores de ciclos entre activaciones de sync_lane
    logic [TOTAL_CYCLES_WIDTH    - 1 : 0] cycle_counter   [0 : AM_LANES - 1];   // Contador actual de ciclos para cada lane
    logic [TOTAL_CYCLES_WIDTH    - 1 : 0] cycle_gap       [0 : AM_LANES - 1];       // Valor del gap calculado entre activaciones de cada lane
    logic [AM_LANES              - 1 : 0] gap_error_flag;         // Bandera de error para gaps diferentes a 8191
    logic [AM_LANES              - 1 : 0] has_synced;             // Indica si un lane ya ha sido sincronizado al menos una vez
    
    // Codewords A, B, C y D con AM y FEC
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_a;
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_b;
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_c;
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_d;

    // Codewords A, B, C y D con AM y sin FEC
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_a_wo_fec;
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_b_wo_fec;
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_c_wo_fec;
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_d_wo_fec;
    
    // Tx scrambled 0 y 1
    logic [BLOCK_W_AM_WIDTH      - 1 : 0] tx_scrambled_0; // 10280 = 40 * 257
    logic [BLOCK_W_AM_WIDTH      - 1 : 0] tx_scrambled_1;
    
    // Tx scrambled 0 y 1 sin AM
    logic [BLOCK_WO_AM_WIDTH     - 1 : 0] tx_scrambled_0_wo_am; // 9220
    logic [BLOCK_WO_AM_WIDTH     - 1 : 0] tx_scrambled_1_wo_am; // 257 * 36 = 9252
    
    // AM mapped
    logic [AM_MAPPED_WIDTH       - 1 : 0] am_mapped_0;
    logic [AM_MAPPED_WIDTH       - 1 : 0] am_mapped_1;
    
    // Buffers para almacenar tx_scrambled en bloques
    logic [BITS_BLOCK - 1 : 0           ] array_tx_scr_0 [NUM_BLOCKS - 1 : 0];
    logic [BITS_BLOCK - 1 : 0           ] array_tx_scr_1 [NUM_BLOCKS - 1 : 0];
    logic [BITS_BLOCK - 1 : 0           ] array_tx_scr_0_wo_am [NUM_BLOCKS - 1 - 4: 0];
    logic [BITS_BLOCK - 1 : 0           ] array_tx_scr_1_wo_am [NUM_BLOCKS - 1 - 4: 0];
    
    // Mensaje original decodificado
    logic [BITS_BLOCK - 1 : 0           ] input_decoded [NUM_BLOCKS*2 - 1 : 0]; // 257 bits
    
    // Flag para verificar que hay data para desescramblear
    logic data_present;
    logic [1:0] desc_clk_started; // pequeño delay
    
    // Index para la posicion a mandar a desescramblear
    logic descr_index;
    
    // Auxiliares para asignar a salidas a descramblear
    logic [BITS_BLOCK - 1 : 0] to_descr_0;
    logic [BITS_BLOCK - 1 : 0] to_descr_1;
    logic [BITS_BLOCK - 1 : 0] flow_0_des;
    logic [BITS_BLOCK - 1 : 0] flow_1_des;
    
    // Clock para descrambler (mitad de frecuencia de clk)
    logic descrambler_clk;
    
    // Arreglos recibidos luego de descranmblear
    logic [BITS_BLOCK - 1 : 0           ] array_flow_0 [NUM_BLOCKS - 1 : 0];
    logic [BITS_BLOCK - 1 : 0           ] array_flow_1 [NUM_BLOCKS - 1 : 0];
    
    

    // Guardamos los valores de AM parametrizado en el registro usado en la comparación
    assign expected_am[AM_LANE[0] ]  = EXPECTED_AM_LANE_0;
    assign expected_am[AM_LANE[1] ]  = EXPECTED_AM_LANE_1;
    assign expected_am[AM_LANE[2] ]  = EXPECTED_AM_LANE_2;
    assign expected_am[AM_LANE[3] ]  = EXPECTED_AM_LANE_3;
    assign expected_am[AM_LANE[4] ]  = EXPECTED_AM_LANE_4;
    assign expected_am[AM_LANE[5] ]  = EXPECTED_AM_LANE_5;
    assign expected_am[AM_LANE[6] ]  = EXPECTED_AM_LANE_6;
    assign expected_am[AM_LANE[7] ]  = EXPECTED_AM_LANE_7;
    assign expected_am[AM_LANE[8] ]  = EXPECTED_AM_LANE_8;
    assign expected_am[AM_LANE[9] ]  = EXPECTED_AM_LANE_9;
    assign expected_am[AM_LANE[10]] = EXPECTED_AM_LANE_10;
    assign expected_am[AM_LANE[11]] = EXPECTED_AM_LANE_11;
    assign expected_am[AM_LANE[12]] = EXPECTED_AM_LANE_12;
    assign expected_am[AM_LANE[13]] = EXPECTED_AM_LANE_13;
    assign expected_am[AM_LANE[14]] = EXPECTED_AM_LANE_14;
    assign expected_am[AM_LANE[15]] = EXPECTED_AM_LANE_15;

    // Idem con las banderas de sincronización que indican que hay presencia de un AM
    assign sync_lanes [AM_LANE[0] ] = sync_lane_0;
    assign sync_lanes [AM_LANE[1] ] = sync_lane_1;
    assign sync_lanes [AM_LANE[2] ] = sync_lane_2;
    assign sync_lanes [AM_LANE[3] ] = sync_lane_3;
    assign sync_lanes [AM_LANE[4] ] = sync_lane_4;
    assign sync_lanes [AM_LANE[5] ] = sync_lane_5;
    assign sync_lanes [AM_LANE[6] ] = sync_lane_6;
    assign sync_lanes [AM_LANE[7] ] = sync_lane_7;
    assign sync_lanes [AM_LANE[8] ] = sync_lane_8;
    assign sync_lanes [AM_LANE[9] ] = sync_lane_9;
    assign sync_lanes [AM_LANE[10]] = sync_lane_10;
    assign sync_lanes [AM_LANE[11]] = sync_lane_11;
    assign sync_lanes [AM_LANE[12]] = sync_lane_12;
    assign sync_lanes [AM_LANE[13]] = sync_lane_13;
    assign sync_lanes [AM_LANE[14]] = sync_lane_14;
    assign sync_lanes [AM_LANE[15]] = sync_lane_15;
    
    // 
    assign descrambled_0 = flow_0_des; // Flows 0 y 1 recuperados
    assign descrambled_1 = flow_1_des;
    assign tx_scr_0_out = to_descr_0; // Salidas a desescramblear
    assign tx_scr_1_out = to_descr_1;
    assign desc_clk = descrambler_clk; // Clock para el descrambler
    


    always_comb begin
        
            stored_lanes[0] = i_lane_0;
            stored_lanes[1] = i_lane_1;
            stored_lanes[2] = i_lane_2;
            stored_lanes[3] = i_lane_3;
            stored_lanes[4] = i_lane_4;
            stored_lanes[5] = i_lane_5;
            stored_lanes[6] = i_lane_6;
            stored_lanes[7] = i_lane_7;
            stored_lanes[8] = i_lane_8;
            stored_lanes[9] = i_lane_9;
            stored_lanes[10] = i_lane_10;
            stored_lanes[11] = i_lane_11;
            stored_lanes[12] = i_lane_12;
            stored_lanes[13] = i_lane_13;
            stored_lanes[14] = i_lane_14;
            stored_lanes[15] = i_lane_15;
        
        
        // Cargar los valores solo si el sync_lane correspondiente está activo
        // Extraer los últimos 120 bits de cada lane si el sync_lane correspondiente está en 1
            extracted_am[0] = sync_lane_0  ? stored_lanes[0][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[1] = sync_lane_1  ? stored_lanes[1][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[2] = sync_lane_2  ? stored_lanes[2][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[3] = sync_lane_3  ? stored_lanes[3][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[4] = sync_lane_4  ? stored_lanes[4][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[5] = sync_lane_5  ? stored_lanes[5][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[6] = sync_lane_6  ? stored_lanes[6][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[7] = sync_lane_7  ? stored_lanes[7][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[8] = sync_lane_8  ? stored_lanes[8][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[9] = sync_lane_9  ? stored_lanes[9][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[10] = sync_lane_10 ? stored_lanes[10][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[11] = sync_lane_11 ? stored_lanes[11][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[12] = sync_lane_12 ? stored_lanes[12][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[13] = sync_lane_13 ? stored_lanes[13][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[14] = sync_lane_14 ? stored_lanes[14][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
            extracted_am[15] = sync_lane_15 ? stored_lanes[15][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};

        // Comparo AMs uno por uno, recibidos con los codificados, para saber si alguna lane recibe un AM incorrecto
        for (int i = 0; i < AM_LANES; i = i + 1'b1) begin
            expected_am_flag[i] = 1'b0;  // Inicializar en 0
            for (int j = 0; j < AM_LANES; j = j + 1'b1) begin
                if (extracted_am[i] == expected_am[j]) begin
                    expected_am_flag[i] = 1'b1;
                end
            end
        end
        
        // guardar los AM para comparar con la proxima vez
        last_am = extracted_am;

        // comparo para cada lane si el AM recibido es igual al anterior guardado
        for (int i = 0; i < AM_LANES; i = i + 1'b1) begin
            if (has_synced[i] && extracted_am[i] != last_am[i]) begin
                continue_am_error_flag[i] = 1'b1;
            end
        end

        // seteo el lane lock si todas las flags de error cumplen
        for (int i = 0; i < AM_LANES; i = i + 1'b1) begin
            if ( expected_am_flag[i] && !continue_am_error_flag[i] && !gap_error_flag[i] && has_synced[i]) begin
                lane_locked[i] = 1'b1;
                $display("Lane %d locked!\n", i);
            end
        end

        // mux 10 bits para Round Robin
        for(int i = 0; i < TOTAL_ITERATIONS; i = i + 1'b1) begin
            for(int j = 0; j < AM_LANES; j = j + 1'b1) begin
                for(int k = 0; k < TOTAL_CODEWORDS; k = k + 1'b1) begin
                    case(k % 4)
                        2'h0: codeword_a[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                        2'h1: codeword_b[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                        2'h2: codeword_c[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                        2'h3: codeword_d[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                    endcase
                end
            end
        end

        // Extrae las codewords sin FEC
        codeword_a_wo_fec = codeword_a[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];
        codeword_b_wo_fec = codeword_b[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];
        codeword_c_wo_fec = codeword_c[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];
        codeword_d_wo_fec = codeword_d[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];

        // Usa round robin para obtener los datos de entrada
        for(int i = 0; i < CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS; i = i + 1'b1) begin
            tx_scrambled_0[(2* i * ROUND_ROBIN_BITS) + 9  -: ROUND_ROBIN_BITS] = codeword_a_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
            tx_scrambled_0[(2* i * ROUND_ROBIN_BITS) + 19 -: ROUND_ROBIN_BITS] = codeword_b_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
            tx_scrambled_1[(2* i * ROUND_ROBIN_BITS) + 9  -: ROUND_ROBIN_BITS] = codeword_c_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
            tx_scrambled_1[(2* i * ROUND_ROBIN_BITS) + 19 -: ROUND_ROBIN_BITS] = codeword_d_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
        end

        // Elimina los AM
        tx_scrambled_0_wo_am = tx_scrambled_0[BLOCK_W_AM_WIDTH - 1 -: BLOCK_WO_AM_WIDTH]; // Desde el bit 10279 hasta el 9220
        tx_scrambled_1_wo_am = tx_scrambled_1[BLOCK_W_AM_WIDTH - 1 -: BLOCK_WO_AM_WIDTH];
        am_mapped_0          = tx_scrambled_0[AM_MAPPED_WIDTH  - 1  :                 0];
        am_mapped_1          = tx_scrambled_1[AM_MAPPED_WIDTH  - 1  :                 0];

        // Armar un for que agarre tx_scrambled_0_wo_am y 1 y junte los datos de ambos en un arreglo de 
        // varias posiciones de 257 bits cada uno. Los primeros 257 son de tx_scrambled_0_wo_am y van al 
        // primer lugar del arreglo, los próximos son de tx_scrambled_1_wo_am y van al segundo lugar, y así
        // sucesivamente hasta que se llenen todas las posiciones del arreglo. El arreglo es input_decoded
        
        // Si vienen AMs, almaceno 36, sino 40
        if(sync_lanes[0]) begin
            for (int i = 0; i < (NUM_BLOCKS - 4); i = i + 1) begin
                int start_f0 = (i + 5) * BITS_BLOCK - 2;    // Ajustamos posición de inicio, debe correrse 1 bit más
                int start_f1 = (i + 5) * BITS_BLOCK - 2;
                array_tx_scr_0_wo_am[i] = tx_scrambled_0[start_f0 -: BITS_BLOCK];
                array_tx_scr_1_wo_am[i] = tx_scrambled_1[start_f1 -: BITS_BLOCK];
            end
        end
        // Almaceno 40 porque no vienen AMs
        else begin
            for (int i = 0; i < NUM_BLOCKS; i = i + 1) begin
                int start_f0 = (i + 1) * BITS_BLOCK - 2;    // Ajustamos posición de inicio, debe correrse 1 bit más
                int start_f1 = (i + 1) * BITS_BLOCK - 2;
                array_tx_scr_0[i] = tx_scrambled_0[start_f0 -: BITS_BLOCK];
                array_tx_scr_1[i] = tx_scrambled_1[start_f1 -: BITS_BLOCK];
            end
        end
        
        
            //input_decoded[2*i]     = tx_scrambled_0_wo_am[start_f0 -: BITS_BLOCK]; // Extrae de flow_0 en orden descendente
            //input_decoded[2*i + 1] = tx_scrambled_1_wo_am[start_f1 -: BITS_BLOCK]; // Extrae de flow_1 en orden descendente
//            input_decoded[2*i]     = tx_scrambled_0[start_f0 -: BITS_BLOCK]; // Extrae de flow_0 en orden descendente
//            input_decoded[2*i + 1] = tx_scrambled_1[start_f1 -: BITS_BLOCK]; // Extrae de flow_1 en orden descendente
//            array_tx_scr_0[i] = tx_scrambled_0[start_f0 -: BITS_BLOCK];
//            array_tx_scr_1[i] = tx_scrambled_1[start_f0 -: BITS_BLOCK];
        
            // Depuración para verificar la extracción
//            $display("Decoded[%0d] = %h", 2*i, input_decoded[2*i]);
//            $display("Decoded[%0d] = %h", 2*i+1, input_decoded[2*i+1]);
        
        
        // Verifico que sean todos distintos de 0 
        if (!rst) begin
            data_present = 0;  // Inicializamos en 0
        end
        
        for (int i = 0; i < NUM_BLOCKS; i = i + 1) begin
            if(sync_lanes[0]) begin
                if (array_tx_scr_0_wo_am[i] != 0) begin
                    data_present = 1; // Encontramos un dato distinto de 0
                    break; // Salimos del for
                end
            end
            else begin
                if (array_tx_scr_0[i] != 0) begin
                    data_present = 1; // Encontramos un dato distinto de 0
                    break; // Salimos del for
                end
            end
            
        end
        
        // REVISAR ESTE FOR DE ARRIBA PARA MANEJAR BIEN LA FLAG DATA PRESENT CUANDO NO VIENEN AMS
        
    end
        
       

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reiniciar el mapeo de lanes
            mapping_complete <= 0;
            for (int i = 0; i < NUM_BLOCKS; i++) begin
                input_decoded[i] <= 0;
            end
            for (int i = 0; i < AM_LANES; i++) begin
                lane_mapping[i] <= 4'h0;
            end
            // Reiniciar los contadores, los gaps, las banderas de error y las señales de sincronización al reset
            for (int i = 0; i <= AM_LANES - 1; i =  i + 1'b1) begin
                cycle_counter[i] <= {TOTAL_CYCLES_WIDTH {1'b0}};
                cycle_gap    [i] <= {TOTAL_CYCLES_WIDTH {1'b0}};
            end
            gap_error_flag <= {AM_LANES {1'b0}}; // Inicializar todas las banderas de error en 0
            has_synced     <= {AM_LANES {1'b0}};     // Inicializar las señales de sincronización en 0
            continue_am_error_flag <= {AM_LANES {1'b0}}; // Inicializar las banderas de error de AM en 0
            lane_locked <= {AM_LANES {1'b0}}; // Inicializar las banderas de bloqueo de lane en 0
            data_present <= 1'b0; // Sin data presente
            descr_index <= 1'b0; // Index en 0
            descrambler_clk <= 0; // Clock descrambler en 0
            desc_clk_started <= 0; // Pequeño delay en 0

        end else begin
        
            // Si los lanes no están mapeados, comienzo a detectarlos
            if (!mapping_complete) begin
                for (int i = 0; i < AM_LANES; i++) begin
                    for (int j = 0; j < AM_LANES; j++) begin
                        if (extracted_am[i] == expected_am[j]) begin
                            lane_mapping[j] <= i;
                        end
                    end
                end
                mapping_complete <= 1;
            end
            
            // Procesar cada línea de sincronización

            for(int i = 0; i <= AM_LANES - 1; i = i + 1'b1) begin
                if (sync_lanes[i]) begin
                    cycle_gap [i] <= cycle_counter[i];
                    cycle_counter[i] <= {TOTAL_CYCLES_WIDTH{1'b0}};
                    if (has_synced[i] && cycle_counter[i] != TOTAL_CYCLES) begin
                        gap_error_flag[i] <= 1'b1; // Marcar error si el gap es diferente de 8191 y ya hubo una sincronización previa
                    end
                    has_synced[i] <= 1'b1; // Indicar que este lane ya fue sincronizado al menos una vez
                end else begin
                    cycle_counter[i] <= cycle_counter[i] + 1'b1;
                end
            end
            
            
            
            // Preparar las salidas para el descrambler
            
            if (data_present) begin
                if (desc_clk_started) begin
                    descrambler_clk <= ~descrambler_clk; // Toggle cada ciclo de clk
                end else begin
                    desc_clk_started <= 1; // Pequeño delay
                end
            end
            
            // Si vienen AMs, almaceno en registros de 36 posiciones
            if(sync_lanes[0]) begin
                if (data_present) begin // Verifico que hayan datos
                    if (descr_index < (NUM_BLOCKS - 4) && !descrambler_clk && desc_clk_started) begin // descrambler_clk) begin // Verifico no haber pasado los NUM_BLOCKS y que el clock sea justo
                        to_descr_0 <= array_tx_scr_0_wo_am[descr_index];
                        to_descr_1 <= array_tx_scr_1_wo_am[descr_index];
                        // FALTA IMPLEMENTAR LA PARTE PARA ALMACENAR LO QUE ENTRA DEL DESCRAMBLER
                        array_flow_0[descr_index] <= flow_0_des;
                        array_flow_1[descr_index] <= flow_1_des;    // TENER EN CUENTA PARA VOLVER A JUNTAR LOS DATOS, HAY QUE IGNORAR 4 POSICIONES PORQUE SE SUPRIMIERON LOS AMs
                        descr_index <= descr_index + 1;
                    end
                    else if (descr_index >= (NUM_BLOCKS - 4)) begin // Si solo son los NUM_BLOCKS
                        descr_index <= 0;
                    end
                end
                else begin
                    to_descr_0 <= 0;
                    to_descr_1 <= 0;
                    descr_index <= 0;
                end
            end
            
            
            
            // Si no vienen AMs, almaceno en registros de 40 posiciones
            else begin
                if (data_present) begin // Verifico que hayan datos
                    if (descr_index < NUM_BLOCKS) begin //  && descrambler_clk) begin // Verifico no haber pasado los NUM_BLOCKS y que el clock sea justo
                        to_descr_0 <= array_tx_scr_0[descr_index];
                        to_descr_1 <= array_tx_scr_1[descr_index];
                        // FALTA IMPLEMENTAR LA PARTE PARA ALMACENAR LO QUE ENTRA DEL DESCRAMBLER
                        array_flow_0[descr_index] <= flow_0_des;
                        array_flow_1[descr_index] <= flow_1_des;
                        descr_index <= descr_index + 1;
                    end
                    else if (descr_index >= NUM_BLOCKS) begin // Si solo son los NUM_BLOCKS
                        descr_index <= 0;
                    end
                end
                else begin
                    to_descr_0 <= 0;
                    to_descr_1 <= 0;
                    descr_index <= 0;
                end
            end
            
            
            // REVISAR QUE EL VALID DEL DESCRAMBLER ME INDICA QUE EL NUEVO DATO YA ESTÁ LISTO
            
            // Hay que revisar que no traigan AMs, los AMs no vienen scrambleados

        end
    end



endmodule