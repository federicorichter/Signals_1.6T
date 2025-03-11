module scrambler (
    input  wire         clk,
    input  wire         rst,
    input  wire [256:0] data_in,   // Entrada de 257 bits
    output reg  [256:0] data_out,  // Salida de 257 bits scrambleados
    output reg          valid      // Señal de validación
);
    reg [57:0] state; // Estado interno del scrambler

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 58'h3FFFFFFFFFFFFFF; // Estado inicial recomendado
            data_out <= 0;
            valid <= 0;
        end else begin
            integer i;
            reg [256:0] scrambled;
            reg [57:0] next_state;
            reg feedback;

            next_state = state; // Mantener el estado actual para actualización
            scrambled = 0;       // Inicializar

            for (i = 0; i < 257; i = i + 1) begin
                feedback = next_state[57] ^ next_state[38]; // X^58 + X^39 + 1
                scrambled[i] = data_in[i] ^ feedback;       // Scrambling bit a bit
                next_state = {next_state[56:0], feedback};  // Shift del estado
            end

            data_out <= scrambled; // Salida del bloque scrambleado
            state <= next_state;   // Actualizar el estado del scrambler
            valid <= 1;            // Indicar que los datos están listos por un ciclo
        end
    end
endmodule