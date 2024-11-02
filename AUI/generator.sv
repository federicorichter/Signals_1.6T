module aui_generator 
#(
    parameter DATA_WIDTH = 64, 
    parameter NUMBER_LANES = 16
)
(
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH-1:0]i_data,
    output logic [DATA_WIDTH-1:0]tx_lane_1,
    output logic [DATA_WIDTH-1:0]tx_lane_2,
    output logic [DATA_WIDTH-1:0]tx_lane_3,
    output logic [DATA_WIDTH-1:0]tx_lane_4,
    output logic [DATA_WIDTH-1:0]tx_lane_5,
    output logic [DATA_WIDTH-1:0]tx_lane_6,
    output logic [DATA_WIDTH-1:0]tx_lane_7,
    output logic [DATA_WIDTH-1:0]tx_lane_8
);
    localparam MAX_INSERTION = 20;
    //localparam AM_LANE1 = 128'h9A4A26B665B5D9D9FE8E0C260171F3;
/*    localparam AM_LANE0 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE1 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE2 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE3 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE4 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE5 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE6 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE7 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE8 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE9 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE10 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE11 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE12 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE13 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE14 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB;
    localparam AM_LANE15 = 120'hAAAAAAAAAAAAAAAABBBBBBBBBBBBBB:*/

    logic [7:0]padding_lane1;

    int counter_insertion = 0;
    logic am_first_half;


    always_ff @(posedge clk or negedge rst_n) begin
        counter_insertion = counter_insertion + 1;
        if (!rst_n) begin
            am_first_half <= 0;
            counter_insertion <= 0;
            padding_lane1 <= 8'h55;
            tx_lane_1 <= {DATA_WIDTH{1'b0}}; // Broadcast i_data to all lanes
            tx_lane_2 <= {DATA_WIDTH{1'b0}};
            tx_lane_3 <= {DATA_WIDTH{1'b0}};
            tx_lane_4 <= {DATA_WIDTH{1'b0}};
            tx_lane_5 <= {DATA_WIDTH{1'b0}};
            tx_lane_6 <= {DATA_WIDTH{1'b0}};
            tx_lane_7 <= {DATA_WIDTH{1'b0}};
            tx_lane_8 <= {DATA_WIDTH{1'b0}};
        end else begin
            if(counter_insertion >= MAX_INSERTION) begin
                //tx_lane_1 <= i_data; // Broadcast i_data to all lanes
                if(am_first_half == 1)begin
                    tx_lane_1 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_2 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_3 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_4 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_5 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_6 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_7 <= AM_LANE1[DATA_WIDTH-1:0];
                    tx_lane_8 <= AM_LANE1[DATA_WIDTH-1:0];
                    am_first_half <= 0;
                    counter_insertion <= 0;
                end else begin
                    tx_lane_1 <= {AM_LANE1 [(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_2 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_3 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_4 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_5 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_6 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_7 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    tx_lane_8 <= {AM_LANE1[(DATA_WIDTH*2)-1:DATA_WIDTH], padding_lane1};
                    am_first_half <= 1;
                end
            end else begin
                for (int i = 0; i < NUMBER_LANES; i++) begin                
                    tx_lane_1 <= i_data; // Broadcast i_data to all lanes
                    tx_lane_2 <= i_data;
                    tx_lane_3 <= i_data;
                    tx_lane_4 <= i_data;
                    tx_lane_5 <= i_data;
                    tx_lane_6 <= i_data;
                    tx_lane_7 <= i_data;
                    tx_lane_8 <= i_data;
                end
            end
        end
    end

endmodule
