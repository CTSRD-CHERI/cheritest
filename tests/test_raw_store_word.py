from bsim_utils import BaseBsimTestCase

class raw_store_word(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load of stored word from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba98, "Unsigned load of word from double word failed")

    def test_a1(self):
        '''Test signed load of stored positive word'''
        self.assertRegisterEqual(self.MIPS.a1, 1, "Sign-extended load of positive word failed")

    def test_a2(self):
        '''Test signed load of stored negative word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended load of negative word failed")

    def test_a3(self):
        '''Test unsigned load of stored positive word'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "Unsigned load of positive word failed")

    def test_a4(self):
        '''Test unsigned load of stored negative word'''
        self.assertRegisterEqual(self.MIPS.a4, 0xffffffff, "Unsigned load of negative word failed")
