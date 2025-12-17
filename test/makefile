# 시뮬레이터 설정
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# 설계 파일 경로들 (소스 코드만 포함)
VERILOG_SOURCES += $(shell pwd)/../src/tt_um_sjcho_LEDLocker.v
VERILOG_SOURCES += $(shell pwd)/../src/button_debouncer.v
VERILOG_SOURCES += $(shell pwd)/../src/LED_rhythm_generator.v
VERILOG_SOURCES += $(shell pwd)/../src/comparator.v
VERILOG_SOURCES += $(shell pwd)/../src/password_storage.v

# 최상위 모듈 및 테스트 파이썬 파일 이름
TOPLEVEL = tt_um_sjcho_LEDLocker
MODULE = test

# cocotb make 규칙 포함
include $(shell cocotb-config --makefiles)/Makefile.sim
