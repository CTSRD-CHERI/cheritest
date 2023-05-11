## This file contains all the test selector definitions and the nosetests_* make rules


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
# cheri - gxemul is simply not CHERI
#

COMMON_UNSUPPORTED_FEATURES?=notyet

COMMON_UNSUPPORTED_FEATURES+=qemu_magic_nops

ifeq ($(TEST_CP2),1)
COMMON_UNSUPPORTED_FEATURES+=mtc0signex
endif

ifneq ($(TEST_CP2),1)
COMMON_UNSUPPORTED_FEATURES+=capabilities
COMMON_UNSUPPORTED_FEATURES_IF+=beri_statcounters=cap_mem
endif

ifneq ($(CAP_SIZE),256)
COMMON_UNSUPPORTED_FEATURES+=cap256
ifeq ($(CAP_PRECISE),1)
COMMON_UNSUPPORTED_FEATURES+=cap_copy_as_data
endif
endif

ifneq ($(CAP_SIZE),128)
COMMON_UNSUPPORTED_FEATURES+=cap128
endif

ifneq ($(CAP_SIZE),64)
COMMON_UNSUPPORTED_FEATURES+=cap64
endif

ifeq ($(CAP_PRECISE),1)
COMMON_UNSUPPORTED_FEATURES+=cap_imprecise
else
COMMON_UNSUPPORTED_FEATURES+=cap_precise
endif

ifeq ($(PERM_SIZE),31)
COMMON_UNSUPPORTED_FEATURES+=cap_perm_15
endif

ifeq ($(PERM_SIZE),15)
COMMON_UNSUPPORTED_FEATURES+=cap_perm_31
endif

ifeq ($(ALLOW_UNALIGNED),0)
COMMON_UNSUPPORTED_FEATURES+=allow_unaligned
else
COMMON_UNSUPPORTED_FEATURES+=trap_unaligned_ld_st alignex
endif

ifneq ($(CLANG),1)
COMMON_UNSUPPORTED_FEATURES+=clang
endif

ifneq ($(DMA),1)
COMMON_UNSUPPORTED_FEATURES+=dma
endif

ifneq ($(MULTI),1)
COMMON_UNSUPPORTED_FEATURES+=multicore
endif

ifneq ($(MT),1)
COMMON_UNSUPPORTED_FEATURES+=mt
endif

ifneq ($(STATCOUNTERS),1)
COMMON_UNSUPPORTED_FEATURES+=beri_statcounters
endif

ifeq ($(TEST_FPU),1)
COMMON_UNSUPPORTED_FEATURES+=nofloat
else
COMMON_UNSUPPORTED_FEATURES+=float float64
endif

ifneq ($(TEST_PS),1)
COMMON_UNSUPPORTED_FEATURES+=floatpaired
endif

ifndef TEST_TRACE
ifndef TEST_TRACE_ONLY
COMMON_UNSUPPORTED_FEATURES+=	trace_tests
endif
endif

ifeq ($(NOFUZZ),1)
COMMON_UNSUPPORTED_FEATURES+=	fuzz_test
endif
ifeq ($(NOFUZZR),1)
COMMON_UNSUPPORTED_FEATURES+=	fuzz_test_regression
endif

#
# GXEMUL predicates
#
FLOAT_FEATURES=float \
float32 \
float64 \
floatfexr \
floatfenr \
floatflags \
floatrecip \
floatrsqrt \
floatexception \
floatechonan \
float_round_upwards \
floatindexed \
floatpaired \
floatrecipflushesdenorm \
floatri \
floatmadd \
float_mtc_signex \
float_mov_signex \
floatabs2008 \
float_round_upwards


