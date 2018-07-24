## This makefile contains all the *_FILES and TESTDIRS variable assignments

#
# List of directories in which to find test source and .py files.
#
TESTDIR=tests
TESTDIRS=					\
		$(TESTDIR)/framework		\
		$(TESTDIR)/alu			\
		$(TESTDIR)/branch		\
		$(TESTDIR)/tlb			\
		$(TESTDIR)/mem			\
		$(TESTDIR)/cache		\
		$(TESTDIR)/cp0			\
		$(TESTDIR)/cp2			\
		$(TESTDIR)/mt			\
		$(TESTDIR)/pic			\
		$(TESTDIR)/dma

CLANG_TESTDIRS=$(TESTDIR)/cframework $(TESTDIR)/c
PURECAP_TESTDIRS=$(TESTDIR)/purecap
ifeq ($(PURECAP),1)
CLANG_TESTDIRS+=$(PURECAP_TESTDIRS)
endif

ifeq ($(CLANG),1)
TESTDIRS+=$(CLANG_TESTDIRS)
endif

ifeq ($(MULTI),1)
TESTDIRS+= $(TESTDIR)/multicore
endif

ifeq ($(MT),1)
TESTDIRS+= $(TESTDIR)/mt
endif

ifeq ($(STATCOUNTERS),1)
TESTDIRS+= $(TESTDIR)/statcounters
endif

ifeq ($(VIRTDEV),1)
TESTDIRS+= $(TESTDIR)/virtdev
endif

ifneq ($(NOFUZZ),1)
TESTDIRS+= $(TESTDIR)/fuzz
endif

ifneq ($(NOFUZZR),1)
TESTDIRS+=$(TESTDIR)/fuzz_regressions
endif

ifeq ($(FUZZ_DMA),1)
TESTDIRS+=$(TESTDIR)/fuzz_dma
endif

ifeq ($(TEST_FPU),1)
TESTDIRS+= $(TESTDIR)/fpu
else
ifdef COP1
$(error "COP1 has been replaced by TEST_FPU")
endif
endif

ifdef COP1_ONLY
TESTDIRS= $(TESTDIR)/fpu
endif

ifdef TEST_TRACE
TESTDIRS+= $(TESTDIR)/trace
endif

ifdef TEST_TRACE_ONLY
TESTDIRS= $(TESTDIR)/trace
endif

ifeq ($(TEST_RMA),1)
TESTDIRS+= $(TESTDIR)/rma
endif

RAW_FRAMEWORK_FILES=				\
		test_raw_template.s		\
		test_raw_cp2_template.s		\
		test_raw_reg_init.s		\
		test_raw_hilo.s			\
		test_raw_dli.s			\
		test_raw_dli_sign.s		\
		test_raw_reg_name.s		\
		test_raw_nop.s			\
		test_raw_ssnop.s		\
		test_raw_lui.s			\
		test_raw_counterdev.s		\
		test_raw_movz_zero.s

RAW_ALU_FILES=					\
		test_raw_add_ex.s		\
		test_raw_addi_ex.s		\
		test_raw_addi.s			\
		test_raw_addiu_ex.s		\
		test_raw_addiu.s		\
		test_raw_add.s			\
		test_raw_addu_ex.s		\
		test_raw_addu.s			\
		test_raw_andi.s			\
		test_raw_and.s			\
		test_raw_arithmetic_combo.s	\
		test_raw_daddi.s		\
		test_raw_daddiu.s		\
		test_raw_dadd.s			\
		test_raw_daddu.s		\
		test_raw_dsll32.s		\
		test_raw_dsll.s			\
		test_raw_dsllv.s		\
		test_raw_dsra32.s		\
		test_raw_dsra.s			\
		test_raw_dsrav.s		\
		test_raw_dsrl32.s		\
		test_raw_dsrl.s			\
		test_raw_dsrlv.s		\
		test_raw_dsub.s			\
		test_raw_dsubu.s		\
		test_raw_nor.s			\
		test_raw_ori.s			\
		test_raw_or.s			\
		test_raw_sll.s			\
		test_raw_sllv.s			\
		test_raw_sra_ex.s		\
		test_raw_sra.s			\
		test_raw_srav_ex.s		\
		test_raw_srav.s			\
		test_raw_srl_ex.s		\
		test_raw_srl.s			\
		test_raw_srlv_ex.s		\
		test_raw_srlv.s			\
		test_raw_sub_ex.s		\
		test_raw_sub.s			\
		test_raw_subu_ex.s		\
		test_raw_subu.s			\
		test_raw_xori.s			\
		test_raw_xor.s

RAW_BRANCH_FILES=				\
		test_raw_jump.s			\
		test_raw_b.s			\
		test_raw_b_maxoffset.s		\
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
		test_raw_jalr.s			\
		test_raw_tlb_j.s

RAW_MEM_FILES=					\
		test_raw_lb.s			\
		test_raw_lh.s			\
		test_raw_lw.s			\
		test_raw_ld.s			\
		test_raw_ld_beq_gt_pipeline.s	\
		test_raw_load_delay_reg.s	\
		test_raw_load_delay_store.s	\
		test_raw_cache_write_to_use.s \
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
		test_raw_scd.s			\
		test_raw_scd_uncached.s

RAW_CP0_FILES=					\
		test_raw_eret_error.s		\
		test_raw_mfc0_dmfc0.s		\
		test_raw_mtc0_sign_extend.s

RAW_CP2_FILES=					\
		test_raw_capinstructions.s

