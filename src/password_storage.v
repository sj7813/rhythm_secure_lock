`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/17 19:12:23
// Design Name: 
// Module Name: password_storage
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


// 파일명: password_storage.v

module password_storage (
    input wire clk,
    input wire rst_n,
    
    // 제어 신호
    input wire write_en,      // 1: 쓰기 모드 (녹화), 0: 읽기 모드 (검사)
    input wire [1:0] addr,    // 현재 다루고 있는 비밀번호의 순서 (0~3번째 자리)
    
    // 입력 데이터 (녹화용)
    input wire [3:0] key_in,      // 사용자가 입력한 키 값
    input wire [1:0] led_pos_in,  // 현재 켜져있는 LED 인덱스 (Rhythm Generator에서 옴)
    
    // 출력 데이터 (검사용)
    output wire [3:0] key_out,     // 저장된 키 값
    output wire [1:0] led_pos_out  // 저장된 LED 위치 값
);

    // 6-bit 너비의 레지스터 4개를 배열로 선언
    // [5:2]는 Key(4bit), [1:0]은 LED Position(2bit)로 사용
    reg [5:0] storage [3:0];
    
    integer i;

    // 쓰기 동작 (Sequential Logic)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 리셋 시 모든 저장소를 0으로 초기화
            for (i = 0; i < 4; i = i + 1) begin
                storage[i] <= 6'b0;
            end
        end else if (write_en) begin
            // 입력된 키와 LED 위치를 합쳐서 저장
            storage[addr] <= {key_in, led_pos_in};
        end
    end

    // 읽기 동작 (Combinational Logic)
    // 현재 주소(addr)에 해당하는 저장된 값을 즉시 출력
    assign key_out = storage[addr][5:2];
    assign led_pos_out = storage[addr][1:0];

endmodule
