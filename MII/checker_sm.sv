module mii_checker_sm #(parameter DATA_WIDTH = 64) (
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH/8-1:0] ctrl_in,  // Control signals per byte
    input logic [DATA_WIDTH-1:0] data_in     // Data bus
);

localparam [7:0]
    MII_IDLE  = 8'h07,
    MII_START = 8'hfb,
    MII_TERM  = 8'hfd,
    MII_ERROR = 8'hfe;

localparam [1:0]
    STATE_IDLE    = 2'd0,
    STATE_PAYLOAD = 2'd1,
    STATE_LAST    = 2'd2;

reg [1:0] state, state_next;
integer data_count, data_count_next, i;

// Temporary array to hold each byte of data_in
logic [7:0] data_bytes [7:0];

always_ff @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin
        state <= STATE_IDLE;
        data_count <= 0;
    end
    else begin
        state <= state_next;
        data_count <= data_count_next;
    end
end

// Populate data_bytes array with each byte of data_in
always_comb begin
    for (i = 0; i < 8; i++) begin
        data_bytes[i] = data_in[i*8 +: 8];
    end
end

always_comb begin 
    state_next = state;  // Default to current state
    data_count_next = data_count;

    case (state)
        STATE_IDLE: begin
            data_count_next = 0;
            if (ctrl_in[0] & (data_bytes[0] == MII_START)) begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_PAYLOAD: begin
            for (i = 0; i < 8; i++) begin
                if (ctrl_in[i] && data_bytes[i] == MII_TERM) begin
                    state_next = STATE_IDLE;
                end
                else begin
                    data_count_next = data_count + 1;
                end
            end
        end
        STATE_LAST: begin
            state_next = STATE_IDLE;
        end
        default: begin
            state_next = STATE_IDLE;
        end
    endcase
end

endmodule
