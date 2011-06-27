from bsim_utils import BaseBsimTestCase

class raw_ld(BaseBsimTestCase):
    def test_a0(self):
        '''Test load double word instruction'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Double word load failed")

    def test_a1(self):
        '''Test load positive double word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fffffffffffffff, "Positive double word load failed")

    def test_a2(self):
        '''Test load negative double word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Negative double word load failed")

    def test_pos_offset(self):
        '''Test double word load at positive offset'''
        self.assertRegisterEqual(self.MIPS.a3, 2, "Double word load at positive offset failed")

    def test_neg_offset(self):
        '''Test double word load at negative offset'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "Double word load at negative offset failed")

