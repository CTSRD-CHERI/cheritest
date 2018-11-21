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
SAIL_CHERI_C_LOGDIR=sail_cheri_c_log
SAIL_CHERI128_LOGDIR=sail_cheri128_log
SAIL_CHERI128_C_LOGDIR=sail_cheri128_c_log
# Use different logdirs for mips/128/256
ifdef MIPS_ONLY
QEMU_LOGDIR=qemu_log/mips
else
QEMU_LOGDIR=qemu_log/$(CAP_SIZE)
ifneq ($(CAP_SIZE),256)
ifeq ($(CAP_PRECISE), 1)
QEMU_LOGDIR:=$(QEMU_LOGDIR)_magic
endif
endif
endif


### Include add the _UNSUPPORTED_FEATURES variables
include Makefile.predicates.mk

FAIL_MAKE_ON_TEST_ERRORS?=0
ifeq ($(FAIL_MAKE_ON_TEST_ERRORS),0)
MAYBE_IGNORE_EXIT_CODE=-
else
MAYBE_IGNORE_EXIT_CODE=
endif


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
CTSRD_SVN_ROOT?=../../
CHERIROOT?=$(CTSRD_SVN_ROOT)/cheri$(BERI_VER)/trunk
CHERIROOT_ABS:=$(realpath $(CHERIROOT))
CHERILIBS?=$(CTSRD_SVN_ROOT)/cherilibs/trunk
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
MEMCONV=$(error Cannot find find memConv.py, set CHERILIBS to the cherilibs/trunk directory or set CTSRD_SVN_ROOT to the SVN root)
else
MEMCONV=python ${TOOLS_DIR_ABS}/memConv.py
endif

ifeq ($(wildcard $(CHERIROOT_ABS)),)
CHERI_SW_MEM_BIN=$(error Cannot find find CHERIROOT/sw/mem.bin, set CHERIROOT to the cheri/trunk directory or set CTSRD_SVN_ROOT to the SVN root)
else
CHERI_SW_MEM_BIN=${CHERIROOT_ABS}/sw/mem.bin
endif

ifeq ($(wildcard $(MEMCONF)),)
MEMCONF=$(error Cannot find find $(CHERIROOT_ABS)/memoryconfig, set CHERIROOT to the cheri/trunk directory or set CTSRD_SVN_ROOT to the SVN root )
endif

ifeq ($(wildcard $(SIM)),)
SIM_ABS=$(error Cannot find find $(SIM), set CHERIROOT to the cheri/trunk directory )
else
SIM_ABS:=$(realpath $(SIM))
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
SAIL_CHERI_C_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI_C_LOGDIR)/,$(TESTS)))
SAIL_CHERI128_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI128_LOGDIR)/,$(TESTS)))
SAIL_CHERI128_C_TEST_LOGS := $(addsuffix .log,$(addprefix \
	$(SAIL_CHERI128_C_LOGDIR)/,$(TESTS)))
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
	if [ -z "$(dollar)BLUESPECDIR" ]; then echo "BLUESPECDIR not set, source the setup.sh script first!"; exit 1; fi; \
	LD_LIBRARY_PATH=$(CHERILIBS_ABS)/peripherals \
    PISM_MODULES_PATH=$(PISM_MODULES_PATH) \
	CHERI_CONFIG=$$TMPDIR/simconfig \
	CHERI_DTB=$(DTB_FILE) \
	BERI_DEBUG_SOCKET_0=$(CHERISOCKET)  $(SIM_ABS) -w +regDump $(SIM_TRACE_OPTS) -m $(TEST_CYCLE_LIMIT) > \
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
#	BERI_DEBUG_SOCKET=$(CHERISOCKET) $(SIM_ABS) -V $(HOME)/$(1).vcd -w +regDump $(SIM_TRACE_OPTS) -m $(TEST_CYCLE_LIMIT) > \
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
	$(OBJCOPY) --strip-all -O binary $< $@

