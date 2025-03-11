module lane_shuffler #(
    parameter NUM_LANES = 16,
    parameter LANE_WIDTH = 1360
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_shuffle_enable,
    input wire [LANE_WIDTH-1:0] i_data [NUM_LANES-1:0],
    output reg [LANE_WIDTH-1:0] o_data [NUM_LANES-1:0]
);

    reg [3:0] shuffle_map [NUM_LANES-1:0]; // Almacena la permutación de lanes
    reg [NUM_LANES-1:0] assigned; // Marca qué lanes ya fueron asignadas
    integer i, j, rand_val;

    // Generar una permutación aleatoria en cada reset
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            assigned = 0;
            for (i = 0; i < NUM_LANES; i = i + 1) begin
                do begin
                    rand_val = $urandom % NUM_LANES; // Generar índice aleatorio
                end while (assigned[rand_val]); // Repetir si ya fue asignado
                
                shuffle_map[i] = rand_val; // Asignar la lane
                assigned[rand_val] = 1; // Marcar como usada
            end
        end
    end

    // Aplicar la permutación solo si shuffle_enable está activo
    always @(*) begin
        for (j = 0; j < NUM_LANES; j = j + 1) begin
            if (i_shuffle_enable) begin
                o_data[j] = i_data[shuffle_map[j]];
            end else begin
                o_data[j] = i_data[j]; // Sin cambios si shuffle_enable = 0
            end
        end
    end

endmodule