RAW_FPU_FILES =					\
		test_raw_fpu_abs_2008.s		\
		test_raw_fpu_abs_qnan.s		\
		test_raw_fpu_abs.s		\
		test_raw_fpu_add_d32.s		\
		test_raw_fpu_add_inf_d64.s 	\
		test_raw_fpu_add_inf_single.s	\
		test_raw_fpu_add.s		\
		test_raw_fpu_bc1t_pipeline.s	\
		test_raw_fpu_blikely.s		\
		test_raw_fpu_branch.s		\
		test_raw_fpu_ceil_d64.s		\
		test_raw_fpu_ceil_l_d64.s	\
		test_raw_fpu_ceil_l_s_d64.s	\
		test_raw_fpu_ceil_l_s_nan_d64.s \
		test_raw_fpu_ceil_nan_d64.s	\
		test_raw_fpu_ceil_nan_single.s	\
		test_raw_fpu_ceil_single.s	\
		test_raw_fpu_ceil_w_d_nan_d64.s \
		test_raw_fpu_ceq_d64.s		\
		test_raw_fpu_ceq.s		\
		test_raw_fpu_ceq_single.s	\
		test_raw_fpu_cf.s		\
		test_raw_fpu_cntrl.s		\
		test_raw_fpu_cole_d64.s		\
		test_raw_fpu_cole.s		\
		test_raw_fpu_cole_single.s	\
		test_raw_fpu_colt_d64.s		\
		test_raw_fpu_colt.s		\
		test_raw_fpu_colt_single.s	\
		test_raw_fpu_cueq_d64.s		\
		test_raw_fpu_cueq.s		\
		test_raw_fpu_cueq_single.s	\
		test_raw_fpu_cule_d64.s		\
		test_raw_fpu_cule.s		\
		test_raw_fpu_cule_single.s	\
		test_raw_fpu_cult_d64.s		\
		test_raw_fpu_cult.s		\
		test_raw_fpu_cult_single.s	\
		test_raw_fpu_cun_d64.s		\
		test_raw_fpu_cun.s		\
		test_raw_fpu_cun_single.s	\
		test_raw_fpu_cvt_d32.s		\
		test_raw_fpu_cvt_d_l_d64.s	\
		test_raw_fpu_cvt_d_w_d64.s	\
		test_raw_fpu_cvt_d_w_ex.s	\
		test_raw_fpu_cvt_l_d_d64.s	\
		test_raw_fpu_cvt_l_s_d64.s	\
		test_raw_fpu_cvt_l_s_nan_d64.s	\
		test_raw_fpu_cvt_nan_d64.s	\
		test_raw_fpu_cvt_nan_single.s	\
		test_raw_fpu_cvt.s		\
		test_raw_fpu_cvt_single.s	\
		test_raw_fpu_cvt_s_l_d64.s	\
		test_raw_fpu_cvt_s_w.s		\
		test_raw_fpu_cvt_s_w_ex.s	\
		test_raw_fpu_cvt_w_d_d64.s	\
		test_raw_fpu_cvt_w_d_nan_d64.s	\
		test_raw_fpu_cvtw.s		\
		test_raw_fpu_denorm.s		\
		test_raw_fpu_div_d32.s		\
		test_raw_fpu_div_inf_single.s	\
		test_raw_fpu_div.s		\
		test_raw_fpu_div_small.s	\
		test_raw_fpu_fccr.s 		\
		test_raw_fpu_fenr.s 		\
		test_raw_fpu_fexr.s 		\
		test_raw_fpu_fir.s 		\
		test_raw_fpu_floor_d64.s	\
		test_raw_fpu_floor_l_d64.s	\
		test_raw_fpu_floor_l_s_d64.s	\
		test_raw_fpu_floor_l_s_nan_d64.s \
		test_raw_fpu_floor_nan_d64.s	\
		test_raw_fpu_floor_nan_single.s	\
		test_raw_fpu_floor_single.s	\
		test_raw_fpu_floor_w_d_nan_d64.s \
		test_raw_fpu_infinity_single.s	\
		test_raw_fpu_madd_d64.s		\
		test_raw_fpu_madd_single.s	\
		test_raw_fpu_mov_cc.s		\
		test_raw_fpu_movci.s		\
		test_raw_fpu_mov_ex.s		\
		test_raw_fpu_movf_s_pipeline.s	\
		test_raw_fpu_mov_gpr.s		\
		test_raw_fpu_movt_pipeline.s	\
		test_raw_fpu_movt_s_pipeline.s	\
		test_raw_fpu_mtc1_ex.s		\
		test_raw_fpu_mul_d32.s		\
		test_raw_fpu_mul_inf_single.s	\
		test_raw_fpu_mul.s		\
		test_raw_fpu_neg_2008.s		\
		test_raw_fpu_neg_qnan.s		\
		test_raw_fpu_neg.s		\
		test_raw_fpu_qnan_s2.s		\
		test_raw_fpu_qnan_single.s	\
		test_raw_fpu_recip.s		\
		test_raw_fpu_round_d64.s	\
		test_raw_fpu_rounding_mode.s	\
		test_raw_fpu_round_l_d64.s	\
		test_raw_fpu_round_l_s_d64.s	\
		test_raw_fpu_round_l_s_nan_d64.s \
		test_raw_fpu_round_nan_d64.s	\
		test_raw_fpu_round_nan_single.s \
		test_raw_fpu_round_single.s	\
		test_raw_fpu_round_w_d_nan_d64.s \
		test_raw_fpu_rsqrt.s		\
		test_raw_fpu_sd_ld.s		\
		test_raw_fpu_sqrt_d32.s		\
		test_raw_fpu_sqrt.s		\
		test_raw_fpu_sub_d32.s		\
		test_raw_fpu_sub_inf_single.s	\
		test_raw_fpu_sub.s		\
		test_raw_fpu_sw_lw.s		\
		test_raw_fpu_trunc_d64.s	\
		test_raw_fpu_trunc_l_d64.s	\
		test_raw_fpu_trunc_l_s_d64.s	\
		test_raw_fpu_trunc_l_s_nan_d64.s \
		test_raw_fpu_trunc_nan_d64.s	\
		test_raw_fpu_trunc_nan_single.s \
		test_raw_fpu_trunc_single.s	\
		test_raw_fpu_trunc_w_d_nan_d64.s \
		test_raw_fpu_underflow.s	\
		test_raw_fpu_xc1.s
