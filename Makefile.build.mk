## This file contains all the rules needed to build the .elf files


SELECT_INIT:=$(OBJDIR)/select_init

RAW_LDSCRIPT=raw.ld
RAW_CACHED_LDSCRIPT=raw_cached.ld
RAW_MULTI_LDSCRIPT=raw_multi.ld
TEST_LDSCRIPT=test.ld
TEST_CACHED_LDSCRIPT=test_cached.ld
TEST_MULTI_LDSCRIPT=test_multi.ld

TEST_INIT_OBJECT=$(OBJDIR)/init.o
# Fuzz tests have a slightly different init which doesn't dump
# capability registers and has more interesting initial register values.
TEST_INIT_CACHED_OBJECT=$(OBJDIR)/init_cached.o
TEST_INIT_MULTI_OBJECT=$(OBJDIR)/init_multi.o
TEST_LIB_OBJECT=$(OBJDIR)/lib.o


#
# Targets for unlinked .o files.  The same .o files can be used for both
# uncached and cached runs of the suite, so we just build them once.
#

$(OBJDIR)/test_raw_statcounters_%.o : test_raw_statcounters_%.s
	$(MIPS_AS) -I $(TESTDIR)/statcounters -EB -mabi=64 -G0 -ggdb $(DEFSYM_FLAG)TEST_CP2=$(TEST_CP2) $(DEFSYM_FLAG)CAP_SIZE=$(CAP_SIZE) -o $@ $<

# Put DMA model makefile into its own file. This one is already ludicrously
# large.
ifeq ($(DMA),1)
DMADIR=$(CHERILIBS_ABS)/peripherals/DMA
vpath DMA% $(DMADIR)

include dmamodel.mk

DMA_LIB_OBJS=$(OBJDIR)/DMAAsm.o $(OBJDIR)/DMAControl.o

$(OBJDIR)/test_clang_dma%.o: test_clang_dma%.c $(OBJDIR)/DMAAsm.o $(OBJDIR)/DMAControl.o
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -Ifuzz_dma -I$(DMADIR) -g -c -o $@ $< -fno-builtin

# For some reasons, these need to be explicit, not implicit
$(OBJDIR)/DMAAsm.o: DMAAsm.c
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -I$(DMADIR) -c -o $@ $<

$(OBJDIR)/DMAControl.o: DMAControl.c
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -I$(DMADIR) -c -o $@ $<
endif

##### BEGIN RULES FOR PURECAP TESTS

PURECAP_ASMDEFS=-Wa,-defsym,TEST_CP2=$(TEST_CP2)      \
		-Wa,-defsym,CAP_SIZE=$(CAP_SIZE)      \
		-Wa,-defsym,BUILDING_PURECAP=1        \
		-Wa,-defsym,__CHERI_PURE_CAPABILITY__=1        \
		-Wa,-defsym,DIE_ON_EXCEPTION=1

ifeq ($(USE_CAP_TABLE),1)
PURECAP_CFLAGS+=-cheri-cap-table-abi=pcrel
PURECAP_ASMDEFS+=-cheri-cap-table-abi=pcrel
PURECAP_ASMDEFS+=-Wa,-defsym,__CHERI_CAPABILITY_TABLE__=2
endif

PURECAP_INIT_OBJS=$(OBJDIR)/purecap_init.o \
		$(OBJDIR)/purecap_lib.o \
		$(OBJDIR)/purecap_crt_init_globals.o
PURECAP_INIT_CACHED_OBJS=$(OBJDIR)/purecap_init_cached.o $(PURECAP_INIT_OBJS)
$(OBJDIR)/purecap_init.o: init.s | $(OBJDIR)
	$(CLANG_AS) -mabi=purecap -mabicalls -G0 -ggdb $(PURECAP_ASMDEFS)  -o $@ $<
$(OBJDIR)/purecap_init_cached.o: init_cached.s | $(OBJDIR)
	$(CLANG_AS) -mabi=purecap -mabicalls -G0 -ggdb $(PURECAP_ASMDEFS)  -o $@ $<
$(OBJDIR)/purecap_lib.o: lib.s | $(OBJDIR)
	$(CLANG_AS) -mabi=purecap -mabicalls -G0 -ggdb $(PURECAP_ASMDEFS) -o $@ $<
