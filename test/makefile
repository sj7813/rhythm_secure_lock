# 시뮬레이터 설정
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# 1. PDK 및 표준 셀 라이브러리 포함 (Tiny Tapeout 환경에서 필수)
# 시뮬레이션 시 gate-level 소자들을 인식하기 위해 필요합니다.
ifeq ($(TOPLEVEL_LANG),verilog)
  VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
  VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
endif

# 2. 설계 파일 경로들
# $(PWD) 대신 $(shell pwd)를 사용하거나 상대 경로를 더 확실히 잡아줍니다.
VERILOG_SOURCES += $(shell pwd)/../src/tt_um_sjcho_LEDLocker.v
VERILOG_SOURCES += $(shell pwd)/../src/button_debouncer.v
VERILOG_SOURCES += $(shell pwd)/../src/LED_rhythm_generator.v
VERILOG_SOURCES += $(shell pwd)/../src/comparator.v
VERILOG_SOURCES += $(shell pwd)/../src/password_storage.v

# 3. 최상위 모듈 및 테스트 파이썬 파일 이름
TOPLEVEL = tt_um_sjcho_LEDLocker
MODULE = test

# cocotb make 규칙 포함
include $(shell cocotb-config --makefiles)/Makefile.sim
