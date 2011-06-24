#
# Build system for CHERI regression tests.  Tests fall into two categories:
#
# "raw" -- which run without any prior software initialisation.  This is used
# only for a few very early tests, such as checking default register values on
# reset.  These tests must explicitly dump the register file and terminate the
# simulation.
#
# "test" -- some amount of software setup and tear-down, but running without
# the TLB enabled.  Tests implement a "test" function that accepts neither
# arguments nor returns values.  The framework will dump registers and
# terminate the simulator on completion.  This is suitable for most forms of
# tests, but not those that need to test final values of $ra, for example.
#
# Each test is accompanied by a Nose test case file, which analyses registers
# from the simulator run to decide if the test passed or not.  The Nose test
# framework drives each test, checks results, and summarises the test run on
# completion.
#
# Tests are run in the order listed in TEST_FILES; it is recommended they be
# sorted by rough functional dependence on CPU features.
#
# Note: For the time being, all tests must reside in the tests/ directory
# itself, and not in further sub-directories.
#
# "make" builds all the required parts
# "make test" runs the tests
#

TESTDIR=tests

TEST_FILES=					\
		raw_template.s			\
		raw_reg_init.s			\
		raw_reg_load_immediate.s	\
		raw_reg_load_immediate_sign.s	\
		raw_branch_unconditional.s	\
		raw_jump_reg.s			\
		raw_jump_and_link.s		\
		raw_load_byte.s			\
		raw_load_hword.s		\
		raw_load_word.s			\
		raw_load_dword.s		\
		raw_load_delay_reg.s		\
		raw_load_delay_store.s		\
		raw_store_byte.s		\
		raw_store_hword.s		\
		raw_store_word.s		\
		raw_store_dword.s		\
		test_template.s			\
		test_reg_zero.s			\
		test_reg_load_immediate.s	\
		test_reg_assignment.s		\
		test_cp0_reg_init.s		\
		test_code_rom_relocation.s	\
		test_code_ram_relocation.s	\
		test_exception_bev1_trap.s	\
		test_exception_bev0_trap.s	\
		test_exception_bev0_trap_bd.s	\
		test_exception_breakpoint.s	\
		test_exception_syscall.s	\
		test_exception_teq_eq.s		\
		test_exception_teq_ne.s		\
		test_exception_teqi_eq.s	\
		test_exception_teqi_ne.s	\
		test_exception_teqi_eq_sign.s	\
		test_exception_tge_eq.s		\
		test_exception_tge_gr.s		\
		test_exception_tge_lt.s		\
		test_exception_tgei_eq.s	\
		test_exception_tgei_gr.s	\
		test_exception_tgei_lt.s	\
		test_exception_tgei_eq_sign.s	\
		test_exception_tgei_gr_sign.s	\
		test_exception_tgei_lt_sign.s

#
# We unconditionally terminate the simulator after TEST_CYCLE_LIMIT
# instructions to ensure that loops terminate.  This is an arbitrary number.
#
TEST_CYCLE_LIMIT=3000

##############################################################################
# No need to modify anything below this point if you are just adding new
# tests to current categories.
#

OBJDIR=obj
LOGDIR=log

RAW_LDSCRIPT=raw.ld
TEST_LDSCRIPT=test.ld
TEST_INIT_OBJECT=$(OBJDIR)/init.o
TEST_LIB_OBJECT=$(OBJDIR)/lib.o

TEST_OBJECTS := $(TEST_FILES:%.s=$(OBJDIR)/%.o)
TEST_ELFS := $(TEST_FILES:%.s=$(OBJDIR)/%.elf)
TEST_MEMS := $(TEST_FILES:%.s=$(OBJDIR)/%.mem)
TEST_DUMPS := $(TEST_FILES:%.s=$(OBJDIR)/%.dump)
TEST_LOGS := $(TEST_FILES:%.s=$(LOGDIR)/%.log)

MEMCONV=python ../tools/memConv.py

all: $(TEST_MEMS) $(TEST_DUMPS)

test: nosetest

cleantest:
	rm -f $(TEST_LOGS)

clean: cleantest
	rm -f $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT)
	rm -f $(TEST_OBJECTS) $(TEST_ELFS) $(TEST_MEMS) $(TEST_DUMPS)
	rm -f *.hex mem.bin

.PHONY: all clean cleantest test nosetest failnosetest
.SECONDARY: $(TEST_OBJECTS) $(TEST_ELFS) $(TEST_MEMS) $(TEST_INIT_OBJECT) \
    $(TEST_LIB_OBJECT)

$(OBJDIR)/%.o : %.s
	sde-as -EB -march=mips64 -mabi=64 -G0 -ggdb -o $@ $<

$(OBJDIR)/%.o : $(TESTDIR)/%.s
	sde-as -EB -march=mips64 -mabi=64 -G0 -ggdb -o $@ $<

## TODO: rename these all to test_raw so that we are consistent 
$(OBJDIR)/raw_%.elf : $(OBJDIR)/raw_%.o $(RAW_LDSCRIPT)
	sde-ld -EB -G0 -T$(RAW_LDSCRIPT) $< -o $@ -m elf64btsmip

$(OBJDIR)/test_%.elf : $(OBJDIR)/test_%.o $(TEST_LDSCRIPT) \
	    $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT)
	sde-ld -EB -G0 -T$(TEST_LDSCRIPT) $(TEST_INIT_OBJECT) \
	    $(TEST_LIB_OBJECT) $< -o $@ -m elf64btsmip

$(OBJDIR)/%.mem : $(OBJDIR)/%.elf
	sde-objcopy -S -O binary $< $@

$(OBJDIR)/%.dump: $(OBJDIR)/%.elf
	sde-objdump -xsSd $< > $@

#
# memConv.py needs fixing so that it accepts explicit sources and
# destinations.  That way concurrent runs can't tread on each other, allowing
# testing with -j, etc.
#
.NOTPARALLEL:
$(LOGDIR)/%.log : $(OBJDIR)/%.mem
	cp $< mem.bin
	$(MEMCONV) bsim
	cp *.hex ..
	../sim -m $(TEST_CYCLE_LIMIT) > $@

# Simulate a failure on all unit tests
failnosetest: cleantest $(TEST_LOGS)
	DEBUG_ALWAYS_FAIL=1 PYTHONPATH=../tools nosetests $(NOSEFLAGS)

print-versions:
	nosetests --version

nosetest: all cleantest $(TEST_LOGS)
	PYTHONPATH=../tools nosetests $(NOSEFLAGS)
