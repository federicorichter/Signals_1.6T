module aui_generator 
#(
    parameter DATA_WIDTH = 64, 
    parameter NUMBER_LANES = 16
)
(
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH-1:0]i_data,
    output logic [DATA_WIDTH-1:0] tx_lane[NUMBER_LANES-1:0]  // 16 lanes, each 64-bit wide
);


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUMBER_LANES; i++) begin
                tx_lane[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            for (int i = 0; i < NUMBER_LANES; i++) begin                
                tx_lane[i] <= i_data; // Broadcast i_data to all lanes
            end
        end
    end

endmodule
