## This file contains all the rules for the test targets


#### configure LOGDIR paths:
LOGDIR=log
ALTERA_LOGDIR=altera_log
HWSIM_LOGDIR=hwsim_log
GXEMUL_LOGDIR=gxemul_log
GXEMUL_BINDIR?=/usr/groups/ctsrd/gxemul/CTSRD-CHERI-gxemul-testversion
GXEMUL_TRACE_OPTS?=-i
GXEMUL_OPTS=-V -E oldtestmips -M 3072 $(GXEMUL_TRACE_OPTS) -p "end"
ifeq ($(BRIEF_GXEMUL),1)
GXEMUL_LOG_FILTER=grep -A100 'cpu0:    pc = '
else
GXEMUL_LOG_FILTER=cat
endif
L3_LOGDIR=l3_log
SAIL_MIPS_LOGDIR=sail_mips_log
SAIL_MIPS_C_LOGDIR=sail_mips_c_log
SAIL_CHERI_LOGDIR=sail_cheri_log
SAIL_CHERI_EMBED_LOGDIR=sail_cheri_embed_log
SAIL_CHERI128_LOGDIR=sail_cheri128_log
SAIL_CHERI128_EMBED_LOGDIR=sail_cheri128_embed_log
# Use different logdirs for 128/256
QEMU_LOGDIR=qemu_log/$(CAP_SIZE)
ifneq ($(CAP_SIZE),256)
ifeq ($(CAP_PRECISE), 1)
QEMU_LOGDIR:=$(QEMU_LOGDIR)_magic
endif
endif


### Include add the _UNSUPPORTED_FEATURES variables
include Makefile.predicates.mk


#
# We unconditionally terminate the simulator after TEST_CYCLE_LIMIT
# instructions to ensure that loops terminate.  This is an arbitrary number.
#
TEST_CYCLE_LIMIT?=1500000

##############################################################################
# No need to modify anything below this point if you are just adding new
# tests to current categories.
#

# Set to 0 to disable capability tests
CHERIROOT?=../../cheri$(BERI_VER)/trunk
CHERIROOT_ABS:=$(realpath $(CHERIROOT))
CHERILIBS?=../../cherilibs/trunk
CHERILIBS_ABS:=$(realpath $(CHERILIBS))
PISM_MODULES_PATH=$(CHERILIBS_ABS)/peripherals
MEMCONF?=$(CHERIROOT_ABS)/memoryconfig
TOOLS_DIR= ${CHERILIBS_ABS}/tools
TOOLS_DIR_ABS:=$(realpath $(TOOLS_DIR))
CHERICTL=$(TOOLS_DIR_ABS)/debug/cherictl
SYSTEM_CONSOLE_DIR_ABS:= /usr/groups/ecad/altera/current/quartus/sopc_builder/bin
CHERISOCKET:= /tmp/$(USER)_beri_debug_socket
SIM:= ${CHERIROOT_ABS}/sim
DTB_FILE:=$(CHERIROOT_ABS)/sim.dtb
# Can be set to a custom value to customise tracing, which is useful to avoid filling up disks when fuzz testing.
ifdef DEBUG
SIM_TRACE_OPTS?= +regfile +trace +cTrace +tlbTrace +instructionBasedCycleCounter +debug +StatCounters
else
ifdef CTRACE
SIM_TRACE_OPTS?=+trace +cTrace +instructionBasedCycleCounter
else
ifdef TRACE
SIM_TRACE_OPTS?=+trace +instructionBasedCycleCounter
else
SIM_TRACE_OPTS?=
endif
endif
endif

ifeq ($(wildcard $(TOOLS_DIR_ABS)),)
MEMCONV=$(error Cannot find find memConv.py, set CHERILIBS to the cherilibs/trunk directory )
else
MEMCONV=python ${TOOLS_DIR_ABS}/memConv.py
endif

ifeq ($(wildcard $(CHERIROOT_ABS)),)
CHERI_SW_MEM_BIN=$(error Cannot find find CHERIROOT/sw/mem.bin, set CHERIROOT to the cheri/trunk directory )
else
CHERI_SW_MEM_BIN=${CHERIROOT_ABS}/sw/mem.bin
endif