GXEMUL_UNSUPPORTED_FEATURES=$(COMMON_UNSUPPORTED_FEATURES) \
allow_unaligned 	\
llsc		\
cache           \
badinstr	\
bev1            \
trapi           \
counterdev      \
watch           \
clang           \
beri            \
dumpicache	\
einstr		\
jump_unaligned	\
nofloat         \
floatabs2008	\
floatindexed    \
floatcmove      \
floatfccr       \
floatfenr       \
floatfexr       \
floatrecip      \
floatrsqrt      \
float64         \
floatexception  \
floatechonan    \
floatmadd	\
smalltlb        \
bigtlb          \
beri1tlb	\
beri2tlb	\
beri1cache	\
beri1oldcache	\
beri2cache	\
extendedtlb	\
enablelargetlb  \
tlbcheck	\
invalidateL2    \
rdhwr           \
config2		\
config3         \
config5		\
userlocal       \
mt              \
pic		\
mul_hilo_cleared \
mips_overflow 	\
dma		\
beri_statcounters \
no_dext


GXEMUL_NOSEFLAGS=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(GXEMUL_UNSUPPORTED_FEATURES))


####### L3 predicates #######


L3_UNSUPPORTED_FEATURES=$(COMMON_UNSUPPORTED_FEATURES) \
newisa \
allow_unaligned \
beri \
beriinitial \
berisyncistep \
counterdev \
dma \
dumpicache \
ignorebadex \
invalidateL2 \
loadcachetag \
llscspan \
llscnoalias \
llscuncached \
mtc0signex \
mul_hilo_unchanged \
swi \
smalltlb \
beri2tlb \
gxemultlb \
beri2cache \
beri1oldcache \
noextendedtlb \
csettype \
beri_statcounters \
tlb_read_uninitialized \
watch \
count_register_is_time

L3_UNSUPPORTED_FEATURES+=$(FLOAT_FEATURES) watch

L3_UNSUPPORTED_FEATURES+=ccall_hw_1

L3_NOSEFLAGS=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(L3_UNSUPPORTED_FEATURES))
L3_NOSEFLAGS_UNCACHED=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(L3_UNSUPPORTED_FEATURES) cached)

####### sail predicates #######


SAIL_UNSUPPORTED_FEATURES=$(COMMON_UNSUPPORTED_FEATURES) \
beri \
beriinitial \
berisyncistep \
cache \
counterdev \
dma \
dumpicache \
ignorebadex \
invalidateL2 \
loadcachetag \
llscspan \
llscspan_csc \
llscnoalias \
mtc0signex \
mul_hilo_cleared \
swi \
smalltlb \
beri2tlb \
gxemultlb \
beri1tlb   \
beri1cache \
beri2cache \
beri1oldcache \
deterministic_random \
extendedtlb \
csettype \
beri_statcounters \
statcounters \
$(FLOAT_FEATURES) \
pic \
mt \
count_register_is_time \
no_experimental_clc \
experimental_csc \
watch


SAIL_MIPS_NOSEFLAGS=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(SAIL_UNSUPPORTED_FEATURES) capabilities)
SAIL_CHERI_NOSEFLAGS=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(SAIL_UNSUPPORTED_FEATURES))
SAIL_CHERI128_NOSEFLAGS=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(SAIL_UNSUPPORTED_FEATURES))


####### QEMU predicates #######


QEMU_UNSUPPORTED_FEATURES=$(COMMON_UNSUPPORTED_FEATURES) \
beri \
beri1cache \
beri1tlb \
beri2cache \
beri2tlb \
bericcres \
berisyncistep \
bev1ram \
countrate \
gxemultlb \
counterdev \
deterministic_random \
dma \
dumpicache \
extendedtlb \
floatfirextended \
floatlegacyabs \
float_mov_signex \
float_mtc_signex \
floatnan2008 \
floatrecipflushesdenorm \
ignorebadex \
invalidateL2 \
loadcachetag \
mt \
mul_hilo_cleared \
nofloat \
pic \
swisync \
tlbcheck \
csettype \
mtc0signex \
no_experimental_clc \
no_experimental_csc \
count_register_is_icount \
watch

ifdef MIPS_ONLY
QEMU_UNSUPPORTED_FEATURES+=beri_statcounters
endif

# XXXAM why settype is disabled?
# XXXAR: mtc0signex was added here because since upstream QEMU commit d54a299b
# the mtc0 instruction no longer sign extends

