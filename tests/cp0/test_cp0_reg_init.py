#-
# Copyright (c) 2011 Steven J. Murdoch
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# @BERI_LICENSE_HEADER_START@
#
# Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  BERI licenses this
# file to you under the BERI Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.beri-open-systems.org/legal/license-1-0.txt
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @BERI_LICENSE_HEADER_END@
#

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

class test_cp0_reg_init(BaseBERITestCase):
    def test_context_reg(self):
        '''Test context register default value'''
        self.assertRegisterEqual(self.MIPS.a0, 0x0, "Unexpected CP0 context register value on reset")

    def test_wired_reg(self):
        '''Test wired register default value'''
        self.assertRegisterEqual(self.MIPS.a1, 0x0, "Unexpected CP0 wired register value on reset")

    ## Hard to know what the count register should be, but we might reasonably
    ## guess that it's in the below range.  This might require tuning, but
    ## will hopefully detect problems such as "very large number".
    @attr('countrate')
    def test_count_reg(self):
        '''Test count register on reset'''
        self.assertRegisterInRange(self.MIPS.a2, 100, 80000, "Unexpected CP0 count cycle register value on reset")

    ## Preferable that the compare register be 0, to maximise time available to
    ## the OS before a timer interrupt fires.
    def test_compare_reg(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "Unexpected CP0 compare register value on reset")

    ## We don't yet have a good idea of what all our status bits should be, so
    ## most are don't cares.  What we do care about is initial user/kernel
    ## mode, etc, so check them.
    ##
    ## According to the MIPS specification, the initial state of the CU bits
    ## is undefined.
    ##
    ## For CHERI, Report no coprocessors enabled; CP0 is always available in
    ## kernel mode.
    @attr('beri')
    def test_status_cu(self):
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 28, 0 << 28, "Unexpected CP0 coprocessor availability on reset")

    @attr('nofloat')
    def test_status_fr_nofloat(self):
        '''Test that CP0.Status.FR doesn't claim that the CPU has 32 floating point registers when there is no FPU'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 26, 0 << 26, "CP0.Status.FR was set but FPU not present")

    @attr('float')
    @attr('float64')
    @attr('float64initial')
    def test_status_fr_float64(self):
        '''Test that CP0.Status.FR says there are 32 floating point registers'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 26, 1 << 26, "CP0.Status.FR was not set")

    ## We should not be using boot-time exceptions (BEV)
    def test_status_bev(self):
        '''Test that CP0.Status.BEV is not set'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 22, 0 << 22, "Unexpected CP0 boot-time exceptions value")


    ## We should have interrupts enabled for all sources.
    def test_status_im(self):
        '''Test status register to confirm that interrupts are disabled for all sources (IM)'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0xff << 8, 0x80 << 8, "Unexpected CP0 interrupt mask value on reset")

    ## We should be in 64-bit kernel mode.
    def test_status_kx(self):
        '''Test status register to confirm that we are in 64-bit kernel mode (KX)'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 7, 1 << 7, "Unexpected CP0 kernel 64-bit mode default on reset")

    ## We should have a 64-bit supervisor mode.
    def test_status_sx(self):
        '''Test status register to confirm that we are in 64-bit supervisor mode (SX)'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 6, 1 << 6, "Unexpected CP0 supervisor 64-bit mode default on reset")

    ## We should have a 64-bit user mode.
    def test_status_ux(self):
        '''Test status register to confirm that we are in 64-bit user mode (UX)'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 5, 1 << 5, "Unexpected CP0 user 64-bit mode default on reset")
 
    ## We expect to be in kernel mode at init.
    def test_status_ksu(self):
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x3 << 3, 0 << 3, "Unexpected CP0 KSU value on reset")
 
    ## We expect the error level to be 0 at init.
    def test_status_erl(self):
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 2, 0 << 2, "Unexpected CP0 ERL value on reset")
 
    ## We expect not to be in exception processing.
    def test_status_exl(self):
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1 << 1, 0 << 1, "Unexpected CP0 EXL value on reset")
 
    ## We expect interrupts enabled
    def test_status_ie(self):
        '''Test status register to confirm that interrupts are disabled (IE)'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0x1, 1, "Unexpected CP0 interrupts enabled value on reset")
 
    ## It doesn't really matter what vendor we report as, but we should indicate
    ## that we are R4400ish
    def test_prid_imp_reg(self):
        '''Test that the PRId register indicates a R4400ish vendor'''
        self.assertRegisterMaskEqual(self.MIPS.a5, 0xff << 8, 0x04 << 8, "Unexpected CP0 vendor value on reset")

    def test_processor_id(self):
        # See Table 9.60 PRId Register Field Descriptions in MIPS Architecture For Programmers Volume III: MIPS64 / microMIPS64 Privileged Resource Architecture
        revision_id = self.MIPS.a5 & 0xff
        company_id = (self.MIPS.a5 >> 16) & 0xff
        processor_id = (self.MIPS.a5 >> 8) & 0xff
        if self.TEST_MACHINE == "qemu":
            # QEMU uses company id = 0x0f, processor id = 0x04
            assert company_id == 0x0f, "Unexpected QEMU CP0_PRID[23..16]"
            assert processor_id == 0x04, "Unexpected QEMU CP0_PRID[15..8]"
            assert revision_id >= 6, "Expected at least rev 6 for QEMU CP0_PRID[7..0]"
        elif self.TEST_MACHINE in ("sim", "sail", "l3"):
            # CHERI Bluespec implementation, company id = 0x00, processor id = 0x04
            # Sail and L3 should report the same values as Bluespec
            assert company_id == 0x00, "Unexpected BERI CP0_PRID[23..16]"
            assert processor_id == 0x04, "Unexpected BERI CP0_PRID[15..8]"
            assert revision_id >= 6, "Expected at least rev 6 for BERI CP0_PRID[7..0]"
        elif self.TEST_MACHINE == "gxemul":
            assert company_id == 0x01, "Unexpected GXEMUL CP0_PRID[23..16]"
            assert processor_id == 0x89, "Unexpected GXEMUL CP0_PRID[15..8]"
            assert revision_id >= 1, "Expected at least rev 1"
        else:
            self.fail("Expected processor ID value not implemented for TEST_MACHINE={tm} (PRID was {prid_val}: company={cid},"
                      " processor={pid}, revision={rev})".format(tm=self.TEST_MACHINE, prid_val=hex(self.MIPS.a5), cid=hex(company_id),
                                                                 pid=hex(processor_id), rev=hex(revision_id)))

    @attr('beri')
    def test_config_reg(self):
        '''Test initial value of CP0.config0'''
        self.assertRegisterEqual(self.MIPS.a6, 0x8000c083, "Unexpected CP0 config register value on reset")

    def mkConfig1(self, M, MMU, IS, IL, IA, DS, DL, DA, C2, MD, PC, WR, CA, EP, FP):
        return ((M & 1) << 31) | \
               ((MMU & 0x3f) << 25) | \
               ((IS & 7) << 22) | \
               ((IL & 7) << 19) | \
               ((IA & 7) << 16) | \
               ((DS & 7) << 13) | \
               ((DL & 7) << 10) | \
               ((DA & 7) << 7) | \
               ((C2 & 7) << 6) | \
               ((MD & 1) << 5) | \
               ((PC & 1) << 4) | \
               ((WR & 1) << 3) | \
               ((CA & 1) << 2) | \
               ((EP & 1) << 1) | \
               ((FP & 1))

    @attr('float')
    def test_config1_float(self):
        '''Test that CP0.Config1.FP is set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1, 1, "CP0.Config1.FP was not set")

    @attr('nofloat')
    def test_config1_nofloat(self):
        '''Test that CP0.Config1.FP is not set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1, 0, "CP0.Config1.FP was set")

    @attr('beri')
    def test_config1_ejtag(self):
        '''Test that CP0.Config1.EP is not set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x2, 0, "CP0.Config1.EP was set")

    @attr('beri')
    def test_config1_compression(self):
        '''Test that CP0.Config1.CA is not set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x4, 0, "CP0.Config1.CA was set")

    @attr('watch')
    def test_config1_watch(self):
        '''Test that CP0.Config1.WR is set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1 << 3, 1 << 3, "CP0.Config1.WR was not set")

    @attr('nowatch')
    def test_config1_nowatch(self):
        '''Test that CP0.Config1.WR is not set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1 << 3, 0 << 3, "CP0.Config1.WR was set")

    @attr('beri1tlb')
    def test_config1_mmu_size_beri1(self):
        '''Test the initial value of CP0.Config1.MMU_Size'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x3f << 25, (16 - 1)<< 25, "CP0.Config1.MMU_Size had an unexpected value")

    @attr('beri')
    def test_config1_performance_counters(self):
        '''Test the initial value of CP0.Config1.PC'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1 << 4, 0 << 4, "CP0.Config1.PC was set")

    @attr('beri')
    def test_config1_mdmx(self):
        '''Test the initial value of CP0.Config1.MD'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1 << 5, 0 << 5, "CP0.Config1.MD was set")

    @attr('capabilities')
    def test_config1_capabilities(self):
        '''Test the initial value of CP0.Config1.C2'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1 << 6, 0x1 << 6, "CP0.Config1.C2 was not set")

    @attr('beri1cache')
    def test_config1_da_beri1(self):
        '''Test the initial value of CP0.Config1.DA'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 7, 3 << 7 , "CP0.Config1.DA did not have the expected value")

    @attr('beri2cache')
    def test_config1_da_beri2(self):
        '''Test the initial value of CP0.Config1.DA'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 7, 3 << 7 , "CP0.Config1.DA did not have the expected value")

    @attr('beri1oldcache')
    def test_config1_dl_beri1(self):
        '''Test the initial value of CP0.Config1.DL'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 10, 4 << 10, "CP0.Config1.DL did not have the expected value")

    @attr('beri1cache')
    def test_config1_dl_beri1(self):
        '''Test the initial value of CP0.Config1.DL'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 10, 6 << 10, "CP0.Config1.DL did not have the expected value")

    @attr('beri2cache')
    def test_config1_dl_beri2(self):
        '''Test the initial value of CP0.Config1.DL'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 10, 4 << 10, "CP0.Config1.DL did not have the expected value")

    @attr('beri1oldcache')
    def test_config1_ds_beri1(self):
        '''Test the initial value of CP0.Config1.DS'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 13, 3 << 13, "CP0.Config1.DS did not have the expected value")

    @attr('beri1cache')
    def test_config1_ds_beri1(self):
        '''Test the initial value of CP0.Config1.DS'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 13, 0 << 13, "CP0.Config1.DS did not have the expected value")

    @attr('beri2cache')
    def test_config1_ds_beri2(self):
        '''Test the initial value of CP0.Config1.DS'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 13, 1 << 13, "CP0.Config1.DS did not have the expected value")

    @attr('beri1cache')
    def test_config1_ia_beri1(self):
        '''Test the initial value of CP0.Config1.IA'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 16, 1 << 16, "CP0.Config1.IA did not have the expected value")

    @attr('beri2cache')
    def test_config1_ia_beri2(self):
        '''Test the initial value of CP0.Config1.IA'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 16, 3 << 16, "CP0.Config1.IA did not have the expected value")

    @attr('beri1oldcache')
    def test_config1_il_beri1(self):
        '''Test the initial value of CP0.Config1.IL'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 19, 4 << 19, "CP0.Config1.IL did not have the expected value")

    @attr('beri1cache')
    def test_config1_il_beri1(self):
        '''Test the initial value of CP0.Config1.IL'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 19, 6 << 19, "CP0.Config1.IL did not have the expected value")

    @attr('beri2cache')
    def test_config1_il_beri2(self):
        '''Test the initial value of CP0.Config1.IL'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 19, 4 << 19, "CP0.Config1.IL did not have the expected value")

    @attr('beri1oldcache')
    def test_config1_is_beri1(self):
        '''Test the initial value of CP0.Config1.IS'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 22, 1 << 22, "CP0.Config1.IS did not have the expected value")

    @attr('beri1cache')
    def test_config1_is_beri1(self):
        '''Test the initial value of CP0.Config1.IS'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 22, 1 << 22, "CP0.Config1.IS did not have the expected value")

    @attr('beri2cache')
    def test_config1_is_beri2(self):
        '''Test the initial value of CP0.Config1.IS'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x7 << 22, 1 << 22, "CP0.Config1.IS did not have the expected value")

    @attr('beri2tlb')
    def test_config1_mmu_size_beri2(self):
        '''Test the initial value of CP0.Config1.MMU_Size'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x3f << 25, (64 - 1)<< 25, "CP0.Config1.MMU_Size had an unexpected value")

    @attr('gxemultlb')
    def test_config1_mmu_size_gxemul(self):
        '''Test the initial value of CP0.Config1.MMU_Size'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x3f << 25, (48 - 1)<< 25, "CP0.Config1.MMU_Size had an unexpected value")

    
    @attr('config2')
    def test_config1_continuation(self):
        '''Test that CP0.Config1.M is set'''
        self.assertRegisterMaskEqual(self.MIPS.a7, 0x1 << 31, 1 << 31, "CP0.Config1.M was not set")

    ## CHERI1 configuration with no FPU, capabilities and a large TLB
    @attr('nofloat')
    @attr('watch')
    @attr('capabilities')
    @attr('tlb')
    @attr('beri1tlb')
    @attr('beri1cache')
    def test_config1_reg_nofloat(self):
        '''Test initial value of CP0.config1'''
        self.assertRegisterEqual(self.MIPS.a7, self.mkConfig1(1,16-1,1,6,1,0,6,3,1,0,0,1,0,0,0), "Unexpected CP0 config1 register value on reset")

    ## CHERI1 configuration with FPU, capabilities and a large TLB
    # (old cache size)
    @attr('float')
    @attr('watch')
    @attr('tlb')
    @attr('beri1tlb')
    @attr('beri1oldcache')
    @attr('capabilities')
    def test_config1_reg_float(self):
        '''Test initial value of CP0.config1'''
        self.assertRegisterEqual(self.MIPS.a7, self.mkConfig1(1,16-1,3,4,0,3,4,0,1,0,0,1,0,0,1), "Unexpected CP0 config1 register value on reset")

    ## CHERI1 configuration with FPU, capabilities and a large TLB
    @attr('float')
    @attr('watch')
    @attr('tlb')
    @attr('beri1oldtlb')
    @attr('beri1cache')
    @attr('capabilities')
    def test_config1_reg_float(self):
        '''Test initial value of CP0.config1'''
        self.assertRegisterEqual(self.MIPS.a7, self.mkConfig1(1,16-1,1,6,1,0,6,3,1,0,0,1,0,0,1), "Unexpected CP0 config1 register value on reset")

    ## CHERI2 configuration with no FPU, watch register, capabilities, and a small TLB
    @attr('nofloat')
    @attr('watch')
    @attr('tlb')
    @attr('beri2tlb')
    @attr('beri2cache')
    @attr('capabilities')
    def test_config1_reg_smalltlb(self):
        '''Test initial value of CP0.config1'''
        self.assertRegisterEqual(self.MIPS.a7, self.mkConfig1(1,64-1,1,4,3,1,4,3,1,0,0,1,0,0,0), "Unexpected CP0 config1 register value on reset")

    # GXEMUL configuration
    @attr('tlb')
    @attr('gxemultlb')
    def test_config1_reg_gxemul(self):
        '''Test initial value of CP0.config1'''
        self.assertRegisterEqual(self.MIPS.a7, self.mkConfig1(0,48-1,3,4,1,3,4,1,0,0,0,0,0,0,1), "Unexpected CP0 config1 register value on reset")

    ## XXX:
    def test_xcontext_reg(self):
        self.assertRegisterEqual(self.MIPS.s0, 0, "Unexpected CP0 xcontext register value on reset")