TESTS_WITHOUT_PURECAP := $(basename $(TEST_FILES))
# Hacky workaround for purecap not working on all targets only add purecap tests after TEST_WITHOUT_PURECAP has been expanded
TEST_FILES+=$(TEST_PURECAP_FILES)
TESTS := $(TESTS_WITHOUT_PURECAP) $(basename $(TEST_PURECAP_FILES))
TEST_OBJS := $(addsuffix .o,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_ELFS := $(addsuffix .elf,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_ELFS := $(addsuffix _cached.elf,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_MULTI_ELFS := $(addsuffix _multi.elf,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHEDMULTI_ELFS := $(addsuffix _cachedmulti.elf,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_MEMS := $(addsuffix .mem,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_MEMS := $(addsuffix _cached.mem,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_MULTI_MEMS := $(addsuffix _multi.mem,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_HEXS := $(addsuffix .hex,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_HEXS := $(addsuffix _cached.hex,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_MULTI_HEXS := $(addsuffix _multi.hex,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_DUMPS := $(addsuffix .dump,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_DUMPS := $(addsuffix _cached.dump,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_MULTI_DUMPS := $(addsuffix _multi.dump,$(addprefix $(OBJDIR)/,$(TESTS)))

TEST_PYTHON := \
	$(addsuffix .py,$(addprefix tests/framework/,$(basename $(RAW_FRAMEWORK_FILES) $(TEST_FRAMEWORK_FILES)))) \
	$(addsuffix .py,$(addprefix tests/cframework/,$(basename $(C_FRAMEWORK_FILES)))) \
	$(addsuffix .py,$(addprefix tests/alu/,$(basename $(RAW_ALU_FILES) $(TEST_ALU_FILES) $(TEST_ALU_OVERFLOW_FILES)))) \
	$(addsuffix .py,$(addprefix tests/branch/,$(basename $(RAW_BRANCH_FILES) $(TEST_BRANCH_FILES)))) \
	$(addsuffix .py,$(addprefix tests/cp0/,$(basename $(RAW_CP0_FILES) $(TEST_CP0_FILES) $(TEST_TRAPI_FILES) $(TEST_BEV1_FILES)))) \
	$(addsuffix .py,$(addprefix tests/cp2/,$(basename $(TEST_CP2_FILES)))) \
	$(addsuffix .py,$(addprefix tests/fpu/,$(basename $(RAW_FPU_FILES) $(TEST_FPU_FILES)))) \
	$(addsuffix .py,$(addprefix tests/mem/,$(basename $(RAW_LLSC_FILES) $(TEST_LLSC_FILES)))) \
	$(addsuffix .py,$(addprefix tests/mem/,$(basename $(RAW_MEM_FILES) $(TEST_MEM_FILES) $(TEST_MEM_UNALIGN_FILES)))) \
	$(addsuffix .py,$(addprefix tests/tlb/,$(basename $(TEST_TLB_FILES)))) \
	$(addsuffix .py,$(addprefix tests/mt/,$(basename $(TEST_MT_FILES)))) \
	$(addsuffix .py,$(addprefix tests/statcounters/,$(basename $(RAW_STATCOUNTERS_FILES)))) \
	$(addsuffix .py,$(addprefix tests/virtdev/,$(basename $(TEST_VIRTDEV_FILES)))) \
	$(addsuffix .py,$(addprefix tests/multicore/,$(basename $(TEST_MULTICORE_FILES))))

# XXXAR: shouldn't this also include test/c/clang_test.py, etc.?


# XXXAR: TODO: build the purecap tests as _cached and _multi (needs some select_init magic)
CHERI_TEST_LOGS := $(addsuffix .log,$(addprefix $(LOGDIR)/,$(TESTS)))
CHERI_TEST_CACHED_LOGS := $(addsuffix _cached.log,$(addprefix \
	$(LOGDIR)/,$(TESTS)))
CHERI_TEST_MULTI_LOGS := $(addsuffix _multi.log,$(addprefix \
	$(LOGDIR)/,$(TESTS)))
CHERI_TEST_CACHEDMULTI_LOGS := $(addsuffix _cachedmulti.log,$(addprefix \
	$(LOGDIR)/,$(TESTS)))
ALTERA_TEST_LOGS := $(addsuffix .log,$(addprefix $(ALTERA_LOGDIR)/,$(TESTS)))
ALTERA_TEST_CACHED_LOGS := $(addsuffix _cached.log,$(addprefix \
	$(ALTERA_LOGDIR)/,$(TESTS)))
HWSIM_TEST_LOGS := $(addsuffix .log,$(addprefix $(HWSIM_LOGDIR)/,$(TESTS)))
HWSIM_TEST_CACHED_LOGS := $(addsuffix _cached.log,$(addprefix \
	$(HWSIM_LOGDIR)/,$(TESTS)))
GXEMUL_TEST_LOGS := $(addsuffix _gxemul.log,$(addprefix \
	$(GXEMUL_LOGDIR)/,$(TESTS)))
GXEMUL_TEST_CACHED_LOGS := $(addsuffix _gxemul_cached.log,$(addprefix \
	$(GXEMUL_LOGDIR)/,$(TESTS)))
L3_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(L3_LOGDIR)/,$(TESTS)))
L3_TEST_CACHED_LOGS := $(addsuffix _cached.log,$(addprefix \
	$(L3_LOGDIR)/,$(TESTS)))
L3_TEST_MULTI_LOGS := $(addsuffix _multi.log,$(addprefix \
	$(L3_LOGDIR)/,$(TESTS)))
L3_TEST_CACHEDMULTI_LOGS := $(addsuffix _cachedmulti.log,$(addprefix \
	$(L3_LOGDIR)/,$(TESTS)))
SAIL_MIPS_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_MIPS_LOGDIR)/,$(TESTS)))
SAIL_MIPS_C_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_MIPS_C_LOGDIR)/,$(TESTS)))
SAIL_CHERI_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI_LOGDIR)/,$(TESTS)))
SAIL_CHERI_EMBED_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI_EMBED_LOGDIR)/,$(TESTS)))
SAIL_CHERI128_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI128_LOGDIR)/,$(TESTS)))
SAIL_CHERI128_EMBED_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI128_EMBED_LOGDIR)/,$(TESTS)))
QEMU_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(QEMU_LOGDIR)/,$(TESTS)))

SIM_FUZZ_TEST_LOGS := $(filter $(LOGDIR)/test_fuzz_%, $(CHERI_TEST_LOGS))
SIM_FUZZ_TEST_CACHED_LOGS := $(filter $(LOGDIR)/test_fuzz_%, $(CHERI_TEST_CACHED_LOGS))
GXEMUL_FUZZ_TEST_LOGS := $(filter $(GXEMUL_LOGDIR)/test_fuzz_%, $(GXEMUL_TEST_LOGS))
GXEMUL_FUZZ_TEST_CACHED_LOGS := $(filter $(GXEMUL_LOGDIR)/test_fuzz_%, $(GXEMUL_TEST_CACHED_LOGS))

#REWRITE_PISM_CONF = sed -e 's,../../cherilibs/trunk,$(CHERILIBS_ABS),' < $(1) > $(2)
#COPY_PISM_CONFS = $(call REWRITE_PISM_CONF,$(MEMCONF),$$TMPDIR/memoryconfig)
COPY_PISM_CONFS = cp $(MEMCONF) $$TMPDIR/memoryconfig

PREPARE_TEST = \
	TMPDIR=$$(mktemp -d) && \
	cd $$TMPDIR && \
	cp $(PWD)/$(1) mem.bin && \
	$(MEMCONV) bsim && \
	$(MEMCONV) bsimc2 && \
	$(COPY_PISM_CONFS)