RAW_PS_FILES=\
		test_raw_fpu_abs_ps.s		\
		test_raw_fpu_add_ps.s		\
		test_raw_fpu_sub_ps.s		\
		test_raw_fpu_neg_ps.s		\
		test_raw_fpu_mul_ps.s		\
		test_raw_fpu_pair.s		\
		test_raw_fpu_cvt_paired.s	\
		test_raw_fpu_mov_ps.s \
		test_raw_fpu_movc_ps.s \
		test_raw_fpu_movcc_ps.s \
		test_raw_fpu_ceq_ps.s \
		test_raw_fpu_cf_ps.s \
		test_raw_fpu_cole_ps.s \
		test_raw_fpu_colt_ps.s \
		test_raw_fpu_cueq_ps.s \
		test_raw_fpu_cule_ps.s \
		test_raw_fpu_cult_ps.s \
		test_raw_fpu_cun_ps.s

RAW_TRACE_FILES=test_raw_trace.s

RAW_PIC_FILES=test_raw_pic_regs.s

ifeq ($(DMA),1)
RAW_DMA_FILES=test_raw_dma_simple.s
else
RAW_DMA_FILES=
endif

ifeq ($(TEST_RMA),1)
RAW_RMA_FILES=test_raw_rma_read.s
else
RAW_RMA_FILES=
endif

TEST_FRAMEWORK_FILES=				\
		test_template.s			\
		test_reg_zero.s			\
		test_reg_forwarding.s		\
		test_dli.s			\
		test_move.s			\
		test_movz_movn_pipeline.s	\
		test_code_rom_relocation.s	\
		test_code_ram_relocation.s	\
		test_raw_jr_cachd.s

ifeq ($(CLANG),1)
C_FRAMEWORK_FILES=				\
		test_ctemplate.c		\
		test_casmgp.c			\
		test_cretval.c			\
		test_crecurse.c			\
		test_cglobals.c
else
C_FRAMEWORK_FILES=
endif

TEST_ALU_FILES=					\
		test_hilo.s			\
		test_div.s			\
		test_divu.s			\
		test_ddiv.s			\
		test_ddivu.s			\
		test_div_zero.s			\
		test_divu_zero.s		\
		test_ddiv_zero.s		\
		test_ddivu_zero.s		\
		test_div_ex.s			\
		test_divu_ex.s			\
		test_mul.s			\
		test_mul_hilo.s			\
		test_mul_ex.s			\
		test_mult.s			\
		test_multu.s			\
		test_multu_ex.s			\
		test_dmult.s			\
		test_dmultu.s			\
		test_madd.s			\
		test_msub.s			\
		test_maddu.s			\
		test_msubu.s			\
		test_madd_ex.s			\
		test_msub_ex.s			\
		test_maddu_ex.s			\
		test_msubu_ex.s			\
		test_mul_div_loop.s		\
		test_mult_exception.s		\
		test_mult_ex.c			\
		test_slt.s			\
		test_slti.s			\
		test_sltiu.s			\
		test_sltu.s			\
		test_subu_carry.s		\
		test_div_zero_ex.s		\
		test_x_dext_ri.s		\
		test_x_jalx_ri.s		\
		test_x_msa_ri.s

TEST_BRANCH_FILES =				\
		test_bltzall_large.s		\
		test_jalr_align.s		\
		test_x_msa_bdelay.s		\
		test_x_3d_bdelay.s

TEST_MEM_FILES=					\
		test_hardware_mappings.s	\
		test_hardware_mappings_write.s	\
		test_ld_cancelled.s		\
		test_memory_flush		\
		test_sd_burst.s			\
		test_storeload.s		\
		test_sync.s			\
		test_mem_alias_data.s		\
		test_raw_pism_truncation.s	\
		test_lwr.s			\
		test_lwl.s			\
		test_swr.s			\
		test_swl.s

TEST_LLSC_FILES=				\
		test_ll_unalign.s		\
		test_lld_unalign.s		\
		test_sc_unalign.s		\
		test_scd_unalign.s		\
		test_scd_alias.s		\
		test_llsc.s			\
		test_lldscd_span.s		\
		test_llsc_span.s		\
		test_lldscd.s			\
		test_cp0_lladdr.s

TEST_CACHE_FILES=				\
		test_hardware_mapping_cached_read.s \
		test_cache_instruction_instruction.s \
		test_cache_instruction_data.s	\
		test_cache_instruction_L2.s	\
		test_cache_taglo.s		\
		test_id_coherence.s

