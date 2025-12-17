# Makefile
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# 설계 파일 경로들 (하드닝 시 사용한 파일들과 동일해야 함)
VERILOG_SOURCES += $(PWD)/../src/tt_um_sjcho_LEDLocker.v
VERILOG_SOURCES += $(PWD)/../src/button_debouncer.v
VERILOG_SOURCES += $(PWD)/../src/LED_rhythm_generator.v
VERILOG_SOURCES += $(PWD)/../src/comparator.v
VERILOG_SOURCES += $(PWD)/../src/password_storage.v
# 최상위 모듈 및 테스트 파이썬 파일 이름
TOPLEVEL = tt_um_sjcho_LEDLocker
MODULE = test

# cocotb make 규칙 포함
include $(shell cocotb-config --makefiles)/Makefile.sim