# XXX rmn30
# As a hack to work around bsim license problems which cause it to sporadically fail we repeat the sim
# command several times until it succeeds. The for loop should be removed once the license server problem
# is fixed.

RUN_TEST_COMMAND = \
	LD_LIBRARY_PATH=$(CHERILIBS_ABS)/peripherals \
    PISM_MODULES_PATH=$(PISM_MODULES_PATH) \
	CHERI_CONFIG=$$TMPDIR/simconfig \
	CHERI_DTB=$(DTB_FILE) \
	BERI_DEBUG_SOCKET_0=$(CHERISOCKET)  $(SIM) -w +regDump $(SIM_TRACE_OPTS) -m $(TEST_CYCLE_LIMIT) > \
	    $(PWD)/$@; \

REPEAT_5 = \
	for attempt in 0 1 2 4 5; do if \
	$(1) \
	then break; else false; fi; done

RUN_TEST = $(call REPEAT_5,$(RUN_TEST_COMMAND))

# XXX jes212
# Use the following version instead of the above (running a severely limited number of tests) if you wish
# to make waves (<test name>.vcd will be dumped into your home directory):
#
#RUN_TEST = \
#	for attempt in 0 1 2 4 5; do if \
#	LD_LIBRARY_PATH=$(CHERILIBS_ABS)/peripherals \
#	PISM_MODULES_PATH=$(PISM_MODULES_PATH) \
#	CHERI_CONFIG=$$TMPDIR/simconfig \
#	BERI_DEBUG_SOCKET=$(CHERISOCKET) $(SIM) -V $(HOME)/$(1).vcd -w +regDump $(SIM_TRACE_OPTS) -m $(TEST_CYCLE_LIMIT) > \
#	    $(PWD)/$@; \
#	then break; else false; fi; done

CLEAN_TEST = rm -r $$TMPDIR

WAIT_FOR_SOCKET = while ! test -e $(1); do sleep 0.1; done







#### Rules to generate the logfiles
#
# Convert ELF images to raw memory images that can be loaded into simulators
# or hardware.
#
$(OBJDIR)/%.mem : $(OBJDIR)/%.elf
	$(OBJCOPY) -S -O binary $< $@

# I instantiate this specifically so that it gets used to when test_clang_dma%
# is used to build a test directly.

$(OBJDIR)/startdramtest.mem: $(OBJDIR)/startdramtest.elf
	$(OBJCOPY) -S -O binary $< $@

#
# Convert ELF images to raw memory images that can be loaded into simulators
# or hardware.
#
$(OBJDIR)/%.hex : $(OBJDIR)/%.mem
	TMPDIR=$$(mktemp -d) && \
	cd $$TMPDIR && \
	cp $(CURDIR)/$< mem.bin && \
	$(MEMCONV) verilog && \
	cp initial.hex $(CURDIR)/$@ && \
	rm -r $$TMPDIR


#
# Provide an annotated disassembly for the ELF image to be used in diagnosis.
# (Use flags that work for both GNU objdump and llvm-objdump)
$(OBJDIR)/%.dump: $(OBJDIR)/%.elf
	$(OBJDUMP) -p -h -s -S -d -l $< > $@

$(LOGDIR)/test_raw_trace.log: CHERI_TRACE_FILE=$(PWD)/log/test_raw_trace.trace
$(LOGDIR)/test_raw_trace_cached.log: CHERI_TRACE_FILE=$(PWD)/log/test_raw_trace_cached.trace

# The trace files need interaction from cherictl
# We fork the test, and use cherictl
# test_raw_trac, because % must be non-empty...
#
$(LOGDIR)/test_raw_trac%.log: $(OBJDIR)/test_raw_trac%.mem $(SIM) $(CHERICTL)
ifeq ($(wildcard $(CHERICTL)),)
	$(error CHERICTL not found, set CHERILIBS variable correctly!)
endif
	rm -f $$CHERI_TRACE_FILE
	$(call PREPARE_TEST,$<) && \
	((BERI_DEBUG_SOCKET_0=$$TMPDIR/sock \
	CHERI_TRACE_FILE=$(CHERI_TRACE_FILE) \
	$(call RUN_TEST,$*); \
	$(CLEAN_TEST)) &) && \
	$(call WAIT_FOR_SOCKET,$$TMPDIR/sock) && \
	$(CHERICTL) setreg -r 12 -v 1 -p $$TMPDIR/sock && \
	$(CHERICTL) memtrace -v 6 -p $$TMPDIR/sock

#
# Target to execute a Bluespec simulation of the test suite; memConv.py needs
# fixing so that it accepts explicit sources and destinations but for now we
# can use a temporary directory so that parallel builds work.
$(LOGDIR)/test_clang_dma%.log: $(OBJDIR)/startdramtest.mem $(OBJDIR)/test_clang_dma%.mem $(SIM)
	$(call PREPARE_TEST,$<) && \
		cp $(PWD)/$(word 2, $^) . && \
		$(call REPEAT_5, CHERI_KERNEL=$(notdir $(word 2, $^)) $(RUN_TEST_COMMAND)); \
		$(CLEAN_TEST)

$(LOGDIR)/%.log : $(OBJDIR)/%.mem $(SIM)
	$(call PREPARE_TEST,$<) && $(call RUN_TEST,$*); $(CLEAN_TEST)

# The test won't be run, but attempting to build with the standard rules fails
$(LOGDIR)/test_clang_dma%_cached.log : ;

#
# Target to do a run of the test suite on hardware.
$(ALTERA_LOGDIR)/%.log : $(OBJDIR)/%.mem $(TOOLS_DIR_ABS)/debug/cherictl
	$(TOOLS_DIR_ABS)/debug/cherictl test -f $(CURDIR)/$< > $(CURDIR)/$@ && \
	sleep .1

