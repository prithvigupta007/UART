`timescale 1ns/1ps

module uart_tx
(
    input wire clk,
    input wire rst,
    input wire tx_tick, //baud tick(1 pulse per bit)

    //tx interface
    input wire tx_start, //when high for one clk cycle transmission begins
    input wire [7:0]tx_data, //8 bit data

    output reg tx_serial, //initially high(idle pin)
    output reg tx_busy, //high while transmitting
    output reg tx_done 
);
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    //internal registers
    reg [1:0] state;
    reg [2:0] bit_index;
    reg [7:0] tx_shift;

    //main fsm for tx
    always @(posedge clk)
    begin

        if(rst)
        begin
            state      <= IDLE;
            bit_index  <= 3'd0;
            tx_shift   <= 8'd0;
	    tx_serial  <= 1'b1;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;
        end
        else
        begin
	    //default
            tx_done <= 1'b0;

            case(state)
	    IDLE:
            begin
                tx_serial <= 1'b1;
                tx_busy   <= 1'b0;
                bit_index <= 3'd0;

                if(tx_start)
                begin
                    tx_shift <= tx_data;
                    tx_busy  <= 1'b1;
                    state    <= START;
                end
            end

            START:
            begin
                tx_serial <= 1'b0;

                if(tx_tick)
                begin
                    state <= DATA;
                end
            end

            DATA:
            begin
                tx_serial <= tx_shift[bit_index];

                if(tx_tick)
                begin
                    if(bit_index == 3'd7)
                    begin
                        bit_index <= 3'd0;
                        state <= STOP;
                    end
                    else
                    begin
                        bit_index <= bit_index + 1'b1;
                    end
                end
            end

            STOP:
            begin
                tx_serial <= 1'b1;

                if(tx_tick)
                begin
                    tx_busy <= 1'b0;
                    tx_done <= 1'b1;
                    state   <= IDLE;
                end
            end

            default:
            begin
                state <= IDLE;
            end

            endcase

        end

    end

endmodule