$(OBJDIR)/purecap_crt_init_globals.o: crt_init_globals.c | $(OBJDIR)
	$(CLANG_CC) $(PURECAP_CFLAGS) -fno-builtin $(CWARNFLAGS) -c -o $@ $<

ifdef VERBOSE
_V=
else
_V=@
endif
srcs_to_objs = $(addprefix $(OBJDIR)/,$(addsuffix .o,$(basename $(notdir $(1)))))
TEST_PURECAP_C_OBJS=$(call srcs_to_objs,$(TEST_PURECAP_C_SRCS))
TEST_PURECAP_CXX_OBJS=$(call srcs_to_objs,$(TEST_PURECAP_CXX_SRCS))
TEST_PURECAP_ASM_OBJS=$(call srcs_to_objs,$(TEST_PURECAP_ASM_SRCS))
# Use static pattern rules here (less fragile than the implicit pattern ones)
$(TEST_PURECAP_C_OBJS): $(OBJDIR)/%.o: tests/purecap/%.c | $(OBJDIR)
	@echo PURECAP_CC $@
	$(_V)$(CLANG_CC) $(PURECAP_CFLAGS) $(CWARNFLAGS) -c -o $@ $<
$(TEST_PURECAP_CXX_OBJS): $(OBJDIR)/%.o: tests/purecap/%.cpp | $(OBJDIR)
	@echo PURECAP_CXX $@
	$(_V)$(CLANG_CC) $(PURECAP_CFLAGS) $(CWARNFLAGS) -c -o $@ $<
$(TEST_PURECAP_ASM_OBJS): $(OBJDIR)/%.o: tests/purecap/%.s | $(OBJDIR)
	@echo PURECAP_AS $@
	$(_V)$(CLANG_AS) -mabi=purecap -mabicalls -G0 -ggdb $(PURECAP_ASMDEFS) -o $@ $<

$(OBJDIR)/tmp_purecap_test_switch.o: tests/purecap/test_purecap_switch.c | $(OBJDIR)
	@echo PURECAP_CC $@
	$(_V)$(CLANG_CC) $(PURECAP_CFLAGS) $(CWARNFLAGS) -c -o $@ $< -DCOMPILE_SWITCH_FN=1
