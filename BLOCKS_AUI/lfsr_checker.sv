module lfsr_257_checker #(
    parameter BLOCK_SIZE = 257,
    parameter LOCK_THRESHOLD = 8,
    parameter UNLOCK_THRESHOLD = 3
)(
    input  logic                   rst,
    input  logic                   i_valid,
    input  logic [BLOCK_SIZE-1:0] i_data,  // Bloque entrante del generador
    output logic                  o_lock   // Salida de estado de sincronización
);

    // FSM states
    typedef enum logic {UNLOCKED, LOCKED} state_t;
    state_t state, next_state;

    // Contadores de aciertos y errores
    logic [$clog2(LOCK_THRESHOLD+1)-1:0]   valid_count, valid_count_next;
    logic [$clog2(UNLOCK_THRESHOLD+1)-1:0] invalid_count, invalid_count_next;

    // Señal de resync
    logic resync;

    // Estado interno del LFSR local
    logic [BLOCK_SIZE-1:0] lfsr_local;
    logic [BLOCK_SIZE-1:0] lfsr_next;
    logic feedback;

    // ------------------------------
    // LFSR next-state calculation
    // ------------------------------
    always_comb begin
        lfsr_next = lfsr_local;
        for (int i = 0; i < BLOCK_SIZE; i++) begin
            feedback = lfsr_next[256] ^ lfsr_next[255] ^ lfsr_next[253] ^ lfsr_next[251];
            lfsr_next = {lfsr_next[255:0], feedback};
        end
    end

    // ------------------------------
    // FSM combinacional
    // ------------------------------
    always_comb begin
        next_state         = state;
        valid_count_next   = valid_count;
        invalid_count_next = invalid_count;
        resync             = 0;

        case (state)
            UNLOCKED: begin
                if (i_data == lfsr_next) begin
                    valid_count_next = valid_count + 1;
                    if (valid_count + 1 >= LOCK_THRESHOLD) begin
                        next_state = LOCKED;
                        valid_count_next = 0;
                    end
                end else begin
                    resync = 1;  // disparar resincronización
                    valid_count_next = 0;
                end
                invalid_count_next = 0;
            end

            LOCKED: begin
                if (i_data == lfsr_next) begin
                    invalid_count_next = 0;
                end else begin
                    invalid_count_next = invalid_count + 1;
                    if (invalid_count + 1 >= UNLOCK_THRESHOLD) begin
                        next_state = UNLOCKED;
                        invalid_count_next = 0;
                        resync = 1;  // resincronizar en próximo ciclo
                    end
                end
                valid_count_next = 0;
            end
        endcase
    end

    // ------------------------------
    // Estado FSM y contadores
    // ------------------------------
    always_ff @(posedge i_valid or posedge rst) begin
        if (rst) begin
            state          <= UNLOCKED;
            valid_count    <= 0;
            invalid_count  <= 0;
        end else begin
            state          <= next_state;
            valid_count    <= valid_count_next;
            invalid_count  <= invalid_count_next;
        end
    end

    // ------------------------------
    // LFSR update
    // ------------------------------
    always_ff @(posedge i_valid or posedge rst) begin
        if (rst) begin
            lfsr_local <= {{(BLOCK_SIZE-1){1'b0}}, 1'b1}; // Semilla = 257'h1
        end else if (resync) begin
            lfsr_local <= i_data; // resincronización con entrada
        end else begin
            lfsr_local <= lfsr_next;
        end
    end

    // ------------------------------
    // Output
    // ------------------------------
    assign o_lock = (state == LOCKED);

endmodule