`timescale 1ns/1ps

module uart_rx
(
    input wire clk,
    input wire rst,
    input wire rx_tick, //16x baud tick
    input wire rx_serial, //serial input
    output reg [7:0]rx_data, //parallel output
    output reg rx_done
);
    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;

    //internal registers
    reg [2:0] state;
    reg [3:0] sample_count;
    reg [2:0] bit_index;
    reg [7:0] rx_shift;

    //synchronizers
    reg rx_sync1;
    reg rx_sync2;

    always @(posedge clk)
    begin
        if(rst)
        begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end
        else
        begin
            rx_sync1 <= rx_serial;
            rx_sync2 <= rx_sync1;
        end
    end

    //main fsm
    always @(posedge clk)
    begin

        if(rst)
        begin
            state        <= IDLE;
            sample_count <= 4'd0;
            bit_index    <= 3'd0;
            rx_shift     <= 8'd0;
            rx_data      <= 8'd0;
            rx_done      <= 1'b0;
        end

        else
        begin
	    //default
            rx_done <= 1'b0;

            if(rx_tick)
            begin

                case(state)

                IDLE:
                begin
                    sample_count <= 4'd0;
                    bit_index <= 3'd0;

                    if(rx_sync2 == 1'b0)
                        state <= START;
                end

                START:
	        begin
    	        sample_count <= sample_count + 1'b1;

    	        if(sample_count == 4'd7)
    	        begin
        	        if(rx_sync2 != 1'b0)
            	        state <= IDLE;
    	        end

    	        if(sample_count == 4'd15)
    	        begin
        	        sample_count <= 4'd0;
        	        state <= DATA;
    	        end
	        end

                DATA:
	        begin

    	        sample_count <= sample_count + 1'b1;

    	        if(sample_count == 4'd7)
        	        rx_shift[bit_index] <= rx_sync2;

    	        if(sample_count == 4'd15)
    	        begin
        	        sample_count <= 4'd0;

        	        if(bit_index == 3'd7)
        	        begin
            	        bit_index <= 0;
                        state <= STOP;
        	        end
        	        else
            	        bit_index <= bit_index + 1'b1;
    	        end
	        end
        
                STOP:
	        begin

    	        sample_count <= sample_count + 1'b1;

    	        if(sample_count == 4'd7)
    	        begin
        	        if(rx_sync2 != 1'b1)
            	        state <= IDLE;      
    	        end

    	        if(sample_count == 4'd15)
    	        begin
        	        sample_count <= 0;
        	        rx_data <= rx_shift;
        	        rx_done <= 1'b1;
        	        state <= IDLE;
    	        end

	        end

                default:
                begin
                    state <= IDLE;
                end

                endcase

            end

        end

    end

endmodule