TEST_CP0_FILES=					\
		test_break.s			\
		test_cp0_badinstr.s		\
		test_cp0_badinstr_p.s		\
		test_cp0_cache_user.s		\
		test_cp0_ccres.s		\
		test_cp0_compare.s		\
		test_cp0_config1		\
		test_cp0_config2		\
		test_cp0_config3		\
		test_cp0_config5		\
		test_cp0_config6		\
		test_cp0_counter.s		\
		test_cp0_eret_user.s		\
		test_cp0_hwre_init.s		\
		test_cp0_hwrenable.s		\
		test_cp0_k0.s			\
		test_cp0_mtc0_user.s		\
		test_cp0_multiop_supervisor.s	\
		test_cp0_multiop_user.s		\
		test_cp0_rdhwr_counter.s	\
		test_cp0_rdhwr_statcounters_icount.s	\
		test_cp0_rdhwr_user2.s		\
		test_cp0_rdhwr_user.s		\
		test_cp0_reg_init.s		\
		test_cp0_ri.s			\
		test_cp0_syncistep.s		\
		test_cp0_tlbwi_user.s		\
		test_cp0_userlocal.s		\
		test_cp0_user.s			\
		test_cp0_wait.s			\
		test_cp0_watch_instr.s		\
		test_cp0_watch_load.s		\
		test_cp0_watch_store.s		\
		test_eret.s			\
		test_exception_bev0_trap_bd.s	\
		test_exception_bev0_trap.s	\
		test_exception_exl.s		\
		test_syscall2.s			\
		test_syscall50.s		\
		test_syscall_cache_store.s	\
		test_syscall.s			\
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
		test_tlt_overflow.s		\
		test_tltu_eq.s			\
		test_tltu_gt.s			\
		test_tltu_gt_sign.s		\
		test_tltu_lt.s			\
		test_tne_eq.s			\
		test_tne_gt.s			\
		test_tne_lt.s

TEST_FPU_FILES=					\
		test_fpu_bc1t_cc.s		\
		test_fpu_cfc1_pipeline.s	\
		test_fpu_compare_cc.s		\
		test_fpu_exception_pipeline.s	\
		test_fpu_fccr_update.s		\
		test_fpu_underflow_rounding.s	\
		test_fpu_x_c_nan.s		\
		test_fpu_x_disabled.s		\
		test_fpu_x_div.s		\
		test_fpu_x_ldc1_disabled.s	\
		test_fpu_x_mthc1.s		\
		test_fpu_x_multiop_disabled2.s	\
		test_fpu_x_multiop_disabled3.s	\
		test_fpu_x_multiop_disabled.s	\
		test_fpu_x_overflow.s		\
		test_fpu_x_reserved.s		\
		test_fpu_x_underflow.s

