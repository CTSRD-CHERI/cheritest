## This file contains all the rules needed to build the .elf files


SELECT_INIT:=$(OBJDIR)/select_init
COMMON_LDSCRIPTS=common.ld common-sections-pre.ld common-sections-post.ld
RAW_LDSCRIPT=raw.ld $(COMMON_LDSCRIPTS)
RAW_CACHED_LDSCRIPT=raw_cached.ld $(COMMON_LDSCRIPTS)
RAW_MULTI_LDSCRIPT=raw_multi.ld $(COMMON_LDSCRIPTS)
TEST_LDSCRIPT=test.ld $(COMMON_LDSCRIPTS)
TEST_CACHED_LDSCRIPT=test_cached.ld $(COMMON_LDSCRIPTS)
TEST_MULTI_LDSCRIPT=test_multi.ld $(COMMON_LDSCRIPTS)

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

$(OBJDIR)/test_raw_statcounters_%.o : test_raw_statcounters_%.s | $(OBJDIR)
	$(MIPS_AS) -I $(TESTDIR)/statcounters $(MIPS_ASFLAGS) -o $@ $<
$(OBJDIR)/test_statcounters_%.o : test_statcounters_%.s | $(OBJDIR)
	$(MIPS_AS) -I $(TESTDIR)/statcounters $(MIPS_ASFLAGS) -o $@ $<

# Put DMA model makefile into its own file. This one is already ludicrously
# large.
ifeq ($(DMA),1)
DMADIR=$(CHERILIBS_ABS)/peripherals/DMA
vpath DMA% $(DMADIR)

include dmamodel.mk

DMA_LIB_OBJS=$(OBJDIR)/DMAAsm.o $(OBJDIR)/DMAControl.o

$(OBJDIR)/test_clang_dma%.o: test_clang_dma%.c $(OBJDIR)/DMAAsm.o $(OBJDIR)/DMAControl.o | $(OBJDIR)
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -Ifuzz_dma -I$(DMADIR) -g -c -o $@ $< -fno-builtin

# For some reasons, these need to be explicit, not implicit
$(OBJDIR)/DMAAsm.o: DMAAsm.c | $(OBJDIR)
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -I$(DMADIR) -c -o $@ $<

$(OBJDIR)/DMAControl.o: DMAControl.c | $(OBJDIR)
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

PURECAP_CXXFLAGS?=-fno-rtti -std=c++11 -fno-exceptions

PURECAP_INIT_OBJS=$(OBJDIR)/purecap_init.o \
		$(OBJDIR)/purecap_lib.o \
		$(OBJDIR)/purecap_crt_init_globals.o
PURECAP_INIT_CACHED_OBJS=$(OBJDIR)/purecap_init_cached.o $(PURECAP_INIT_OBJS)
$(OBJDIR)/purecap_init.o: init.s | $(OBJDIR)
	$(CLANG_AS) -mabi=purecap -mabicalls -ggdb $(PURECAP_ASMDEFS)  -o $@ $<
$(OBJDIR)/purecap_init_cached.o: init_cached.s | $(OBJDIR)
	$(CLANG_AS) -mabi=purecap -mabicalls -ggdb $(PURECAP_ASMDEFS)  -o $@ $<
$(OBJDIR)/purecap_lib.o: lib.s | $(OBJDIR)
	$(CLANG_AS) -mabi=purecap -mabicalls -ggdb $(PURECAP_ASMDEFS) -o $@ $<
$(OBJDIR)/purecap_crt_init_globals.o: crt_init_globals.c | $(OBJDIR)
	$(CLANG_CC) $(PURECAP_CFLAGS) -fno-builtin $(CWARNFLAGS) -c -o $@ $<
$(OBJDIR)/purecap_atomic_runtime.o: tests/purecap/atomic.c | $(OBJDIR)
	$(CLANG_CC) $(PURECAP_CFLAGS) -fno-builtin $(CWARNFLAGS) -c -o $@ $<