#
# Target to run the hardware test suite on the simulator.
$(HWSIM_LOGDIR)/%.log : $(OBJDIR)/%.mem $(TOOLS_DIR_ABS)/debug/cherictl
	sleep 2
	while ! test -e /tmp/cheri_debug_listen_socket; do sleep 0.1; done
	TMPDIR=$$(mktemp -d) && \
	cd $$TMPDIR && \
	$(TOOLS_DIR_ABS)/debug/cherictl test -f $(CURDIR)/$< > $(CURDIR)/$@ && \
	rm -r $$TMPDIR
	killall -9 bluetcl
	rm /tmp/cheri_debug_listen_socket
	sleep 1

#
# Target to execute a gxemul simulation.  Gxemul is focused on running
# interactively which causes two problems: firstly there is no way to
# say on the command line that we want to run for only
# TEST_CYCLE_LIMIT cycles, and secondly gxemul assumes that there is
# an interactive terminal and hangs if stdin goes away. We get around
# this with the following glorious hackery to 1) feed gxemul commands
# to step TEST_CYCLE_LIMIT times then exit and 2) wait until gxemul
# closes stdin before exiting the pipeline.
#
$(GXEMUL_LOGDIR)/%_gxemul.log : $(OBJDIR)/%.elf
	(printf "step $(TEST_CYCLE_LIMIT)\nquit\n"; while echo > /dev/stdout; do sleep 0.01; done ) | \
	$(GXEMUL_BINDIR)/gxemul $(GXEMUL_OPTS) $< 2>&1 | \
	    $(GXEMUL_LOG_FILTER) >$@ || true


$(GXEMUL_LOGDIR)/%_gxemul_cached.log : $(OBJDIR)/%_cached.elf
	(printf "step $(TEST_CYCLE_LIMIT)\nquit\n"; while echo > /dev/stdout; do sleep 0.01; done ) | \
	$(GXEMUL_BINDIR)/gxemul $(GXEMUL_OPTS) $< 2>&1 | \
	    $(GXEMUL_LOG_FILTER) >$@ || true

max_cycles: max_cycles.c
	$(CC) -o max_cycles max_cycles.c

l3tosim: l3tosim.c
	$(CC) -o l3tosim l3tosim.c

ifeq ($(MULTI),1)
L3_MULTI=--nbcore 2
else
L3_MULTI=
endif

$(L3_LOGDIR)/%.log: $(OBJDIR)/%.hex l3tosim max_cycles | $(L3_LOGDIR)
ifdef TRACE
	$(L3_SIM) --cycles `./max_cycles $@ 20000 300000` --uart-delay 0 --ignore HI --ignore LO --ignore TLB --trace 2 $(L3_MULTI) $< 2> $@.err > $@ || true
else
ifdef PROFILE
	rm -f mlmon.out
endif
	$(L3_SIM) --cycles `./max_cycles $@ 20000 300000` --uart-delay 0 --ignore HI --ignore LO --ignore TLB $(L3_MULTI) $< 2> $@.err > $@ || true
ifdef PROFILE
	mlprof -raw true -show-line true `which $(L3_SIM)` mlmon.out > $(L3_LOGDIR)/$*.cover
endif
endif

$(SAIL_MIPS_LOGDIR)/%.log: $(OBJDIR)/%.elf $(SAIL_MIPS_SIM) max_cycles | $(SAIL_MIPS_LOGDIR)
	-$(TIMEOUT) 2m $(SAIL_MIPS_SIM) $< > $@ 2>&1

$(OBJDIR)/%.sailbin: $(OBJDIR)/%.elf $(SAIL_DIR)/sail
	$(SAIL_DIR)/sail -elf $< -o $@

$(SAIL_MIPS_C_LOGDIR)/%.log: $(OBJDIR)/%.sailbin $(SAIL_MIPS_C_SIM) max_cycles | $(SAIL_MIPS_C_LOGDIR)
	-$(SAIL_MIPS_C_SIM) --cyclelimit `./max_cycles $@ 20000 300000` --image $< > $@ 2>&1

$(SAIL_CHERI_LOGDIR)/%.log: $(OBJDIR)/%.elf $(SAIL_CHERI_SIM) max_cycles | $(SAIL_CHERI_LOGDIR)
	-$(TIMEOUT) 2m $(SAIL_CHERI_SIM) $< > $@ 2>&1

$(SAIL_CHERI_EMBED_LOGDIR)/%.log: $(OBJDIR)/%.mem $(SAIL_EMBED) max_cycles | $(SAIL_CHERI_EMBED_LOGDIR)
	-$(SAIL_EMBED) --model cheri --quiet --max_instruction `./max_cycles $@ 20000 300000` $(<)@0x40000000 > $@ 2>&1

$(SAIL_CHERI128_LOGDIR)/%.log: $(OBJDIR)/%.elf $(SAIL_CHERI128_SIM) max_cycles | $(SAIL_CHERI128_LOGDIR)
	-$(TIMEOUT) 2m $(SAIL_CHERI128_SIM) $< > $@ 2>&1

$(SAIL_CHERI128_EMBED_LOGDIR)/%.log: $(OBJDIR)/%.mem $(SAIL_EMBED) max_cycles | $(SAIL_CHERI128_EMBED_LOGDIR)
	-$(SAIL_EMBED) --model cheri128 --quiet --max_instruction `./max_cycles $@ 20000 300000` $(<)@0x40000000 > $@ 2>&1

ALL_LOGDIRS=$(L3_LOGDIR) $(QEMU_LOGDIR) $(LOGDIR) \
	$(SAIL_MIPS_LOGDIR) $(SAIL_MIPS_C_LOGDIR) \
	$(SAIL_CHERI_LOGDIR) $(SAIL_CHERI_EMBED_LOGDIR) \
	$(SAIL_CHERI128_LOGDIR) $(SAIL_CHERI128_EMBED_LOGDIR) \

# See ﻿https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html#Prerequisite-Types (dep has to be after a '|')
$(ALL_LOGDIRS) $(OBJDIR):
	mkdir -p "$@"

