#
# Build system for CHERI regression tests.  Tests fall into three categories:
#
# "raw" -- which run without any prior software initialisation.  This is used
# only for a few very early tests, such as checking default register values on
# reset.  These tests must explicitly dump the register file and terminate the
# simulation.  Source file names must match the pattern "test_raw_*.s".
#
# "test" -- some amount of software setup and tear-down, but running without
# the TLB enabled.  Tests implement a "test" function that accepts neither
# arguments nor returns values.  The framework will dump registers and
# terminate the simulator on completion.  This is suitable for most forms of
# tests, but not those that need to test final values of $ra, for example.
# Source file names must match the pattern "test_*.s".
#
# "c" -- tests written in the C language; similar to the "test" category, but
# based on a .c input file containing a single function test() with similar
# properties to the "test" case.  Source file names must match the pattern
# "test_*.c".
#
# As a further dimension, each test is run in two forms: at the default start
# address in the uncached xkphys region, and relocated to the cached xkphys
# region.  The latter requires an additional instructions to jump to the
# cached start location when the test begins.  Notice that there are .celf,
# .cmem, etc, indicating the version linked for cached instructions.
#
# Each test is accompanied by a Nose test case file, which analyses registers
# from the simulator run to decide if the test passed or not.  The Nose test
# framework drives each test, checks results, and summarises the test run on
# completion.
#
# Tests are run in the order listed in TEST_FILES; it is recommended they be
# sorted by rough functional dependence on CPU features.
#
# All tests must be in the $(TESTDIR) tree; if you add new sub-directories,
# remember to add them to $(TESTDIRS).  Some tests are annotated with Nose
# attributes so that they will be excluded on gxemul -- see GXEMUL_NOSEFLAGS.
#
# "make" builds all the required parts
# "make test" runs the tests through CHERI
# "make gxemul-test" runs the tests through gxemul
#

#
# List of directories in which to find test source and .py files.
#
TESTDIR=tests
TESTDIRS=					\
		$(TESTDIR)/framework		\
		$(TESTDIR)/alu			\
		$(TESTDIR)/branch		\
		$(TESTDIR)/mem			\
		$(TESTDIR)/cache		\
		$(TESTDIR)/cp0                  \
		$(TESTDIR)/cp2

RAW_FRAMEWORK_FILES=				\
		test_raw_template.s		\
		test_raw_reg_init.s		\
		test_raw_hilo.s			\
		test_raw_dli.s			\
		test_raw_dli_sign.s		\
		test_raw_reg_name.s		\
		test_raw_nop.s			\
		test_raw_ssnop.s		\
		test_raw_lui.s			\
		test_raw_counterdev.s

RAW_ALU_FILES=					\
		test_raw_add.s			\
		test_raw_addi.s			\
		test_raw_addiu.s		\
		test_raw_addu.s			\
		test_raw_and.s			\
		test_raw_arithmetic_combo.s	\
		test_raw_sub.s			\
		test_raw_subu.s			\
		test_raw_dadd.s			\
		test_raw_daddi.s		\
		test_raw_daddiu.s		\
		test_raw_daddu.s		\
		test_raw_dsub.s			\
		test_raw_dsubu.s		\
		test_raw_andi.s			\
		test_raw_nor.s			\
		test_raw_or.s			\
		test_raw_ori.s			\
		test_raw_xor.s			\
		test_raw_xori.s			\
		test_raw_sll.s			\
		test_raw_sllv.s			\
		test_raw_srl.s			\
		test_raw_srlv.s			\
		test_raw_sra.s			\
		test_raw_srav.s			\
		test_raw_dsll.s			\
		test_raw_dsllv.s		\
		test_raw_dsll32.s		\
		test_raw_dsrl.s			\
		test_raw_dsrlv.s		\
		test_raw_dsrl32.s		\
		test_raw_dsra.s			\
		test_raw_dsrav.s		\
		test_raw_dsra32.s

