from bsim_utils import BaseBsimTestCase

class test_cp0_compare(BaseBsimTestCase):
    def test_compare_readback(self):
        '''Test that CP0 compare register write succeeded'''
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a1, "CP0 compare register write failed")

    def test_cycle_count(self):
        ''' Test that cycle counter interrupted CPU at the right moment'''
	self.assertRegisterInRange(self.MIPS.a2, self.MIPS.a0 - 10, self.MIPS.a0 + 10, "Unexpected CP0 count cycle register value on reset")

    def test_interrupt_fired(self):
        '''Test that compare register triggered interrupt'''
        self.assertRegisterEqual(self.MIPS.a5, 1, "Exception didn't fire")

    def test_eret_happened(self):
        '''Test that eret occurred'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "Exception didn't return")

    def test_cause_bd(self):
        '''Test that branch-delay slot flag in cause register not set in exception'''
        self.assertRegisterEqual((self.MIPS.a7 >> 31) & 0x1, 0, "Branch delay (BD) flag set")

    def test_cause_ip(self):
        '''Test that interrupt pending (IP) bit set in cause register'''
        self.assertRegisterEqual((self.MIPS.a7 >> 8) & 0xff, 0x80, "IP7 flag not set")

    def test_cause_code(self):
        '''Test that exception code is set to "interrupt"'''
        self.assertRegisterEqual((self.MIPS.a7 >> 2) & 0x1f, 0, "Code not set to Int")

    def test_exl_in_handler(self):
        self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 1, "EXL not set in exception handler")

    def test_cause_ip_cleared(self):
	'''Test that writing to the CP0 compare register cleared IP7'''
	self.assertRegisterEqual((self.MIPS.s0 >> 8) & 0xff, 0, "IP7 flag not cleared")

    def test_not_exl_after_handler(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 1) & 0x1, 0, "EXL still set after ERET")

