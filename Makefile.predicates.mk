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
GXEMUL_NOSEFLAGS=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "   \
allow_unaligned 	\
llsc		\
cache           \
bev1            \
trapi           \
counterdev      \
watch           \
capabilities    \
clang           \
beri            \
dumpicache	\
einstr		\
jump_unaligned	\
nofloat         \
floatabs2008	\
floatpaired     \
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
mips_overflow 	\
dma		\
beri_statcounters	\
"

COMMON_UNSUPPORTED_FEATURES?=

ifneq ($(TEST_CP2),1)
COMMON_UNSUPPORTED_FEATURES+=capabilities
endif

ifneq ($(CAP_SIZE),256)
COMMON_UNSUPPORTED_FEATURES+=cap256
ifeq ($(CAP_PRECISE),1)
COMMON_UNSUPPORTED_FEATURES+=cap_copy_as_data
else
COMMON_UNSUPPORTED_FEATURES+=cap_null_length
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

ifeq ($(PERM_SIZE),23)
COMMON_UNSUPPORTED_FEATURES+=cap_perm_31
endif

ifeq ($(PERM_SIZE),19)
COMMON_UNSUPPORTED_FEATURES+=cap_perm_31 cap_perm_23
endif

ifeq ($(PERM_SIZE),15)
COMMON_UNSUPPORTED_FEATURES+=cap_perm_31 cap_perm_23
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
llscnotmatching \
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
watch \
deterministic_random \
noextendedtlb \
csettype \
beri_statcounters \
tlb_read_uninitialized \
count_register_is_time

L3_UNSUPPORTED_FEATURES+=\
float32 \
floatpaired \
floatfexr \
floatfenr \
floatflags \
floatrecip \
floatrsqrt \
floatexception \
floatechonan \
float_round_upwards

L3_UNSUPPORTED_FEATURES+=ccall_hw_1 ccall_hw_2

L3_NOSEFLAGS=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(L3_UNSUPPORTED_FEATURES)"
L3_NOSEFLAGS_UNCACHED=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(L3_UNSUPPORTED_FEATURES) cached"

####### sail predicates #######


SAIL_UNSUPPORTED_FEATURES=$(COMMON_UNSUPPORTED_FEATURES) \
beri \
beriinitial \
berisyncistep \
counterdev \
dma \
dumpicache \
ignorebadex \
invalidateL2 \
loadcachetag \
llscnotmatching \
llscspan \
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
watch \
deterministic_random \
extendedtlb \
csettype \
beri_statcounters \
float \
pic \
mt \
einstr \
count_register_is_time \
no_experimental_clc \
experimental_csc

SAIL_MIPS_NOSEFLAGS=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(SAIL_UNSUPPORTED_FEATURES) capabilities"
SAIL_CHERI_NOSEFLAGS=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(SAIL_UNSUPPORTED_FEATURES)"
SAIL_CHERI128_NOSEFLAGS=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(SAIL_UNSUPPORTED_FEATURES)"


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
floatpaired \
floatrecipflushesdenorm \
ignorebadex \
invalidateL2 \
lladdr \
llscspan \
loadcachetag \
mt \
mul_hilo_cleared \
nofloat \
pic \
swisync \
tlbcheck \
watch \
csettype \
mtc0signex \
no_experimental_clc \
no_experimental_csc \
count_register_is_icount

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

QEMU_UNSUPPORTED_IF+=beri_statcounters=icount
QEMU_UNSUPPORTED_IF+=beri_statcounters=mem
QEMU_UNSUPPORTED_IF+=beri_statcounters=cache
# QEMU_UNSUPPORTED_FEATURES+=beri_statcounters

QEMU_NOSEFLAGS=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(QEMU_UNSUPPORTED_FEATURES)" --unsupported-feature-if-equal "$(QEMU_UNSUPPORTED_IF)"



####### Simulator predicates #######

NOSEPRED=$(COMMON_UNSUPPORTED_FEATURES)
ifeq ($(ALLOW_UNALIGNED),0)
NOSEPRED+=allow_unaligned
endif
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
ifndef TEST_PS
NOSEPRED+=floatpaired
endif
ifdef WONTFIX
NOSEPRED+=float_multiply_rounding float_round_maxint
endif
endif

# CHERI supports experimental CLC since r30617
NOSEPRED+=no_experimental_clc
NOSEPRED+=no_experimental_csc
# CHERI implements a sensible count register (unlike qemu)
NOSEPRED+=count_register_is_time

NOSEPRED+=llscnoalias
ifdef CHERI_MICRO
NOSEPRED+=tlb cache invalidateL2 bigtlb watch
ifdef WONTFIX
NOSEPRED+=jump_unaligned
endif
else
NOSEPRED+=nowatch
endif

ifneq ($(NOSEPRED),)
NOSEFLAGS?=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(NOSEPRED) uncached"
NOSEFLAGS_UNCACHED?=$(PYTHON_TEST_ATTRIB_SELETOR_FLAG) "$(NOSEPRED) cached"
endif
