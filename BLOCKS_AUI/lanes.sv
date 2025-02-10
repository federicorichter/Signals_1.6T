module lanes #(
    parameter BITS_BLOCK = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE = 10, 
    parameter BLOCKS_REPETITION = 8192,
    parameter LANE_WIDTH = 1360,
    parameter AM_MAPPED_WIDTH = 10280, // AM mapped signal width -> 40 blocks,
    parameter WIDTH_WORD_RS = 5440
    //parameter LANE_WIDTH = 1360
)
(
    input clk,
    input rst,

    input i_valid,

    input logic [WIDTH_WORD_RS-1:0] word_A,
    input logic [WIDTH_WORD_RS-1:0] word_B,
    input logic [WIDTH_WORD_RS-1:0] word_C,
    input logic [WIDTH_WORD_RS-1:0] word_D,

    output logic [LANE_WIDTH-1:0] o_lane_0,
    output logic sync_lane_0,
    output logic [LANE_WIDTH-1:0] o_lane_1,
    output logic sync_lane_1,
    output logic [LANE_WIDTH-1:0] o_lane_2,
    output logic sync_lane_2,
    output logic [LANE_WIDTH-1:0] o_lane_3,
    output logic sync_lane_3,
    output logic [LANE_WIDTH-1:0] o_lane_4,
    output logic sync_lane_4,
    output logic [LANE_WIDTH-1:0] o_lane_5,
    output logic sync_lane_5,
    output logic [LANE_WIDTH-1:0] o_lane_6,
    output logic sync_lane_6,
    output logic [LANE_WIDTH-1:0] o_lane_7,
    output logic sync_lane_7,
    output logic [LANE_WIDTH-1:0] o_lane_8,
    output logic sync_lane_8,
    output logic [LANE_WIDTH-1:0] o_lane_9,
    output logic sync_lane_9,
    output logic [LANE_WIDTH-1:0] o_lane_10,
    output logic sync_lane_10,
    output logic [LANE_WIDTH-1:0] o_lane_11,
    output logic sync_lane_11,
    output logic [LANE_WIDTH-1:0] o_lane_12,
    output logic sync_lane_12,
    output logic [LANE_WIDTH-1:0] o_lane_13,
    output logic sync_lane_13,
    output logic [LANE_WIDTH-1:0] o_lane_14,
    output logic sync_lane_14,
    output logic [LANE_WIDTH-1:0] o_lane_15,
    output logic sync_lane_15
);

//reg [WIDTH_WORD_RS-1:0] word_A, word_B, word_C, word_D;