$(OBJDIR)/purecap_cxx_runtime.o: tests/purecap/fake_cxx_runtime.cpp | $(OBJDIR)
	$(CLANG_CC) $(PURECAP_CFLAGS) $(PURECAP_CXXFLAGS) -fno-builtin $(CWARNFLAGS) -c -o $@ $<

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
	$(_V)$(CLANG_CC) $(PURECAP_CFLAGS) $(PURECAP_CXXFLAGS) $(CWARNFLAGS) -c -o $@ $<
$(TEST_PURECAP_ASM_OBJS): $(OBJDIR)/%.o: tests/purecap/%.s | $(OBJDIR)
	@echo PURECAP_AS $@
	$(_V)$(CLANG_AS) -mabi=purecap -mabicalls -ggdb $(PURECAP_ASMDEFS) -o $@ $<

# The purecap tests still use the old exception_count_handler
PURECAP_LDFLAGS=-m elf64btsmip_cheri_fbsd --defsym=default_trap_handler=exception_count_handler


define multiobj_purecap_rule
# HACK to get a test with multiple sources working
$(OBJDIR)/$(1).elf: $$(OBJDIR)/$(1).o test_purecap.ld $$(PURECAP_INIT_OBJS) $(addprefix $$(OBJDIR)/,$(2))
	@echo "MULTIOBJ LINKING HACK $$@ (extra objs = $(addprefix $$(OBJDIR)/,$(2)))"
	$$(_V)$(RUN_MIPS_LD) $$(MIPS_LDFLAGS) -Ttest_purecap.ld $$(PURECAP_INIT_OBJS) \
	    $(addprefix $$(OBJDIR)/,$(2)) $$< -o $$@ $$(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$$@)

$(OBJDIR)/$(1)_cached.elf: $$(OBJDIR)/$(1).o test_purecap_cached.ld $$(PURECAP_INIT_CACHED_OBJS) $(addprefix $$(OBJDIR)/,$(2))
	@echo "MULTIOBJ LINKING HACK cached $$@ (extra objs = $(addprefix $$(OBJDIR)/,$(2)))"
	$$(_V)$(RUN_MIPS_LD) $$(MIPS_LDFLAGS) -Ttest_purecap_cached.ld $$(PURECAP_INIT_CACHED_OBJS) \
	    $(addprefix $$(OBJDIR)/,$(2)) $$< -o $$@ $$(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$$@)

$(OBJDIR)/$(1)_multi.elf: $$(OBJDIR)/$(1).o test_purecap.ld $(PURECAP_INIT_OBJS) $(addprefix $$(OBJDIR)/,$(2))
	@echo "MULTIOBJ LINKING HACK multi $$@ (extra objs = $(addprefix $$(OBJDIR)/,$(2)))"
	$$(_V)$(RUN_MIPS_LD) $$(MIPS_LDFLAGS) -Ttest_purecap.ld $$(PURECAP_INIT_OBJS) \
	    $(addprefix $$(OBJDIR)/,$(2)) $$< -o $$@ $$(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$$@)

$(OBJDIR)/$(1)_cachedmulti.elf: $$(OBJDIR)/$(1).o test_purecap_cached.ld $$(PURECAP_INIT_CACHED_OBJS) $(addprefix $$(OBJDIR)/,$(2))
	@echo "MULTIOBJ LINKING HACK cached multi $$@ (extra objs = $(addprefix $$(OBJDIR)/,$(2)))"
	$$(_V)$(RUN_MIPS_LD) $$(MIPS_LDFLAGS) -Ttest_purecap_cached.ld $$(PURECAP_INIT_CACHED_OBJS) \
	    $(addprefix $$(OBJDIR)/,$(2)) $$< -o $$@ $$(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$$@)
endef