ifeq ($(QEMU_UNALIGNED_OKAY),0)
# ifeq ($(ALLOW_UNALIGNED),0)
QEMU_UNSUPPORTED_FEATURES+=allow_unaligned
else
QEMU_UNSUPPORTED_FEATURES+=trap_unaligned_ld_st alignex
endif

ifdef TEST_QEMU_R4000
QEMU_UNSUPPORTED_FEATURES+=\
floatcmove \
floatfccr \
floatfenr \
floatindexed \
floatmadd \
floatrecip \
floatrsqrt \
madd \
movz \
rdhwr
else
QEMU_UNSUPPORTED_FEATURES+=no_dext nomthc1 nowatch
endif

# QEMU now supports the icount statcounters register
QEMU_UNSUPPORTED_IF=$(COMMON_UNSUPPORTED_FEATURES_IF)
QEMU_UNSUPPORTED_IF+=beri_statcounters=mem
QEMU_UNSUPPORTED_IF+=beri_statcounters=cache

QEMU_UNSUPPORTED_FEATURES_FINAL=$(filter-out qemu_magic_nops,$(QEMU_UNSUPPORTED_FEATURES))

# QEMU_UNSUPPORTED_FEATURES+=beri_statcounters

QEMU_NOSEFLAGS=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(QEMU_UNSUPPORTED_FEATURES_FINAL)) $(addprefix --unsupported-feature-if-equal=,$(QEMU_UNSUPPORTED_IF))



####### Simulator predicates #######

NOSEPRED=$(COMMON_UNSUPPORTED_FEATURES)
NOSEPRED+=allow_unaligned
NOSEPRED+=csettype
NOSEPRED+=dumpicache
NOSEPRED+=loadcachetag
NOSEPRED+=errorepc
NOSEPRED+=tlbcheck
NOSEPRED+=mul_hilo_cleared
ifeq ($(BERI_VER),2)
NOSEPRED+=invalidateL2only
NOSEPRED+=lladdr
NOSEPRED+=extendedtlb
NOSEPRED+=bigtlb
NOSEPRED+=csettype
NOSEPRED+=gxemultlb
NOSEPRED+=beri1tlb
NOSEPRED+=beri1cache
NOSEPRED+=beri1oldcache
else
NOSEPRED+=alignex
NOSEPRED+=noextendedtlb
NOSEPRED+=smalltlb
NOSEPRED+=gxemultlb
NOSEPRED+=beri2tlb
NOSEPRED+=beri1oldcache
NOSEPRED+=beri2cache
ifeq ($(GENERIC_L1),1)
NOSEPRED+=beri1cache
# The parser for the ICache dump hard-codes the size of the cache,
# so isn't expected to work if the cache size changes.
NOSEPRED+=dumpicache
endif
NOSEPRED+=berisyncistep
endif
ifeq ($(TEST_FPU),1)
NOSEPRED+=float32 floatexception floatflags floatrecipflushesdenorm floatri floatmadd float_mtc_signex float_mov_signex floatabs2008 float_round_upwards
ifdef WONTFIX
NOSEPRED+=float_multiply_rounding
endif
endif

ifeq ($(TEST_WATCH),0)
NOSEPRED+=watch
else
NOSEPRED+=nowatch
endif

# CHERI supports experimental CLC since r30617
NOSEPRED+=no_experimental_clc
NOSEPRED+=no_experimental_csc
# CHERI implements a sensible count register (unlike qemu)
NOSEPRED+=count_register_is_time

NOSEPRED+=llscnoalias
ifdef CHERI_MICRO
NOSEPRED+=tlb cache invalidateL2 bigtlb
ifdef WONTFIX
NOSEPRED+=jump_unaligned
endif
endif

ifneq ($(NOSEPRED),)
NOSEFLAGS?=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(NOSEPRED) uncached) $(addprefix --unsupported-feature-if-equal=,$(COMMON_UNSUPPORTED_FEATURES_IF))
NOSEFLAGS_UNCACHED?=$(addprefix $(PYTHON_TEST_ATTRIB_SELETOR_FLAG)=,$(NOSEPRED) cached) $(addprefix --unsupported-feature-if-equal=,$(COMMON_UNSUPPORTED_FEATURES_IF))
endif