RAW_BRANCH_FILES=				\
		test_raw_jump.s			\
		test_raw_b.s			\
		test_raw_beq_eq.s		\
		test_raw_beq_eq_back.s		\
		test_raw_beq_gt.s		\
		test_raw_beq_lt.s		\
		test_raw_beql_eq.s		\
		test_raw_beql_eq_back.s		\
		test_raw_beql_gt.s		\
		test_raw_beql_lt.s		\
		test_raw_bgez_eq.s		\
		test_raw_bgez_eq_back.s		\
		test_raw_bgez_gt.s		\
		test_raw_bgez_lt.s		\
		test_raw_bgezal_eq.s		\
		test_raw_bgezal_eq_back.s	\
		test_raw_bgezal_gt.s		\
		test_raw_bgezal_lt.s		\
		test_raw_bgezall_eq.s		\
		test_raw_bgezall_eq_back.s	\
		test_raw_bgezall_gt.s		\
		test_raw_bgezall_lt.s		\
		test_raw_bgezl_eq.s		\
		test_raw_bgezl_eq_back.s	\
		test_raw_bgezl_gt.s		\
		test_raw_bgezl_lt.s		\
		test_raw_bgtz_eq.s		\
		test_raw_bgtz_gt_back.s		\
		test_raw_bgtz_gt.s		\
		test_raw_bgtz_lt.s		\
		test_raw_bgtzl_eq.s		\
		test_raw_bgtzl_gt_back.s	\
		test_raw_bgtzl_gt.s		\
		test_raw_bgtzl_lt.s		\
		test_raw_blez_eq_back.s		\
		test_raw_blez_eq.s		\
		test_raw_blez_gt.s		\
		test_raw_blez_lt.s		\
		test_raw_blezl_eq_back.s	\
		test_raw_blezl_eq.s		\
		test_raw_blezl_gt.s		\
		test_raw_blezl_lt.s		\
		test_raw_bltz_eq.s		\
		test_raw_bltz_gt.s		\
		test_raw_bltz_lt_back.s		\
		test_raw_bltz_lt.s		\
		test_raw_bltzal_eq.s		\
		test_raw_bltzal_gt.s		\
		test_raw_bltzal_lt_back.s	\
		test_raw_bltzal_lt.s		\
		test_raw_bltzall_eq.s		\
		test_raw_bltzall_gt.s		\
		test_raw_bltzall_lt_back.s	\
		test_raw_bltzall_lt.s		\
		test_raw_bltzl_eq.s		\
		test_raw_bltzl_gt.s		\
		test_raw_bltzl_lt.s		\
		test_raw_bltzl_lt_back.s	\
		test_raw_bne_eq.s		\
		test_raw_bne_gt.s		\
		test_raw_bne_lt_back.s		\
		test_raw_bne_lt.s		\
		test_raw_bnel_eq.s		\
		test_raw_bnel_gt.s		\
		test_raw_bnel_lt_back.s		\
		test_raw_bnel_lt.s		\
		test_raw_jr.s			\
		test_raw_jal.s			\
		test_raw_jalr.s

RAW_MEM_FILES=					\
		test_raw_lb.s			\
		test_raw_lh.s			\
		test_raw_lw.s			\
		test_raw_ld.s			\
		test_raw_ld_beq_gt_pipeline.s	\
		test_raw_load_delay_reg.s	\
		test_raw_load_delay_store.s	\
		test_raw_sb.s			\
		test_raw_sh.s			\
		test_raw_sw.s			\
		test_raw_sd.s			\
		test_raw_ldl.s			\
		test_raw_ldr.s			\
		test_raw_lwl.s			\
		test_raw_lwr.s			\
		test_raw_sdl.s			\
		test_raw_sdr.s			\
		test_raw_swl.s			\
		test_raw_swr.s

RAW_LLSC_FILES=					\
		test_raw_ll.s			\
		test_raw_lld.s			\
		test_raw_sc.s			\
		test_raw_scd.s

RAW_CP0_FILES=					\
		test_raw_mfc0_dmfc0.s		\
		test_raw_mtc0_sign_extend.s

RAW_CP2_FILES=					\
		test_raw_capinstructions.s

