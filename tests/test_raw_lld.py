from bsim_utils import BaseBsimTestCase

class raw_lld(BaseBsimTestCase):
    def test_a0(self):
        '''Test load linked double word instruction'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Double word load linked failed")

    def test_a1(self):
        '''Test load linked positive double word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fffffffffffffff, "Positive double word load linked failed")

    def test_a2(self):
        '''Test load linked negative double word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Negative double word load linked failed")

    def test_pos_offset(self):
        '''Test double word load linked at positive offset'''
        self.assertRegisterEqual(self.MIPS.a3, 2, "Double word load linked at positive offset failed")

    def test_neg_offset(self):
        '''Test double word load linked at negative offset'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "Double word load linked at negative offset failed")