ifeq ($(TEST_CP2),1)
TEST_CP2_FILES=					\
		test_cp2_alu_mod_pipeline.s	\
		test_cp2_badinstr.s		\
		test_cp2_badinstr_p.s		\
		test_cp2_branchtag.s		\
		test_cp2_c0_lbu.s		\
		test_cp2_c0_ld.s		\
		test_cp2_c0_lhu.s		\
		test_cp2_c0_lld.s		\
		test_cp2_c0_ll.s		\
		test_cp2_c0_lwu.s		\
		test_cp2_c0_notag.s		\
		test_cp2_c0_perm.s		\
		test_cp2_c0_sb.s		\
		test_cp2_c0_sc.s		\
		test_cp2_c0_sd.s		\
		test_cp2_c0_sealed.s		\
		test_cp2_c0_sh.s		\
		test_cp2_c0_sw.s		\
		test_cp2_cap_as_data.s		\
		test_cp2_cause_bdelay.s		\
		test_cp2_cbez.s			\
		test_cp2_cbnz.s			\
		test_cp2_cbts.s			\
		test_cp2_cbtu.s			\
		test_cp2_cbuildcap.s		\
		test_cp2_cbuildcap_restricted.s	\
		test_cp2_cbuildcap_same_register.s	\
		test_cp2_ccall2.s		\
		test_cp2_ccall.s		\
		test_cp2_ccheckperm.s		\
		test_cp2_cchecktype.s		\
		test_cp2_ccopytype.s		\
		test_cp2_ceqex.s		\
		test_cp2_ceq.s			\
		test_cp2_cfromptr_imprecise.s	\
		test_cp2_cfromptr_null.s	\
		test_cp2_cfromptr.s		\
		test_cp2_cgetaddr.s		\
		test_cp2_cgettype.s		\
		test_cp2_cincoffset_imprecise.s \
		test_cp2_cincoffset_notag.s	\
		test_cp2_cincoffset_rep_underflow.s \
		test_cp2_cincoffset.s		\
		test_cp2_cincoffset_zero.s	\
		test_cp2_cjalr_delay.s		\
		test_cp2_cjalr_delay_2.s	\
		test_cp2_cjalr_loop.s		\
		test_cp2_cjalr_pcc.s		\
		test_cp2_cjalr_rcc.s		\
		test_cp2_cjalr.s		\
		test_cp2_cjr.s			\
		test_cp2_clb_neg.s		\
		test_cp2_clbr_priv.s		\
		test_cp2_clbr_unpriv.s		\
		test_cp2_clb_unpriv.s		\
		test_cp2_clbu_priv.s		\
		test_cp2_clbu_unpriv.s		\
		test_cp2_clc_perm.s		\
		test_cp2_clc_perm_tag.s		\
		test_cp2_clcr_null.s		\
		test_cp2_clcr_otype.s		\
		test_cp2_clcr.s			\
		test_cp2_clcr_tag.s		\
		test_cp2_clc_tlb.s		\
		test_cp2_cldr_priv.s		\
		test_cp2_cldr_unpriv.s		\
		test_cp2_cld_unpriv.s		\
		test_cp2_clearregs_caphi.s	\
		test_cp2_clearregs_caplo.s	\
		test_cp2_clearregs_gphi.s	\
		test_cp2_clearregs_gplo.s	\
		test_cp2_cle.s			\
		test_cp2_cleu.s			\
		test_cp2_clhr_priv.s		\
		test_cp2_clhr_unpriv.s		\
		test_cp2_clh_unpriv.s		\
		test_cp2_clhu_priv.s		\
		test_cp2_clhu_unpriv.s		\
		test_cp2_cllb.s			\
		test_cp2_cllb_span.s		\
		test_cp2_cllc_perm_tag.s	\
		test_cp2_cllc.s			\
		test_cp2_cllc_span.s		\
		test_cp2_clld.s			\
		test_cp2_clld_span.s		\
		test_cp2_cllh.s			\
		test_cp2_cllh_span.s		\
		test_cp2_cllw.s			\
		test_cp2_cllw_span.s		\
		test_cp2_clt.s			\
		test_cp2_cltu.s			\
		test_cp2_clwr_priv.s		\
		test_cp2_clwr_unpriv.s		\
		test_cp2_clw_unpriv.s		\
		test_cp2_clwu_priv.s		\
		test_cp2_clwu_unpriv.s		\
		test_cp2_cmove_j.s		\
		test_cp2_cmove.s		\
		test_cp2_cmove_sealed.s		\
		test_cp2_cmove_tag.s		\
		test_cp2_cmovn.s		\
		test_cp2_cmovz.s		\
		test_cp2_cne.s			\
		test_cp2_cnexeq_imprecise.s	\
		test_cp2_cnexeq.s		\
		test_cp2_creturn_trap.s		\
		test_cp2_csb_neg.s		\
		test_cp2_csbr_priv.s		\
		test_cp2_csbr_unpriv.s		\
		test_cp2_csb_unpriv.s		\
		test_cp2_csc_ephemeral_invalid.s\
		test_cp2_cscc_untagged.s	\
		test_cp2_csch_align.s		\
		test_cp2_csci.s			\
		test_cp2_csc_neg.s		\
		test_cp2_cscr_offset.s		\
		test_cp2_cscr_untagged.s	\
		test_cp2_cscr.s			\
		test_cp2_csc_tlb.s		\
		test_cp2_csdr_priv.s		\
		test_cp2_csdr_unpriv.s		\
		test_cp2_csd_unpriv.s		\
		test_cp2_csealcode.s		\
		test_cp2_csealdata.s		\
		test_cp2_cseal_large.s		\
		test_cp2_csealunsealcode.s	\
		test_cp2_csetbounds_cases.s	\
		test_cp2_csetboundsexact.s	\
		test_cp2_csetbounds_large.s	\
		test_cp2_csetbounds_rounding.s  \
		test_cp2_csetbounds.s		\
		test_cp2_csetcause.s		\
		test_cp2_csetoffset_fastcheck.s \
		test_cp2_csetoffset_imprecise.s \
		test_cp2_csetoffset_int.s	\
		test_cp2_csetoffset_notag.s	\
		test_cp2_cshr_priv.s		\
		test_cp2_cshr_unpriv.s		\
		test_cp2_csh_unpriv.s		\
		test_cp2_csub.s			\
		test_cp2_cswitch_clr_20.s	\
		test_cp2_cswitch_clr.s		\
		test_cp2_cswitch.s		\
		test_cp2_cswr_priv.s		\
		test_cp2_cswr_unpriv.s		\
		test_cp2_csw_unpriv.s		\
		test_cp2_ctestsubset.s		\
		test_cp2_ctestsubset_tag.s	\
		test_cp2_ctoptr_bounds.s	\
		test_cp2_ctoptr_null.s		\
		test_cp2_ctoptr.s		\
		test_cp2_ctoptr_tag.s		\
		test_cp2_ctoptr_zero.s		\
		test_cp2_cunseal_ephemeral.s	\
		test_cp2_cunseal_global.s	\
		test_cp2_data_as_cap.s		\
		test_cp2_disabled_exception.s	\
		test_cp2_exception_epcc_rep.s	\
		test_cp2_exception_epcc.s	\
		test_cp2_exception_epcc_unrep.s \
		test_cp2_exception_exl.s	\
		test_cp2_exception_pipeline.s	\
		test_cp2_fast_rep_check.s	\
		test_cp2_floatstore.s		\
		test_cp2_get_alu_pipeline.s	\
		test_cp2_getandperm.s		\
		test_cp2_getandperm_user.s	\
		test_cp2_getcleartag.s		\
		test_cp2_getincoffset.s		\
		test_cp2_get_mem_pipeline.s	\
		test_cp2_getpcc.s		\
		test_cp2_getpccsetoffset.s	\
		test_cp2_getsetoffset.s		\
		test_cp2_getunsealed.s		\
		test_cp2_jump_to_usermode_pcc_perms.s \
		test_cp2_kcc_base.s		\
		test_cp2_kcc.s			\
		test_cp2_kdc.s			\
		test_cp2_kr1c.s			\
		test_cp2_kr2c.s			\
		test_cp2_ldl_unalign.s		\
		test_cp2_ll_signex.s		\
		test_cp2_ll_zeroex.s		\
		test_cp2_load_pipeline.s	\
		test_cp2_mem_mod_pipeline.s	\
		test_cp2_memory_cursor_location.s	\
		test_cp2_null_vs_ddc.s		\
		test_cp2_mod_mod_pipeline.s	\
		test_cp2_qemu_incoffset_negative.s	\
		test_cp2_reg_init.s		\
		test_cp2_reg_name.s		\
		test_cp2_sandbox_jal.s		\
		test_cp2_sbx_j.s		\
		test_cp2_signex.s		\
		test_cp2_tagmem.s		\
		test_cp2_tagstorec0.s		\
		test_cp2_tagstore.s		\
		test_cp2_tlb_exception_fill.s	\
		test_cp2_tlb_instruction_miss.s \
		test_cp2_zeroex.s		\
		test_cp2_x_bounds.s		\
		test_cp2_x_c0_multiop_perm.s	\
		test_cp2_x_candperm_tag.s	\
		test_cp2_x_cbts_length.s	\
		test_cp2_x_cbts_reg.s		\
		test_cp2_x_cbtu_length.s	\
		test_cp2_x_cbtu_reg.s		\
		test_cp2_x_ccall_tag.s		\
		test_cp2_x_ccall_type.s		\
		test_cp2_x_ccheckperm_2.s	\
		test_cp2_x_ccheckperm.s		\
		test_cp2_x_cchecktype.s		\
		test_cp2_x_cclearreg_reg.s	\
		test_cp2_x_cgetbase_reg.s	\
		test_cp2_x_cgetcause_perm.s	\
		test_cp2_x_cgetlen_reg.s	\
		test_cp2_x_cgetpcc_reg.s	\
		test_cp2_x_cgetpccsetoffset_reg.s	\
		test_cp2_x_cgetperm_reg.s	\
		test_cp2_x_cgettag_reg.s	\
		test_cp2_x_cgettype_reg.s	\
		test_cp2_x_cgetunsealed_reg.s	\
		test_cp2_x_cincoffset_sealed.s	\
		test_cp2_x_cjalr_length2.s	\
		test_cp2_x_cjalr_length.s	\
		test_cp2_x_cjalr_perm.s		\
		test_cp2_x_cjalr_reg2.s		\
		test_cp2_x_cjalr_reg.s		\
		test_cp2_x_cjalr_sealed.s	\
		test_cp2_x_cjalr_tag.s		\
		test_cp2_x_cjr_delay.s		\
		test_cp2_x_cjr_length.s		\
		test_cp2_x_cjr_perm.s		\
		test_cp2_x_cjr_reg.s		\
		test_cp2_x_cjr_sealed.s		\
		test_cp2_x_cjr_tag.s		\
		test_cp2_x_clb_disabled.s	\
		test_cp2_x_clbu_perm.s		\
		test_cp2_x_clbu_reg.s		\
		test_cp2_x_clbu_sealed.s	\
		test_cp2_x_clbu_tag.s		\
		test_cp2_x_clc_align.s		\
		test_cp2_x_clc_bigimm.s		\
		test_cp2_x_clc_bounds.s		\
		test_cp2_x_clc_perm.s		\
		test_cp2_x_clc_priority.s	\
		test_cp2_x_clc_underflow.s	\
		test_cp2_x_clc_vaddr.s		\
		test_cp2_x_cld_pri2.s		\
		test_cp2_x_cld_priority.s	\
		test_cp2_x_clearreg_unimp.s	\
		test_cp2_x_cllc_tlb.s		\
		test_cp2_x_creadhwr_kernel_perm.s \
		test_cp2_x_csb_perm.s		\
		test_cp2_x_csc_align.s		\
		test_cp2_x_csc_bigimm.s		\
		test_cp2_x_cscc_local.s		\
		test_cp2_x_cscc_perm.s		\
		test_cp2_x_csc_ephemeral.s	\
		test_cp2_x_csc_perm.s		\
		test_cp2_x_csc_tlb.s		\
		test_cp2_x_csc_underflow.s	\
		test_cp2_x_csc_vaddr.s		\
		test_cp2_x_csealdata_perm.s	\
		test_cp2_x_csealdata_tag.s	\
		test_cp2_x_cseal_imprecise.s	\
		test_cp2_x_cseal_length.s	\
		test_cp2_x_cseal_otype.s	\
		test_cp2_x_csetbounds_base.s	\
		test_cp2_x_csetbounds_delay2.s	\
		test_cp2_x_csetbounds_delay.s	\
		test_cp2_x_csetboundsexact_imprecise.s  \
		test_cp2_x_csetboundsexact_length.s \
		test_cp2_x_csetbounds_length.s	\
		test_cp2_x_csetbounds_overflow.s \
		test_cp2_x_csetbounds_underflow.s \
		test_cp2_x_csetcause_perm.s	\
		test_cp2_x_csetoffset_sealed.s	\
		test_cp2_x_cunseal_bounds.s	\
		test_cp2_x_cunseal_otype.s	\
		test_cp2_x_cunseal_perm.s	\
		test_cp2_x_cunseal_sealed.s	\
		test_cp2_x_cunseal_unsealed.s	\
		test_cp2_x_cwritehwr_kernel_perm.s \
		test_cp2_x_disable_cp2_trap_handler_okay.s \
		test_cp2_x_exl_pcc.s		\
		test_cp2_x_fetch.s		\
		test_cp2_x_jr_imprecise.s	\
		test_cp2_x_lb_perm.s		\
		test_cp2_x_lb_sealed.s		\
		test_cp2_x_lb_tag.s		\
		test_cp2_x_ld_align.s		\
		test_cp2_x_ldc1_perm.s		\
		test_cp2_x_ld_len.s		\
		test_cp2_x_ldr.s		\
		test_cp2_x_ldxc1_perm.s		\
		test_cp2_x_lwc1_perm.s		\
		test_cp2_x_lwr.s		\
		test_cp2_x_lwxc1_perm.s		\
		test_cp2_x_multiop_adel.s	\
		test_cp2_x_multiop_ades.s	\
		test_cp2_x_multiop_disabled.s	\
		test_cp2_x_multiop_length.s	\
		test_cp2_x_multiop_ll_adel.s	\
		test_cp2_x_multiop_permit_load.s \
		test_cp2_x_multiop_permit_store.s \
		test_cp2_x_multiop_reg2.s	\
		test_cp2_x_multiop_reg.s	\
		test_cp2_x_multiop_sealed.s	\
		test_cp2_x_multiop_tag.s	\
		test_cp2_x_qemu_length_broken.s	\
		test_cp2_x_reg0_is_ddc_load.s	\
		test_cp2_x_reg0_is_ddc_load_linked.s	\
		test_cp2_x_reg0_is_ddc_store.s	\
		test_cp2_x_reg0_is_ddc_store_cond.s	\
		test_cp2_x_sb_perm.s		\
		test_cp2_x_sdc1_perm.s		\
		test_cp2_x_sdr.s		\
		test_cp2_x_swc1_perm.s		\
		test_cp2_x_swr.s		\
		test_raw_cp2_reg_init.s