TEST_FRAMEWORK_FILES=				\
		test_template.s			\
		test_reg_zero.s			\
		test_dli.s			\
		test_move.s			\
		test_movz_movn_pipeline.s	\
		test_code_rom_relocation.s	\
		test_code_ram_relocation.s	\
		test_ctemplate.c		\
		test_casmgp.c			\
		test_cretval.c			\
		test_crecurse.c			\
		test_cglobals.c

TEST_ALU_FILES=					\
		test_hilo.s			\
		test_div.s			\
		test_divu.s			\
		test_ddiv.s			\
		test_ddivu.s			\
		test_mult.s			\
		test_multu.s			\
		test_dmult.s			\
		test_dmultu.s			\
		test_madd.s			\
		test_msub.s			\
		test_mul_div_loop.s		\
		test_slt.s			\
		test_slti.s			\
		test_sltiu.s			\
		test_sltu.s

TEST_MEM_FILES=					\
		test_hardware_mappings.s	\
		test_hardware_mappings_write.s

TEST_LLSC_FILES=				\
		test_ll_unalign.s		\
		test_lld_unalign.s		\
		test_sc_unalign.s		\
		test_scd_unalign.s		\
		test_llsc.s			\
		test_lldscd.s			\
		test_cp0_lladdr.s

TEST_CACHE_FILES=				\
		test_hardware_mapping_cached_read.s

TEST_CP0_FILES=					\
		test_cp0_reg_init.s		\
		test_eret.s			\
		test_exception_bev0_trap.s	\
		test_exception_bev0_trap_bd.s	\
		test_break.s			\
		test_syscall.s			\
		test_syscall2.s			\
		test_syscall50.s		\
		test_syscall_cache_store.s	\
		test_teq_eq.s			\
		test_teq_gt.s			\
		test_teq_lt.s			\
		test_tge_eq.s			\
		test_tge_gt.s			\
		test_tge_lt.s			\
		test_tgeu_eq.s			\
		test_tgeu_gt.s			\
		test_tgeu_lt.s			\
		test_tlt_eq.s			\
		test_tlt_gt.s			\
		test_tlt_lt.s			\
		test_tltu_eq.s			\
		test_tltu_gt_sign.s		\
		test_tltu_gt.s			\
		test_tltu_lt.s			\
		test_tne_eq.s			\
		test_tne_gt.s			\
		test_tne_lt.s			\
		test_cp0_compare.s

TEST_CP2_FILES=					\
		test_cp2_reg_init.s		\
		test_cp2_reg_name.s		\
		test_cp2_getsettype.s		\
		test_cp2_getincbase.s		\
		test_cp2_getdecleng.s		\
		test_cp2_getandperm.s		\
		test_cp2_cmove.s		\
		test_cp2_cscr.s			\
		test_cp2_clcr.s			\
		test_cp2_alu_mod_pipeline.s	\
		test_cp2_mem_mod_pipeline.s	\
		test_cp2_get_alu_pipeline.s	\
		test_cp2_get_mem_pipeline.s	\
		test_cp2_cldr_priv.s		\
		test_cp2_clwr_priv.s		\
		test_cp2_clhr_priv.s		\
		test_cp2_clbr_priv.s		\
		test_cp2_cldr_unpriv.s		\
		test_cp2_clwr_unpriv.s		\
		test_cp2_clhr_unpriv.s		\
		test_cp2_clbr_unpriv.s		\
		test_cp2_cld_unpriv.s		\
		test_cp2_clw_unpriv.s		\
		test_cp2_clh_unpriv.s		\
		test_cp2_clb_unpriv.s		\
		test_cp2_c0_ld.s		\
		test_cp2_c0_lwu.s		\
		test_cp2_c0_lhu.s		\
		test_cp2_c0_lbu.s

TEST_ALU_OVERFLOW_FILES=			\
		test_add_overflow.s		\
		test_addi_overflow.s		\
		test_addiu_overflow.s		\
		test_addu_overflow.s		\
		test_dadd_overflow.s		\
		test_daddi_overflow.s		\
		test_daddiu_overflow.s		\
		test_daddu_overflow.s		\
		test_dsub_overflow.s		\
		test_dsubu_overflow.s		\
		test_sub_overflow.s		\
		test_subu_overflow.s		\
		test_madd_lo_overflow.s

