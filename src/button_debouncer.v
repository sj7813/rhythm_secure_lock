`timescale 1ns / 1ps

module button_debouncer #(
    parameter CNT_MAX = 20'd1_000_000  // 상위 모듈에서 값을 넘겨받음
)(
    input  wire clk,      // 시스템 클럭
    input  wire rst_n,    // 리셋 (Active Low)
    input  wire btn_in,   // 물리적 버튼 입력 
    output reg  btn_out   // 정제된 버튼 출력
);

    // 최소 20비트 필요
    // 파라미터 크기에 맞춰 20비트로 선언
    reg [19:0] count;
    reg btn_sync_0, btn_sync_1;

    // 1. Meta-stability 방지를 위한 동기화 (2nd Stage Flip-Flop)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // 2. Debouncing 로직
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 20'd0;
            btn_out <= 1'b0;
        end else begin
            // 버튼 상태가 현재 출력값과 다를 때만 카운트 시작
            if (btn_sync_1 != btn_out) begin
                if (count >= CNT_MAX) begin
                    count <= 20'd0;
                    btn_out <= btn_sync_1; // 일정 시간 유지되면 상태 변경
                end else begin
                    count <= count + 1'b1;
                end
            end else begin
                count <= 20'd0; // 상태가 같으면 카운터 초기화
            end
        end
    end

endmodule