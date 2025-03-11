module block_generator #(
        parameter BLOCK_SIZE = 257
    )
    (
    input  wire        clk,
    input  wire        rst,
    input  logic      [1:0] i_config, //Determina si se generan datos random, patron fijo o secuencia de lfsr
    output reg [BLOCK_SIZE-1:0] data_out,  // Salida de 257 bits
    output reg         valid_gen  // Señal de validación del bloque
);
    reg [BLOCK_SIZE-1:0] lfsr_state; // Estado interno del generador de bloques

    localparam [1:0] configuration_sequence = 2'b00;
    localparam [1:0] configuration_random = 2'b01;
    localparam [1:0] configuration_fixed = 2'b10;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr_state <= {BLOCK_SIZE, 1'h1};  // Estado inicial (semilla)
            valid_gen <= 0;
            data_out <= {BLOCK_SIZE{1'h0}};
        end else begin
            integer i;
            reg feedback;
            reg [BLOCK_SIZE-1:0] next_state;

            next_state = lfsr_state; // Mantener estado actual

            for (i = 0; i < BLOCK_SIZE; i = i + 1) begin
                feedback = next_state[BLOCK_SIZE-1] ^ next_state[255] ^ next_state[253] ^ next_state[251]; 
                next_state = {next_state[255:0], feedback}; // Desplazamiento y realimentación
            end

            //data_out <= next_state;  // Salida del nuevo bloque generado
            lfsr_state <= next_state; // Actualizar estado del generador
            valid_gen <= 1;  // Activar señal de validación por 1 ciclo

            if(i_config == configuration_sequence) begin
                data_out <= next_state;
            end 
            else if (i_config == configuration_random) begin
                data_out <=  {$random} % 150000;
            end
            else if (i_config == configuration_fixed) begin
                data_out <= {BLOCK_SIZE{1'h1}};
            end
        end
    end
endmodule
