`timescale 1ns/1ps

module uart_tb;

parameter CLK_FREQ  = 50000000;
parameter BAUD_RATE = 1000000;

reg clk;
reg rst;
reg tx_start;
reg [7:0]tx_data;

wire tx_busy;
wire tx_done;
wire [7:0]rx_data;
wire rx_done;

uart_top #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
)
DUT
(
    .clk(clk),
    .rst(rst),

    .tx_start(tx_start),
    .tx_data(tx_data),

    .tx_busy(tx_busy),
    .tx_done(tx_done),

    .rx_data(rx_data),
    .rx_done(rx_done)
);

initial
begin
    clk = 0;
    forever #10 clk = ~clk;     //defining clock 20ns
end

task send_byte; //send task

input [7:0] data;

begin
    //wait until transmitter is idle
    @(posedge clk);
    while(tx_busy)
        @(posedge clk);

    tx_data  = data;
    tx_start = 1'b1;

    @(posedge clk);
    tx_start = 1'b0;

    //wait until receiver gets byte
    wait(rx_done);

    if(rx_data == data)
        $display("[%0t] PASS : Sent = %h Received = %h",
                 $time, data, rx_data);
    else
        $display("[%0t] FAIL : Sent = %h Received = %h",
                 $time, data, rx_data);

    //small gap before next transmission
    repeat(20) @(posedge clk);

end

endtask

initial
begin

    rst = 1;
    tx_start = 0;
    tx_data = 8'h00;

    repeat(10) @(posedge clk);
    rst = 0;

   
    send_byte(8'hA5);
    send_byte(8'h55);
    send_byte(8'hFF);

    $display("--------------------------------");
    $display("Simulation Finished");
    $display("--------------------------------");

    #1000;
    $finish;

end

endmodule
