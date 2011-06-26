from bsim_utils import BaseBsimTestCase

class raw_sd(BaseBsimTestCase):
    def test_a0(self):
        '''Test load of stored double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Load of stored double word failed")

    def test_a1(self):
        '''Test signed load of stored positive double word'''
        self.assertRegisterEqual(self.MIPS.a1, 1, "Signed load of positive double word failed")

    def test_a2(self):
        '''Test signed load of stored negative double word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Signed load of negative double word failed")
