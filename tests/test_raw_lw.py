from bsim_utils import BaseBsimTestCase

class raw_lw(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load word from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba98, "Unsigned load word from double word failed")

    def test_a1(self):
        '''Test signed-extended positive load word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fffffff, "Sign-extended positive word load failed")

    def test_a2(self):
        '''Test signed-extended negative load word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended negative word load failed")

    def test_a3(self):
        '''Test unsigned positive load word'''
        self.assertRegisterEqual(self.MIPS.a3, 0x7fffffff, "Unsigned positive word load failed")

    def test_a4(self):
        '''Test unsigned negative load word'''
        self.assertRegisterEqual(self.MIPS.a4, 0xffffffff, "Unsigned negaive word load failed")
