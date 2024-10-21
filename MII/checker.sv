module gmii_checker #(parameter DATA_WIDTH = 64) (
    input logic clk,
    input logic rst_n,
    input logic start_monitoring,
    input logic [DATA_WIDTH/8-1:0] ctrl_in,  // Control signals per byte
    input logic [DATA_WIDTH-1:0] data_in     // Data bus
);
    // State definitions
    typedef enum logic [1:0] {
        WAITING = 2'b00,
        MONITORING = 2'b01
    } state_t;

    state_t current_state, next_state;

    // Counters for control and data characters
    int ctrl_char_count;
    int data_char_count;

    int temp_ctrl_count = 0;
    int temp_data_count = 0;

    // State transition and counting logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= WAITING;
            ctrl_char_count <= 0;
            data_char_count <= 0;
        end else begin
            temp_ctrl_count = 0;
            temp_data_count = 0;
            current_state <= next_state;
            // Monitor and count characters in MONITORING state
            if (current_state == MONITORING) begin
                for (int i = 0; i < DATA_WIDTH/8; i++) begin

                    // Check if the character is control or data
                    if (ctrl_in[i] == 1'b0) begin
                        // Data character detected
                        temp_data_count += 1;
                    end else begin
                        // Control character detected
                        temp_ctrl_count += 1;
                    end
                end
                
                // Update the counters
                ctrl_char_count <= ctrl_char_count + temp_ctrl_count;
                data_char_count <= data_char_count + temp_data_count;
            end
        end
    end

    // State transition logic
    always_comb begin
        case (current_state)
            WAITING: begin
                // Transition logic from WAITING to MONITORING
                if (start_monitoring == 1'b1) begin  
                    next_state = MONITORING;
                end else begin
                    next_state = WAITING;
                end
            end
            MONITORING: begin
                // Transition logic from MONITORING back to WAITING or other states
                if (start_monitoring == 1'b0) begin
                    next_state = WAITING;
                end else begin
                    next_state = MONITORING;
                end
            end
            default: next_state = WAITING;
        endcase
    end

    always @(negedge start_monitoring) begin
        $display("Data Characters Counted: %0d", data_char_count);
        $display("Control Characters Counted: %0d", ctrl_char_count);
    end

endmodule