# I instantiate this specifically so that it gets used to when test_clang_dma%
# is used to build a test directly.

$(OBJDIR)/startdramtest.mem: $(OBJDIR)/startdramtest.elf
	$(OBJCOPY) --strip-all -O binary $< $@

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
$(LOGDIR)/test_raw_trac%.log: $(OBJDIR)/test_raw_trac%.mem $(CHECK_SIM_EXISTS) $(CHERICTL)
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
$(LOGDIR)/test_clang_dma%.log: $(OBJDIR)/startdramtest.mem $(OBJDIR)/test_clang_dma%.mem $(CHECK_SIM_EXISTS)
	$(call PREPARE_TEST,$<) && \
		cp $(PWD)/$(word 2, $^) . && \
		$(call REPEAT_5, CHERI_KERNEL=$(notdir $(word 2, $^)) $(RUN_TEST_COMMAND)); \
		$(CLEAN_TEST)

$(LOGDIR)/%.log : $(OBJDIR)/%.mem $(CHECK_SIM_EXISTS)
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
	-$(GXEMUL_BINDIR)/gxemul $(GXEMUL_OPTS) $< 2>&1 | $(GXEMUL_LOG_FILTER) >$@


$(GXEMUL_LOGDIR)/%_gxemul_cached.log : $(OBJDIR)/%_cached.elf
	(printf "step $(TEST_CYCLE_LIMIT)\nquit\n"; while echo > /dev/stdout; do sleep 0.01; done ) | \
	-$(GXEMUL_BINDIR)/gxemul $(GXEMUL_OPTS) $< 2>&1 | $(GXEMUL_LOG_FILTER) >$@

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
	-$(L3_SIM) --cycles `./max_cycles $@ 20000 300000` --uart-delay 0 --ignore HI --ignore LO --ignore TLB --trace 2 $(L3_MULTI) $< 2> $@.err > $@
else
ifdef PROFILE
	rm -f mlmon.out
endif
	-$(L3_SIM) --cycles `./max_cycles $@ 20000 300000` --uart-delay 0 --ignore HI --ignore LO --ignore TLB $(L3_MULTI) $< 2> $@.err > $@
ifdef PROFILE
	mlprof -raw true -show-line true `which $(L3_SIM)` mlmon.out > $(L3_LOGDIR)/$*.cover
endif
endif

$(SAIL_MIPS_LOGDIR)/%.log: $(OBJDIR)/%.elf $(SAIL_MIPS_SIM) max_cycles | $(SAIL_MIPS_LOGDIR)
	-$(TIMEOUT) 2m $(SAIL_MIPS_SIM) $< >$@ 2>&1

$(OBJDIR)/%.sailbin: $(OBJDIR)/%.elf $(SAIL)
	$(SAIL) -elf $< -o $@ 

$(SAIL_MIPS_C_LOGDIR)/%.log: $(OBJDIR)/%.sailbin $(SAIL_MIPS_C_SIM) max_cycles | $(SAIL_MIPS_C_LOGDIR)
	-$(SAIL_MIPS_C_SIM) --cyclelimit `./max_cycles $@ 20000 300000` --image $< >$@ 2>&1

$(SAIL_CHERI_LOGDIR)/%.log: $(OBJDIR)/%.elf $(SAIL_CHERI_SIM) max_cycles | $(SAIL_CHERI_LOGDIR)
	-$(TIMEOUT) 2m $(SAIL_CHERI_SIM) $< >$@ 2>&1

$(SAIL_CHERI_C_LOGDIR)/%.log: $(OBJDIR)/%.sailbin $(SAIL_CHERI_C_SIM) max_cycles | $(SAIL_CHERI_C_LOGDIR)
	-$(SAIL_CHERI_C_SIM) --cyclelimit `./max_cycles $@ 20000 300000` --image $< >$@ 2>&1

$(SAIL_CHERI128_LOGDIR)/%.log: $(OBJDIR)/%.elf $(SAIL_CHERI128_SIM) max_cycles | $(SAIL_CHERI128_LOGDIR)
	-$(TIMEOUT) 2m $(SAIL_CHERI128_SIM) $< >$@ 2>&1