always_ff @(posedge clk) begin
    if(rst) begin
        o_lane_0 <= {LANE_WIDTH{1'd0}};
        o_lane_1 <= {LANE_WIDTH{1'd0}};
        o_lane_2 <= {LANE_WIDTH{1'd0}};
        o_lane_3 <= {LANE_WIDTH{1'd0}};
        o_lane_4 <= {LANE_WIDTH{1'd0}};
        o_lane_5 <= {LANE_WIDTH{1'd0}};
        o_lane_6 <= {LANE_WIDTH{1'd0}};
        o_lane_7 <= {LANE_WIDTH{1'd0}};
        o_lane_8 <= {LANE_WIDTH{1'd0}};
        o_lane_9 <= {LANE_WIDTH{1'd0}};
        o_lane_10 <= {LANE_WIDTH{1'd0}};
        o_lane_11 <= {LANE_WIDTH{1'd0}};
        o_lane_12 <= {LANE_WIDTH{1'd0}};
        o_lane_13 <= {LANE_WIDTH{1'd0}};
        o_lane_14 <= {LANE_WIDTH{1'd0}};
        o_lane_15 <= {LANE_WIDTH{1'd0}};
    end 
    else if(i_valid) begin
        for(int k = 0;k <= 33; k++) begin
            //for(j = 0;j <= 15;j++)begin
            o_lane_0[(40*k) +: 10] <=word_A[((544 - (16*k)) * 10)-1 -: 10];
            o_lane_0[(40*k) + 10 +: 10] <=word_B[((544 - (16*k)) * 10) -1 -: 10];
            o_lane_0[(40*k) + 20 +: 10] <=word_C[((544 - (16*k)) * 10) -1 -: 10];
            o_lane_0[(40*k) + 30 +: 10] <=word_D[((544 - (16*k)) * 10) -1 -: 10];

            o_lane_1[(40*k) +: 10]  <=word_A[(544-(16*k)- 1)*10 - 1-:10];
            o_lane_1[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 1)*10 - 1-:10];
            o_lane_1[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 1)*10 - 1-:10];
            o_lane_1[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 1)*10 - 1-:10];

            o_lane_2[(40*k) +: 10]  <=word_A[(544-(16*k)- 2)*10 - 1-:10];
            o_lane_2[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 2)*10 - 1-:10];
            o_lane_2[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 2)*10 - 1-:10];
            o_lane_2[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 2)*10 - 1-:10];

            o_lane_3[(40*k) +: 10]  <=word_A[(544-(16*k)- 3)*10 - 1-:10];
            o_lane_3[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 3)*10 - 1-:10];
            o_lane_3[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 3)*10 - 1-:10];
            o_lane_3[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 3)*10 - 1-:10];

            o_lane_4[(40*k) +: 10]  <=word_A[(544-(16*k)- 4)*10 - 1-:10];
            o_lane_4[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 4)*10 - 1-:10];
            o_lane_4[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 4)*10 - 1-:10];
            o_lane_4[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 4)*10 - 1-:10];

            o_lane_5[(40*k) +: 10]  <=word_A[(544-(16*k)- 5)*10 - 1-:10];
            o_lane_5[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 5)*10 - 1-:10];
            o_lane_5[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 5)*10 - 1-:10];
            o_lane_5[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 5)*10 - 1-:10];

            o_lane_6[(40*k) +: 10]  <=word_A[(544-(16*k)- 6)*10 - 1-:10];
            o_lane_6[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 6)*10 - 1-:10];
            o_lane_6[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 6)*10 - 1-:10];
            o_lane_6[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 6)*10 - 1-:10];

            o_lane_7[(40*k) +: 10]  <=word_A[(544-(16*k)- 7)*10 - 1-:10];
            o_lane_7[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 7)*10 - 1-:10];
            o_lane_7[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 7)*10 - 1-:10];
            o_lane_7[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 7)*10 - 1-:10];

            o_lane_8[(40*k) +: 10]  <=word_A[(544-(16*k)- 8)*10 - 1-:10];
            o_lane_8[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 8)*10 - 1-:10];
            o_lane_8[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 8)*10 - 1-:10];
            o_lane_8[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 8)*10 - 1-:10];

            o_lane_9[(40*k) +: 10]  <=word_A[(544-(16*k)- 9)*10 - 1-:10];
            o_lane_9[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 9)*10 - 1-:10];
            o_lane_9[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 9)*10 - 1-:10];
            o_lane_9[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 9)*10 - 1-:10];

            o_lane_10[(40*k) +: 10]  <=word_A[(544-(16*k)- 10)*10 - 1-:10];
            o_lane_10[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 10)*10 - 1-:10];
            o_lane_10[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 10)*10 - 1-:10];
            o_lane_10[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 10)*10 - 1-:10];

            o_lane_11[(40*k) +: 10]  <=word_A[(544-(16*k)- 11)*10 - 1-:10];
            o_lane_11[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 11)*10 - 1-:10];
            o_lane_11[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 11)*10 - 1-:10];
            o_lane_11[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 11)*10 - 1-:10];

            o_lane_12[(40*k) +: 10]  <=word_A[(544-(16*k)- 12)*10 - 1-:10];
            o_lane_12[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 12)*10 - 1-:10];
            o_lane_12[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 12)*10 - 1-:10];
            o_lane_12[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 12)*10 - 1-:10];

            o_lane_13[(40*k) +: 10]  <=word_A[(544-(16*k)- 13)*10 - 1-:10];
            o_lane_13[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 13)*10 - 1-:10];
            o_lane_13[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 13)*10 - 1-:10];
            o_lane_13[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 13)*10 - 1-:10];

            o_lane_14[(40*k) +: 10]  <=word_A[(544-(16*k)- 14)*10 - 1-:10];
            o_lane_14[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 14)*10 - 1-:10];
            o_lane_14[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 14)*10 - 1-:10];
            o_lane_14[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 14)*10 - 1-:10];

            o_lane_15[(40*k) +: 10]  <=word_A[(544-(16*k)- 15)*10 - 1-:10];
            o_lane_15[(40*k) + 10 +: 10] <=word_B[(544-(16*k)- 15)*10 - 1-:10];
            o_lane_15[(40*k) + 20 +: 10] <=word_C[(544-(16*k)- 15)*10 - 1-:10];
            o_lane_15[(40*k) + 30 +: 10] <=word_D[(544-(16*k)- 15)*10 - 1-:10];
            
        end

        end
    end

    assign sync_lane_0 = i_valid;
    assign sync_lane_1 = i_valid;
    assign sync_lane_2 = i_valid;
    assign sync_lane_3 = i_valid;
    assign sync_lane_4 = i_valid;
    assign sync_lane_5 = i_valid;
    assign sync_lane_6 = i_valid;
    assign sync_lane_7 = i_valid;
    assign sync_lane_8 = i_valid;
    assign sync_lane_9 = i_valid;
    assign sync_lane_10 = i_valid;
    assign sync_lane_11 = i_valid;
    assign sync_lane_12 = i_valid;
    assign sync_lane_13 = i_valid;
    assign sync_lane_14 = i_valid;
    assign sync_lane_15 = i_valid;

endmodule