TEST_MEM_UNALIGN_FILES=				\
		test_lh_unalign.s		\
		test_lw_unalign.s		\
		test_ld_unalign.s		\
		test_sh_unalign.s		\
		test_sw_unalign.s		\
		test_sd_unalign.s

TEST_BEV1_FILES=				\
		test_exception_bev1_trap.s

TEST_TRAPI_FILES=				\
		test_teqi_eq.s			\
		test_teqi_gt.s			\
		test_teqi_lt.s			\
		test_teqi_eq_sign.s		\
		test_tgei_eq.s			\
		test_tgei_gt.s			\
		test_tgei_lt.s			\
		test_tgei_eq_sign.s		\
		test_tgei_gt_sign.s		\
		test_tgei_lt_sign.s		\
		test_tgeiu_eq.s			\
		test_tgeiu_gt.s			\
		test_tgeiu_lt.s			\
		test_tlti_eq.s			\
		test_tlti_gt.s			\
		test_tlti_lt.s			\
		test_tlti_eq_sign.s		\
		test_tlti_gt_sign.s		\
		test_tlti_lt_sign.s		\
		test_tltiu_eq.s			\
		test_tltiu_gt_sign.s		\
		test_tltiu_gt.s			\
		test_tltiu_lt.s			\
		test_tnei_eq_sign.s		\
		test_tnei_eq.s			\
		test_tnei_gt_sign.s		\
		test_tnei_gt.s			\
		test_tnei_lt_sign.s		\
		test_tnei_lt.s

#
# All unit tests.  Implicitly, these will all be run for CHERI, but subsets
# may be used for other targets.
#
TEST_FILES=					\
		$(RAW_FRAMEWORK_FILES)		\
		$(RAW_ALU_FILES)		\
		$(RAW_BRANCH_FILES)		\
		$(RAW_MEM_FILES)		\
		$(RAW_LLSC_FILES)		\
		$(RAW_CP0_FILES)		\
		$(TEST_FRAMEWORK_FILES)		\
		$(TEST_ALU_FILES)		\
		$(TEST_MEM_FILES)		\
		$(TEST_LLSC_FILES)		\
		$(TEST_CACHE_FILES)		\
		$(TEST_CP0_FILES)		\
		$(TEST_CP2_FILES)		\
		$(TEST_BEV1_FILES)		\
		$(TEST_ALU_OVERFLOW_FILES)	\
		$(TEST_MEM_UNALIGN_FILES)	\
		$(TEST_TRAPI_FILES)

#
# Omit certain categories of tests due to gxemul functional omissions:
#
# llsc - gxemul terminates the simulator on load linked, store conditional
# cache - gxemul does not simulate a cache
# bev1 - gxemul does not support early boot exception vectors
# trapi - gxemul does not implement trap instructions with immediate
#         arguments
#
# Some tests are omitted as CHERI-specific:
#
# counterdev - gxemul does not provide the "counter" device used to test
#              cache semantics.
#
GXEMUL_NOSEFLAGS=-A "not llsc and not cache and not bev1 and not trapi and not counterdev and not capabilities"

#
# We unconditionally terminate the simulator after TEST_CYCLE_LIMIT
# instructions to ensure that loops terminate.  This is an arbitrary number.
#
TEST_CYCLE_LIMIT=20000

##############################################################################
# No need to modify anything below this point if you are just adding new
# tests to current categories.
#

CHERIROOT?=../../cheri/trunk

VPATH=$(TESTDIRS)
OBJDIR=obj
LOGDIR=log
GXEMUL_LOGDIR=gxemul_log
GXEMUL_BINDIR=tools/gxemul/CTSRD-CHERI-gxemul-8d92b42
GXEMUL_OPTS=-E oldtestmips -M 3072 -i -p "end"

RAW_LDSCRIPT=raw.ld
RAW_CACHED_LDSCRIPT=raw_cached.ld
TEST_LDSCRIPT=test.ld
TEST_CACHED_LDSCRIPT=test_cached.ld

