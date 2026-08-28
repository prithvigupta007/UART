`timescale 1ns/1ps

module baud_gen #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)
(
    input wire clk,
    input wire rst,
    output reg tx_tick,
    output reg rx_tick
);

    localparam integer TX_DIV = CLK_FREQ/BAUD_RATE; //50Mhz/115200 => 434
    localparam integer RX_DIV = CLK_FREQ/(BAUD_RATE*16); //434/16 => 27

    reg [15:0]tx_count;
    reg [15:0]rx_count;

    always @(posedge clk)
    begin

        if(rst)
        begin
            tx_count <= 0;
            rx_count <= 0;

            tx_tick <= 0;
            rx_tick <= 0;
        end

        else
        begin

	    //default
            tx_tick <= 1'b0;
            rx_tick <= 1'b0;

	    //tx tick
            if(tx_count == TX_DIV-1)
            begin
                tx_count <= 0;
                tx_tick <= 1'b1;
            end
            else
            begin
                tx_count <= tx_count + 1;
            end

  	    //rx tick
            if(rx_count == RX_DIV-1)
            begin
                rx_count <= 0;
                rx_tick <= 1'b1;
            end
            else
            begin
                rx_count <= rx_count + 1;
            end

        end

    end

endmodule
