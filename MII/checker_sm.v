module mii_checker_sm #(parameter DATA_WIDTH = 64) (
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH/8-1:0] ctrl_in,  // Control signals per byte
    input wire [DATA_WIDTH-1:0] data_in     // Data bus
);

localparam [7:0]
    MII_IDLE = 8'h07,
    MII_START = 8'hfb,
    MII_TERM = 8'hfd,
    MII_ERROR = 8'hfe;

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PAYLOAD = 2'd1,
    STATE_LAST = 2'd2;

reg [1:0]state, state_next;
integer data_count, data_count_next, i;

always @( posedge clk ) begin 
    if(!rst_n) begin
        state <= STATE_IDLE;
        data_count <= 0;
    end
    else begin
        state <= state_next;
        data_count <= data_count_next;
    end
end

always @(*) begin
    //state_next = STATE_IDLE;
    case (state)
        STATE_IDLE: begin
            data_count_next = 0;
            if(ctrl_in[0] & (data_in[7:0] == MII_START)) begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_PAYLOAD: begin
            data_count_next = data_count;
            for(i = 0;i < 8;i = i + 1)begin
                if(ctrl_in[i] && data_in[i*8 +: 8] == MII_TERM)begin
                    state_next = STATE_LAST;
                end
                else begin
                    data_count_next = data_count_next + 1;
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