# HACK to get a test with multiple sources working
$(OBJDIR)/test_purecap_switch.elf: $(OBJDIR)/test_purecap_switch.o test_purecap.ld $(PURECAP_INIT_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o
	@echo "MULTIOBJ LINKING HACK $@"
	$(_V)$(RUN_MIPS_LD) $(MIPS_LDFLAGS) -Ttest_purecap.ld $(PURECAP_INIT_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)
$(OBJDIR)/test_purecap_switch_cached.elf: $(OBJDIR)/test_purecap_switch.o test_purecap_cached.ld $(PURECAP_INIT_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o
	@echo "MULTIOBJ LINKING HACK cached $@"
	$(_V)$(RUN_MIPS_LD) $(MIPS_LDFLAGS) -Ttest_purecap_cached.ld $(PURECAP_INIT_CACHED_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)
$(OBJDIR)/test_purecap_switch_multi.elf: $(OBJDIR)/test_purecap_switch.o test_purecap.ld $(PURECAP_INIT_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o
	@echo "MULTIOBJ LINKING HACK multi $@"
	$(_V)$(RUN_MIPS_LD) $(MIPS_LDFLAGS) -Ttest_purecap.ld $(PURECAP_INIT_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)
$(OBJDIR)/test_purecap_switch_cachedmulti.elf: $(OBJDIR)/test_purecap_switch.o test_purecap_cached.ld $(PURECAP_INIT_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o
	@echo "MULTIOBJ LINKING HACK cached multi$@"
	$(_V)$(RUN_MIPS_LD) $(MIPS_LDFLAGS) -Ttest_purecap_cached.ld $(PURECAP_INIT_CACHED_OBJS) $(OBJDIR)/tmp_purecap_test_switch.o $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap_%_cached.elf : $(OBJDIR)/test_purecap_%.o \
	    test_purecap_cached.ld \
	    $(PURECAP_INIT_CACHED_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD cached $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap_%_multi.elf : $(OBJDIR)/test_purecap_%.o \
	    test_purecap.ld \
	    $(PURECAP_INIT_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD multi $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap_%_cachedmulti.elf : $(OBJDIR)/test_purecap_%.o \
	    test_purecap_cached.ld \
	    $(PURECAP_INIT_CACHED_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD cached multi $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap%.elf: $(OBJDIR)/test_purecap%.o test_purecap.ld $(PURECAP_INIT_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ -m elf64btsmip_cheri_fbsd && $(call CAPSIZEFIX,$@)


### END RULES FOR PURECAP TESTS

# Once the assembler works, we can try this version too:
#$(CLANG_CC)  -S -fno-pic -target cheri-unknown-freebsd -o - $<  | $(MIPS_AS) -EB -march=mips64 -mabi=64 -G0 -ggdb -o $@ -

$(OBJDIR)/test_clang%.o : test_clang%.c | $(OBJDIR)
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -c -o $@ $<
$(OBJDIR)/test_%.o : test_%.s macros.s | $(OBJDIR)
	$(MIPS_AS) -EB -mabi=64 -G0 -ggdb $(DEFSYM_FLAG)TEST_CP2=$(TEST_CP2) $(DEFSYM_FLAG)CAP_SIZE=$(CAP_SIZE) -o $@ $<
$(OBJDIR)/test_%.o : test_%.c | $(OBJDIR)
	$(CLANG_CC) $(CWARNFLAGS) -c $(HYBRID_CFLAGS) -o $@ $<

$(OBJDIR)/%.o: %.s macros.s | $(OBJDIR)
	$(MIPS_AS) -EB -mabi=64 -G0 -ggdb $(DEFSYM_FLAG)TEST_CP2=$(TEST_CP2) $(DEFSYM_FLAG)CAP_SIZE=$(CAP_SIZE) -o $@ $<

$(SELECT_INIT): select_init.c | $(OBJDIR)
	$(CC) -o $@ $<

#
# Targets for ELF images
#

#$(OBJDIR)/test_clang_dma_simple.elf : $(OBJDIR)/test_clang_dma_simple.o $(DMA_LIB_OBJS)\
#	    #$(TEST_LDSCRIPT) \
#	    #$(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT) $(SELECT_INIT)
#	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))`  $< -o $@ $(DMA_LIB_OBJS) -m elf64btsmip

$(OBJDIR)/startdramtest.elf: $(OBJDIR)/startdramtest.o $(TEST_LDSCRIPT)
	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) raw.ld $< -o $@ -m elf64btsmip

$(OBJDIR)/test_clang_dma%.elf : $(OBJDIR)/test_clang_dma%.o $(DMA_LIB_OBJS)\
	    $(TEST_LDSCRIPT) \
	    $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT)
	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) -Ttest_dram.ld $(OBJDIR)/lib.o $< -o $@ $(DMA_LIB_OBJS) -m elf64btsmip

$(OBJDIR)/test_%.elf : $(OBJDIR)/test_%.o \
	    $(TEST_LDSCRIPT) \
	    $(TEST_INIT_OBJECT) $(TEST_LIB_OBJECT) $(SELECT_INIT)
	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))`  $< -o $@ -m elf64btsmip

$(OBJDIR)/test_%_cached.elf : $(OBJDIR)/test_%.o \
	    $(TEST_CACHED_LDSCRIPT) \
	    $(TEST_INIT_OBJECT) $(TEST_INIT_CACHED_OBJECT) \
	    $(TEST_LIB_OBJECT) $(SELECT_INIT)
	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))`  $< -o $@ -m elf64btsmip

$(OBJDIR)/test_%_multi.elf : $(OBJDIR)/test_%.o \
	    $(TEST_MULTI_LDSCRIPT) \
	    $(TEST_INIT_MULTI_OBJECT) \
	    $(TEST_INIT_OBJECT) $(TEST_INIT_CACHED_OBJECT) \
	    $(TEST_LIB_OBJECT) $(SELECT_INIT)
	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))`  $< -o $@ -m elf64btsmip

$(OBJDIR)/test_%_cachedmulti.elf : $(OBJDIR)/test_%.o \
	    $(TEST_CACHEDMULTI_LDSCRIPT) \
	    $(TEST_INIT_MULTI_OBJECT) \
	    $(TEST_INIT_OBJECT) $(TEST_INIT_CACHED_OBJECT) \
	    $(TEST_LIB_OBJECT) $(SELECT_INIT)
	$(RUN_MIPS_LD) $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))`  $< -o $@ -m elf64btsmip