QEMU_FLAGS=-D "$@" -cpu 5Kf -bc `./max_cycles $@ 20000 300000` \
           -kernel "$<" -serial none -monitor none -nographic -m 2048M -bp 0x`$(OBJDUMP) -t "$<" | awk -f end.awk`
ifeq ($(MULTI),1)
QEMU_FLAGS+=-smp 2 -M malta
else
QEMU_FLAGS+=-M mipssim
endif

SANITIZER_ENV=UBSAN_OPTIONS=print_stacktrace=1,halt_on_error=1 LSAN_OPTIONS=suppressions=QEMU_LEAKS.supp

# raw tests need to be started with tracing in, for the others we can start it in init.s
$(QEMU_LOGDIR)/test_raw_%.log: $(OBJDIR)/test_raw_%.elf max_cycles $(QEMU) | $(QEMU_LOGDIR)
ifeq ($(wildcard $(QEMU_ABSPATH)),)
	$(error QEMU ($(QEMU)) is missing, could not execute it)
endif
	@echo "$(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) -d instr > /dev/null"
	@env $(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) -d instr 2>&1 >/dev/null; \
	    exit_code=$(dollar)?; \
	    if [ "$(dollar)exit_code" -ne 255 ] && [ "$(dollar)exit_code" -ne 0 ]; then \
	        echo "UNEXPECTED EXIT CODE $(dollar)exit_code"; rm -f "$@"; false; \
	    fi
	@if ! test -e "$@"; then echo "ERROR: QEMU didn't create $@"; false ; fi
	@if ! test -s "$@"; then echo "ERROR: QEMU created a zero size logfile for $@"; rm "$@"; false ; fi

$(QEMU_LOGDIR)/%.log: $(OBJDIR)/%.elf max_cycles $(QEMU) | $(QEMU_LOGDIR)
ifeq ($(wildcard $(QEMU_ABSPATH)),)
	$(error QEMU ($(QEMU)) is missing, could not execute it)
endif
	@echo "$(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) > /dev/null"
	@env $(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) 2>&1 >/dev/null; \
	    exit_code=$(dollar)?; \
	    if [ "$(dollar)exit_code" -ne 255 ] && [ "$(dollar)exit_code" -ne 0 ]; then \
	        echo "UNEXPECTED EXIT CODE $(dollar)exit_code"; rm -f "$@"; false; \
	    fi
	@if ! test -e "$@"; then echo "ERROR: QEMU didn't create $@"; false ; fi
	@if ! test -s "$@"; then echo "ERROR: QEMU created a zero size logfile for $@"; rm "$@"; false ; fi

$(QEMU_LOGDIR)/%.log.symbolized: $(QEMU_LOGDIR)/%.log
	$(CHERI_SDK_BINDIR)/symbolize-cheri-trace.py $< "$(OBJDIR)/`basename $< .log`.elf" > $@

clion/$(QEMU_LOGDIR)/%.log.symbolized: $(QEMU_LOGDIR)/%.log.symbolized
	clion $(abspath $<)






#### Run python to generate XUnit XML:

### Configure pytest invocation:

