from bsim_utils import BaseBsimTestCase

class test_cp0_reg_init(BaseBsimTestCase):
    def test_context_reg(self):
        '''Test context register default value'''
        self.assertRegisterEqual(self.MIPS.a0, 0x0)

    def test_wired_reg(self):
        '''Test wired register default value'''
        self.assertRegisterEqual(self.MIPS.a1, 0x0)

    ## Hard to know what the count register should be, but we might reasonably
    ## guess that it's in the range 50 to 600.  This might require tuning, but
    ## will hopefully detect problems such as "very large number".
    def test_count_reg(self):
        self.assertRegisterInRange(self.MIPS.a2, 100, 600)

    ## Preferable that the compare register be 0, to maximise time available to
    ## the OS before a timer interrupt fires.
    def test_compare_reg(self):
        self.assertRegisterEqual(self.MIPS.a3, 0)

    ## We don't yet have a good idea of what all our status bits should be, so
    ## most are don't cares.  What we do care about is initial user/kernel
    ## mode, etc, so check them.
    ##
    ## Report no coprocessors enabled; CP0 is always available in kernel mode.
    def test_status_cu(self):
        self.assertRegisterEqual((self.MIPS.a4) >> 28 & 0x1, 0)

    ## We should have interrupts enabled for all sources.
    ##
    ## XXX: but we don't
    def test_status_im(self):
        #self.assertRegisterEqual((self.MIPS.a4 >> 8) & 0xff, 0xff)
        self.assertRegisterEqual((self.MIPS.a4 >> 8) & 0xff, 0x02)

    ## We should be in 64-bit kernel mode.
    ##
    ## XXX: but we aren't
    def test_status_kx(self):
        #self.assertRegisterEqual((self.MIPS.a4 >> 7) & 0x1, 1)
        self.assertRegisterEqual((self.MIPS.a4 >> 7) & 0x1, 0)

    ## We should have a 64-bit supervisor mode.
    ##
    ## XXX: but we don't
    def test_status_sx(self):
        #self.assertRegisterEqual((self.MIPS.a4 >> 6) & 0x1, 1)
        self.assertRegisterEqual((self.MIPS.a4 >> 6) & 0x1, 0)

    ## We should have a 64-bit user mode.
    ##
    ## XXX: but we don't
    def test_status_ux(self):
        #self.assertRegisterEqual((self.MIPS.a4 >> 5) & 0x1, 1)
        self.assertRegisterEqual((self.MIPS.a4 >> 5) & 0x1, 0)
 
    ## We expect to be in kernel mode at init.
    def test_status_ksu(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 3) & 0x3, 0)
 
    ## We expect the error level to be 0 at init.
    def test_status_erl(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1, 0)
 
    ## We expect not to be in exception processing.
    def test_status_exl(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 1) & 0x1, 0)
 
    ## We expect interrupts enabled
    ##
    ## XXX: but we don't
    def test_status_ie(self):
        #self.assertRegisterEqual(self.MIPS.a4 & 0x1, 1)
        self.assertRegisterEqual(self.MIPS.a4 & 0x1, 0)
 
    ## It doesn't really matter what vendor we report as, but we should indicate
    ## that we are R4400ish
    ##
    ## XXX: but we don't
    def test_prid_imp_reg(self):
        #self.assertRegisterEqual((self.MIPS.a5 >> 8) & 0xff, 0x04)
        self.assertRegisterEqual((self.MIPS.a5 >> 8) & 0xff, 0)

    ## XXX
    def test_config_reg(self):
        self.assertRegisterEqual(self.MIPS.a6, 0)

    ## XXX:
    def test_xcontext_reg(self):
        self.assertRegisterEqual(self.MIPS.a7, 0)