ifeq ($(USING_LLVM_ASSEMBLER),1)
# FIXME: gas does not yet implement ccall fast
TEST_CP2_FILES += \
		test_cp2_ccall_fast.s		\
		test_cp2_x_ccall_fast_delay.s	\
		test_cp2_x_ccall_fast_code_perm.s	\
		test_cp2_x_ccall_fast_data_perm.s
endif

endif # TEST_CP2=1

TEST_ALU_OVERFLOW_FILES=			\
		test_add_overflow.s		\
		test_add_overflow_wrong_sign.s  \
		test_addi_overflow.s		\
		test_addiu_overflow.s		\
		test_addu_overflow.s		\
		test_dadd_overflow.s		\
		test_daddi_overflow.s		\
		test_daddiu_overflow.s		\
		test_daddu_overflow.s		\
		test_dsub_overflow.s		\
		test_dsub_overflow_minint.s	\
		test_dsubu_overflow.s		\
		test_sub_overflow.s		\
		test_sub_overflow_minint.s	\
		test_subu_overflow.s		\
		test_madd_lo_overflow.s
TEST_MEM_UNALIGN_FILES=				\
		test_lh_unalign.s		\
		test_lw_unalign.s		\
		test_ld_unalign.s		\
		test_ld_unalign_ok.s		\
		test_sh_unalign.s		\
		test_sw_unalign.s		\
		test_sd_unalign.s		\
		test_beq_lb.s

