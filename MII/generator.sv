module gmii_generator 
#(
    parameter DATA_WIDTH = 64, 
    parameter int DATA_CHAR_PROBABILITY = 80
)
(
    input logic clk,
    input logic rst_n,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic [DATA_WIDTH/8-1:0] ctrl_out
);
    // Define constants for data and control characters
    localparam logic [7:0] DATA_CHAR_PATTERN = 8'hAA;
    localparam logic [7:0] CTRL_CHAR_PATTERN = 8'h1C; 

    int rand_num;

    // Always block for generating data and control characters
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= '0;
            ctrl_out <= '0;
        end else begin
            for (int i = 0; i < DATA_WIDTH/8; i++) begin
                rand_num = $urandom_range(0, 99);
                if (rand_num < DATA_CHAR_PROBABILITY) begin
                    // data character
                    data_out[i*8 +: 8] <= DATA_CHAR_PATTERN;
                    ctrl_out[i] <= 1'b0;
                end else begin
                    //  control character
                    data_out[i*8 +: 8] <= CTRL_CHAR_PATTERN;
                    ctrl_out[i] <= 1'b1; 
                end
            end
        end
    end
endmodule
