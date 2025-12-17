import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_led_locker(dut):
    # 1. 클럭 설정 (10MHz 가정, 필요시 조정)
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    # 2. 초기화 (Reset)
    dut._log.info("Resetting DUT")
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    dut._log.info("Starting Test: Record and Verify")

    # --- 1단계: 비밀번호 녹화 (S_RECORD) ---
    # btn_record (ui_in[0]) 누름
    dut.ui_in.value = 0x01  # ui_in[0] = 1
    await ClockCycles(dut.clk, 20) # 디바운서 통과를 위해 충분히 기다림
    dut.ui_in.value = 0x00
    await ClockCycles(dut.clk, 10)

    # 4자리를 녹화한다고 가정 (Enter 버튼 ui_in[1] 활용)
    for i in range(4):
        dut._log.info(f"Recording digit {i}")
        dut.ui_in.value = (0x01 << 2)  # key_in = 4'b0001
        val = (0x01 << 2) | 0x02
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 20)
        val_release = (0x01 << 2) & ~0x02 # Enter = 0
        await ClockCycles(dut.clk, 100) # 처리 시간 대기

        # --- 2단계: 검증 모드 진입 (S_CHECK) ---
        await ClockCycles(dut.clk, 100)
        
        # --- 3단계: 비밀번호 입력 및 확인 ---
        for i in range(4):
            dut._log.info(f"Entering digit {i} for check")
            dut.ui_in.value = (0x01 << 2) | 0x02 # 같은 키 + Enter
            await ClockCycles(dut.clk, 20)
            dut.ui_in.value = 0x00
            await ClockCycles(dut.clk, 100)
        # 최종 결과 확인 (flag_unlock = uo_out[7])  
        await ClockCycles(dut.clk, 200)
        if int(dut.uo_out.value) & 0x80:
            dut._log.info("SUCCESS: Unlock Flag is HIGH!")
        else:
            dut._log.error("FAIL: Unlock Flag is {dut.uo_out.value.integer}")

        await ClockCycles(dut.clk, 100)

