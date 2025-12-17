`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/17 18:57:20
// Design Name: 
// Module Name: LED_rhythm_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LED_rhythm_generator #(
    parameter CLK_DIV_WIDTH = 24  // 하드닝 시에는 24, 시뮬레이션 시에는 8 추천
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [3:0] led_out,   // case 문에서 값을 넣으려면 반드시 reg!
    output wire [1:0] led_index  // assign으로 연결하므로 wire!
);

    // ==========================================
    // 1. Clock Divider
    // ==========================================
    reg [CLK_DIV_WIDTH-1:0] counter;
    wire tick = (counter == {CLK_DIV_WIDTH{1'b1}});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
        end else if (enable) begin
            counter <= counter + 1;
        end
    end

    // ==========================================
    // 2. Pattern Logic (Up/Down Counter)
    // ==========================================
    reg [1:0] current_pos;
    reg direction; 

    // 인덱스 출력 연결
    assign led_index = current_pos;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_pos <= 0;
            direction <= 0;
        end else if (enable && tick) begin
            if (direction == 0) begin // UP
                if (current_pos == 2'd3) begin
                    current_pos <= 2'd2;
                    direction <= 1;
                end else begin
                    current_pos <= current_pos + 1;
                end
            end else begin // DOWN
                if (current_pos == 2'd0) begin
                    current_pos <= 2'd1;
                    direction <= 0;
                end else begin
                    current_pos <= current_pos - 1;
                end
            end
        end
    end

    // ==========================================
    // 3. Output Logic (Decoder)
    // ==========================================
    // current_pos에 따라 led_out을 결정하는 '울타리'입니다.
    always @(*) begin
        case (current_pos)
            2'd0:    led_out = 4'b0001; 
            2'd1:    led_out = 4'b0010; 
            2'd2:    led_out = 4'b0100; 
            2'd3:    led_out = 4'b1000; 
            default: led_out = 4'b0000;
        endcase
    end

endmodule