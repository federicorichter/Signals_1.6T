module block_generator (
    input  wire        clk,
    input  wire        rst,
    output reg [256:0] data_out,  // Salida de 257 bits
    output reg         valid_gen  // Señal de validación del bloque
);
    reg [256:0] lfsr_state; // Estado interno del generador de bloques

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr_state <= 257'h1;  // Estado inicial (semilla)
            valid_gen <= 0;
        end else begin
            integer i;
            reg feedback;
            reg [256:0] next_state;

            next_state = lfsr_state; // Mantener estado actual

            for (i = 0; i < 257; i = i + 1) begin
                feedback = next_state[256] ^ next_state[255] ^ next_state[253] ^ next_state[251]; 
                next_state = {next_state[255:0], feedback}; // Desplazamiento y realimentación
            end

            data_out <= next_state;  // Salida del nuevo bloque generado
            lfsr_state <= next_state; // Actualizar estado del generador
            valid_gen <= 1;  // Activar señal de validación por 1 ciclo
        end
    end
endmodule