TEST_INIT_OBJECT=$(OBJDIR)/init.o
TEST_INIT_CACHED_OBJECT=$(OBJDIR)/init_cached.o
TEST_LIB_OBJECT=$(OBJDIR)/lib.o

TESTS := $(basename $(TEST_FILES))
TEST_OBJS := $(addsuffix .o,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_ELFS := $(addsuffix .elf,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_ELFS := $(addsuffix _cached.elf,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_MEMS := $(addsuffix .mem,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_MEMS := $(addsuffix _cached.mem,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_DUMPS := $(addsuffix .dump,$(addprefix $(OBJDIR)/,$(TESTS)))
TEST_CACHED_DUMPS := $(addsuffix _cached.dump,$(addprefix $(OBJDIR)/,$(TESTS)))

CHERI_TEST_LOGS := $(addsuffix .log,$(addprefix $(LOGDIR)/,$(TESTS)))
CHERI_TEST_CACHED_LOGS := $(addsuffix _cached.log,$(addprefix \
	$(LOGDIR)/,$(TESTS)))
GXEMUL_TEST_LOGS := $(addsuffix _gxemul.log,$(addprefix \
	$(GXEMUL_LOGDIR)/,$(TESTS)))
GXEMUL_TEST_CACHED_LOGS := $(addsuffix _gxemul_cached.log,$(addprefix \
	$(GXEMUL_LOGDIR)/,$(TESTS)))

MEMCONV=python ${CHERIROOT}/tools/memConv.py
AS=mips64-as

all: $(TEST_MEMS) $(TEST_CACHED_MEMS) $(TEST_DUMPS) $(TEST_CACHED_DUMPS)

test: nosetest

test_cached: nosetest_cached

cleantest:
	rm -f $(CHERI_TEST_LOGS) $(CHERI_TEST_CACHED_LOGS)
	rm -f $(GXEMUL_TEST_LOGS) $(GXEMUL_TEST_CACHED_LOGS)

clean: cleantest
	rm -f $(TEST_INIT_OBJECT) $(TEST_INIT_CACHED_OBJECT) $(TEST_LIB_OBJECT)
	rm -f $(TEST_OBJECTS) $(TEST_ELFS) $(TEST_MEMS) $(TEST_DUMPS)
	rm -f $(TEST_CACHED_ELFS) $(TEST_CACHED_MEMS) $(TEST_CACHED_DUMPS)
	rm -f $(TESTDIR)/*/*.pyc
	rm -f *.hex mem.bin

.PHONY: all clean cleantest test nosetest failnosetest
.SECONDARY: $(TEST_OBJECTS) $(TEST_ELFS) $(TEST_MEMS) $(TEST_INIT_OBJECT) \
    $(TEST_INIT_CACHED_OBJECT) $(TEST_LIB_OBJECT)

#
# Targets for unlinked .o files.  The same .o files can be used for both
# uncached and cached runs of the suite, so we just build them once.
#
$(OBJDIR)/test_%.o : test_%.s
	$(AS) -EB -march=mips64 -mabi=64 -G0 -ggdb -o $@ $<

$(OBJDIR)/test_%.o : test_%.c
	sde-gcc -c -EB -march=mips64 -mabi=64 -G0 -ggdb -o $@ $<

$(OBJDIR)/%.o: %.s
	$(AS) -EB -march=mips64 -mabi=64 -G0 -ggdb -o $@ $<

#
# Targets for ELF images of tests running out of uncached memory.
#
$(OBJDIR)/test_raw_%.elf : $(OBJDIR)/test_raw_%.o $(RAW_LDSCRIPT)
	sde-ld -EB -G0 -T$(RAW_LDSCRIPT) $< -o $@ -m elf64btsmip

$(OBJDIR)/test_%.elf : $(OBJDIR)/test_%.o $(TEST_LDSCRIPT) \
	    $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT)
	sde-ld -EB -G0 -T$(TEST_LDSCRIPT) $(TEST_INIT_OBJECT) \
	    $(TEST_LIB_OBJECT) $< -o $@ -m elf64btsmip

#
# Targets for ELF images of tests running out of cached memory.
#
$(OBJDIR)/test_raw_%_cached.elf : $(OBJDIR)/test_raw_%.o \
	    $(TEST_INIT_CACHED_OBJECT) $(RAW_CACHED_LDSCRIPT)
	sde-ld -EB -G0 -T$(RAW_CACHED_LDSCRIPT) $(TEST_INIT_CACHED_OBJECT) \
	    $< -o $@ -m elf64btsmip

$(OBJDIR)/test_%_cached.elf : $(OBJDIR)/test_%.o \
	    $(TEST_CACHED_LDSCRIPT) $(TEST_INIT_CACHED_OBJECT) \
	    $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT)
	sde-ld -EB -G0 -T$(TEST_CACHED_LDSCRIPT) $(TEST_INIT_CACHED_OBJECT) \
	    $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT) $< -o $@ -m elf64btsmip

#
# Convert ELF images to raw memory images that can be loaded into simulators
# or hardware.
#
$(OBJDIR)/%.mem : $(OBJDIR)/%.elf
	sde-objcopy -S -O binary $< $@

#
# Provide an annotated disassembly for the ELF image to be used in diagnosis.
#
$(OBJDIR)/%.dump: $(OBJDIR)/%.elf
	mips64-objdump -xsSD $< > $@

#
# Target to execute a Bluespec simulation of the test suite; memConv.py needs
# fixing so that it accepts explicit sources and destinations.  That way
# concurrent runs can't tread on each other, allowing testing with -j, etc.
#
.NOTPARALLEL:
$(LOGDIR)/%.log : $(OBJDIR)/%.mem
	cp $< mem.bin
	$(MEMCONV) bsim
	${CHERIROOT}/sim -m $(TEST_CYCLE_LIMIT) > $@

#
# Target to execute a gxemul simulation.
#
# XXX: What is this not parallel?
#
.NOTPARALLEL:
$(GXEMUL_LOGDIR)/%_gxemul.log : $(OBJDIR)/%.elf
	$(GXEMUL_BINDIR)/gxemul $(GXEMUL_OPTS) $< >$@ 2>&1 < /dev/ptmx || true

$(GXEMUL_LOGDIR)/%_gxemul_cached.log : $(OBJDIR)/%_cached.elf
	$(GXEMUL_BINDIR)/gxemul $(GXEMUL_OPTS) $< >$@ 2>&1 < /dev/ptmx || true

# Simulate a failure on all unit tests
failnosetest: cleantest $(CHERI_TEST_LOGS)
	DEBUG_ALWAYS_FAIL=1 PYTHONPATH=tools nosetests $(NOSEFLAGS) $(TESTDIRS)

print-versions:
	nosetests --version

foo: $(CHERI_TEST_LOGS)

# Run unit tests using nose (http://somethingaboutorange.com/mrl/projects/nose/)
nosetest: all $(CHERI_TEST_LOGS)
	PYTHONPATH=tools/sim CACHED=0 nosetests $(NOSEFLAGS) $(TESTDIRS) || true

nosetest_cached: all $(CHERI_TEST_CACHED_LOGS)
	PYTHONPATH=tools/sim CACHED=1 nosetests $(NOSEFLAGS) $(TESTDIRS) || true

gxemul-nosetest: all $(GXEMUL_TEST_LOGS)
	PYTHONPATH=tools/gxemul CACHED=0 nosetests $(NOSEFLAGS) $(GXEMUL_NOSEFLAGS) \
	    $(TESTDIRS) || true

gxemul-nosetest_cached: all $(GXEMUL_TEST_CACHED_LOGS)
	PYTHONPATH=tools/gxemul CACHED=1 nosetests $(NOSEFLAGS) $(GXEMUL_NOSEFLAGS) \
	    $(TESTDIRS) || true

gxemul-build:
	rm -f -r $(GXEMUL_BINDIR)
	wget https://github.com/CTSRD-CHERI/gxemul/zipball/8d92b42a6ccdb7d94a2ad43f7e5e70d17bb7839c -O tools/gxemul/gxemul-testversion.zip --no-check-certificate
	unzip tools/gxemul/gxemul-testversion.zip -d tools/gxemul/
	cd $(GXEMUL_BINDIR) && ./configure && $(MAKE)
