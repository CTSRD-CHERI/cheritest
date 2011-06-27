from bsim_utils import BaseBsimTestCase

class raw_ll(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load linked word from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba98, "Unsigned load linked word from double word failed")

    def test_a1(self):
        '''Test signed-extended positive load linked word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fffffff, "Sign-extended positive word load linked failed")

    def test_a2(self):
        '''Test signed-extended negative load linked word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended negative word load linked failed")

    def test_pos_offset(self):
        '''Test word load linked at positive offset'''
        self.assertRegisterEqual(self.MIPS.a3, 2, "Word load linked at positive offset failed")

    def test_neg_offset(self):
        '''Test word load linked at negative offset'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "Word load linked at negative offset failed")