define compile_purecap_with_extra_defs
$$(OBJDIR)/$(2): tests/purecap/$(1) | $(OBJDIR)
	@echo PURECAP_CC $$@
	$$(_V)$$(CLANG_CC) $$(PURECAP_CFLAGS) $$(CWARNFLAGS) -c -o $$@ $$< $(3)
endef


#$(OBJDIR)/tmp_purecap_test_switch.o: tests/purecap/test_purecap_switch.c | $(OBJDIR)
#	@echo PURECAP_CC $@
#	$(_V)$(CLANG_CC) $(PURECAP_CFLAGS) $(CWARNFLAGS) -c -o $@ $< -DCOMPILE_SWITCH_FN=1

$(eval $(call multiobj_purecap_rule,test_purecap_switch,tmp_purecap_test_switch.o))
$(eval $(call compile_purecap_with_extra_defs,test_purecap_switch.c,tmp_purecap_test_switch.o,-DCOMPILE_SWITCH_FN=1))

$(eval $(call multiobj_purecap_rule,test_purecap_atomic,purecap_atomic_runtime.o))

$(eval $(call multiobj_purecap_rule,test_purecap_member_ptr,purecap_cxx_runtime.o test_purecap_member_ptr_impl.o))
$(eval $(call compile_purecap_with_extra_defs,test_purecap_member_ptr.cpp,test_purecap_member_ptr_impl.o,$(PURECAP_CXXFLAGS) -DBUILD_IMPLEMENTATION=1))


$(OBJDIR)/test_purecap_%_cached.elf : $(OBJDIR)/test_purecap_%.o \
	    test_purecap_cached.ld \
	    $(PURECAP_INIT_CACHED_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD cached $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ $(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap_%_multi.elf : $(OBJDIR)/test_purecap_%.o \
	    test_purecap.ld \
	    $(PURECAP_INIT_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD multi $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ $(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap_%_cachedmulti.elf : $(OBJDIR)/test_purecap_%.o \
	    test_purecap_cached.ld \
	    $(PURECAP_INIT_CACHED_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD cached multi $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ $(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$@)

$(OBJDIR)/test_purecap%.elf: $(OBJDIR)/test_purecap%.o test_purecap.ld $(PURECAP_INIT_OBJS) $(SELECT_INIT)
	@echo "PURECAP_LD $@"
	$(_V)$(RUN_MIPS_LD) --fatal-warnings $(MIPS_LDFLAGS) `$(SELECT_INIT) $@ $(abspath $(OBJDIR))` $< -o $@ $(PURECAP_LDFLAGS) && $(call CAPSIZEFIX,$@)


### END RULES FOR PURECAP TESTS

$(OBJDIR)/test_clang%.o : test_clang%.c | $(OBJDIR)
	$(CLANG_CC) $(HYBRID_CFLAGS) $(CWARNFLAGS) -c -o $@ $<

$(OBJDIR)/test_%.o : test_%.s macros.s | $(OBJDIR)
	$(MIPS_AS) $(MIPS_ASFLAGS) -o $@ $<
# Add dependencies on the common.s for test_reg0_is_ddc files:
$(OBJDIR)/test_cp2_x_reg0_is_ddc_load.o: tests/cp2/common_code_reg0_is_ddc.s
$(OBJDIR)/test_cp2_x_reg0_is_ddc_load_linked.o: tests/cp2/common_code_reg0_is_ddc.s
$(OBJDIR)/test_cp2_x_reg0_is_ddc_store.o: tests/cp2/common_code_reg0_is_ddc.s
$(OBJDIR)/test_cp2_x_reg0_is_ddc_store_cond.o: tests/cp2/common_code_reg0_is_ddc.s

$(OBJDIR)/test_%.o : test_%.c | $(OBJDIR)
	$(CLANG_CC) $(CWARNFLAGS) -c $(HYBRID_CFLAGS) -o $@ $<

$(OBJDIR)/%.o: %.s macros.s | $(OBJDIR)
	$(MIPS_AS) $(MIPS_ASFLAGS) -o $@ $<

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
