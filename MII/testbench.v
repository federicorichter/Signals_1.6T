`timescale 1ns / 1ps
module tb_checker;

reg clk;
reg rst_n;
reg [63:0] data_in;
reg [7:0] ctrl_in;

mii_checker_sm uut(
    .clk(clk),
    .rst_n(rst_n),
    .ctrl_in(ctrl_in),
    .data_in(data_in)
);

integer j;

initial begin
    clk = 0;
    forever #50 clk = ~clk;  // 10 MHz clock
end

initial begin
    rst_n = 1;
    #100;
    rst_n = 0;
    #100;
    rst_n = 1;

    for(j = 0; j < 10;j=j+1)begin
        @(posedge clk);
        data_in = 64'h0707070707070707;
        ctrl_in = 8'hFF;
    end
    //Start packet
    @(posedge clk);
    data_in = 64'h55555555555555FB;
    ctrl_in = 8'h01;
    //Start data

    for(j = 0; j < 20;j=j+1)begin
        @(posedge clk);
        data_in = 64'h1111111111111111;
        ctrl_in = 8'h00;
    end
    @(posedge clk);
    data_in = 64'h07070707FD000000;
    ctrl_in = 8'hF8;
    @(posedge clk);
    @(posedge clk);
    $finish;
end

endmodule