# TODO: for now also run with python 2.7 but we should update to 3.x soon
NOSETESTS?=python3 -m pytest -q
_PYTEST_INSTALLED_STR=This is pytest
PYTEST_VERSION_OUTPUT=$(shell $(NOSETESTS) --version 2>&1; echo FOO >&2)
PYTEST_CHECK1=$(if $(findstring $(_PYTEST_INSTALLED_STR),$(PYTEST_VERSION_OUTPUT)),@echo pytest is installed,$(error pytest not installed? Try running `pip3 install --user pytest`. Got error running $(NOSETESTS) --version: $(PYTEST_VERSION_OUTPUT)"))
PYTEST_CHECK2=$(if $(findstring requires pytest-,$(PYTEST_VERSION_OUTPUT)),$(error pytest version is too old. Try running `pip3 install --upgrade --user pytest`),@echo pytest version is not too old)


check_pytest_version:
	@echo "Checking if pytest is valid:"
	$(PYTEST_CHECK1)
	$(PYTEST_CHECK2)


PYTHON_TEST_XUNIT_FLAG=--junit-xml
PYTHON_TEST_ATTRIB_SELETOR_FLAG=--unsupported-features

ifeq ($(USING_LLVM_ASSEMBLER),0)
NOSETESTS:=TEST_ASSEMBLER=gnu $(NOSETESTS)
endif
ifeq ($(PYTEST),)
PYTEST:=python3 -m pytest
endif

NOSETESTS:=PYTHONPATH=tools/sim PERM_SIZE=$(PERM_SIZE) $(NOSETESTS)
PYTEST:=PYTHONPATH=tools/sim:. PERM_SIZE=$(PERM_SIZE) $(PYTEST)
# For now allow running tests with c0 == ddc by setting CHERI_C0_IS_NULL=0
CHERI_C0_IS_NULL?=1
NOSETESTS:=CHERI_C0_IS_NULL=$(CHERI_C0_IS_NULL) CAP_SIZE=$(CAP_SIZE) $(NOSETESTS)
PYTEST:=CHERI_C0_IS_NULL=$(CHERI_C0_IS_NULL) CAP_SIZE=$(CAP_SIZE) $(PYTEST)

SIM_NOSETESTS=		LOGDIR=$(LOGDIR) TEST_MACHINE=SIM $(NOSETESTS)
HWSIM_NOSETESTS=	LOGDIR=$(HWSIM_LOGDIR) TEST_MACHINE=HWSIM $(NOSETESTS)
L3_NOSETESTS=		LOGDIR=$(L3_LOGDIR) TEST_MACHINE=L3 $(NOSETESTS)
QEMU_NOSETESTS= 	LOGDIR=$(QEMU_LOGDIR) TEST_MACHINE=QEMU $(NOSETESTS) $(QEMU_NOSEFLAGS)
QEMU_PYTEST=		LOGDIR=$(QEMU_LOGDIR) TEST_MACHINE=QEMU $(PYTEST) $(QEMU_NOSEFLAGS)
ALTERA_NOSETESTS=	LOGDIR=$(ALTERA_LOGDIR) TEST_MACHINE=ALTERA $(NOSETESTS)
# For this one we don't set LOGDIR since each target uses a different one
SAIL_NOSETESTS= 	TEST_MACHINE=SAIL $(NOSETESTS)



# Simulate a failure on all unit tests
failnosetest: cleantest $(CHERI_TEST_LOGS)
	DEBUG_ALWAYS_FAIL=1 PYTHONPATH=tools $(NOSETESTS) $(NOSEFLAGS) $(TESTDIRS)


.PHONY: fuzz_run_tests fuzz_run_tests_cached fuzz_generate nose_fuzz nose_fuzz_cached
fuzz_run_tests: $(GXEMUL_FUZZ_TEST_LOGS) $(SIM_FUZZ_TEST_LOGS)

fuzz_run_tests_cached: $(GXEMUL_FUZZ_TEST_CACHED_LOGS) $(SIM_FUZZ_TEST_CACHED_LOGS)

fuzz_generate: $(FUZZ_SCRIPT)
	python $(FUZZ_SCRIPT) $(FUZZ_SCRIPT_OPTS) -d $(FUZZ_TEST_DIR)

# The rather unpleasant side-effect of snorting too much candy floss...
nose_fuzz: $(SIM) fuzz_run_tests
	CACHED=0 $(NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_fuzz.xml \
	    $(NOSEFLAGS_UNCACHED) tests/fuzz || true

nose_fuzz_cached: $(SIM) fuzz_run_tests_cached
	CACHED=1 $(NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_fuzz_cached.xml \
	    $(NOSEFLAGS) tests/fuzz || true


# Run unit tests using nose (http://somethingaboutorange.com/mrl/projects/nose/)

nosetest: nosetests_uncached.xml

nosetest_cached: nosetests_cached.xml

nosetests_multi: nosetests_multi.xml

nosetests_cachedmulti: nosetests_cachedmulti.xml

#
# Merge resuls of cached and uncached tests
#

nosetests_combined.xml: nosetests_uncached.xml nosetests_cached.xml xmlcat
	rm -f nosetests_combined.xml
	# ./xmlcat nosetests_uncached.xml nosetests_cached.xml | tee nosetests_combined.xml
	@echo "XMLCAT SEEMS TO BE BROKEN!"; exit 1

#
# Use the target FORCE to force the xmk files to be rebuilt each time.
# This is done because Jenkins will complain if it doens't get a fresh XML
# file each time.

nosetests_uncached.xml: $(CHERI_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	CACHED=0 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_uncached.xml \
	$(NOSEFLAGS_UNCACHED) $(TESTDIRS) || true

nosetests_cached.xml: $(CHERI_TEST_CACHED_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	CACHED=1 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_cached.xml \
	$(NOSEFLAGS) $(TESTDIRS) || true

nosetests_multi.xml: $(CHERI_TEST_MULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	MULTI1=1 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_multi.xml \
	$(NOSEFLAGS) $(TESTDIRS) || true

nosetests_cachedmulti.xml: $(CHERI_TEST_CACHEDMULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	MULTI1=1 CACHED=1 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_cachedmulti.xml \
	$(NOSEFLAGS) $(TESTDIRS) || true

altera-nosetest: all $(ALTERA_TEST_LOGS)
	CACHED=0 $(ALTERA_NOSETESTS) \
	    $(NOSEFLAGS_UNCACHED) $(ALTERA_NOSEFLAGS) $(TESTDIRS) || true

altera-nosetest_cached: all $(ALTERA_TEST_CACHED_LOGS)
	CACHED=1 $(ALTERA_NOSETESTS) \
	    $(NOSEFLAGS) $(ALTERA_NOSEFLAGS) $(TESTDIRS) || true

hwsim-nosetest: $(CHERISOCKET) all $(HWSIM_TEST_LOGS)
	CACHED=0 $(HWSIM_NOSETESTS) \
	$(NOSEFLAGS_UNCACHED) $(HWSIM_NOSEFLAGS) $(TESTDIRS) || true

hwsim-nosetest_cached: $(CHERISOCKET) all $(HWSIM_TEST_CACHED_LOGS)
	CACHED=1 $(HWSIM_NOSETESTS) \
	    $(NOSEFLAGS) $(HWSIM_NOSEFLAGS) $(TESTDIRS) || true

nosetests_gxemul: nosetests_gxemul_uncached.xml

nosetests_gxemul_uncached.xml: $(GXEMUL_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	PYTHONPATH=tools/gxemul CACHED=0 $(NOSETESTS) \
	    $(PYTHON_TEST_XUNIT_FLAG)=nosetests_gxemul_uncached.xml \
	    $(GXEMUL_NOSEFLAGS) $(TESTDIRS) || true

nosetests_gxemul_cached: nosetests_gxemul_cached.xml

nosetests_gxemul_cached.xml: $(GXEMUL_TEST_CACHED_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	PYTHONPATH=tools/gxemul CACHED=1 $(NOSETESTS) \
	    $(PYTHON_TEST_XUNIT_FLAG)=nosetests_gxemul_cached.xml \
	    $(GXEMUL_NOSEFLAGS) $(TESTDIRS) || true

gxemul-build:
	rm -f -r $(GXEMUL_BINDIR)
	wget https://github.com/CTSRD-CHERI/gxemul/zipball/8d92b42a6ccdb7d94a2ad43f7e5e70d17bb7839c -O tools/gxemul/gxemul-testversion.zip --no-check-certificate
	unzip tools/gxemul/gxemul-testversion.zip -d tools/gxemul/
	cd $(GXEMUL_BINDIR) && ./configure && $(MAKE)

nosetests_l3: nosetests_l3.xml

nosetests_l3_cached: nosetests_l3_cached.xml

nosetests_l3_multi: nosetests_l3_multi.xml

nosetests_l3_cachedmulti: nosetests_l3_cachedmulti.xml

nosetests_l3.xml: $(L3_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(L3_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3.xml \
	$(L3_NOSEFLAGS_UNCACHED) $(TESTDIRS) || true

nosetests_l3_cached.xml: $(L3_TEST_CACHED_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	CACHED=1 $(L3_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3_cached.xml \
	$(L3_NOSEFLAGS) $(TESTDIRS) || true

nosetests_l3_multi.xml: $(L3_TEST_MULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	MULTI1=1 $(L3_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3_multi.xml \
	$(L3_NOSEFLAGS_UNCACHED) $(TESTDIRS) || true

nosetests_l3_cachedmulti.xml: $(L3_TEST_CACHEDMULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	CACHED=1 MULTI1=1 $(L3_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3_cachedmulti.xml $(L3_NOSEFLAGS) \
	    $(TESTDIRS) || true

_CHECK_FILE_EXIST=$(if $(wildcard $(shell command -v $(1) 2>/dev/null)),$(info SAIL_MIPS_SIM=$(1)),$(error $(2) not found in expected path: "$(1)"))
check_sail_deps: FORCE
	@echo Checking if timeout command exists:
	@which $(TIMEOUT)

nosetests_sail: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_MIPS_SIM), sail MIPS)
	$(MAKE) $(MFLAGS) nosetests_sail.xml
nosetests_sail_mips_c: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_MIPS_C_SIM), sail MIPS)
	$(MAKE) $(MFLAGS) nosetests_sail_mips_c.xml
nosetests_sail_cheri: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_CHERI_SIM), sail CHERI256)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri.xml
nosetests_sail_cheri_embed: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_EMBED), sail embed)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri_embed.xml
nosetests_sail_cheri128: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_CHERI128_SIM), sail CHERI128)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri128.xml
nosetests_sail_cheri128_embed: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_EMBED), sail embed)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri128_embed.xml

# SAIL_MIPS_SIM=$(SAIL_DIR)/mips/mips
# SAIL_CHERI_SIM=$(SAIL_DIR)/cheri/cheri
# SAIL_CHERI128_SIM=$(SAIL_DIR)/cheri/cheri128
# SAIL_EMBED=$(SAIL_DIR)/src/run_embed.native


nosetests_sail.xml: $(SAIL_MIPS_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	LOGDIR=$(SAIL_MIPS_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_MIPS_NOSEFLAGS) \
	     $(TESTDIRS) || true

nosetests_sail_mips_c.xml: $(SAIL_MIPS_C_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	LOGDIR=$(SAIL_MIPS_C_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_MIPS_NOSEFLAGS) \
	    $(TESTDIRS) || true

nosetests_sail_cheri.xml: $(SAIL_CHERI_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	LOGDIR=$(SAIL_CHERI_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI_NOSEFLAGS) \
	     $(TESTDIRS) || true

nosetests_sail_cheri_embed.xml: $(SAIL_CHERI_EMBED_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	LOGDIR=$(SAIL_CHERI_EMBED_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI_NOSEFLAGS) \
	    $(TESTDIRS) || true

nosetests_sail_cheri128.xml: $(SAIL_CHERI128_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	LOGDIR=$(SAIL_CHERI128_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI128_NOSEFLAGS) \
	   $(TESTDIRS) || true

nosetests_sail_cheri128_embed.xml: $(SAIL_CHERI128_EMBED_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	LOGDIR=$(SAIL_CHERI128_EMBED_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI128_NOSEFLAGS) \
	    $(TESTDIRS) || true

nosetests_qemu: FORCE
	$(call _CHECK_FILE_EXIST, $(QEMU), QEMU)
	$(MAKE) $(MFLAGS) nosetests_qemu.xml

check_valid_qemu: FORCE
	@echo "Checking if QEMU $(QEMU_ABSPATH) is valid for this configuration:"
	@echo "CAP_PRECISE='$(CAP_PRECISE)', QEMU_CAP_PRECISE='$(QEMU_CAP_PRECISE)'"
	@echo "CAP_SIZE='$(CAP_SIZE)', QEMU_CAP_SIZE='$(QEMU_CAP_SIZE)'"
	@echo "CHERI_C0_IS_NULL='$(CHERI_C0_IS_NULL)', QEMU_C0_IS_NULL='$(QEMU_C0_IS_NULL)'"
	@if [ "$(CAP_PRECISE)" != "$(QEMU_CAP_PRECISE)" ]; then \
		echo "CAP_PRECISE set to '$(CAP_PRECISE)' but QEMU precise capabilities=$(QEMU_CAP_PRECISE). Change CAP_PRECISE or select a different $(dollar)QEMU"; \
		exit 1; \
	fi
	@if [ "$(CAP_SIZE)" != "$(QEMU_CAP_SIZE)" ]; then \
		echo "CAP_SIZE set to '$(CAP_SIZE)' but QEMU capability size='$(QEMU_CAP_SIZE)'. Change CAP_SIZE or select a different $(dollar)QEMU"; \
		exit 1; \
	fi
	@if [ "$(CHERI_C0_IS_NULL)" != "$(QEMU_C0_IS_NULL)" ]; then \
		echo "CHERI_C0_IS_NULL set to '$(CHERI_C0_IS_NULL)' but QEMU $c0 == $cnull is '$(QEMU_C0_IS_NULL)'. Change CHERI_C0_IS_NULL or select a different $(dollar)QEMU"; \
		exit 1; \
	fi
	@echo "Success. Can run tests with $(QEMU_ABSPATH)"


# set TEST_MACHINE to QEMU to mark tests that are not implemented as xfail
nosetests_qemu.xml: $(QEMU_TEST_LOGS) check_pytest_version $(TEST_PYTHON) check_valid_qemu FORCE
	@echo "Pytest flags: $(QEMU_NOSEFLAGS)"
	LOGDIR=$(QEMU_LOGDIR) $(QEMU_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(TESTDIRS) || true

xmlcat: xmlcat.c
	$(CC) -o xmlcat xmlcat.c -I/usr/include/libxml2 -lxml2 -lz -lm


CLANG_TESTS = $(basename $(TEST_CLANG_FILES) $(TEST_PURECAP_FILES) $(C_FRAMEWORK_FILES))
FILES_TO_QEMU_LOGFILES = $(addsuffix .log,$(addprefix $(QEMU_LOGDIR)/,$(basename $(1))))
QEMU_CLANG_TEST_LOGS = $(call FILES_TO_QEMU_LOGFILES, $(TEST_CLANG_FILES) $(TEST_PURECAP_FILES) $(C_FRAMEWORK_FILES))

ifeq ($(CLANG), 1)
TEST_PYTHON +=	tests/c/test_clang.py
# dummy target to make the pytest/qemu/target work
%/test_clang.log: tests/c/test_clang.py $(call FILES_TO_QEMU_LOGFILES, $(TEST_CLANG_FILES))
	echo "DUMMY" > $@
endif
ifeq ($(PURECAP), 1)
TEST_PYTHON +=	tests/purecap/test_purecap.py
TEST_PYTHON +=	tests/purecap/test_purecap_reg_init.py
# dummy target to make the pytest/qemu/target work
%/test_purecap.log: tests/purecap/test_purecap.py $(call FILES_TO_QEMU_LOGFILES, $(TEST_PURECAP_FILES))
	echo "DUMMY" > $@
endif

qemu_clang_tests: qemu_clang_tests.xml
qemu_clang_tests.xml: $(QEMU_CLANG_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(QEMU_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=$@ -v $(CLANG_TESTDIRS) || true

PURECAP_TESTS := $(basename $(TEST_PURECAP_FILES))
PURECAP_TEST_LOGS := $(addsuffix .log,$(addprefix $(QEMU_LOGDIR)/,$(PURECAP_TESTS)))
PURECAP_DUMPS := $(addsuffix .dump,$(addprefix $(OBJDIR)/,$(PURECAP_TESTS)))
purecap_dumps: $(PURECAP_DUMPS)
qemu_purecap_tests: qemu_purecap_tests.xml
qemu_purecap_tests.xml: $(PURECAP_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(QEMU_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=$@ -v $(PURECAP_TESTDIRS) || true

qemu_purecap_symbolized_logs: $(addsuffix .log.symbolized,$(addprefix $(QEMU_LOGDIR)/,$(PURECAP_TESTS)))

pytest_qemu_purecap_tests: pytest_qemu_purecap_tests.xml
pytest_qemu_purecap_tests.xml: $(PURECAP_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(QEMU_PYTEST) --junit-xml=$@ -v $(PURECAP_TESTDIRS) || true

CP2_TESTS := $(basename $(TEST_CP2_FILES))
CP2_TEST_LOGS := $(addsuffix .log,$(addprefix $(QEMU_LOGDIR)/,$(CP2_TESTS)))
#CP2_DUMPS := $(addsuffix .dump,$(addprefix $(OBJDIR)/,$(CP2_TESTS)))
#cp2_dumps: $(CP2_DUMPS)
pytest_qemu_cp2_tests: pytest_qemu_cp2_tests.xml
pytest_qemu_cp2_tests.xml: $(CP2_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(QEMU_PYTEST) --junit-xml=$@ $(TESTDIR)/cp2 || true

pytest_qemu_clang_tests: pytest_qemu_clang_tests.xml
pytest_qemu_clang_tests.xml: $(QEMU_CLANG_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(QEMU_PYTEST) --junit-xml=$@ -v $(CLANG_TESTDIRS) || true

pytest_qemu: pytest_qemu.xml
pytest_qemu.xml: $(QEMU_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	@echo "pytest selector: $(QEMU_NOSEFLAGS)"
	$(QEMU_PYTEST) --junit-xml=$@ $(TESTDIRS) || true

QEMU_ALL_PYTHON_TESTS=$(addprefix pytest/qemu/, $(TEST_PYTHON))
# TODO: $(NOTDIR $(BASENAME)) won't work on the % wildcard dependency
$(QEMU_ALL_PYTHON_TESTS): pytest/qemu/%.py: %.py check_valid_qemu FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(QEMU_LOGDIR)/$(notdir $(basename $@)).log
	$(QEMU_PYTEST) -v $< || true

# TODO: $(NOTDIR $(BASENAME)) won't work on the % wildcard dependency

pytest/sim_uncached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@)).log
	CACHED=0 $(SIM_NOSETESTS) $(NOSEFLAGS_UNCACHED) -v $< || true

pytest/sim_cached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@))_cached.log
	CACHED=1 $(SIM_NOSETESTS) $(NOSEFLAGS) -v $< || true

pytest/sim_multi/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@))_multi.log
	CACHED=0 MULTI1=1 $(SIM_NOSETESTS) $(NOSEFLAGS_UNCACHED) -v $< || true

pytest/sim_cachedmulti/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@))_cachedmulti.log
	MULTI1=1 CACHED=1 $(SIM_NOSETESTS) $(NOSEFLAGS) -v $< || true

# Single L3 tests:
pytest/l3_uncached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@)).log
	CACHED=0 $(L3_NOSETESTS) $(L3_NOSEFLAGS_UNCACHED) -v $< || true

pytest/l3_cached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@))_cached.log
	CACHED=1 $(L3_NOSETESTS) $(L3_NOSEFLAGS) -v $< || true

pytest/l3_multi/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@))_multi.log
	CACHED=0 MULTI1=1 $(L3_NOSETESTS) $(L3_NOSEFLAGS_UNCACHED) -v $< || true

pytest/l3_cachedmulti/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@))_cachedmulti.log
	MULTI1=1 CACHED=1 $(L3_NOSETESTS) $(L3_NOSEFLAGS) -v $< || true
