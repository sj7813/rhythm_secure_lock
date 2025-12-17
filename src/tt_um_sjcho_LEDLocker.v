`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/17 19:24:34
// Design Name: 
// Module Name: tt_um_sjcho_LEDLocker
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


module tt_um_sjcho_LEDLocker (
    input  wire [7:0] ui_in,    // [고정] 전용 입력 8개
    output wire [7:0] uo_out,   // [고정] 전용 출력 8개
    input  wire [7:0] uio_in,   // [고정] 양방향 입력 (안씀)
    output wire [7:0] uio_out,  // [고정] 양방향 출력 (안씀)
    output wire [7:0] uio_oe,   // [고정] 양방향 제어 (안씀)
    input  wire       ena,      // [고정] 칩 활성화 (무시)
    input  wire       clk,      // [고정] 클럭
    input  wire       rst_n     // [고정] 리셋
);

    // ==========================================
    // 0. 핀 연결 (Pin Mapping)
    // ==========================================
    
    // [입력 매핑]
    wire btn_record = ui_in[0];      // 0번 핀 -> 녹화 버튼
    wire btn_enter  = ui_in[1];      // 1번 핀 -> 입력(Enter) 버튼
    wire [3:0] key_in = ui_in[5:2];  // 2~5번 핀 -> 키 입력

    // [출력 매핑]
    // 출력으로 나갈 내부 신호들을 위한 변수 선언
    wire [3:0] led_rhythm;
    reg  [2:0] led_status;
    reg        flag_unlock;

    // 실제 출력 핀에 연결
    assign uo_out[3:0] = led_rhythm;
    assign uo_out[6:4] = led_status;
    assign uo_out[7]   = flag_unlock;

    // [미사용 핀 처리]
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // ==========================================
    // 1. 상태 정의 (S_CONFIRM 추가됨)
    // ==========================================
    localparam S_IDLE    = 3'b000;
    localparam S_RECORD  = 3'b001;
    localparam S_CHECK   = 3'b010;
    localparam S_CONFIRM = 3'b101; // 4자리 입력 후 확인 대기 상태
    localparam S_SUCCESS = 3'b011;
    localparam S_FAIL    = 3'b100;
    
    reg [2:0] state;
    reg [1:0] digit_cnt;
    reg sequence_error; // 에러 발생 여부 기억 (0:정상, 1:에러있음)

    // 내부 와이어
    wire [1:0] current_led_pos;
    wire [1:0] saved_led_pos;
    wire [3:0] saved_key;
    wire is_match;
    wire btn_record_clean;
    wire btn_enter_clean;
    
    // 엣지 디텍션
    reg btn_enter_prev, btn_record_prev;
    wire btn_enter_pulse, btn_record_pulse;

    // --- 모듈 인스턴스화 ---
    
    button_debouncer #( .CNT_MAX(20'd1_000_000) ) u_db_record (
        .clk(clk),
        .rst_n(rst_n),
        .btn_in(btn_record),       // 외부에서 들어오는 거친 신호
        .btn_out(btn_record_clean) // 깨끗해진 신호 (이제 이걸 씁니다!)
    );

    // (2) 입력(Enter) 버튼용
    button_debouncer #( .CNT_MAX(20'd1_000_000) ) u_db_enter (
        .clk(clk),
        .rst_n(rst_n),
        .btn_in(btn_enter),        // 외부에서 들어오는 거친 신호
        .btn_out(btn_enter_clean)  // 깨끗해진 신호 (이제 이걸 씁니다!)
    );
    
    LED_rhythm_generator #( .CLK_DIV_WIDTH(24) ) u_rhythm (
        .clk(clk), .rst_n(rst_n), .enable(1'b1), 
        .led_out(led_rhythm), .led_index(current_led_pos)
    );

    password_storage u_storage (
        .clk(clk), .rst_n(rst_n), 
        .write_en( (state == S_RECORD) && btn_enter_pulse ),
        .addr(digit_cnt),
        .key_in(key_in), .led_pos_in(current_led_pos),
        .key_out(saved_key), .led_pos_out(saved_led_pos)
    );

    comparator u_comp (
        .key_in(key_in), .current_led_pos(current_led_pos),
        .saved_key(saved_key), .saved_led_pos(saved_led_pos),
        .is_match(is_match)
    );

    // --- 엣지 디텍션 로직 ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_enter_prev <= 0; btn_record_prev <= 0;
        end else begin
            btn_enter_prev <= btn_enter_clean; btn_record_prev <= btn_record_clean;
        end
    end
    assign btn_enter_pulse  = btn_enter_clean & ~btn_enter_prev;
    assign btn_record_pulse = btn_record_clean & ~btn_record_prev;

    // ==========================================
    // 2. FSM (상태 머신)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            digit_cnt <= 0;
            sequence_error <= 0;
        end else begin
            case (state)
                // --- 대기 상태 ---
                S_IDLE: begin
                    digit_cnt <= 0;
                    if (btn_record_pulse) begin
                        state <= S_RECORD;
                    end 
                    else if (btn_enter_pulse) begin
                        // 첫 번째 입력 처리
                        if (is_match) sequence_error <= 0;
                        else          sequence_error <= 1;
                        
                        digit_cnt <= 1; // 1번 인덱스로 이동
                        state <= S_CHECK;
                    end
                end

                // --- 녹화 상태 ---
                S_RECORD: begin
                    if (btn_enter_pulse) begin
                        if (digit_cnt == 3) begin
                            state <= S_IDLE;
                            digit_cnt <= 0;
                        end else begin
                            digit_cnt <= digit_cnt + 1;
                        end
                    end
                end

                // --- 검사 상태 (입력 중) ---
                S_CHECK: begin
                    if (btn_enter_pulse) begin
                        // 현재 입력 검사
                        if (!is_match) sequence_error <= 1;
                        
                        if (digit_cnt == 3) begin
                            // 4번째 입력(마지막)이 끝남!
                            // 결과 바로 안 보여주고 '확인 대기' 상태로 이동
                            state <= S_CONFIRM; 
                        end else begin
                            digit_cnt <= digit_cnt + 1;
                        end
                    end
                end
                
                // --- [NEW] 확인 대기 상태 ---
                S_CONFIRM: begin
                    // 여기서 엔터를 한 번 더 눌러야 최종 결과 판정
                    if (btn_enter_pulse) begin
                        if (sequence_error == 0) begin
                            state <= S_SUCCESS; // 완벽!
                        end else begin
                            state <= S_FAIL;    // 틀림!
                        end
                    end
                end

                // --- 결과 상태 ---
                S_SUCCESS: if (btn_enter_pulse || btn_record_pulse) state <= S_IDLE;
                S_FAIL:    if (btn_enter_pulse || btn_record_pulse) state <= S_IDLE;
                
                default: state <= S_IDLE;
            endcase
        end
    end

    // --- 출력 로직 ---
    always @(*) begin
        led_status = 3'b000;
        flag_unlock = 0;
        case (state)
            S_RECORD:  led_status = 3'b001; // Yellow
            S_SUCCESS: begin
                led_status = 3'b010; // Green
                flag_unlock = 1;
            end
            S_FAIL:    led_status = 3'b100; // Red
            default:   led_status = 3'b000; // IDLE, CHECK, CONFIRM 때는 끔
        endcase
    end

endmodule