$(SAIL_CHERI128_C_LOGDIR)/%.log: $(OBJDIR)/%.sailbin $(SAIL_CHERI128_C_SIM) max_cycles | $(SAIL_CHERI128_C_LOGDIR)
	-$(SAIL_CHERI128_C_SIM) --cyclelimit `./max_cycles $@ 20000 300000` --image $< >$@ 2>&1

ALL_LOGDIRS=$(L3_LOGDIR) $(QEMU_LOGDIR) $(LOGDIR) \
	$(SAIL_MIPS_LOGDIR) $(SAIL_MIPS_C_LOGDIR) \
	$(SAIL_CHERI_LOGDIR) $(SAIL_CHERI_C_LOGDIR) \
	$(SAIL_CHERI128_LOGDIR) $(SAIL_CHERI128_C_LOGDIR) \

# See ﻿https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html#Prerequisite-Types (dep has to be after a '|')
$(ALL_LOGDIRS) $(OBJDIR):
	mkdir -p "$@"


# TODO: make BERI the default once everyone has updated
ifdef MIPS_ONLY
QEMU_CPU_MODEL?=BERI
else
QEMU_CPU_MODEL?=5Kf
endif

QEMU_FLAGS=-D "$@" -cpu $(QEMU_CPU_MODEL) -bc `./max_cycles $@ 20000 300000` \
           -kernel "$<" -serial none -monitor none -nographic -m 2048M -bp 0x`$(OBJDUMP) -t "$<" | awk -f end.awk`

QEMU_MACHINE_MODEL?=mipssim
# QEMU_MACHINE_MODEL?=mipssim
ifeq ($(MULTI),1)
QEMU_FLAGS+=-smp 2 -M malta
else
QEMU_FLAGS+=-M $(QEMU_MACHINE_MODEL)
endif

# There is a use-after free due to undetermined pthread shutdown order, ignore that too:
# TODO: ASAN_OPTIONS=suppressions=QEMU_ASAN.supp
SANITIZER_ENV=UBSAN_OPTIONS=print_stacktrace=1,halt_on_error=1 LSAN_OPTIONS=suppressions=QEMU_LEAKS.supp

# We can't have the logfile targets depend on $(QEMU) since that gives the
# following useless error if $(QEMU) doesn't exist:
# make: *** No rule to make target 'qemu_log/mips/test_raw_template.log', needed by 'qemu_logs'. Stop.
# By indirecting through an existing target the wildcard rule will be created and
# if we create an output file here all logfiles are recreated if QEMU changes
# TODO: do the same for sail,sim, etc!
CHECK_QEMU_EXISTS=$(QEMU_LOGDIR)/.qemu_exists
$(CHECK_QEMU_EXISTS): $(QEMU) | $(QEMU_LOGDIR) check_valid_qemu
	$(QEMU) --version > "$@"
	@echo "CHECKED $(QEMU)"

CHECK_SIM_EXISTS=$(LOGDIR)/.qemu_exists
$(CHECK_SIM_EXISTS): $(SIM) | $(LOGDIR)
	$(SIM_ABS) --version > "$@"
	@echo "CHECKED $(SIM_ABS)"


# raw tests need to be started with tracing in, for the others we can start it in init.s
$(QEMU_LOGDIR)/test_raw_%.log: $(OBJDIR)/test_raw_%.elf max_cycles $(CHECK_QEMU_EXISTS) | $(QEMU_LOGDIR)
	@echo "$(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) -d instr > /dev/null"
	@env $(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) -d instr 2>&1 >/dev/null; \
	    exit_code=$(dollar)?; \
	    if [ "$(dollar)exit_code" -ne 255 ] && [ "$(dollar)exit_code" -ne 0 ]; then \
	        echo "UNEXPECTED EXIT CODE $(dollar)exit_code"; rm -f "$@"; false; \
	    fi
	@if ! test -e "$@"; then echo "ERROR: QEMU didn't create $@"; false ; fi
	@if ! test -s "$@"; then echo "ERROR: QEMU created a zero size logfile for $@"; rm "$@"; false ; fi