TEST_BEV1_FILES=				\
		test_exception_bev1_trap.s


TEST_TLB_FILES=					\
		test_tlb_load_0.s		\
		test_tlb_load_1.s		\
		test_tlb_load_1_large_page.s	\
		test_tlb_large_page.s		\
		test_tlb_probe.s		\
		test_tlb_exception_fill.s	\
		test_tlb_instruction_miss.s	\
		test_tlb_load_max.s		\
		test_tlb_load_asid.s		\
		test_tlb_read.s			\
		test_tlb_store_0.s		\
		test_tlb_store_protected.s	\
		test_tlb_user_mode.s		\
		test_tlb_invalid_load.s		\
		test_tlb_invalid_store.s	\
		test_tlb_invalid_store_h.s	\
		test_tlb_addrerr_load.s		\
		test_tlb_addrerr_store.s	\
		test_tlb_wired.s                \
		test_tlb_ext_enable.s		\
		test_tlb_tlbwr.s		\
		test_tlb_tlbwr_ext.s		\
		test_tlb_tlbr_ext.s		\
		test_tlb_x_mask.s		\
		test_tlb_initial.s		\
		test_tlb_multiop_miss.s		\
		test_tlb_xkseg.s		\
		test_tlb_xksseg.s

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

TEST_PIC_FILES=test_pic_irq.s

TEST_PURECAP_FILES=
# Don't attempt to build clang tests unless CLANG is set to 1, because clang might not be available
# This will cause clang tests to fail but that is better than make falling over.
# The DMA engine also depends on clang, and works in the same way
ifeq ($(CLANG),1)

ifeq ($(DMA), 1)
TEST_DMA_FILES=					\
		test_clang_dma_simple.c		\
		test_clang_dma_byte.c		\
		test_clang_dma_line.c		\
		test_clang_dma_loop.c		\
		test_clang_dma_add.c		\
		test_clang_dma_sub.c		\
		test_clang_dma_big_dram.c	\
		test_clang_dma_long_program.c	\
		test_clang_dma_successive_programs.c \
		test_clang_dma_nested_loop.c	\
		test_clang_dma_irq.c
else
TEST_DMA_FILES=
endif

ifeq ($(DMA_VIRT), 1)
TEST_DMA_FILES+=test_clang_dma_virt_translate.c
endif


ifeq ($(PURECAP), 1)
TEST_PURECAP_C_SRCS:=$(wildcard tests/purecap/test_*.c)
TEST_PURECAP_CXX_SRCS:=$(wildcard tests/purecap/test_*.cpp)
TEST_PURECAP_ASM_SRCS:=tests/purecap/test_purecap_reg_init.s
TEST_PURECAP_FILES:= $(notdir $(TEST_PURECAP_C_SRCS) $(TEST_PURECAP_ASM_SRCS) $(TEST_PURECAP_CXX_SRCS))
endif

