`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/17 19:08:10
// Design Name: 
// Module Name: comparator
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
// 파일명: comparator.v

module comparator (
    // 사용자 입력 (실시간)
    input wire [3:0] key_in,          // 사용자가 누른 숫자 (0~9)
    input wire [1:0] current_led_pos, // 현재 켜져 있는 LED 위치 (0~3)
    
    // 저장된 정답 (Password Storage에서 옴)
    input wire [3:0] saved_key,       // 저장해둔 숫자
    input wire [1:0] saved_led_pos,   // 저장해둔 LED 위치
    
    // 결과 출력
    output wire is_match              // 1: 일치(성공), 0: 불일치(실패)
);

    // 두 조건이 모두 참(True)이어야만 정답으로 인정 (AND 연산)
    assign is_match = (key_in == saved_key) && (current_led_pos == saved_led_pos);

endmodule
