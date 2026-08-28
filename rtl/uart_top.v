`timescale 1ns/1ps

module uart_top
#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)
(
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0]tx_data,
    output wire tx_busy,
    output wire tx_done,
    output wire [7:0]rx_data,
    output wire rx_done
);
    //internal signals
    wire serial_line;
    wire tx_tick;
    wire rx_tick;

    baud_gen #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE))BAUD_GEN(.clk(clk),.rst(rst),.tx_tick(tx_tick),.rx_tick(rx_tick));
    uart_tx TX(.clk(clk),.rst(rst),.tx_tick(tx_tick),.tx_start(tx_start),.tx_data(tx_data),.tx_serial(serial_line),.tx_busy(tx_busy),.tx_done(tx_done));
    uart_rx RX(.clk(clk),.rst(rst),.rx_tick(rx_tick),.rx_serial(serial_line),.rx_data(rx_data),.rx_done(rx_done));
endmodule