FAIL_FAST_QEMU_ERROR?=0
ifneq ($(FAIL_FAST_QEMU_ERROR),0)
fail_qemu_logfile=rm -f "$@"; false
else
fail_qemu_logfile=true
endif


$(QEMU_LOGDIR)/%.log: $(OBJDIR)/%.elf max_cycles $(CHECK_QEMU_EXISTS) | $(QEMU_LOGDIR)
	@echo "$(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) > /dev/null"
	@env $(SANITIZER_ENV) $(QEMU) $(QEMU_FLAGS) 2>&1 >/dev/null; \
	    exit_code=$(dollar)?; \
	    if [ "$(dollar)exit_code" -ne 255 ] && [ "$(dollar)exit_code" -ne 0 ]; then \
	        echo "UNEXPECTED EXIT CODE $(dollar)exit_code"; $(fail_qemu_logfile); \
	    fi
	@if ! test -e "$@"; then echo "ERROR: QEMU didn't create $@"; $(fail_qemu_logfile) ; fi
	@if ! test -s "$@"; then echo "ERROR: QEMU created a zero size logfile for $@"; $(fail_qemu_logfile) ; fi

$(QEMU_LOGDIR)/%.log.symbolized: $(QEMU_LOGDIR)/%.log
	$(CHERI_SDK_BINDIR)/symbolize-cheri-trace.py $< "$(OBJDIR)/`basename $< .log`.elf" > $@

clion/$(QEMU_LOGDIR)/%.log.symbolized: $(QEMU_LOGDIR)/%.log.symbolized
	clion $(abspath $<)






#### Run python to generate XUnit XML:

### Configure pytest invocation:

# TODO: for now also run with python 2.7 but we should update to 3.x soon
NOSETESTS?=python3 -m pytest -q
_PYTEST_INSTALLED_STR=This is pytest
PYTEST_VERSION_OUTPUT=$(shell $(NOSETESTS) --version 2>&1)
PYTEST_CHECK1=$(if $(findstring $(_PYTEST_INSTALLED_STR),$(PYTEST_VERSION_OUTPUT)),@echo pytest is installed,$(error pytest not installed? Try running `pip3 install --user pytest`. Got error running $(NOSETESTS) --version: $(PYTEST_VERSION_OUTPUT)"))
PYTEST_CHECK2=$(if $(findstring requires pytest-,$(PYTEST_VERSION_OUTPUT)),$(error pytest version is too old. Try running `pip3 install --upgrade --user pytest`),@echo installed pytest version is new enough)


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

NOSETESTS:=CAP_SIZE=$(CAP_SIZE) $(NOSETESTS)
PYTEST:=CAP_SIZE=$(CAP_SIZE) $(PYTEST)

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
nose_fuzz: $(CHECK_SIM_EXISTS) fuzz_run_tests
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=0 $(NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_fuzz.xml \
	    $(NOSEFLAGS_UNCACHED) tests/fuzz

nose_fuzz_cached: $(CHECK_SIM_EXISTS) fuzz_run_tests_cached
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=1 $(NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_fuzz_cached.xml \
	    $(NOSEFLAGS) tests/fuzz


ifndef BLUESPECDIR
_SIM_MAKE=source $(CHERIROOT_ABS)/setup.sh && $(MAKE)
else
_SIM_MAKE=$(MAKE)
endif

nosetest:
	$(_SIM_MAKE) nosetests_uncached.xml

nosetest_cached:
	$(_SIM_MAKE) nosetests_cached.xml

nosetests_multi:
	$(_SIM_MAKE) nosetests_multi.xml

nosetests_cachedmulti:
	$(_SIM_MAKE) nosetests_cachedmulti.xml

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
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=0 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_uncached.xml \
	$(NOSEFLAGS_UNCACHED) $(TESTDIRS)

nosetests_cached.xml: $(CHERI_TEST_CACHED_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=1 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_cached.xml \
	$(NOSEFLAGS) $(TESTDIRS)

nosetests_multi.xml: $(CHERI_TEST_MULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env MULTI1=1 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_multi.xml \
	$(NOSEFLAGS) $(TESTDIRS)

nosetests_cachedmulti.xml: $(CHERI_TEST_CACHEDMULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env MULTI1=1 CACHED=1 $(SIM_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_cachedmulti.xml \
	$(NOSEFLAGS) $(TESTDIRS)

altera-nosetest: all $(ALTERA_TEST_LOGS)
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=0 $(ALTERA_NOSETESTS) \
	    $(NOSEFLAGS_UNCACHED) $(ALTERA_NOSEFLAGS) $(TESTDIRS)

altera-nosetest_cached: all $(ALTERA_TEST_CACHED_LOGS)
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=1 $(ALTERA_NOSETESTS) \
	    $(NOSEFLAGS) $(ALTERA_NOSEFLAGS) $(TESTDIRS)

hwsim-nosetest: $(CHERISOCKET) all $(HWSIM_TEST_LOGS)
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=0 $(HWSIM_NOSETESTS) \
	$(NOSEFLAGS_UNCACHED) $(HWSIM_NOSEFLAGS) $(TESTDIRS)

hwsim-nosetest_cached: $(CHERISOCKET) all $(HWSIM_TEST_CACHED_LOGS)
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=1 $(HWSIM_NOSETESTS) \
	    $(NOSEFLAGS) $(HWSIM_NOSEFLAGS) $(TESTDIRS)

nosetests_gxemul: nosetests_gxemul_uncached.xml

nosetests_gxemul_uncached.xml: $(GXEMUL_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env PYTHONPATH=tools/gxemul CACHED=0 $(NOSETESTS) \
	    $(PYTHON_TEST_XUNIT_FLAG)=nosetests_gxemul_uncached.xml \
	    $(GXEMUL_NOSEFLAGS) $(TESTDIRS)

nosetests_gxemul_cached: nosetests_gxemul_cached.xml

nosetests_gxemul_cached.xml: $(GXEMUL_TEST_CACHED_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env PYTHONPATH=tools/gxemul CACHED=1 $(NOSETESTS) \
	    $(PYTHON_TEST_XUNIT_FLAG)=nosetests_gxemul_cached.xml \
	    $(GXEMUL_NOSEFLAGS) $(TESTDIRS)

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
	$(MAYBE_IGNORE_EXIT_CODE)$(L3_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3.xml \
	$(L3_NOSEFLAGS_UNCACHED) $(TESTDIRS)

nosetests_l3_cached.xml: $(L3_TEST_CACHED_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=1 $(L3_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3_cached.xml \
	$(L3_NOSEFLAGS) $(TESTDIRS)

nosetests_l3_multi.xml: $(L3_TEST_MULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env MULTI1=1 $(L3_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3_multi.xml \
	$(L3_NOSEFLAGS_UNCACHED) $(TESTDIRS)

nosetests_l3_cachedmulti.xml: $(L3_TEST_CACHEDMULTI_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env CACHED=1 MULTI1=1 $(L3_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=nosetests_l3_cachedmulti.xml $(L3_NOSEFLAGS) \
	    $(TESTDIRS)

_CHECK_FILE_EXIST=$(if $(wildcard $(shell command -v $(1) 2>/dev/null)),$(info SAIL_MIPS_SIM=$(1)),$(error $(2) not found in expected path: "$(1)"))
check_sail_deps: FORCE
	@echo Checking if timeout command exists:
	@which $(TIMEOUT)

nosetests_sail: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_MIPS_SIM), sail MIPS)
	$(MAKE) $(MFLAGS) nosetests_sail.xml
nosetests_sail_mips_c: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_MIPS_C_SIM), sail MIPS_C)
	$(MAKE) $(MFLAGS) nosetests_sail_mips_c.xml
nosetests_sail_cheri: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_CHERI_SIM), sail CHERI256)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri.xml
nosetests_sail_cheri_c: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_CHERI_C_SIM), sail CHERI_C)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri_c.xml
nosetests_sail_cheri128: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_CHERI128_SIM), sail CHERI128)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri128.xml
nosetests_sail_cheri128_c: check_sail_deps FORCE
	$(call _CHECK_FILE_EXIST, $(SAIL_CHERI128_C_SIM), sail CHERI128_C)
	$(MAKE) $(MFLAGS) nosetests_sail_cheri128_c.xml

nosetests_sail.xml: $(SAIL_MIPS_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(SAIL_MIPS_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_MIPS_NOSEFLAGS) \
	     $(TESTDIRS)

nosetests_sail_mips_c.xml: $(SAIL_MIPS_C_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(SAIL_MIPS_C_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_MIPS_NOSEFLAGS) \
	    $(TESTDIRS)

nosetests_sail_cheri.xml: $(SAIL_CHERI_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(SAIL_CHERI_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI_NOSEFLAGS) \
	     $(TESTDIRS)

nosetests_sail_cheri_c.xml: $(SAIL_CHERI_C_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(SAIL_CHERI_C_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI_NOSEFLAGS) \
	    $(TESTDIRS)

nosetests_sail_cheri128.xml: $(SAIL_CHERI128_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(SAIL_CHERI128_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI128_NOSEFLAGS) \
	   $(TESTDIRS)

nosetests_sail_cheri128_c.xml: $(SAIL_CHERI128_C_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(SAIL_CHERI128_C_LOGDIR) $(SAIL_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(SAIL_CHERI128_NOSEFLAGS) \
	    $(TESTDIRS)

.PHONY: nosetests_qemu check_valid_qemu

nosetests_qemu:
	$(call _CHECK_FILE_EXIST, $(QEMU), QEMU)
	$(MAKE) $(MFLAGS) nosetests_qemu.xml

check_valid_qemu:
	@echo "Checking if QEMU $(QEMU_ABSPATH) is valid for this configuration:"
	$(QEMU) --version
ifndef MIPS_ONLY
	@echo "CAP_PRECISE='$(CAP_PRECISE)', QEMU_CAP_PRECISE='$(QEMU_CAP_PRECISE)'"
	@echo "CAP_SIZE='$(CAP_SIZE)', QEMU_CAP_SIZE='$(QEMU_CAP_SIZE)'"
	@if [ "$(CAP_PRECISE)" != "$(QEMU_CAP_PRECISE)" ]; then \
		echo "CAP_PRECISE set to '$(CAP_PRECISE)' but QEMU precise capabilities=$(QEMU_CAP_PRECISE). Change CAP_PRECISE or select a different $(dollar)QEMU"; \
		exit 1; \
	fi
	@if [ "$(CAP_SIZE)" != "$(QEMU_CAP_SIZE)" ]; then \
		echo "CAP_SIZE set to '$(CAP_SIZE)' but QEMU capability size='$(QEMU_CAP_SIZE)'. Change CAP_SIZE or select a different $(dollar)QEMU"; \
		exit 1; \
	fi
endif
	@echo "Success. Can run tests with $(QEMU_ABSPATH)"


# set TEST_MACHINE to QEMU to mark tests that are not implemented as xfail
nosetests_qemu.xml: $(QEMU_TEST_LOGS) check_pytest_version $(TEST_PYTHON) check_valid_qemu FORCE
	@echo "Pytest flags: $(QEMU_NOSEFLAGS)"
	$(MAYBE_IGNORE_EXIT_CODE)env LOGDIR=$(QEMU_LOGDIR) $(QEMU_NOSETESTS) \
	$(PYTHON_TEST_XUNIT_FLAG)=$@ $(TESTDIRS)

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
	$(MAYBE_IGNORE_EXIT_CODE)$(QEMU_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=$@ -v $(CLANG_TESTDIRS)

PURECAP_TESTS := $(basename $(TEST_PURECAP_FILES))
PURECAP_TEST_LOGS := $(addsuffix .log,$(addprefix $(QEMU_LOGDIR)/,$(PURECAP_TESTS)))
PURECAP_DUMPS := $(addsuffix .dump,$(addprefix $(OBJDIR)/,$(PURECAP_TESTS)))
purecap_dumps: $(PURECAP_DUMPS)
qemu_purecap_tests: qemu_purecap_tests.xml
qemu_purecap_tests.xml: $(PURECAP_TEST_LOGS) check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)$(QEMU_NOSETESTS) $(PYTHON_TEST_XUNIT_FLAG)=$@ -v $(PURECAP_TESTDIRS)

qemu_purecap_symbolized_logs: $(addsuffix .log.symbolized,$(addprefix $(QEMU_LOGDIR)/,$(PURECAP_TESTS)))

pytest_qemu_purecap_tests: pytest_qemu_purecap_tests.xml
pytest_qemu_purecap_tests.xml: $(PURECAP_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)$(QEMU_PYTEST) --junit-xml=$@ -v $(PURECAP_TESTDIRS)

CP2_TESTS := $(basename $(TEST_CP2_FILES))
CP2_TEST_LOGS := $(addsuffix .log,$(addprefix $(QEMU_LOGDIR)/,$(CP2_TESTS)))
#CP2_DUMPS := $(addsuffix .dump,$(addprefix $(OBJDIR)/,$(CP2_TESTS)))
#cp2_dumps: $(CP2_DUMPS)
pytest_qemu_cp2_tests: pytest_qemu_cp2_tests.xml
pytest_qemu_cp2_tests.xml: $(CP2_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)$(QEMU_PYTEST) --junit-xml=$@ $(TESTDIR)/cp2

pytest_qemu_clang_tests: pytest_qemu_clang_tests.xml
pytest_qemu_clang_tests.xml: $(QEMU_CLANG_TEST_LOGS) check_valid_qemu check_pytest_version $(TEST_PYTHON) FORCE
	$(MAYBE_IGNORE_EXIT_CODE)$(QEMU_PYTEST) --junit-xml=$@ -v $(CLANG_TESTDIRS)

qemu_logs: $(QEMU_TEST_LOGS)
qemu_logs256:
	$(MAKE) CAP_SIZE=256 CAP_PRECISE=1 qemu_logs
qemu_logs128:
	$(MAKE) CAP_SIZE=128 CAP_PRECISE=0 qemu_logs
qemu_logs128magic:
	$(MAKE) CAP_SIZE=128 CAP_PRECISE=1 qemu_logs


pytest_qemu_mips:
	$(MAKE) CAP_SIZE=0 nosetests_qemu
pytest_qemu256:
	$(MAKE) CAP_SIZE=256 CAP_PRECISE=1 nosetests_qemu
pytest_qemu128:
	$(MAKE) CAP_SIZE=128 CAP_PRECISE=0 nosetests_qemu
pytest_qemu128magic:
	$(MAKE) CAP_SIZE=128 CAP_PRECISE=1 nosetests_qemu

pytest_qemu_all:
	# first build all the binaries to check for assembler errors (and to make use of parallelism)
	@$(MAKE) elfs128 elfs256
	# Also generate the QEMU lots in parallel:
	@$(MAKE) qemu_logs256 qemu_logs128 qemu_logs128magic
	# But these steps should run sequentially:
	$(MAKE) FAIL_MAKE_ON_TEST_ERRORS=1 pytest_qemu256
	$(MAKE) FAIL_MAKE_ON_TEST_ERRORS=1 pytest_qemu128
	$(MAKE) FAIL_MAKE_ON_TEST_ERRORS=1 pytest_qemu128magic

# pytest -rxXs  # show extra info on xfailed, xpassed, and skipped tests
SINGLE_TEST_VERBOSE=-v -rxXs

QEMU_ALL_PYTHON_TESTS=$(addprefix pytest/qemu/, $(TEST_PYTHON))
# TODO: $(NOTDIR $(BASENAME)) won't work on the % wildcard dependency
$(QEMU_ALL_PYTHON_TESTS): pytest/qemu/%.py: %.py check_valid_qemu FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(QEMU_LOGDIR)/$(notdir $(basename $@)).log
	$(QEMU_PYTEST) $(SINGLE_TEST_VERBOSE) $<

# TODO: $(NOTDIR $(BASENAME)) won't work on the % wildcard dependency

pytest/sim_uncached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(_SIM_MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@)).log
	CACHED=0 $(SIM_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(NOSEFLAGS_UNCACHED) $<

pytest/sim_cached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(_SIM_MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@))_cached.log
	CACHED=1 $(SIM_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(NOSEFLAGS) $<

pytest/sim_multi/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(_SIM_MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@))_multi.log
	CACHED=0 MULTI1=1 $(SIM_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(NOSEFLAGS_UNCACHED) $<

pytest/sim_cachedmulti/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(_SIM_MAKE) $(MFLAGS) $(LOGDIR)/$(notdir $(basename $@))_cachedmulti.log
	MULTI1=1 CACHED=1 $(SIM_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(NOSEFLAGS) $<

# Single L3 tests:
pytest/l3_uncached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@)).log
	CACHED=0 $(L3_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(L3_NOSEFLAGS_UNCACHED) $<

pytest/l3_cached/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@))_cached.log
	CACHED=1 $(L3_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(L3_NOSEFLAGS) $<

pytest/l3_multi/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@))_multi.log
	CACHED=0 MULTI1=1 $(L3_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(L3_NOSEFLAGS_UNCACHED) $<

pytest/l3_cachedmulti/%.py: %.py FORCE
	# echo "DEPS: $^ "
	$(MAKE) $(MFLAGS) $(L3_LOGDIR)/$(notdir $(basename $@))_cachedmulti.log
	MULTI1=1 CACHED=1 $(L3_NOSETESTS) $(SINGLE_TEST_VERBOSE) $(L3_NOSEFLAGS) $<


# run single sail test:
_RUN_SINGLE_SAIL_TEST=$(MAKE) $(MFLAGS) $(strip $(1))/$(notdir $(basename $@)).log && env "LOGDIR=$(strip $(1))" $(filter-out -q,$(SAIL_NOSETESTS) $(SINGLE_TEST_VERBOSE)) $(2) -v $<

pytest/sail_mips/%.py: %.py FORCE
	$(call _RUN_SINGLE_SAIL_TEST, $(SAIL_MIPS_LOGDIR), $(SAIL_MIPS_NOSEFLAGS))
pytest/sail_mips_c/%.py: %.py FORCE
	$(call _RUN_SINGLE_SAIL_TEST, $(SAIL_MIPS_LOGDIR), $(SAIL_MIPS_NOSEFLAGS))
pytest/sail_cheri/%.py: %.py FORCE
	$(call _RUN_SINGLE_SAIL_TEST, $(SAIL_CHERI_LOGDIR), $(SAIL_CHERI_NOSEFLAGS))
pytest/sail_cheri_c/%.py: %.py FORCE
	$(call _RUN_SINGLE_SAIL_TEST, $(SAIL_CHERI_C_LOGDIR), $(SAIL_CHERI_NOSEFLAGS))
pytest/sail_cheri128/%.py: %.py FORCE
	$(call _RUN_SINGLE_SAIL_TEST, $(SAIL_CHERI128_LOGDIR), $(SAIL_CHERI128_NOSEFLAGS))
pytest/sail_cheri128_c/%.py: %.py FORCE
	$(call _RUN_SINGLE_SAIL_TEST, $(SAIL_CHERI128_C_LOGDIR), $(SAIL_CHERI128_NOSEFLAGS))
