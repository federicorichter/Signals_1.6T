module prbs9_generator (
    input logic clk,
    input logic rst_n,
    output logic [8:0] prbs_out
);
    logic [8:0] prbs_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            prbs_reg <= 9'h1FF; // Initial seed
        else
            prbs_reg <= {prbs_reg[7:0], prbs_reg[8] ^ prbs_reg[4]};
    end

    assign prbs_out = prbs_reg;
endmodule