TEST_CLANG_C_SRCS:=$(wildcard tests/c/test_*.c)
TEST_CLANG_CXX_SRCS:=$(wildcard tests/c/test_*.cpp)
TEST_CLANG_ASM_SRCS:=
TEST_CLANG_FILES:= $(notdir $(TEST_CLANG_C_SRCS) $(TEST_CLANG_CXX_SRCS) $(TEST_CLANG_ASM_SRCS))
else
TEST_CLANG_FILES=
endif

ifeq ($(TEST_CP2), 0)
# The clang and purecap tests depend on CHERI:
TEST_CLANG_FILES:=
TEST_PURECAP_FILES:=
endif


ifeq ($(MULTI),1)
TEST_MULTICORE_FILES=				\
		test_raw_coherence_setup.s	\
		test_raw_coherence_mp_loop.s	\
		test_mc_pics.s			\
		test_mc_pic_irq.s		\
		test_mc_rdhwr.s			\
		test_mc_rdhwr_core.s		\
		test_mc_coherence_sequential.s	\
		test_mc_llsc.s			\
		test_mc_llsc_alias.s		\
		test_mc_core0_first.s		\
		test_mc_core0_last.s		\
		test_mc_tag_coherence.s		\
		test_mc_addr.s
else
TEST_MULTICORE_FILES=
endif

ifeq ($(MT),1)
TEST_MT_FILES=					\
		test_ipc.s			\
		test_mt_rdhwr.s
else
TEST_MT_FILES=
endif

ifeq ($(STATCOUNTERS),1)
RAW_STATCOUNTERS_FILES=                \
		test_raw_statcounters_reset.s   \
		test_raw_statcounters_dcache.s  \
		test_raw_statcounters_l2cachemaster.s  \
		test_raw_statcounters_mipsmem.s \
		test_statcounters_no_trap_in_user_mode.s
else
RAW_STATCOUNTERS_FILES=
endif

ifeq ($(VIRTDEV),1)
TEST_VIRTDEV_FILES= test_mc_virtdev_read.s
else
TEST_VIRTDEV_FILES=
endif


ifeq ($(TEST_RMA), 1)
TEST_RMA_FILES = test_raw_rma_read.s
else
TEST_RMA_FILES=
endif




FUZZ_SCRIPT:=fuzzing/fuzz.py
FUZZ_SCRIPT_OPTS?=
FUZZ_TEST_DIR:=tests/fuzz
ifneq ($(NOFUZZ),1)
FUZZ_TEST_FILES:=$(notdir $(wildcard $(FUZZ_TEST_DIR)/*.s))
endif
ifneq ($(NOFUZZR),1)
FUZZ_REGRESSION_TEST_DIR:=tests/fuzz_regressions/
FUZZ_REGRESSION_TEST_FILES:=$(notdir $(wildcard $(FUZZ_REGRESSION_TEST_DIR)/*.s))
else
FUZZ_REGRESSION_TEST_DIR:=
FUZZ_REGRESSION_TEST_FILES:=
endif

ifeq ($(FUZZ_DMA), 1)
FUZZ_DMA_FILES:=$(notdir $(wildcard tests/fuzz_dma/*.c))
else
FUZZ_DMA_FILES:=
endif
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
		$(RAW_PIC_FILES)		\
		$(RAW_DMA_FILES)		\
		$(RAW_STATCOUNTERS_FILES)	\
		$(RAW_RMA_FILES)		\
		$(TEST_VIRTDEV_FILES)		\
		$(TEST_FRAMEWORK_FILES)		\
		$(TEST_ALU_FILES)		\
		$(TEST_BRANCH_FILES)		\
		$(TEST_MEM_FILES)		\
		$(TEST_LLSC_FILES)		\
		$(TEST_CACHE_FILES)		\
		$(TEST_CP0_FILES)		\
		$(TEST_CP2_FILES)		\
		$(TEST_BEV1_FILES)		\
		$(TEST_TLB_FILES)		\
		$(TEST_ALU_OVERFLOW_FILES)	\
		$(TEST_MEM_UNALIGN_FILES)	\
		$(TEST_TRAPI_FILES)		\
		$(FUZZ_TEST_FILES)		\
		$(TEST_DMA_FILES)		\
		$(FUZZ_DMA_FILES)		\
		$(C_FRAMEWORK_FILES)		\
		$(TEST_CLANG_FILES)		\
		$(TEST_MULTICORE_FILES)		\
		$(TEST_MT_FILES)		\
		$(TEST_PIC_FILES)


ifeq ($(TEST_FPU),1)
TEST_FILES+=	$(RAW_FPU_FILES) $(TEST_FPU_FILES)
endif

ifdef COP1_ONLY
TEST_FILES=	$(RAW_FPU_FILES) $(TEST_FPU_FILES)
endif

ifdef TEST_PS
ifeq ($(USING_LLVM_ASSEMBLER),1)
$(error "The LLVM assembler does not support paired single instructions")
endif
TEST_FILES+= $(RAW_PS_FILES)
endif

ifeq ($(FUZZ_DMA_ONLY), 1)
TEST_FILES = $(FUZZ_DMA_FILES)
endif

ifneq ($(NOFUZZR),1)
TEST_FILES+=$(FUZZ_REGRESSION_TEST_FILES)
endif

ifdef TEST_TRACE
TEST_FILES+=	$(RAW_TRACE_FILES)
else
ifdef TEST_TRACE_ONLY
TEST_FILES=	$(RAW_TRACE_FILES)
endif
endif
